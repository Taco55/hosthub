import 'dart:math' as math;

import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';

import '../domain/website_content.dart';

/// Loaded editor content for one page: the source-language field values plus
/// the per-language translated fields.
class WebsitePageContent {
  const WebsitePageContent({
    required this.source,
    required this.translations,
    this.sourceLanguage,
    this.locales,
    this.previewDomain,
  });

  /// `fieldKey -> text` in the source language.
  final Map<String, String> source;

  /// `language -> (fieldKey -> TranslatedField)` for the target languages.
  final Map<String, Map<String, TranslatedField>> translations;

  /// The site's source language (`sites.default_locale`); null when the
  /// caller should keep its current value.
  final String? sourceLanguage;

  /// The site's enabled locales; null when unknown.
  final List<String>? locales;

  /// The site's primary public domain (from `site_domains`); null when the
  /// site has none — the editor then falls back to the schematic mock preview.
  final String? previewDomain;
}

/// Where an editor field lives in the site's content: which document, and the
/// path inside that document's JSON (object keys as String, list indices as int).
class EditorFieldLocation {
  const EditorFieldLocation({
    required this.contentType,
    required this.slug,
    required this.path,
  });

  final String contentType;
  final String slug;
  final List<Object> path;

  /// The field's address as the website knows it, e.g.
  /// `cabin/main:hero.title` or `page/home:highlights.0.description`.
  ///
  /// The live preview speaks this: the console sends values keyed by address,
  /// and the rendered page carries the same address on the element the value is
  /// bound to. Neither side needs to know the other's field names.
  String get address => '$contentType/$slug:${path.join('.')}';
}

/// Persistence for the website editor. The editor's flat field keys map onto
/// the site's real CMS documents (the same JSON the public site renders):
///
/// | field key                 | document (type/slug) | JSON path                 |
/// |---------------------------|----------------------|---------------------------|
/// | hero.headline             | cabin / main         | hero.title                |
/// | hero.subtitle             | cabin / main         | hero.subtitle             |
/// | highlights.N              | page / home          | highlights[N].description |
/// | chalet.description.N      | cabin / main         | description[N]            |
/// | chalet.experience.N       | cabin / main         | experience[N]             |
/// | practical.header.title    | page / practical     | header.title              |
/// | practical.header.subtitle | page / practical     | header.subtitle           |
/// | area.intro                | page / area          | intro                     |
/// | contact.title             | contact_form / main  | title                     |
/// | contact.subtitle          | contact_form / main  | subtitle                  |
///
/// Working values for target languages live in `site_translations`
/// (value/status/source_hash per field); publish folds them back into each
/// locale's documents (draft -> published with a version snapshot, mirroring
/// CmsRepository.publishDocument).
class WebsiteContentRepository extends SupabaseRepository {
  WebsiteContentRepository({required SupabaseClient supabase})
    : super(supabase);

  static const String page = 'home';

  static const List<({String contentType, String slug})> _documents = [
    (contentType: 'cabin', slug: 'main'),
    (contentType: 'page', slug: 'home'),
    (contentType: 'page', slug: 'practical'),
    (contentType: 'page', slug: 'area'),
    (contentType: 'contact_form', slug: 'main'),
  ];

  // -- field <-> document JSON mapping ------------------------------------

  /// Resolves an editor field key to the document and the JSON path inside it.
  ///
  /// One table, one lookup: adding a field is a line here plus its
  /// [EditorFieldDef], not a branch in a read function and a matching branch in
  /// a write function. `{n}` in a pattern captures the row index of a
  /// repeatable field and lands in the path at the same position.
  static const List<({String pattern, int document, List<Object> path})>
  _fieldPaths = [
    (pattern: 'hero.headline', document: 0, path: ['hero', 'title']),
    (pattern: 'hero.subtitle', document: 0, path: ['hero', 'subtitle']),
    (pattern: 'chalet.description.{n}', document: 0, path: ['description', 0]),
    (pattern: 'chalet.experience.{n}', document: 0, path: ['experience', 0]),
    (
      pattern: 'highlights.{n}',
      document: 1,
      path: ['highlights', 0, 'description'],
    ),
    (
      pattern: 'practical.header.title',
      document: 2,
      path: ['header', 'title'],
    ),
    (
      pattern: 'practical.header.subtitle',
      document: 2,
      path: ['header', 'subtitle'],
    ),
    (pattern: 'area.intro', document: 3, path: ['intro']),
    (pattern: 'contact.title', document: 4, path: ['title']),
    (pattern: 'contact.subtitle', document: 4, path: ['subtitle']),
  ];

