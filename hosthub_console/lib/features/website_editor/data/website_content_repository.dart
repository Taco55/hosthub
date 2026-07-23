import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';

import '../domain/website_content.dart';

/// Loaded editor content for one page: the source-language field values plus
/// the per-language translated fields.
class WebsitePageContent {
  const WebsitePageContent({required this.source, required this.translations});

  /// `fieldKey -> text` in the source language.
  final Map<String, String> source;

  /// `language -> (fieldKey -> TranslatedField)` for the target languages.
  final Map<String, Map<String, TranslatedField>> translations;
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

  static ({String contentType, String slug}) _documentFor(String fieldKey) {
    if (fieldKey.startsWith('hero.') || fieldKey.startsWith('chalet.')) {
      return _documents[0];
    }
    if (fieldKey.startsWith('highlights.')) return _documents[1];
    if (fieldKey.startsWith('practical.')) return _documents[2];
    if (fieldKey.startsWith('area.')) return _documents[3];
    if (fieldKey.startsWith('contact.')) return _documents[4];
    return _documents[1];
  }

  static String _documentKeyOf(({String contentType, String slug}) doc) =>
      '${doc.contentType}:${doc.slug}';

  static String? readField(
    String fieldKey,
    String contentType,
    Map<String, dynamic> content,
  ) {
    if (fieldKey == 'hero.headline' && contentType == 'cabin') {
      return ((content['hero'] as Map<String, dynamic>?)?['title']) as String?;
    }
    if (fieldKey == 'hero.subtitle' && contentType == 'cabin') {
      return ((content['hero'] as Map<String, dynamic>?)?['subtitle'])
          as String?;
    }
    if (fieldKey.startsWith('highlights.') && contentType == 'page') {
      final index = int.tryParse(fieldKey.split('.').last);
      final highlights = content['highlights'] as List<dynamic>?;
      if (index == null || highlights == null || index >= highlights.length) {
        return null;
      }
      return (highlights[index] as Map<String, dynamic>?)?['description']
          as String?;
    }
    if (fieldKey.startsWith('chalet.') && contentType == 'cabin') {
      final parts = fieldKey.split('.'); // chalet.<list>.<index>
      final list = content[parts[1]] as List<dynamic>?;
      final index = int.tryParse(parts[2]);
      if (list == null || index == null || index >= list.length) return null;
      return list[index] as String?;
    }
    if (fieldKey.startsWith('practical.header.') && contentType == 'page') {
      final header = content['header'] as Map<String, dynamic>?;
      return header?[fieldKey.split('.').last] as String?;
    }
    if (fieldKey == 'area.intro' && contentType == 'page') {
      return content['intro'] as String?;
    }
    if (fieldKey.startsWith('contact.') && contentType == 'contact_form') {
      return content[fieldKey.split('.').last] as String?;
    }
    return null;
  }

