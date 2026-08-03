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
    this.mediaKeys = const {},
    this.publishedByLocale = const {},
    this.sourceLanguage,
    this.locales,
    this.previewDomain,
  });

  /// `fieldKey -> text` in the source language.
  final Map<String, String> source;

  /// `listKey -> row ids` in display order, from the source-locale documents.
  final Map<String, List<String>> listOrder;

  /// `images.<slot> -> storage paths` in display order, from `site_config`.
  final Map<String, List<String>> mediaKeys;

  /// What is **live** right now, per locale: `language -> (fieldKey -> text)`
  /// read from each document's published `content`. The delta the publish
  /// dialog reports is measured against this, not against translation
  /// freshness — "changed since the last publish" is the question an owner
  /// reviewing a site actually has.
  final Map<String, Map<String, String>> publishedByLocale;

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

  /// The template whose field paths this repository reads and writes.
  ///
  /// One instance today; the parameter is what lets a second one exist without
  /// the addressing being global again. Static delegates below keep the call
  /// sites that have no repository to hand (tests, the schema test).
  final WebsiteTemplate template = kDefaultTemplate;

  /// Where one editor field lives, per the default template.
  static EditorFieldLocation? locationOf(String fieldKey) =>
      kDefaultTemplate.locationOf(fieldKey);

  static ({
    ({String contentType, String slug}) document,
    List<Object> arrayPath,
  })?
  _listLocationOf(String listKey, {List<String> enclosingIds = const []}) =>
      kDefaultTemplate.listLocationOf(listKey, enclosingIds: enclosingIds);

  static const List<({String contentType, String slug})> _documents = [
    kDocCabin,
    kDocHome,
    kDocPractical,
    kDocArea,
    kDocContactForm,
    kDocGallery,
    kDocSiteConfig,
    kDocPrivacy,
  ];

  /// The document a field key lives in, or null when the key is not mapped.
  ///
  /// Null rather than a default: this used to answer `page/home` for an
  /// unmapped key, so "I do not know this field" and "it is on the home page"
  /// were the same reply — and a write then marked home dirty over a field it
  /// could not store.
  static ({String contentType, String slug})? _documentFor(String fieldKey) {
    final location = locationOf(fieldKey);
    if (location == null) return null;
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
  ///
  /// For a nested list (a group's items) [enclosingIds] carries the enclosing
  /// row ids, outermost first.
  static List<String> listRowIdsIn(
    String listKey,
    Map<String, dynamic>? content, {
    List<String> enclosingIds = const [],
  }) {
    if (content == null) return const [];
    final list = _listLocationOf(listKey, enclosingIds: enclosingIds);
    if (list == null) return const [];
    final node = _resolvePath(content, list.arrayPath);
    if (node is! List) return const [];
    return [
      for (final row in node)
        if (row is Map && row['id'] is String) row['id'] as String,
    ];
  }

  /// Walks a resolved path without requiring a String at the end, so callers
  /// can reach a container (a list) rather than a value.
  static Object? _resolvePath(Object? node, List<Object> path) {
    var current = node;
    for (final segment in path) {
      switch (segment) {
        case final RowId id:
          if (current is! List) return null;
          // A plain loop, not firstWhere(orElse: () => null): on a list whose
          // element type is not nullable — which a decoded document can be —
          // that orElse is a type error at runtime, not a miss.
          Object? found;
          for (final row in current) {
            if (row is Map && row['id'] == id.value) {
              found = row;
              break;
            }
          }
          if (found == null) return null;
          current = found;
        case final int index:
          if (current is! List || index >= current.length) return null;
          current = current[index];
        default:
          if (current is! Map) return null;
          current = current[segment];
      }
    }
    return current;
  }

  /// Reads a JSON path, stopping at the first segment that is not there.
  static String? _readPath(Object? node, List<Object> path) {
    var current = node;
    for (final segment in path) {
      switch (segment) {
        case final RowId id:
          if (current is! List) return null;
          // A plain loop, not firstWhere(orElse: () => null): on a list whose
          // element type is not nullable — which a decoded document can be —
          // that orElse is a type error at runtime, not a miss.
          Object? found;
          for (final row in current) {
            if (row is Map && row['id'] == id.value) {
              found = row;
              break;
            }
          }
          if (found == null) return null;
          current = found;
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
            list.add(
              next is int || next is RowId ? <dynamic>[] : <String, dynamic>{},
            );
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
    List<String> order, {
    List<String> enclosingIds = const [],
  }) {
    final list = _listLocationOf(listKey, enclosingIds: enclosingIds);
    if (list == null) return;
    final parent = _resolvePath(
      content,
      list.arrayPath.sublist(0, list.arrayPath.length - 1),
    );
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
      // What is live, per locale: the published column only.
      final publishedByDocLocale = <String, Map<String, dynamic>>{
        for (final row in documentRows as List<dynamic>)
          if (row['content'] is Map)
            '${row['content_type']}:${row['slug']}:${row['locale']}':
                Map<String, dynamic>.from(row['content'] as Map),
      };

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
        if (doc == null) return null;
        final content = contentByDocLocale['${_documentKeyOf(doc)}:$locale'];
        if (content == null) return null;
        return readField(fieldKey, doc.contentType, content);
      }

      // List rows carry their identity in the row itself; the source-locale
      // document is authoritative for which rows exist and in what order.
      // Read every list the schema knows, then let the schema expand the
      // fields — so the enumeration cannot drift from what the editor renders.
      Map<String, dynamic>? sourceDocumentFor(String listKey) {
        final document = _listLocationOf(listKey)?.document;
        if (document == null) return null;
        return contentByDocLocale['${_documentKeyOf(document)}:$sourceLanguage'];
      }

      final listOrder = <String, List<String>>{};
      for (final list in kDefaultTemplate.lists) {
        final content = sourceDocumentFor(list.listKey);
        final ids = listRowIdsIn(list.listKey, content);
        listOrder[list.listKey] = ids;
        final itemsListKey = list.itemsListKey;
        if (itemsListKey == null) continue;
        // A group's items live one level deeper, addressed through the group.
        //
        // The lookup key keeps the enclosing `{id}` placeholder, because that
        // is the shape _listLocationOf compares against — it strips pattern
        // segments only up to the placeholder it is resolving. Passing
        // `<list>.items` matched no pattern, so every group list came back
        // with its groups but none of their items.
        for (final groupId in ids) {
          final key = groupItemsListKey(list.listKey, groupId, itemsListKey);
          listOrder[key] = listRowIdsIn(
            '${list.listKey}.{id}.$itemsListKey',
            content,
            enclosingIds: [groupId],
          );
        }
      }

      final fieldKeys = <String>[
        for (final page in kDefaultTemplate.pageKeys)
          for (final field in kDefaultTemplate.fieldsFor(page, listOrder))
            field.key,
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

      // Photo slots, from the source locale's site_config: they are the same
      // for every language, so one read answers for all of them.
      final configContent =
          contentByDocLocale['site_config:main:$sourceLanguage'];
      final images = configContent?['images'];
      final mediaKeys = <String, List<String>>{
        if (images is Map)
          for (final entry in images.entries)
            if (entry.value is List)
              'images.${entry.key}': [
                for (final path in entry.value as List<dynamic>)
                  if (path is String) path,
              ],
      };

      String? publishedValue(String fieldKey, String locale) {
        final doc = _documentFor(fieldKey);
        if (doc == null) return null;
        final content = publishedByDocLocale['${_documentKeyOf(doc)}:$locale'];
        if (content == null) return null;
        return readField(fieldKey, doc.contentType, content);
      }

      final publishedByLocale = <String, Map<String, String>>{
        for (final locale in locales)
          locale: {
            for (final key in fieldKeys)
              if (publishedValue(key, locale) case final value?) key: value,
          },
      };

      return WebsitePageContent(
        source: source,
        translations: translations,
        listOrder: listOrder,
        mediaKeys: mediaKeys,
        publishedByLocale: publishedByLocale,
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
    Map<String, List<String>> mediaKeys = const {},
  }) async {
    try {
      await _mergeFieldsIntoDocuments(
        siteId: siteId,
        locale: sourceLanguage,
        fields: fields,
        listOrders: listOrders,
        mediaKeys: mediaKeys,
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
    Map<String, List<String>> mediaKeys = const {},
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
          // Photos are one set for the site: every locale's site_config gets
          // the same paths, so a language cannot end up with its own gallery.
          mediaKeys: mediaKeys,
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
    Map<String, List<String>> mediaKeys = const {},
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
      // Photo slots belong to site_config; every other document ignores them.
      final docMedia = doc.contentType == 'site_config' && doc.slug == 'main'
          ? mediaKeys
          : const <String, List<String>>{};
      // A pure reorder or a photo choice is a document change too: the array
      // order is what the public site renders.
      if (docFields.isEmpty && docOrders.isEmpty && docMedia.isEmpty) continue;

      final row = await _documentRow(siteId: siteId, doc: doc, locale: locale);
      // A site whose documents were never provisioned — or a locale enabled
      // after provisioning — has no row for this document yet. The row is
      // created rather than skipped: silently dropping the edit is what made
      // the editor look like it did nothing.
      if (row == null) {
        docFields = fieldsForNewDocument(docFields);
        if (docFields.isEmpty && docOrders.isEmpty && docMedia.isEmpty) {
          continue;
        }
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
      if (docMedia.isNotEmpty) {
        final images = Map<String, dynamic>.from(
          content['images'] as Map? ?? const {},
        );
        docMedia.forEach((mediaKey, paths) {
          // `images.heroPhotos` -> images['heroPhotos'].
          images[mediaKey.split('.').last] = paths;
        });
        content['images'] = images;
      }

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