  /// Where one editor field lives: which document, and the path within its JSON.
  /// Path segments are object keys (String) or list indices (int).
  static EditorFieldLocation? locationOf(String fieldKey) {
    for (final entry in _fieldPaths) {
      final match = _match(entry.pattern, fieldKey);
      if (!match.matched) continue;
      final document = _documents[entry.document];
      return EditorFieldLocation(
        contentType: document.contentType,
        slug: document.slug,
        path: [
          for (final segment in entry.path)
            // The int placeholder in the table is where the row index lands.
            if (segment is int) match.index ?? segment else segment,
        ],
      );
    }
    return null;
  }

  /// Matches a field key against a pattern. [index] carries the captured row
  /// number for a `{n}` pattern and is null for a fixed one.
  static ({bool matched, int? index}) _match(String pattern, String fieldKey) {
    const noMatch = (matched: false, index: null);
    final placeholder = pattern.indexOf('{n}');
    if (placeholder == -1) {
      return pattern == fieldKey ? (matched: true, index: null) : noMatch;
    }
    final prefix = pattern.substring(0, placeholder);
    if (!fieldKey.startsWith(prefix)) return noMatch;
    final index = int.tryParse(fieldKey.substring(prefix.length));
    return index == null ? noMatch : (matched: true, index: index);
  }

  static ({String contentType, String slug}) _documentFor(String fieldKey) {
    final location = locationOf(fieldKey);
    if (location == null) return _documents[1];
    return (contentType: location.contentType, slug: location.slug);
  }

  static String _documentKeyOf(({String contentType, String slug}) doc) =>
      '${doc.contentType}:${doc.slug}';

  static String? readField(
    String fieldKey,
    String contentType,
    Map<String, dynamic> content,
  ) {
    final location = locationOf(fieldKey);
    if (location == null || location.contentType != contentType) return null;
    return _readPath(content, location.path);
  }

  /// Reads a JSON path, stopping at the first segment that is not there.
  static String? _readPath(Object? node, List<Object> path) {
    var current = node;
    for (final segment in path) {
      if (segment is int) {
        if (current is! List || segment >= current.length) return null;
        current = current[segment];
      } else {
        if (current is! Map) return null;
        current = current[segment];
      }
    }
    return current is String ? current : null;
  }

  /// Writes a JSON path, creating the objects and list entries it runs through.
  /// Lists grow to fit the index; the filler matches what the next segment
  /// needs, so a row added at the end is a usable row and not a type error.
  static void _writePath(
    Map<String, dynamic> content,
    List<Object> path,
    String value,
  ) {
    Object container = content;
    for (var i = 0; i < path.length - 1; i++) {
      final segment = path[i];
      final nextIsIndex = path[i + 1] is int;
      final child = nextIsIndex ? <dynamic>[] : <String, dynamic>{};
      if (segment is int) {
        final list = container as List<dynamic>;
        while (list.length <= segment) {
          list.add(nextIsIndex ? <dynamic>[] : <String, dynamic>{});
        }
        list[segment] = _coerce(list[segment], child);
        container = list[segment] as Object;
      } else {
        final key = segment as String;
        final map = container as Map<String, dynamic>;
        map[key] = _coerce(map[key], child);
        container = map[key] as Object;
      }
    }

    final last = path.last;
    if (last is int) {
      final list = container as List<dynamic>;
      while (list.length <= last) {
        list.add('');
      }
      list[last] = value;
    } else {
      (container as Map<String, dynamic>)[last as String] = value;
    }
  }

