import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// Repository whose load always fails the way the real one does: with a mapped
/// [DomainError]. The client is never touched.
class _FailingLoadRepository extends WebsiteContentRepository {
  _FailingLoadRepository()
    : super(
        supabase: SupabaseClient(
          'http://localhost:7011',
          'sb_publishable_test',
        ),
      );

  @override
  Future<WebsitePageContent> loadPageContent({
    required String siteId,
    required String sourceLanguage,
    required List<String> locales,
  }) async => throw DomainErrorCode.unknown.err(
    reason: DomainErrorReason.cannotLoadData,
    message: 'boom',
  );
}

String Function() _sequentialIds() {
  var next = 0;
  return () => 'r${++next}';
}

void main() {
  SiteContentCubit build() => SiteContentCubit(
    translationService: const SeedTranslationService(),
    // Deterministic ids: the first row added in a test is always 'r1'.
    rowIdGenerator: _sequentialIds(),
  );

  group('SiteContentCubit', () {
    test('seeds a published, source-mode state with fresh translations', () {
      final cubit = build();
      final s = cubit.state;

      expect(s.sourceLanguage, 'nl');
      expect(s.previewLanguage, 'nl');
      expect(s.isSourceMode, isTrue);
      expect(s.dirty, isFalse);
      expect(s.unsavedChanges, isFalse);
      expect(s.staleLanguages, isEmpty);
      expect(
        s.valueFor('en', 'cabin.hero.title'),
        'Your mountain home in Trysil',
      );
      expect(s.lockedFieldCount('en'), 0);
    });

    test(
      'editing source marks dependent auto fields stale, leaves locked',
      () async {
        final cubit = build();
        // Lock the subtitle in EN so it must survive a source edit.
        cubit.editTranslationField(
          'en',
          'cabin.hero.subtitle',
          'Locked subtitle',
        );

        cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
        // Staleness follows the *saved* source: what is still in the fields has
        // not been translated from, so it cannot have made anything stale.
        expect(cubit.state.staleLanguages, isEmpty);
        await cubit.save();

        final s = cubit.state;
        expect(s.dirty, isTrue);
        // The auto headline is now stale in every target language.
        expect(s.isFieldStale('en', 'cabin.hero.title'), isTrue);
        expect(s.isFieldStale('no', 'cabin.hero.title'), isTrue);
        expect(s.staleLanguages, containsAll(<String>['en', 'no']));
        // The locked subtitle is never stale.
        expect(s.isFieldStale('en', 'cabin.hero.subtitle'), isFalse);
        expect(
          s.translatedField('en', 'cabin.hero.subtitle')!.status,
          FieldTranslationStatus.locked,
        );
      },
    );

    test('editing a translation field locks it', () {
      final cubit = build();

      cubit.editTranslationField('en', 'cabin.hero.title', 'My own headline');

      final field = cubit.state.translatedField('en', 'cabin.hero.title')!;
      expect(field.status, FieldTranslationStatus.locked);
      expect(field.value, 'My own headline');
      // Typing is a draft, not a save and not a publishable change.
      expect(cubit.state.unsavedChanges, isTrue);
      expect(cubit.state.dirty, isFalse);
    });

    test('translateNow refreshes only auto fields and clears stale', () async {
      final cubit = build();
      cubit.editTranslationField(
        'en',
        'cabin.hero.subtitle',
        'Locked subtitle',
      );
      cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
      await cubit.save();
      expect(cubit.state.isLanguageStale('en'), isTrue);

      await cubit.translateNow(['en']);

      final s = cubit.state;
      expect(s.isLanguageStale('en'), isFalse);
      // Locked field kept its owner value.
      expect(s.valueFor('en', 'cabin.hero.subtitle'), 'Locked subtitle');
      expect(
        s.translatedField('en', 'cabin.hero.subtitle')!.status,
        FieldTranslationStatus.locked,
      );
      // NO was not requested → still stale.
      expect(cubit.state.isLanguageStale('no'), isTrue);
    });

    test(
      'resetFieldToAi reverts a locked field to source-derived auto',
      () async {
        final cubit = build();
        cubit.editTranslationField('en', 'cabin.hero.title', 'Manual override');
        expect(
          cubit.state.translatedField('en', 'cabin.hero.title')!.status,
          FieldTranslationStatus.locked,
        );

        await cubit.resetFieldToAi('en', 'cabin.hero.title');

        final field = cubit.state.translatedField('en', 'cabin.hero.title')!;
        expect(field.status, FieldTranslationStatus.auto);
        expect(field.value, 'Your mountain home in Trysil');
        expect(cubit.state.isFieldStale('en', 'cabin.hero.title'), isFalse);
      },
    );

    test('publishAll clears dirty and stale for all languages', () async {
      final cubit = build();
      cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
      await cubit.save();
      expect(cubit.state.dirty, isTrue);
      expect(cubit.state.staleLanguages, isNotEmpty);

      await cubit.publishAll();

      expect(cubit.state.dirty, isFalse);
      expect(cubit.state.staleLanguages, isEmpty);
      expect(cubit.state.publishOpen, isFalse);
    });

    test('switching preview language toggles source/translation mode', () {
      final cubit = build();
      expect(cubit.state.isSourceMode, isTrue);

      cubit.setPreviewLanguage('en');
      expect(cubit.state.isSourceMode, isFalse);

      cubit.setPreviewLanguage('nl');
      expect(cubit.state.isSourceMode, isTrue);
    });

    test('selecting a page exposes that page\'s fields', () {
      final cubit = build();
      // Home carries the chalet description/experience and contact fields:
      // that content renders on the homepage (fase 2 §0).
      expect(
        cubit.state.fields.map((f) => f.key),
        containsAll(<String>[
          'cabin.hero.title',
          'home.highlights.h1.description',
          'cabin.description.d1.text',
          'contact.title',
        ]),
      );
      expect(
        cubit.state.valueFor('nl', 'cabin.description.d1.text'),
        startsWith('Vrijstaand chalet in Fageråsen'),
      );

      cubit.selectPage('practical');
      expect(
        cubit.state.fields.map((f) => f.key),
        containsAll(<String>[
          'practical.header.title',
          'practical.header.subtitle',
        ]),
      );
      // Home's fields are not on Practical.
      expect(
        cubit.state.fields.map((f) => f.key),
        isNot(contains('cabin.hero.title')),
      );
    });

    test('publish scope covers fields of every page', () async {
      final cubit = build();
      // Editing an off-page source field marks EN stale while Home is open.
      cubit.editSourceField('practical.header.title', 'Nieuwe kop');
      await cubit.save();
      expect(cubit.state.pageKey, 'home');
      expect(cubit.state.isLanguageStale('en'), isTrue);

      await cubit.publishAll();
      expect(cubit.state.staleLanguages, isEmpty);
    });

    test('addRow appends an empty repeatable row in every language', () {
      final cubit = build();
      expect(cubit.state.rowIdsOfList('home.highlights'), hasLength(2));

      cubit.addRow('home.highlights');

      expect(cubit.state.rowIdsOfList('home.highlights'), hasLength(3));
      expect(cubit.state.valueFor('nl', 'home.highlights.r1.description'), '');
      expect(
        cubit.state
            .translatedField('en', 'home.highlights.r1.description')!
            .status,
        FieldTranslationStatus.auto,
      );
      expect(cubit.state.unsavedChanges, isTrue);
      // The new empty row is fresh, not stale.
      expect(
        cubit.state.isFieldStale('en', 'home.highlights.r1.description'),
        isFalse,
      );
    });

    test('an added row survives being typed into and emptied again', () {
      // The row only exists in the draft, so "back to the saved value" must not
      // be allowed to delete a key the saved layer never had.
      final cubit = build();
      cubit.addRow('home.highlights');

      cubit.editSourceField('home.highlights.r1.description', 'Iets');
      cubit.editSourceField('home.highlights.r1.description', '');

      expect(cubit.state.rowIdsOfList('home.highlights'), hasLength(3));
      expect(cubit.state.unsavedChanges, isTrue);
    });

    test('moveRow changes the order; every value travels with its row id', () {
      // The regression stable ids exist for (fase 2 §0.2): with index-based
      // keys, dragging row 1 elsewhere handed its translation to row 2.
      final cubit = build();
      cubit.editTranslationField(
        'en',
        'home.highlights.h1.description',
        'Locked first',
      );

      // Drag row 0 below row 1 (ReorderableListView semantics: newIndex is
      // the insertion point before removal).
      cubit.moveRow('home.highlights', 0, 2);

      // The display order changed…
      expect(cubit.state.effectiveListOrder['home.highlights'], ['h2', 'h1']);
      expect(cubit.state.rowIdsOfList('home.highlights'), ['h2', 'h1']);
      // …and nothing else: source text and the locked EN translation are
      // keyed by the row's id and traveled with it.
      expect(
        cubit.state.valueFor('nl', 'home.highlights.h1.description'),
        'Direct de Trysilfjellet-pistes op.',
      );
      final moved = cubit.state.translatedField(
        'en',
        'home.highlights.h1.description',
      )!;
      expect(moved.value, 'Locked first');
      expect(moved.status, FieldTranslationStatus.locked);
      expect(cubit.state.unsavedChanges, isTrue);
    });

    test('ordering back to the saved order clears the draft', () {
      final cubit = build();
      cubit.moveRow('home.highlights', 0, 2);
      expect(cubit.state.unsavedChanges, isTrue);

      cubit.moveRow('home.highlights', 1, 0);
      expect(cubit.state.draftListOrder, isEmpty);
      expect(cubit.state.unsavedChanges, isFalse);
    });

    test('the locked counter is what the lane header reports', () async {
      // §11g: "% translated" can only read 100% once translation is automatic,
      // so the lane counts the fields the owner took over instead.
      final cubit = build();
      expect(cubit.state.lockedFieldCount('en'), 0);
      expect(cubit.state.translatableFieldCount, greaterThan(0));

      cubit.editTranslationField('en', 'cabin.hero.title', 'Mine');
      expect(cubit.state.lockedFieldCount('en'), 1);

      // Editing the source makes a field stale; it does not make it "not
      // yours" — the counter is about ownership, not freshness.
      cubit.editSourceField('cabin.hero.subtitle', 'Nieuwe ondertitel');
      await cubit.save();
      expect(cubit.state.lockedFieldCount('en'), 1);
      expect(cubit.state.isLanguageStale('en'), isTrue);
    });

    test('switching a field back to automatic is undoable, once', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'cabin.hero.title', 'Manual override');
      expect(cubit.state.pendingAutoSwitch, isNull);

      await cubit.resetFieldToAi('en', 'cabin.hero.title');
      expect(cubit.state.pendingAutoSwitch?.previousValue, 'Manual override');
      expect(
        cubit.state.translatedField('en', 'cabin.hero.title')!.status,
        FieldTranslationStatus.auto,
      );

      cubit.undoAutoSwitch();
      final restored = cubit.state.translatedField('en', 'cabin.hero.title')!;
      expect(restored.value, 'Manual override');
      expect(restored.status, FieldTranslationStatus.locked);
      // One undo only: it is spent, not a history.
      expect(cubit.state.pendingAutoSwitch, isNull);
    });

    test('the undo does not survive leaving the field behind', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'cabin.hero.title', 'Manual override');
      await cubit.resetFieldToAi('en', 'cabin.hero.title');
      expect(cubit.state.pendingAutoSwitch, isNotNull);

      cubit.setPreviewLanguage('nl');
      expect(cubit.state.pendingAutoSwitch, isNull);
    });

    test('opening a stale language translates it, without a button', () async {
      // §11a: translation is lazy — on open, and on publish. There is no
      // trigger to press, and no eager translate on every source save.
      final cubit = build();
      cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
      await cubit.save();
      expect(cubit.state.isLanguageStale('en'), isTrue);

      cubit.setPreviewLanguage('en');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isLanguageStale('en'), isFalse);
      // The language nobody opened is left alone until publish.
      expect(cubit.state.isLanguageStale('no'), isTrue);
    });

    test('publish translates the languages nobody opened', () async {
      // §11a is two halves: on open, *and* on publish for the languages the
      // owner never opened. Without the second half you can publish a language
      // that is stale or empty.
      final cubit = build();
      cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
      await cubit.save();
      expect(cubit.state.staleLanguages, {'en', 'no'});
      expect(cubit.state.reviewedPages, isEmpty);

      await cubit.publishAll();

      expect(cubit.state.staleLanguages, isEmpty);
      expect(cubit.state.dirty, isFalse);
    });

    test('opening a language that is already current costs nothing', () async {
      final cubit = build();
      expect(cubit.state.isLanguageStale('en'), isFalse);

      cubit.setPreviewLanguage('en');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.translating, isEmpty);
    });

    test('locking keeps the text and stops re-translation touching it', () {
      final cubit = build();
      final before = cubit.state.valueFor('en', 'cabin.hero.subtitle');

      cubit.lockField('en', 'cabin.hero.subtitle');

      final field = cubit.state.translatedField('en', 'cabin.hero.subtitle')!;
      expect(field.status, FieldTranslationStatus.locked);
      expect(field.value, before);
    });
  });

  group('SiteContentCubit — explicit save (§11i)', () {
    test('editField writes the draft only and leaves saved untouched', () {
      final cubit = build();
      final savedSource = cubit.state.source['cabin.hero.title'];

      cubit.editSourceField('cabin.hero.title', 'Half getypte zin');
      cubit.editTranslationField(
        'en',
        'cabin.hero.subtitle',
        'Half typed line',
      );

      final s = cubit.state;
      // What the fields show.
      expect(s.valueFor('nl', 'cabin.hero.title'), 'Half getypte zin');
      expect(s.valueFor('en', 'cabin.hero.subtitle'), 'Half typed line');
      // What publish and translation would read.
      expect(s.source['cabin.hero.title'], savedSource);
      expect(
        s.savedValueFor('en', 'cabin.hero.subtitle'),
        isNot('Half typed line'),
      );
      expect(
        s.savedTranslatedField('en', 'cabin.hero.subtitle')!.status,
        FieldTranslationStatus.auto,
      );
      expect(s.unsavedChanges, isTrue);
      expect(s.dirty, isFalse);
    });

    test('typing a value back to the saved one is not an unsaved change', () {
      final cubit = build();
      final saved = cubit.state.source['cabin.hero.title']!;

      cubit.editSourceField('cabin.hero.title', 'Iets anders');
      expect(cubit.state.unsavedChanges, isTrue);

      cubit.editSourceField('cabin.hero.title', saved);
      expect(cubit.state.unsavedChanges, isFalse);
    });

    test(
      'save merges the draft into saved, clears it and sets dirty',
      () async {
        final cubit = build();
        cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
        cubit.editTranslationField('en', 'cabin.hero.subtitle', 'Mine');

        await cubit.save();

        final s = cubit.state;
        expect(s.unsavedChanges, isFalse);
        expect(s.draftSource, isEmpty);
        expect(s.draftTranslations, isEmpty);
        expect(s.source['cabin.hero.title'], 'Nieuwe titel');
        expect(s.savedValueFor('en', 'cabin.hero.subtitle'), 'Mine');
        expect(
          s.savedTranslatedField('en', 'cabin.hero.subtitle')!.status,
          FieldTranslationStatus.locked,
        );
        expect(s.dirty, isTrue);
        expect(s.saving, isFalse);
        expect(s.lastSavedAt, isNotNull);
      },
    );

    test('saving one language also commits a draft left in another', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'cabin.hero.title', 'English draft');
      cubit.setPreviewLanguage('no');
      cubit.editTranslationField('no', 'cabin.hero.title', 'Norsk utkast');

      await cubit.save();

      expect(cubit.state.unsavedChanges, isFalse);
      expect(
        cubit.state.savedValueFor('en', 'cabin.hero.title'),
        'English draft',
      );
      expect(
        cubit.state.savedValueFor('no', 'cabin.hero.title'),
        'Norsk utkast',
      );
    });

    test('discard drops the draft for every language', () {
      final cubit = build();
      final savedHeadline = cubit.state.valueFor('nl', 'cabin.hero.title');
      final savedEnglish = cubit.state.valueFor('en', 'cabin.hero.title');
      cubit.editSourceField('cabin.hero.title', 'Weg hiermee');
      cubit.editTranslationField('en', 'cabin.hero.title', 'Gone');
      cubit.editTranslationField('no', 'cabin.hero.subtitle', 'Borte');

      cubit.discardDraft();

      final s = cubit.state;
      expect(s.unsavedChanges, isFalse);
      expect(s.valueFor('nl', 'cabin.hero.title'), savedHeadline);
      expect(s.valueFor('en', 'cabin.hero.title'), savedEnglish);
      expect(
        s.translatedField('en', 'cabin.hero.title')!.status,
        FieldTranslationStatus.auto,
      );
      expect(s.dirty, isFalse);
    });

    test('publish is rejected while a draft exists', () async {
      final cubit = build();
      cubit.editSourceField('cabin.hero.title', 'Nog niet af');

      cubit.openPublish();
      expect(cubit.state.publishOpen, isFalse);

      await cubit.publishAll();

      // Nothing shipped, nothing saved on the owner's behalf.
      expect(cubit.state.unsavedChanges, isTrue);
      expect(cubit.state.source['cabin.hero.title'], isNot('Nog niet af'));
      expect(cubit.state.lastSavedAt, isNull);
    });

    test('translation reads the saved layer, never the draft', () async {
      final cubit = build();
      // A draft in EN must not be overwritten by machine output, and the source
      // it would be translated from is the saved text, not what is being typed.
      cubit.editTranslationField('en', 'cabin.hero.title', 'My own headline');
      cubit.editSourceField('cabin.hero.subtitle', 'Half getypte ondertitel');

      await cubit.translateNow(['en']);

      expect(cubit.state.valueFor('en', 'cabin.hero.title'), 'My own headline');
      expect(
        cubit.state.savedValueFor('en', 'cabin.hero.subtitle'),
        isNot(contains('Half getypte')),
      );
    });
  });

  group('SiteContentCubit — load failure', () {
    test('surfaces a DomainError, not a toast message', () async {
      final cubit = SiteContentCubit(
        translationService: const SeedTranslationService(),
        repository: _FailingLoadRepository(),
        siteId: 'site-1',
      );

      await cubit.loadContent();

      final error = cubit.state.loadError;
      expect(error, isNotNull);
      expect(error!.reason, DomainErrorReason.cannotLoadData);
      // A failed load is blocking; it must not degrade into the toast lane.
      expect(cubit.state.errorMessage, isNull);

      cubit.clearLoadError();
      expect(cubit.state.loadError, isNull);
    });
  });

  group('translation mode at scale (par. B.4 / D.1)', () {
    test('the changed count is derived from the schema, never from keys', () {
      final cubit = build();
      cubit.setPreviewLanguage('en');
      // A key nobody has a field for — a leftover from an earlier schema, or
      // a document key the editor does not expose. It must not be reviewable:
      // the owner cannot see it, so it cannot be counted.
      cubit.editSourceField('ghost.key.nobody.renders', 'Spook');

      expect(
        cubit.state.allFields.any((f) => f.key == 'ghost.key.nobody.renders'),
        isFalse,
      );
      expect(cubit.state.changedFieldCount('en'), 0);
      expect(cubit.state.changedCountForCard('en', 'hero'), 0);
    });

    test('a card rollup counts only its own fields', () {
      final cubit = build();
      cubit.setPreviewLanguage('en');
      cubit.editSourceField('cabin.hero.subtitle', 'Nieuwe ondertitel');
      // Saving is what makes a translation stale (par. 11i).
      cubit.save();

      expect(cubit.state.changedCountForCard('en', 'hero'), 1);
      expect(cubit.state.changedCountForCard('en', 'highlights'), 0);
      expect(cubit.state.changedFieldCount('en'), 1);
    });

    test('structure actions refuse to run outside the source language', () {
      final cubit = build();
      cubit.setPreviewLanguage('en');

      // par. B.4: structure belongs to the source. The UI turns these off, but
      // the rule lives on the cubit — a convention that only exists in a
      // widget is one refactor away from being gone.
      expect(() => cubit.addRow('home.highlights'), throwsAssertionError);
      expect(
        () => cubit.moveRow('home.highlights', 0, 2),
        throwsAssertionError,
      );
      expect(
        () => cubit.removeRowById('home.highlights', 'h1'),
        throwsAssertionError,
      );
    });

    test('the filter is off until something turns it on', () {
      final cubit = build();
      expect(cubit.state.onlyChangedFields, isFalse);

      cubit.setOnlyChangedFields(true);
      expect(cubit.state.onlyChangedFields, isTrue);

      // With nothing changed, an on filter empties the lane rather than
      // leaving card heads behind (CONFORMANCE par. 5).
      cubit.setPreviewLanguage('en');
      expect(cubit.state.changedFieldCount('en'), 0);
      expect(cubit.state.visibleCards, isEmpty);

      cubit.setOnlyChangedFields(false);
      expect(cubit.state.visibleCards, isNotEmpty);
    });

    test('a row added in the source is new in every target, never locked', () {
      final cubit = build();
      cubit.addRow('home.highlights');
      final rowId = cubit.state.rowIdsOfList('home.highlights').last;
      final key = 'home.highlights.$rowId.description';
      cubit.editSourceField(key, 'Een nieuw hoogtepunt');

      for (final language in cubit.state.targetLanguages) {
        expect(cubit.state.isFieldNew(language, key), isTrue);
        expect(
          cubit.state.translatedField(language, key)!.status,
          FieldTranslationStatus.auto,
        );
      }
      // And it is what the counters count.
      expect(cubit.state.changedFieldCount('en'), greaterThan(0));
    });
  });

  group('publishing at scale (par. D.2)', () {
    test('changed counts what publish will put on the live pages', () {
      final cubit = build();
      // Nothing published-vs-saved differs yet: the seed is what is live.
      expect(cubit.state.changedFieldCount('en'), 0);
      expect(cubit.state.changedPages('en'), isEmpty);

      cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
      cubit.save();

      // The English auto field is stale, so publish will rewrite it: that is a
      // change to the live English page even though nobody typed in it.
      expect(cubit.state.changedFieldCount('en'), 1);
      expect(cubit.state.changedPages('en'), ['home']);

      // Re-translating refreshes the wording; the live page still shows the
      // old text, so the delta stays. A counter a background job can reset
      // answers no question.
      cubit.translateNow(['en']);
      expect(cubit.state.changedFieldCount('en'), 1);
    });

    test('reviewing is page-granular', () async {
      // The test the design calls for (CONFORMANCE par. 10.6): change a field
      // on Practical, open EN on Home only, and EN must not read as reviewed.
      final cubit = build();
      cubit.editSourceField('practical.header.title', 'Nieuwe kop');
      await cubit.save();

      expect(cubit.state.changedPages('en'), ['practical']);

      cubit.setPreviewLanguage('en');
      expect(cubit.state.pageKey, 'home');
      expect(cubit.state.isLanguageReviewed('en'), isFalse);
      expect(cubit.state.reviewedChangedPageCount('en'), 0);

      cubit.selectPage('practical');
      expect(cubit.state.isLanguageReviewed('en'), isTrue);
      expect(cubit.state.reviewedChangedPageCount('en'), 1);
    });

    test('a partly reviewed language says how far it got', () async {
      final cubit = build();
      cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
      cubit.editSourceField('practical.header.title', 'Nieuwe kop');
      await cubit.save();
      expect(cubit.state.changedPages('en'), ['home', 'practical']);

      cubit.setPreviewLanguage('en');
      expect(cubit.state.reviewedChangedPageCount('en'), 1);
      expect(cubit.state.isLanguageReviewed('en'), isFalse);
    });

    test('Openen lands in the language, the page, and the filter', () {
      final cubit = build();
      expect(cubit.state.onlyChangedFields, isFalse);

      cubit.openReview('en', 'practical');

      expect(cubit.state.previewLanguage, 'en');
      expect(cubit.state.pageKey, 'practical');
      expect(cubit.state.onlyChangedFields, isTrue);
      // Landing there is reviewing that page.
      expect(cubit.state.reviewedPages['en'], contains('practical'));
    });

    test(
      'publishing moves the baseline; a skipped language keeps its own',
      () async {
        final cubit = build();
        cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
        await cubit.save();
        expect(cubit.state.changedFieldCount('en'), 1);
        expect(cubit.state.changedFieldCount('no'), 1);

        await cubit.publishAll(skipLanguages: {'no'});

        // What went out is live now, so its delta is empty; the language that
        // stayed behind still has something waiting, because its pages did not
        // change either.
        expect(cubit.state.changedFieldCount('en'), 0);
        expect(cubit.state.changedFieldCount('no'), 1);
        await cubit.close();
      },
    );
  });
}
