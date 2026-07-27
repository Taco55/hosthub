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
    this.listOrder = const {},
    this.sourceLanguage,
    this.locales,
    this.previewDomain,
  });

  /// `fieldKey -> text` in the source language.
  final Map<String, String> source;

  /// `listKey -> row ids` in display order, from the source-locale documents.
  final Map<String, List<String>> listOrder;

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

/// A path segment addressing a repeatable-list row by its stable id.
///
/// The array index is display order; the id is identity. Reads and writes
/// resolve the row by scanning the array for `row['id'] == value`, so a row
/// keeps its translations and its content when the owner drags it elsewhere.
class RowId {
  const RowId(this.value);

  final String value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is RowId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Where an editor field lives in the site's content: which document, and the
/// path inside that document's JSON (object keys as String, row ids as
/// [RowId], list indices as int).
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

/// Marks the position in a path template where a captured row id lands.
class _RowIdSlot {
  const _RowIdSlot();
}

const _rowId = _RowIdSlot();

/// Persistence for the website editor. The editor's flat field keys map onto
/// the site's real CMS documents (the same JSON the public site renders):
///
/// | field key                       | document (type/slug) | JSON path                    |
/// |---------------------------------|----------------------|------------------------------|
/// | cabin.hero.title                | cabin / main         | hero.title                   |
/// | cabin.hero.subtitle             | cabin / main         | hero.subtitle                |
/// | cabin.description.{id}.text     | cabin / main         | description[id].text         |
/// | cabin.experience.{id}.text      | cabin / main         | experience[id].text          |
/// | home.highlights.{id}.description| page / home          | highlights[id].description   |
/// | practical.header.title          | page / practical     | header.title                 |
/// | practical.header.subtitle       | page / practical     | header.subtitle              |
/// | area.intro                      | page / area          | intro                        |
/// | contact.title                   | contact_form / main  | title                        |
/// | contact.subtitle                | contact_form / main  | subtitle                     |
///
/// `{id}` is the row's **stable id** — an `id` key stored in the row object
/// itself. The array index is display order and nothing else: reordering rows
/// moves objects around, and every translation keyed by id travels along.
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
  /// One table, one lookup: adding a field is a line here plus its row in
  /// the page schema ([kPageCards]), not a branch in a read function and a
  /// matching branch in a write function. `{id}` in a pattern captures a
  /// stable row id and lands in the path at the [_rowId] position.
  static const List<({String pattern, int document, List<Object> path})>
  _fieldPaths = [
    (pattern: 'cabin.hero.title', document: 0, path: ['hero', 'title']),
    (pattern: 'cabin.hero.subtitle', document: 0, path: ['hero', 'subtitle']),
    (
      pattern: 'cabin.description.{id}.text',
      document: 0,
      path: ['description', _rowId, 'text'],
    ),
    (
      pattern: 'cabin.experience.{id}.text',
      document: 0,
      path: ['experience', _rowId, 'text'],
    ),
    (
      pattern: 'home.highlights.{id}.description',
      document: 1,
      path: ['highlights', _rowId, 'description'],
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
  /// Path segments are object keys (String), row-id lookups (a String at a
  /// list position) or plain list indices (int).
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
            // The slot in the table is where the captured row id lands.
            if (segment is _RowIdSlot) RowId(match.rowId!) else segment,
        ],
      );
    }
    return null;
  }

  /// The document and array path a repeatable list lives at, from the same
  /// table (`<listKey>.{id}...` patterns). Null for an unknown list.
  static ({
    ({String contentType, String slug}) document,
    List<Object> arrayPath,
  })?
  _listLocationOf(String listKey) {
    for (final entry in _fieldPaths) {
      if (!entry.pattern.startsWith('$listKey.{id}')) continue;
      final slot = entry.path.indexWhere((segment) => segment is _RowIdSlot);
      if (slot < 0) continue;
      return (
        document: _documents[entry.document],
        arrayPath: entry.path.sublist(0, slot),
      );
    }
    return null;
  }

  /// Matches a field key against a pattern. [rowId] carries the captured id
  /// for a `{id}` pattern and is null for a fixed one.
  static ({bool matched, String? rowId}) _match(
    String pattern,
    String fieldKey,
  ) {
    const noMatch = (matched: false, rowId: null);
    final placeholder = pattern.indexOf('{id}');
    if (placeholder == -1) {
      return pattern == fieldKey ? (matched: true, rowId: null) : noMatch;
    }
    final prefix = pattern.substring(0, placeholder);
    final suffix = pattern.substring(placeholder + '{id}'.length);
    if (!fieldKey.startsWith(prefix) || !fieldKey.endsWith(suffix)) {
      return noMatch;
    }
    final rowId = fieldKey.substring(
      prefix.length,
      fieldKey.length - suffix.length,
    );
    if (rowId.isEmpty || rowId.contains('.')) return noMatch;
    return (matched: true, rowId: rowId);
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

  /// The stable row ids of a repeatable list in a document's JSON, in array
  /// (= display) order. Rows without an id are skipped: identity is the id,
  /// and a row that has none is not addressable by the editor.
  static List<String> listRowIdsIn(
    String listKey,
    Map<String, dynamic>? content,
  ) {
    if (content == null) return const [];
    final list = _listLocationOf(listKey);
    if (list == null) return const [];
    Object? node = content;
    for (final segment in list.arrayPath) {
      if (node is! Map) return const [];
      node = node[segment];
    }
    if (node is! List) return const [];
    return [
      for (final row in node)
        if (row is Map && row['id'] is String) row['id'] as String,
    ];
  }

  /// Reads a JSON path, stopping at the first segment that is not there.
  static String? _readPath(Object? node, List<Object> path) {
    var current = node;
    for (final segment in path) {
      switch (segment) {
        case final RowId id:
          if (current is! List) return null;
          current = current.firstWhere(
            (row) => row is Map && row['id'] == id.value,
            orElse: () => null,
          );
          if (current == null) return null;
        case final int index:
          if (current is! List || index >= current.length) return null;
          current = current[index];
        default:
          if (current is! Map) return null;
          current = current[segment];
      }
    }
    return current is String ? current : null;
  }

  /// Writes a JSON path, creating the containers it runs through. A [RowId]
  /// segment resolves its row by stable id and appends a fresh `{id: ...}`
  /// row when the id is not there yet — a newly added row lands at the end of
  /// the list, in every locale, as a usable row.
  static void _writePath(
    Map<String, dynamic> content,
    List<Object> path,
    String value,
  ) {
    Object container = content;
    for (var i = 0; i < path.length - 1; i++) {
      final segment = path[i];
      final next = path[i + 1];
      final Object emptyChild = next is int || next is RowId
          ? <dynamic>[]
          : <String, dynamic>{};
      switch (segment) {
        case final RowId id:
          final list = container as List<dynamic>;
          var index = list.indexWhere(
            (row) => row is Map && row['id'] == id.value,
          );
          if (index == -1) {
            list.add(<String, dynamic>{'id': id.value});
            index = list.length - 1;
          }
          list[index] = _coerce(list[index], emptyChild);
          container = list[index] as Object;
        case final int index:
          final list = container as List<dynamic>;
          while (list.length <= index) {
            list.add(next is int || next is RowId
                ? <dynamic>[]
                : <String, dynamic>{});
          }
          list[index] = _coerce(list[index], emptyChild);
          container = list[index] as Object;
        default:
          final key = segment as String;
          final map = container as Map<String, dynamic>;
          map[key] = _coerce(map[key], emptyChild);
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

  /// Reorders a repeatable list's array in [content] to match [order]
  /// (row ids in display order). Rows whose id is not in [order] keep their
  /// place after the ordered ones, so an unknown row is never dropped.
  static void applyListOrder(
    String listKey,
    Map<String, dynamic> content,
    List<String> order,
  ) {
    final list = _listLocationOf(listKey);
    if (list == null) return;
    Object? parent = content;
    for (var i = 0; i < list.arrayPath.length - 1; i++) {
      if (parent is! Map) return;
      parent = parent[list.arrayPath[i]];
    }
    if (parent is! Map) return;
    final arrayKey = list.arrayPath.last as String;
    final array = parent[arrayKey];
    if (array is! List) return;

    final byId = <String, Object?>{};
    final rest = <Object?>[];
    for (final row in array) {
      final id = row is Map ? row['id'] : null;
      if (id is String) {
        byId[id] = row;
      } else {
        rest.add(row);
      }
    }
    parent[arrayKey] = <dynamic>[
      for (final id in order)
        if (byId.containsKey(id)) byId.remove(id),
      ...byId.values,
      ...rest,
    ];
  }

  /// Keeps an existing container of the right shape, replaces anything else.
  static Object _coerce(Object? existing, Object empty) {
    if (empty is List<dynamic> && existing is List) {
      return existing;
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

      // List rows carry their identity in the row itself; the source-locale
      // document is authoritative for which rows exist and in what order.
      final listOrder = <String, List<String>>{};
      final fieldKeys = <String>[];
      for (final cards in kPageCards.values) {
        for (final card in cards) {
          for (final row in card.rows) {
            switch (row) {
              case FieldRow(:final key):
                fieldKeys.add(key);
              case ListRow(:final listKey, :final sub):
                final document = _listLocationOf(listKey)?.document;
                final ids = document == null
                    ? const <String>[]
                    : listRowIdsIn(
                        listKey,
                        contentByDocLocale['${_documentKeyOf(document)}:$sourceLanguage'],
                      );
                listOrder[listKey] = ids;
                fieldKeys.addAll([
                  for (final id in ids) listFieldKey(listKey, id, sub),
                ]);
            }
          }
        }
      }

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
        listOrder: listOrder,
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
    Map<String, List<String>> listOrders = const {},
  }) async {
    try {
      await _mergeFieldsIntoDocuments(
        siteId: siteId,
        locale: sourceLanguage,
        fields: fields,
        listOrders: listOrders,
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
    Map<String, List<String>> listOrders = const {},
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
          listOrders: listOrders,
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
    Map<String, List<String>> listOrders = const {},
    String? seedLocale,
  }) async {
    for (final doc in _documents) {
      var docFields = {
        for (final entry in fields.entries)
          if (_documentFor(entry.key) == doc) entry.key: entry.value,
      };
      final docOrders = {
        for (final entry in listOrders.entries)
          if (_listLocationOf(entry.key)?.document == doc)
            entry.key: entry.value,
      };
      // A pure reorder is a document change too: the array order is what the
      // public site renders.
      if (docFields.isEmpty && docOrders.isEmpty) continue;

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
      docOrders.forEach(
        (listKey, order) => applyListOrder(listKey, content, order),
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