  /// Keeps an existing container of the right shape, replaces anything else.
  static Object _coerce(Object? existing, Object empty) {
    if (empty is List<dynamic> && existing is List) {
      return List<dynamic>.from(existing);
    }
    if (empty is Map<String, dynamic> && existing is Map) {
      return Map<String, dynamic>.from(existing);
    }
    return empty;
  }

  /// The fields a write carries when the document has to be created.
  ///
  /// Blank values are dropped: a document that exists shadows the site's
  /// fallback content, so creating one out of empty fields would replace the
  /// live page with empty headings. A document only comes into existence once
  /// there is something to put in it.
  static Map<String, String> fieldsForNewDocument(Map<String, String> fields) =>
      {
        for (final entry in fields.entries)
          if (entry.value.trim().isNotEmpty) entry.key: entry.value,
      };

  /// The columns a save or a publish writes.
  ///
  /// Saving touches `draft_content` and nothing else: `content` and `status`
  /// stay exactly as they are, so the page a guest sees does not change while
  /// the owner is working. Publishing promotes the draft into `content`, clears
  /// the draft layer and marks the document published.
  ///
  /// A document being created ([isNewDocument]) also needs a `content` and a
  /// `status`: it starts unpublished, because the public site reads `status`
  /// and a half-filled new document must not shadow the site's fallback
  /// content before anyone published it.
  static Map<String, dynamic> documentWrite({
    required Map<String, dynamic> content,
    required bool publish,
    required String? userId,
    bool isNewDocument = false,
  }) {
    return {
      if (publish) ...{
        'content': content,
        'draft_content': null,
        'status': 'published',
        'published_at': DateTime.now().toUtc().toIso8601String(),
      } else ...{
        'draft_content': content,
        if (isNewDocument) ...{'content': content, 'status': 'draft'},
      },
      'updated_by': userId,
    };
  }

  static void writeField(
    String fieldKey,
    String contentType,
    Map<String, dynamic> content,
    String value,
  ) {
    final location = locationOf(fieldKey);
    if (location == null || location.contentType != contentType) return;
    _writePath(content, location.path, value);
  }

  // -- loading -------------------------------------------------------------

