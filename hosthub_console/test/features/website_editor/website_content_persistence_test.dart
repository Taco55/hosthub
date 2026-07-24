import 'package:flutter_test/flutter_test.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// In-memory fake capturing repository interactions (extends the real class so
/// the cubit contract stays honest; Supabase is never touched because every
/// public method is overridden).
class FakeWebsiteContentRepository implements WebsiteContentRepository {
  FakeWebsiteContentRepository({required this.content});

  WebsitePageContent content;
  int loadCalls = 0;
  final List<Map<String, String>> sourceDraftSaves = [];
  final List<(String, String, TranslatedField)> translationSaves = [];
  final List<Map<String, Map<String, String>>> publishes = [];

  @override
  Future<WebsitePageContent> loadPageContent({
    required String siteId,
    required String sourceLanguage,
    required List<String> locales,
  }) async {
    loadCalls++;
    return content;
  }

  @override
  Future<void> saveSourceDraft({
    required String siteId,
    required String sourceLanguage,
    required Map<String, String> fields,
  }) async {
    sourceDraftSaves.add(Map.of(fields));
  }

  @override
  Future<void> saveTranslationField({
    required String siteId,
    required String language,
    required String fieldKey,
    required TranslatedField field,
  }) async {
    translationSaves.add((language, fieldKey, field));
  }

