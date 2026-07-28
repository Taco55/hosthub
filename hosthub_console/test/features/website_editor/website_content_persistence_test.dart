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

  /// When set, the next [saveSourceDraft] throws it (once).
  Object? nextSourceDraftError;

  /// When set, [loadPageContent] throws it instead of returning content.
  Object? loadError;

  /// The list orders each saveSourceDraft call carried.
  final List<Map<String, List<String>>> sourceDraftOrders = [];

  /// The photo slots each saveSourceDraft call carried.
  final List<Map<String, List<String>>> sourceDraftMedia = [];

  /// The photo slots each publish carried.
  final List<Map<String, List<String>>> publishedMedia = [];

  @override
  Future<WebsitePageContent> loadPageContent({
    required String siteId,
    required String sourceLanguage,
    required List<String> locales,
  }) async {
    loadCalls++;
    final error = loadError;
    if (error != null) throw error;
    return content;
  }

  @override
  Future<void> saveSourceDraft({
    required String siteId,
    required String sourceLanguage,
    required Map<String, String> fields,
    Map<String, List<String>> listOrders = const {},
    Map<String, List<String>> mediaKeys = const {},
  }) async {
    final error = nextSourceDraftError;
    if (error != null) {
      nextSourceDraftError = null;
      throw error;
    }
    sourceDraftSaves.add(Map.of(fields));
    sourceDraftOrders.add(Map.of(listOrders));
    sourceDraftMedia.add(Map.of(mediaKeys));
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
    required String sourceLocale,
    required Map<String, Map<String, String>> valuesByLocale,
    Map<String, List<String>> listOrders = const {},
    Map<String, List<String>> mediaKeys = const {},
  }) async {
    publishes.add(valuesByLocale);
    publishedMedia.add(Map.of(mediaKeys));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WebsitePageContent _remoteContent() => WebsitePageContent(
  // The site row carries the authoring language and the enabled locales; a
  // persistent editor has none of its own until this arrives.
  sourceLanguage: 'nl',
  locales: const ['nl', 'en', 'no'],
  listOrder: const {
    'home.highlights': ['hA', 'hB'],
  },
  source: {
    'cabin.hero.title': 'Titel uit database',
    'cabin.hero.subtitle': 'Ondertitel uit database',
    'home.highlights.hA.description': 'Hoogtepunt A',
    'home.highlights.hB.description': 'Hoogtepunt B',
  },
  translations: {
    for (final lang in ['en', 'no'])
      lang: {
        for (final key in const [
          'cabin.hero.title',
          'cabin.hero.subtitle',
          'home.highlights.hA.description',
          'home.highlights.hB.description',
        ])
          key: TranslatedField(
            value: '[$lang] $key',
            status: FieldTranslationStatus.auto,
            sourceHash: sourceHashOf(
              {
                'cabin.hero.title': 'Titel uit database',
                'cabin.hero.subtitle': 'Ondertitel uit database',
                'home.highlights.hA.description': 'Hoogtepunt A',
                'home.highlights.hB.description': 'Hoogtepunt B',
              }[key]!,
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
    );

void main() {
  test('a persistent editor holds no seed content before it loads', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);

    expect(cubit.state.loadStatus, ContentLoadStatus.loading);
    expect(cubit.state.source, isEmpty);
    expect(cubit.state.translations, isEmpty);
    expect(cubit.state.propertyName, isEmpty);
    // Not the seed's 'Jouw bergwoning in Trysil'.
    expect(cubit.state.valueFor('nl', 'cabin.hero.title'), isEmpty);
    await cubit.close();
  });

  test('a failed load leaves no content to save', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent())
      ..loadError = StateError('column cms_documents.draft_content missing');
    final cubit = _build(repo);

    await cubit.loadContent();

    expect(cubit.state.loadStatus, ContentLoadStatus.failed);
    expect(cubit.state.loadError, isNotNull);
    expect(cubit.state.source, isEmpty);

    // Whatever the editor does next must not reach the site's documents: the
    // fields belong to no site, so a save would overwrite the owner's pages.
    cubit.editSourceField('cabin.hero.title', 'Iets');
    await cubit.save();
    expect(repo.sourceDraftSaves, isEmpty);

    await cubit.publishAll();
    expect(repo.publishes, isEmpty);

    // A retry that succeeds puts the site's own content in.
    repo.loadError = null;
    await cubit.loadContent();
    expect(cubit.state.loadStatus, ContentLoadStatus.ready);
    expect(cubit.state.valueFor('nl', 'cabin.hero.title'), 'Titel uit database');
    await cubit.close();
  });

  test(
    'loadContent hydrates source + translations from the repository',
    () async {
      final repo = FakeWebsiteContentRepository(content: _remoteContent());
      final cubit = _build(repo);

      await cubit.loadContent();

      expect(repo.loadCalls, 1);
      expect(cubit.state.valueFor('nl', 'cabin.hero.title'), 'Titel uit database');
      expect(cubit.state.valueFor('en', 'cabin.hero.title'), '[en] cabin.hero.title');
      expect(cubit.state.dirty, isFalse);
      expect(cubit.state.staleLanguages, isEmpty);
      await cubit.close();
    },
  );

  test('editing writes nothing until save is called', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();

    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');

    expect(cubit.state.unsavedChanges, isTrue);
    expect(repo.sourceDraftSaves, isEmpty);

    await cubit.save();

    expect(repo.sourceDraftSaves, hasLength(1));
    expect(repo.sourceDraftSaves.single['cabin.hero.title'], 'Nieuwe titel');
    expect(cubit.state.unsavedChanges, isFalse);
    await cubit.close();
  });

  test('closing the editor does not save silently', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();

    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    await cubit.close();

    expect(repo.sourceDraftSaves, isEmpty);
  });

  test('a failed save keeps the edit pending for a retry', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();

    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    repo.nextSourceDraftError = StateError('offline');
    await cubit.save();

    expect(repo.sourceDraftSaves, isEmpty);
    expect(cubit.state.errorMessage, 'save_failed');
    expect(cubit.state.saving, isFalse);
    expect(cubit.state.unsavedChanges, isTrue);

    await cubit.save();

    expect(repo.sourceDraftSaves, hasLength(1));
    expect(cubit.state.unsavedChanges, isFalse);
    await cubit.close();
  });

  test('a reorder saves the new row order; translations stay put', () async {
    // The handoff's mandatory regression (fase 2, stap 1): drag a row in the
    // source, open the target language — the translations traveled with
    // their row. Persistence-side: the save carries the order, not swapped
    // values.
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();
    expect(cubit.state.listOrder['home.highlights'], ['hA', 'hB']);

    cubit.moveRow('home.highlights', 0, 2);
    await cubit.save();

    // The write is the order; no field values changed hands.
    expect(repo.sourceDraftOrders.single, {
      'home.highlights': ['hB', 'hA'],
    });
    expect(repo.sourceDraftSaves.single['home.highlights.hA.description'],
        'Hoogtepunt A');
    expect(cubit.state.listOrder['home.highlights'], ['hB', 'hA']);
    expect(cubit.state.unsavedChanges, isFalse);

    // Open the target language: the translation still belongs to its row.
    cubit.setPreviewLanguage('en');
    expect(
      cubit.state.valueFor('en', 'home.highlights.hA.description'),
      '[en] home.highlights.hA.description',
    );
    expect(cubit.state.rowIdsOfList('home.highlights'), ['hB', 'hA']);
    await cubit.close();
  });


  test('photo choices are one set for the site, saved into site_config',
      () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();

    cubit.setMediaPaths('images.heroPhotos', [
      'site-1/a.jpg',
      'site-1/b.jpg',
    ]);
    expect(cubit.state.unsavedChanges, isTrue);
    // Nothing is written until the owner saves (par. 11i holds for photos too).
    expect(repo.sourceDraftMedia, isEmpty);

    await cubit.save();

    expect(repo.sourceDraftMedia.single, {
      'images.heroPhotos': ['site-1/a.jpg', 'site-1/b.jpg'],
    });
    expect(cubit.state.mediaKeys['images.heroPhotos'], [
      'site-1/a.jpg',
      'site-1/b.jpg',
    ]);
    expect(cubit.state.unsavedChanges, isFalse);

    // Publishing ships the saved set to every locale's site_config: a photo is
    // language-independent, so no language can end up with its own gallery.
    await cubit.publishAll();
    expect(repo.publishedMedia.single, {
      'images.heroPhotos': ['site-1/a.jpg', 'site-1/b.jpg'],
    });
    await cubit.close();
  });

  test('reordering photos is a change; ordering back is not', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();
    cubit.setMediaPaths('images.heroPhotos', ['a', 'b', 'c']);
    await cubit.save();

    cubit.moveMediaPath('images.heroPhotos', 0, 2);
    expect(cubit.state.mediaPathsOf('images.heroPhotos'), ['b', 'c', 'a']);
    expect(cubit.state.unsavedChanges, isTrue);

    // The first photo is the share image, so this order is content — and
    // putting it back is not a change to save.
    cubit.setMediaPaths('images.heroPhotos', ['a', 'b', 'c']);
    expect(cubit.state.draftMediaKeys, isEmpty);
    expect(cubit.state.unsavedChanges, isFalse);
    await cubit.close();
  });

  test('removing a photo drops only that one', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();
    cubit.setMediaPaths('images.heroPhotos', ['a', 'b', 'c']);

    cubit.removeMediaPath('images.heroPhotos', 1);

    expect(cubit.state.mediaPathsOf('images.heroPhotos'), ['a', 'c']);
    await cubit.close();
  });

  test('translation edits persist as locked rows on save', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();

    cubit.editTranslationField('en', 'cabin.hero.title', 'My headline');
    await cubit.save();

    expect(repo.translationSaves, hasLength(1));
    final (language, key, field) = repo.translationSaves.single;
    expect(language, 'en');
    expect(key, 'cabin.hero.title');
    expect(field.status, FieldTranslationStatus.locked);
    expect(field.value, 'My headline');
    await cubit.close();
  });

  test('publishAll persists all locales into the documents', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();
    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    // Publish ships the saved layer, so there has to be one (§11i).
    await cubit.save();

    await cubit.publishAll();

    expect(repo.publishes, hasLength(1));
    final byLocale = repo.publishes.single;
    expect(byLocale.keys, containsAll(<String>['nl', 'en', 'no']));
    expect(byLocale['nl']!['cabin.hero.title'], 'Nieuwe titel');
    // Targets publish their current (translated) values for every field of
    // every page (the publish scope spans the whole site).
    expect(byLocale['en']!.keys, hasLength(cubit.state.allFields.length));
    expect(cubit.state.dirty, isFalse);
    await cubit.close();
  });

  test(
    'loadContent adopts the site source language and resets the preview',
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
    },
  );

  test(
    'loadContent adopts the preview domain; saving bumps lastSavedAt',
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

      cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
      await cubit.save();

      // The save marked its moment, which the embedded live preview uses as a
      // cache-busting reload key.
      expect(cubit.state.lastSavedAt, isNotNull);
      await cubit.close();
    },
  );

  test('hydrated auto fields go stale when their source changes', () async {
    final repo = FakeWebsiteContentRepository(content: _remoteContent());
    final cubit = _build(repo);
    await cubit.loadContent();
    expect(cubit.state.isLanguageStale('en'), isFalse);

    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    // Staleness is measured against the saved source: the translations still
    // match what was translated from until the edit is committed.
    expect(cubit.state.isFieldStale('en', 'cabin.hero.title'), isFalse);
    await cubit.save();

    // sha256 source hashes survive hydration, so staleness is detected.
    expect(cubit.state.isFieldStale('en', 'cabin.hero.title'), isTrue);
    expect(cubit.state.isFieldStale('en', 'cabin.hero.subtitle'), isFalse);
    await cubit.close();
  });

  group('what a save and a publish write', () {
    // The bug this pins: saving used to write the new copy into `content` and
    // flip `status` to 'draft'. The public site reads `status = published`, so
    // pressing Save took the live page offline until the owner published.
    test('a save touches the draft layer only', () {
      final write = WebsiteContentRepository.documentWrite(
        content: {'hero': 'Nieuwe titel'},
        publish: false,
        userId: 'user-1',
      );

      expect(write['draft_content'], {'hero': 'Nieuwe titel'});
      expect(write.containsKey('content'), isFalse);
      expect(write.containsKey('status'), isFalse);
      expect(write.containsKey('published_at'), isFalse);
    });

    test('a publish promotes the draft and clears it', () {
      final write = WebsiteContentRepository.documentWrite(
        content: {'hero': 'Nieuwe titel'},
        publish: true,
        userId: 'user-1',
      );

      expect(write['content'], {'hero': 'Nieuwe titel'});
      expect(write['draft_content'], isNull);
      expect(write['status'], 'published');
      expect(write['published_at'], isNotNull);
    });

    test('a document created by a save starts unpublished', () {
      final write = WebsiteContentRepository.documentWrite(
        content: {'hero': 'Nieuwe titel'},
        publish: false,
        userId: 'user-1',
        isNewDocument: true,
      );

      // The row needs a content and a status to exist at all, but it must not
      // start out published — that would shadow the site's fallback content
      // with copy nobody published.
      expect(write['status'], 'draft');
      expect(write['content'], {'hero': 'Nieuwe titel'});
      expect(write['draft_content'], {'hero': 'Nieuwe titel'});
    });
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
        WebsiteContentRepository.readField('cabin.hero.title', 'cabin', content),
        'Oude titel',
      );

      WebsiteContentRepository.writeField(
        'cabin.hero.title',
        'cabin',
        content,
        'Nieuwe titel',
      );
      expect((content['hero'] as Map)['title'], 'Nieuwe titel');
      // Sibling keys survive the merge.
      expect((content['hero'] as Map)['subtitle'], 'Oude ondertitel');
      expect((content['meta'] as Map)['name'], 'x');
    });

    test('list rows resolve by their stable id', () {
      final content = <String, dynamic>{
        'description': <dynamic>[
          <String, dynamic>{'id': 'dA', 'text': 'Eerste alinea'},
          <String, dynamic>{'id': 'dB', 'text': 'Tweede alinea'},
        ],
        'houseRules': <String, dynamic>{
          'bullets': <dynamic>[
            <String, dynamic>{'id': 'eA', 'text': 'Ski-in'},
            <String, dynamic>{'id': 'eB', 'text': 'Sauna'},
          ],
        },
      };

      expect(
        WebsiteContentRepository.readField(
          'cabin.description.dA.text',
          'cabin',
          content,
        ),
        'Eerste alinea',
      );
      expect(
        WebsiteContentRepository.readField(
          'cabin.rules.bullets.eB.text',
          'cabin',
          content,
        ),
        'Sauna',
      );

      WebsiteContentRepository.writeField(
        'cabin.rules.bullets.eA.text',
        'cabin',
        content,
        'Nieuw',
      );
      final bullets = (content['houseRules'] as Map)['bullets'] as List;
      expect((bullets[0] as Map)['text'], 'Nieuw');
      expect((bullets[1] as Map)['text'], 'Sauna');
      expect(
        ((content['description'] as List)[0] as Map)['text'],
        'Eerste alinea',
      );
    });

    test('a row keeps its value when the array is reordered', () {
      // The regression the id model exists for: with index-based keys,
      // dragging row 1 to position 3 made the translation of row 1 the
      // translation of row 2.
      final content = <String, dynamic>{
        'highlights': <dynamic>[
          <String, dynamic>{'id': 'hA', 'description': 'Eerste'},
          <String, dynamic>{'id': 'hB', 'description': 'Tweede'},
          <String, dynamic>{'id': 'hC', 'description': 'Derde'},
        ],
      };

      WebsiteContentRepository.applyListOrder(
        'home.highlights',
        content,
        const ['hC', 'hA', 'hB'],
      );

      final rows = content['highlights'] as List;
      expect([for (final r in rows) (r as Map)['id']], ['hC', 'hA', 'hB']);
      // Reads by id are order-independent.
      expect(
        WebsiteContentRepository.readField(
          'home.highlights.hA.description',
          'page',
          content,
        ),
        'Eerste',
      );
      expect(
        WebsiteContentRepository.listRowIdsIn('home.highlights', content),
        ['hC', 'hA', 'hB'],
      );
    });

    test('practical/area/contact fields map to their documents', () {
      final practical = <String, dynamic>{
        'header': <String, dynamic>{'title': 'Praktisch', 'subtitle': 'Sub'},
      };
      expect(
        WebsiteContentRepository.readField(
          'practical.header.title',
          'page',
          practical,
        ),
        'Praktisch',
      );
      WebsiteContentRepository.writeField(
        'practical.header.subtitle',
        'page',
        practical,
        'Nieuwe sub',
      );
      expect((practical['header'] as Map)['subtitle'], 'Nieuwe sub');
      expect((practical['header'] as Map)['title'], 'Praktisch');

      final area = <String, dynamic>{'intro': 'Oud', 'sections': <dynamic>[]};
      WebsiteContentRepository.writeField('area.intro', 'page', area, 'Nieuw');
      expect(area['intro'], 'Nieuw');
      expect(area['sections'], isEmpty);

      final contact = <String, dynamic>{'title': 'T', 'subtitle': 'S'};
      expect(
        WebsiteContentRepository.readField(
          'contact.subtitle',
          'contact_form',
          contact,
        ),
        'S',
      );
      WebsiteContentRepository.writeField(
        'contact.title',
        'contact_form',
        contact,
        'Nieuw',
      );
      expect(contact['title'], 'Nieuw');
    });

    test('a document is only created for fields that carry content', () {
      // Documents the site never provisioned are created on save — but not out
      // of blank fields, which would shadow the site's fallback content with
      // empty headings.
      expect(
        WebsiteContentRepository.fieldsForNewDocument({
          'practical.header.title': 'Praktisch',
          'practical.header.subtitle': '   ',
        }),
        {'practical.header.title': 'Praktisch'},
      );
      expect(
        WebsiteContentRepository.fieldsForNewDocument({'area.intro': ''}),
        isEmpty,
      );
    });

    test('highlight fields map to their row by id, not by position', () {
      final content = <String, dynamic>{
        'highlights': <dynamic>[
          <String, dynamic>{
            'id': 'hA',
            'title': 'Ski-in / ski-out',
            'description': 'Oud',
          },
          <String, dynamic>{
            'id': 'hB',
            'title': 'Sauna',
            'description': 'Ontspan',
          },
        ],
      };

      expect(
        WebsiteContentRepository.readField(
          'home.highlights.hB.description',
          'page',
          content,
        ),
        'Ontspan',
      );

      WebsiteContentRepository.writeField(
        'home.highlights.hA.description',
        'page',
        content,
        'Direct de pistes op',
      );
      final highlights = content['highlights'] as List;
      expect((highlights[0] as Map)['description'], 'Direct de pistes op');
      // Titles are not touched by the editor.
      expect((highlights[0] as Map)['title'], 'Ski-in / ski-out');
    });

    test('a write reaches a path whose containers do not exist yet', () {
      final content = <String, dynamic>{};

      WebsiteContentRepository.writeField(
        'cabin.hero.title',
        'cabin',
        content,
        'Titel',
      );
      WebsiteContentRepository.writeField(
        'cabin.rules.bullets.eZ.text',
        'cabin',
        content,
        'Derde',
      );

      expect((content['hero'] as Map)['title'], 'Titel');
      // A write for an unknown row id appends a fresh, usable row, creating
      // the containers on the way.
      expect((content['houseRules'] as Map)['bullets'], [
        {'id': 'eZ', 'text': 'Derde'},
      ]);
    });

    test('a field key that is not in the mapping is left alone', () {
      final content = <String, dynamic>{'hero': <String, dynamic>{}};

      WebsiteContentRepository.writeField('nope.at.all', 'cabin', content, 'X');
      // Also refuses a real field against the wrong document.
      WebsiteContentRepository.writeField('area.intro', 'cabin', content, 'X');

      expect(content, {'hero': <String, dynamic>{}});
      expect(
        WebsiteContentRepository.readField('area.intro', 'cabin', content),
        isNull,
      );
    });

    test('addresses are what the live preview and the site agree on', () {
      String? addressOf(String fieldKey) =>
          WebsiteContentRepository.locationOf(fieldKey)?.address;

      expect(addressOf('cabin.hero.title'), 'cabin/main:hero.title');
      expect(addressOf('cabin.hero.subtitle'), 'cabin/main:hero.subtitle');
      expect(
        addressOf('cabin.description.dA.text'),
        'cabin/main:description.dA.text',
      );
      // Two nesting levels: a group id and then an item id.
      expect(
        addressOf('cabin.amenities.groups.gA.items.iB.text'),
        'cabin/main:amenities.groups.gA.items.iB.text',
      );
      expect(
        addressOf('home.highlights.a1b2c3d4.description'),
        'page/home:highlights.a1b2c3d4.description',
      );
      expect(
        addressOf('practical.header.title'),
        'page/practical:header.title',
      );
      expect(addressOf('area.intro'), 'page/area:intro');
      expect(addressOf('contact.title'), 'contact_form/main:title');
      expect(addressOf('nope'), isNull);
    });
  });
}