  /// Loads the page's content: source fields from the source-locale documents
  /// and per-target-language fields from `site_translations`, falling back to
  /// the target locale's document values (as fresh auto entries) for fields
  /// without a translation row yet.
  Future<WebsitePageContent> loadPageContent({
    required String siteId,
    required String sourceLanguage,
    required List<String> locales,
  }) async {
    try {
      // The site row is authoritative for the source language + locales; the
      // caller's values are only the fallback (seed) configuration.
      final siteRow = await supabase
          .from('sites')
          .select('default_locale, locales')
          .eq('id', siteId)
          .maybeSingle();
      final domainRow = await supabase
          .from('site_domains')
          .select('domain')
          .eq('site_id', siteId)
          .eq('is_primary', true)
          .maybeSingle();
      final siteSourceLanguage =
          (siteRow?['default_locale'] as String?) ?? sourceLanguage;
      final siteLocales =
          (siteRow?['locales'] as List<dynamic>?)
              ?.map((l) => l as String)
              .toList() ??
          locales;
      sourceLanguage = siteSourceLanguage;
      locales = siteLocales;

      final documentRows = await supabase
          .from('cms_documents')
          .select('content_type, slug, locale, content, draft_content')
          .eq('site_id', siteId)
          .inFilter('locale', locales);
      // The editor edits the draft when there is one: what the owner saved but
      // has not published yet is what they expect to find in the fields.
      final contentByDocLocale = <String, Map<String, dynamic>>{
        for (final row in documentRows as List<dynamic>)
          '${row['content_type']}:${row['slug']}:${row['locale']}':
              Map<String, dynamic>.from(
                (row['draft_content'] ?? row['content']) as Map,
              ),
      };

      String? documentValue(String fieldKey, String locale) {
        final doc = _documentFor(fieldKey);
        final content = contentByDocLocale['${_documentKeyOf(doc)}:$locale'];
        if (content == null) return null;
        return readField(fieldKey, doc.contentType, content);
      }

      // Highlight rows are repeatable: derive the actual count from the
      // source document so extra rows survive a reload.
      final homeDoc = contentByDocLocale['page:home:$sourceLanguage'];
      final highlightCount = math.max(
        2,
        (homeDoc?['highlights'] as List<dynamic>?)?.length ?? 0,
      );
      final fieldKeys = <String>[
        for (final field in kAllFields)
          if (!field.key.startsWith('highlights.')) field.key,
        for (var i = 0; i < highlightCount; i++) 'highlights.$i',
      ];

      final source = <String, String>{
        for (final key in fieldKeys)
          key: documentValue(key, sourceLanguage) ?? '',
      };

      final translationRows = await supabase
          .from('site_translations')
          .select('field_key, language, value, status, source_hash')
          .eq('site_id', siteId)
          .eq('page', page);
      final rowsByLangKey = <String, Map<String, dynamic>>{
        for (final row in translationRows as List<dynamic>)
          '${row['language']}:${row['field_key']}': Map<String, dynamic>.from(
            row as Map,
          ),
      };

      final translations = <String, Map<String, TranslatedField>>{};
      for (final language in locales.where((l) => l != sourceLanguage)) {
        final fields = <String, TranslatedField>{};
        for (final key in fieldKeys) {
          final row = rowsByLangKey['$language:$key'];
          if (row != null) {
            fields[key] = TranslatedField(
              value: row['value'] as String? ?? '',
              status: row['status'] == 'locked'
                  ? FieldTranslationStatus.locked
                  : FieldTranslationStatus.auto,
              sourceHash: row['source_hash'] as String?,
            );
          } else {
            final published = documentValue(key, language);
            fields[key] = TranslatedField(
              value: published ?? source[key] ?? '',
              status: FieldTranslationStatus.auto,
              sourceHash: sourceHashOf(source[key] ?? ''),
            );
          }
        }
        translations[language] = fields;
      }

      return WebsitePageContent(
        source: source,
        translations: translations,
        sourceLanguage: sourceLanguage,
        locales: locales,
        previewDomain: domainRow?['domain'] as String?,
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'loadPageContent', 'siteId': siteId},
      );
    }
  }

  // -- drafts --------------------------------------------------------------

  /// Writes the source-language fields into their documents' draft layer.
  ///
  /// The live page is untouched: the copy goes into `draft_content` and the
  /// document keeps whatever it is publishing. Saving is not publishing, and it
  /// is not unpublishing either.
  Future<void> saveSourceDraft({
    required String siteId,
    required String sourceLanguage,
    required Map<String, String> fields,
  }) async {
    try {
      await _mergeFieldsIntoDocuments(
        siteId: siteId,
        locale: sourceLanguage,
        fields: fields,
        publish: false,
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'saveSourceDraft', 'siteId': siteId},
      );
    }
  }

  /// Persists one target-language field (owner-edited -> locked, or a reset
  /// auto value with its source hash).
  Future<void> saveTranslationField({
    required String siteId,
    required String language,
    required String fieldKey,
    required TranslatedField field,
  }) async {
    try {
      await supabase.from('site_translations').upsert({
        'site_id': siteId,
        'page': page,
        'field_key': fieldKey,
        'language': language,
        'value': field.value,
        'status': field.isLocked ? 'locked' : 'auto',
        'source_hash': field.sourceHash,
        'translated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'site_id,page,field_key,language');
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {
          'op': 'saveTranslationField',
          'siteId': siteId,
          'language': language,
          'fieldKey': fieldKey,
        },
      );
    }
  }

  // -- publish -------------------------------------------------------------

  /// Publishes every locale's documents: folds the given values into each
  /// document's JSON, inserts a version snapshot, marks it published and clears
  /// the draft layer (same flow as CmsRepository.publishDocument).
  ///
  /// The source locale is written first, so a target locale whose document
  /// does not exist yet can be created from it.
  Future<void> publishAll({
    required String siteId,
    required String sourceLocale,
    required Map<String, Map<String, String>> valuesByLocale,
  }) async {
    try {
      final locales = [
        if (valuesByLocale.containsKey(sourceLocale)) sourceLocale,
        ...valuesByLocale.keys.where((locale) => locale != sourceLocale),
      ];
      for (final locale in locales) {
        await _mergeFieldsIntoDocuments(
          siteId: siteId,
          locale: locale,
          fields: valuesByLocale[locale]!,
          publish: true,
          seedLocale: locale == sourceLocale ? null : sourceLocale,
        );
      }
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'publishAll', 'siteId': siteId},
      );
    }
  }

  /// Folds [fields] into each document's JSON for one locale.
  ///
  /// With [publish] false the result lands in `draft_content` and the document
  /// keeps publishing whatever it publishes now; with [publish] true it becomes
  /// the document's `content`, gets a version snapshot, and the draft layer is
  /// cleared. Those two are the whole difference between saving and publishing.
  Future<void> _mergeFieldsIntoDocuments({
    required String siteId,
    required String locale,
    required Map<String, String> fields,
    required bool publish,
    String? seedLocale,
  }) async {
    for (final doc in _documents) {
      var docFields = {
        for (final entry in fields.entries)
          if (_documentFor(entry.key) == doc) entry.key: entry.value,
      };
      if (docFields.isEmpty) continue;

      final row = await _documentRow(siteId: siteId, doc: doc, locale: locale);
      // A site whose documents were never provisioned — or a locale enabled
      // after provisioning — has no row for this document yet. The row is
      // created rather than skipped: silently dropping the edit is what made
      // the editor look like it did nothing.
      if (row == null) {
        docFields = fieldsForNewDocument(docFields);
        if (docFields.isEmpty) continue;
      }
      // A new target-locale row starts from the source locale's document (as
      // provisioning does when cloning a site), so it is a complete document
      // and not just the edited fields.
      final baseRow =
          row ??
          (seedLocale == null
              ? null
              : await _documentRow(
                  siteId: siteId,
                  doc: doc,
                  locale: seedLocale,
                ));
      // Edits build on the draft when there is one, so two saves in a row do
      // not lose the first; publishing builds on the same draft.
      final content = baseRow == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(
              (baseRow['draft_content'] ?? baseRow['content']) as Map,
            );
      docFields.forEach(
        (key, value) => writeField(key, doc.contentType, content, value),
      );

      final String documentId;
      if (row == null) {
        final created = await supabase
            .from('cms_documents')
            .insert({
              'site_id': siteId,
              'content_type': doc.contentType,
              'slug': doc.slug,
              'locale': locale,
              ...documentWrite(
                content: content,
                publish: publish,
                userId: supabase.auth.currentUser?.id,
                isNewDocument: true,
              ),
            })
            .select('id')
            .single();
        documentId = created['id'] as String;
      } else {
        documentId = row['id'] as String;
        await supabase
            .from('cms_documents')
            .update(
              documentWrite(
                content: content,
                publish: publish,
                userId: supabase.auth.currentUser?.id,
              ),
            )
            .eq('id', documentId);
      }

      if (publish) {
        await supabase.from('cms_document_versions').insert({
          'document_id': documentId,
          'version': 0, // trigger auto-increments
          'content': content,
          'published_by': supabase.auth.currentUser?.id,
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _documentRow({
    required String siteId,
    required ({String contentType, String slug}) doc,
    required String locale,
  }) async {
    final row = await supabase
        .from('cms_documents')
        .select('id, content, draft_content')
        .eq('site_id', siteId)
        .eq('content_type', doc.contentType)
        .eq('slug', doc.slug)
        .eq('locale', locale)
        .maybeSingle();
    return row;
  }
}