  @override
  Future<void> publishAll({
    required String siteId,
    required Map<String, Map<String, String>> valuesByLocale,
  }) async {
    publishes.add(valuesByLocale);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

WebsitePageContent _remoteContent() => WebsitePageContent(
      source: {
        'hero.headline': 'Titel uit database',
        'hero.subtitle': 'Ondertitel uit database',
        'highlights.0': 'Hoogtepunt A',
        'highlights.1': 'Hoogtepunt B',
      },
      translations: {
        for (final lang in ['en', 'no'])
          lang: {
            for (final field in kHomeFields)
              field.key: TranslatedField(
                value: '[$lang] ${field.key}',
                status: FieldTranslationStatus.auto,
                sourceHash: sourceHashOf(
                  {
                    'hero.headline': 'Titel uit database',
                    'hero.subtitle': 'Ondertitel uit database',
                    'highlights.0': 'Hoogtepunt A',
                    'highlights.1': 'Hoogtepunt B',
                  }[field.key]!,
                ),
              ),
          },
      },
    );

SiteContentCubit _build(FakeWebsiteContentRepository repository) =>
    SiteContentCubit(
      translationService: const SeedTranslationService(),
      repository: repository,
      siteId: 'site-1',
      autosaveDebounce: Duration.zero,
    );

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  test('loadContent hydrates source + translations from the repository',
      () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);

    await cubit.loadContent();

    expect(repo.loadCalls, 1);
    expect(cubit.state.valueFor('nl', 'hero.headline'), 'Titel uit database');
    expect(cubit.state.valueFor('en', 'hero.headline'), '[en] hero.headline');
    expect(cubit.state.dirty, isFalse);
    expect(cubit.state.staleLanguages, isEmpty);
    await cubit.close();
  });

  test('source edits autosave a draft (debounced)', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();

    cubit.editSourceField('hero.headline', 'Nieuwe titel');
    await _settle();

    expect(repo.sourceDraftSaves, hasLength(1));
    expect(repo.sourceDraftSaves.single['hero.headline'], 'Nieuwe titel');
    await cubit.close();
  });

  test('translation edits persist as locked rows', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();

    cubit.editTranslationField('en', 'hero.headline', 'My headline');
    await _settle();

    expect(repo.translationSaves, hasLength(1));
    final (language, key, field) = repo.translationSaves.single;
    expect(language, 'en');
    expect(key, 'hero.headline');
    expect(field.status, FieldTranslationStatus.locked);
    expect(field.value, 'My headline');
    await cubit.close();
  });

  test('publishAll persists all locales into the documents', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();
    cubit.editSourceField('hero.headline', 'Nieuwe titel');

    await cubit.publishAll();

    expect(repo.publishes, hasLength(1));
    final byLocale = repo.publishes.single;
    expect(byLocale.keys, containsAll(<String>['nl', 'en', 'no']));
    expect(byLocale['nl']!['hero.headline'], 'Nieuwe titel');
    // Targets publish their current (translated) values for every field of
    // every page (the publish scope spans the whole site).
    expect(byLocale['en']!.keys, hasLength(kAllFields.length));
    expect(cubit.state.dirty, isFalse);
    await cubit.close();
  });

  test('loadContent adopts the site source language and resets the preview',
      () async {
    final base = _remoteContent();
    final repo = FakeWebsiteContentRepository(
      content: WebsitePageContent(
        source: base.source,
        translations: base.translations,
        sourceLanguage: 'en',
        locales: const ['en', 'no'],
      ),
    );
    final cubit = _build(repo);
    // Seed preview is 'nl', which the site no longer offers.
    expect(cubit.state.previewLanguage, 'nl');

    await cubit.loadContent();

    expect(cubit.state.sourceLanguage, 'en');
    expect(cubit.state.locales, ['en', 'no']);
    // Preview snapped to the new source because 'nl' is not enabled.
    expect(cubit.state.previewLanguage, 'en');
    expect(cubit.state.targetLanguages, ['no']);
    await cubit.close();
  });

  test('loadContent adopts the preview domain; autosave bumps lastSavedAt',
      () async {
    final base = _remoteContent();
    final repo = FakeWebsiteContentRepository(
      content: WebsitePageContent(
        source: base.source,
        translations: base.translations,
        previewDomain: 'trysilpanorama.com',
      ),
    );
    final cubit = _build(repo);
    await cubit.loadContent();

    expect(cubit.state.previewDomain, 'trysilpanorama.com');
    expect(cubit.state.lastSavedAt, isNull);

    cubit.editSourceField('hero.headline', 'Nieuwe titel');
    await _settle();

    // The debounced autosave flushed and marked the save moment, which the
    // embedded live preview uses as a cache-busting reload key.
    expect(cubit.state.lastSavedAt, isNotNull);
    await cubit.close();
  });

  test('hydrated auto fields go stale when their source changes', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();
    expect(cubit.state.isLanguageStale('en'), isFalse);

    cubit.editSourceField('hero.headline', 'Nieuwe titel');

    // sha256 source hashes survive hydration, so staleness is detected.
    expect(cubit.state.isFieldStale('en', 'hero.headline'), isTrue);
    expect(cubit.state.isFieldStale('en', 'hero.subtitle'), isFalse);
    await cubit.close();
  });

  group('field <-> document JSON mapping', () {
    test('hero fields read from and write to cabin hero.title/subtitle', () {
      final content = <String, dynamic>{
        'hero': <String, dynamic>{
          'title': 'Oude titel',
          'subtitle': 'Oude ondertitel',
        },
        'meta': <String, dynamic>{'name': 'x'},
      };

      expect(
        WebsiteContentRepository.readField('hero.headline', 'cabin', content),
        'Oude titel',
      );

      WebsiteContentRepository.writeField(
        'hero.headline', 'cabin', content, 'Nieuwe titel');
      expect((content['hero'] as Map)['title'], 'Nieuwe titel');
      // Sibling keys survive the merge.
      expect((content['hero'] as Map)['subtitle'], 'Oude ondertitel');
      expect((content['meta'] as Map)['name'], 'x');
    });

    test('chalet fields map to cabin description[N]/experience[N]', () {
      final content = <String, dynamic>{
        'description': <dynamic>['Eerste alinea', 'Tweede alinea'],
        'experience': <dynamic>['Ski-in', 'Sauna'],
      };

      expect(
        WebsiteContentRepository.readField(
            'chalet.description.0', 'cabin', content),
        'Eerste alinea',
      );
      expect(
        WebsiteContentRepository.readField(
            'chalet.experience.1', 'cabin', content),
        'Sauna',
      );

      WebsiteContentRepository.writeField(
          'chalet.experience.0', 'cabin', content, 'Nieuw');
      expect((content['experience'] as List)[0], 'Nieuw');
      expect((content['experience'] as List)[1], 'Sauna');
      expect((content['description'] as List)[0], 'Eerste alinea');
    });

    test('practical/area/contact fields map to their documents', () {
      final practical = <String, dynamic>{
        'header': <String, dynamic>{'title': 'Praktisch', 'subtitle': 'Sub'},
      };
      expect(
        WebsiteContentRepository.readField(
            'practical.header.title', 'page', practical),
        'Praktisch',
      );
      WebsiteContentRepository.writeField(
          'practical.header.subtitle', 'page', practical, 'Nieuwe sub');
      expect((practical['header'] as Map)['subtitle'], 'Nieuwe sub');
      expect((practical['header'] as Map)['title'], 'Praktisch');

      final area = <String, dynamic>{'intro': 'Oud', 'sections': <dynamic>[]};
      WebsiteContentRepository.writeField('area.intro', 'page', area, 'Nieuw');
      expect(area['intro'], 'Nieuw');
      expect(area['sections'], isEmpty);

      final contact = <String, dynamic>{'title': 'T', 'subtitle': 'S'};
      expect(
        WebsiteContentRepository.readField(
            'contact.subtitle', 'contact_form', contact),
        'S',
      );
      WebsiteContentRepository.writeField(
          'contact.title', 'contact_form', contact, 'Nieuw');
      expect(contact['title'], 'Nieuw');
    });

    test('highlight fields map to page highlights[N].description', () {
      final content = <String, dynamic>{
        'highlights': <dynamic>[
          <String, dynamic>{'title': 'Ski-in / ski-out', 'description': 'Oud'},
          <String, dynamic>{'title': 'Sauna', 'description': 'Ontspan'},
        ],
      };

      expect(
        WebsiteContentRepository.readField('highlights.1', 'page', content),
        'Ontspan',
      );

      WebsiteContentRepository.writeField(
        'highlights.0', 'page', content, 'Direct de pistes op');
      final highlights = content['highlights'] as List;
      expect((highlights[0] as Map)['description'], 'Direct de pistes op');
      // Titles are not touched by the editor.
      expect((highlights[0] as Map)['title'], 'Ski-in / ski-out');
    });
  });
}