  static void writeField(
    String fieldKey,
    String contentType,
    Map<String, dynamic> content,
    String value,
  ) {
    if (contentType == 'cabin' && fieldKey.startsWith('hero.')) {
      final hero = Map<String, dynamic>.from(
        content['hero'] as Map<String, dynamic>? ?? {},
      );
      hero[fieldKey == 'hero.headline' ? 'title' : 'subtitle'] = value;
      content['hero'] = hero;
      return;
    }
    if (contentType == 'page' && fieldKey.startsWith('highlights.')) {
      final index = int.tryParse(fieldKey.split('.').last);
      if (index == null) return;
      final highlights = List<dynamic>.from(
        content['highlights'] as List<dynamic>? ?? [],
      );
      while (highlights.length <= index) {
        highlights.add(<String, dynamic>{});
      }
      final item = Map<String, dynamic>.from(
        highlights[index] as Map<String, dynamic>? ?? {},
      );
      item['description'] = value;
      highlights[index] = item;
      content['highlights'] = highlights;
      return;
    }
    if (contentType == 'cabin' && fieldKey.startsWith('chalet.')) {
      final parts = fieldKey.split('.'); // chalet.<list>.<index>
      final index = int.tryParse(parts[2]);
      if (index == null) return;
      final list = List<dynamic>.from(content[parts[1]] as List<dynamic>? ?? []);
      while (list.length <= index) {
        list.add('');
      }
      list[index] = value;
      content[parts[1]] = list;
      return;
    }
    if (contentType == 'page' && fieldKey.startsWith('practical.header.')) {
      final header = Map<String, dynamic>.from(
        content['header'] as Map<String, dynamic>? ?? {},
      );
      header[fieldKey.split('.').last] = value;
      content['header'] = header;
      return;
    }
    if (contentType == 'page' && fieldKey == 'area.intro') {
      content['intro'] = value;
      return;
    }
    if (contentType == 'contact_form' && fieldKey.startsWith('contact.')) {
      content[fieldKey.split('.').last] = value;
      return;
    }
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
      final documentRows = await supabase
          .from('cms_documents')
          .select('content_type, slug, locale, content')
          .eq('site_id', siteId)
          .inFilter('locale', locales);
      final contentByDocLocale = <String, Map<String, dynamic>>{
        for (final row in documentRows as List<dynamic>)
          '${row['content_type']}:${row['slug']}:${row['locale']}':
              Map<String, dynamic>.from(row['content'] as Map),
      };

      String? documentValue(String fieldKey, String locale) {
        final doc = _documentFor(fieldKey);
        final content = contentByDocLocale['${_documentKeyOf(doc)}:$locale'];
        if (content == null) return null;
        return readField(fieldKey, doc.contentType, content);
      }

      final source = <String, String>{
        for (final field in kAllFields)
          field.key: documentValue(field.key, sourceLanguage) ?? '',
      };

      final translationRows = await supabase
          .from('site_translations')
          .select('field_key, language, value, status, source_hash')
          .eq('site_id', siteId)
          .eq('page', page);
      final rowsByLangKey = <String, Map<String, dynamic>>{
        for (final row in translationRows as List<dynamic>)
          '${row['language']}:${row['field_key']}':
              Map<String, dynamic>.from(row as Map),
      };

      final translations = <String, Map<String, TranslatedField>>{};
      for (final language in locales.where((l) => l != sourceLanguage)) {
        final fields = <String, TranslatedField>{};
        for (final field in kAllFields) {
          final row = rowsByLangKey['$language:${field.key}'];
          if (row != null) {
            fields[field.key] = TranslatedField(
              value: row['value'] as String? ?? '',
              status: row['status'] == 'locked'
                  ? FieldTranslationStatus.locked
                  : FieldTranslationStatus.auto,
              sourceHash: row['source_hash'] as String?,
            );
          } else {
            final published = documentValue(field.key, language);
            fields[field.key] = TranslatedField(
              value: published ?? source[field.key] ?? '',
              status: FieldTranslationStatus.auto,
              sourceHash: sourceHashOf(source[field.key] ?? ''),
            );
          }
        }
        translations[language] = fields;
      }

      return WebsitePageContent(source: source, translations: translations);
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

  /// Writes the source-language fields back into their documents as drafts.
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
        status: 'draft',
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
  /// document's JSON, inserts a version snapshot and marks it published
  /// (same flow as CmsRepository.publishDocument).
  Future<void> publishAll({
    required String siteId,
    required Map<String, Map<String, String>> valuesByLocale,
  }) async {
    try {
      for (final entry in valuesByLocale.entries) {
        await _mergeFieldsIntoDocuments(
          siteId: siteId,
          locale: entry.key,
          fields: entry.value,
          status: 'published',
          snapshotVersion: true,
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

  Future<void> _mergeFieldsIntoDocuments({
    required String siteId,
    required String locale,
    required Map<String, String> fields,
    required String status,
    bool snapshotVersion = false,
  }) async {
    for (final doc in _documents) {
      final docFields = {
        for (final entry in fields.entries)
          if (_documentFor(entry.key) == doc) entry.key: entry.value,
      };
      if (docFields.isEmpty) continue;

      final row = await supabase
          .from('cms_documents')
          .select('id, content')
          .eq('site_id', siteId)
          .eq('content_type', doc.contentType)
          .eq('slug', doc.slug)
          .eq('locale', locale)
          .maybeSingle();
      if (row == null) continue;

      final content = Map<String, dynamic>.from(row['content'] as Map);
      docFields.forEach(
        (key, value) => writeField(key, doc.contentType, content, value),
      );

      final documentId = row['id'] as String;
      if (snapshotVersion) {
        await supabase.from('cms_document_versions').insert({
          'document_id': documentId,
          'version': 0, // trigger auto-increments
          'content': content,
          'published_by': supabase.auth.currentUser?.id,
        });
      }
      await supabase.from('cms_documents').update({
        'content': content,
        'status': status,
        'updated_by': supabase.auth.currentUser?.id,
        if (status == 'published')
          'published_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', documentId);
    }
  }
}
