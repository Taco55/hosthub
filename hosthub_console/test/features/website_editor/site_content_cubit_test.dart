import 'package:flutter_test/flutter_test.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

void main() {
  SiteContentCubit build() =>
      SiteContentCubit(translationService: const SeedTranslationService());

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
      expect(s.valueFor('en', 'hero.headline'), 'Your mountain home in Trysil');
      expect(s.lockedFieldCount('en'), 0);
    });

    test(
      'editing source marks dependent auto fields stale, leaves locked',
      () async {
        final cubit = build();
        // Lock the subtitle in EN so it must survive a source edit.
        cubit.editTranslationField('en', 'hero.subtitle', 'Locked subtitle');

        cubit.editSourceField('hero.headline', 'Nieuwe titel');
        // Staleness follows the *saved* source: what is still in the fields has
        // not been translated from, so it cannot have made anything stale.
        expect(cubit.state.staleLanguages, isEmpty);
        await cubit.save();

        final s = cubit.state;
        expect(s.dirty, isTrue);
        // The auto headline is now stale in every target language.
        expect(s.isFieldStale('en', 'hero.headline'), isTrue);
        expect(s.isFieldStale('no', 'hero.headline'), isTrue);
        expect(s.staleLanguages, containsAll(<String>['en', 'no']));
        // The locked subtitle is never stale.
        expect(s.isFieldStale('en', 'hero.subtitle'), isFalse);
        expect(
          s.translatedField('en', 'hero.subtitle')!.status,
          FieldTranslationStatus.locked,
        );
      },
    );

    test('editing a translation field locks it', () {
      final cubit = build();

      cubit.editTranslationField('en', 'hero.headline', 'My own headline');

      final field = cubit.state.translatedField('en', 'hero.headline')!;
      expect(field.status, FieldTranslationStatus.locked);
      expect(field.value, 'My own headline');
      // Typing is a draft, not a save and not a publishable change.
      expect(cubit.state.unsavedChanges, isTrue);
      expect(cubit.state.dirty, isFalse);
    });

    test('translateNow refreshes only auto fields and clears stale', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'hero.subtitle', 'Locked subtitle');
      cubit.editSourceField('hero.headline', 'Nieuwe titel');
      await cubit.save();
      expect(cubit.state.isLanguageStale('en'), isTrue);

      await cubit.translateNow(['en']);

      final s = cubit.state;
      expect(s.isLanguageStale('en'), isFalse);
      // Locked field kept its owner value.
      expect(s.valueFor('en', 'hero.subtitle'), 'Locked subtitle');
      expect(
        s.translatedField('en', 'hero.subtitle')!.status,
        FieldTranslationStatus.locked,
      );
      // NO was not requested → still stale.
      expect(cubit.state.isLanguageStale('no'), isTrue);
    });

    test(
      'resetFieldToAi reverts a locked field to source-derived auto',
      () async {
        final cubit = build();
        cubit.editTranslationField('en', 'hero.headline', 'Manual override');
        expect(
          cubit.state.translatedField('en', 'hero.headline')!.status,
          FieldTranslationStatus.locked,
        );

        await cubit.resetFieldToAi('en', 'hero.headline');

        final field = cubit.state.translatedField('en', 'hero.headline')!;
        expect(field.status, FieldTranslationStatus.auto);
        expect(field.value, 'Your mountain home in Trysil');
        expect(cubit.state.isFieldStale('en', 'hero.headline'), isFalse);
      },
    );

    test('publishAll clears dirty and stale for all languages', () async {
      final cubit = build();
      cubit.editSourceField('hero.headline', 'Nieuwe titel');
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
      expect(cubit.state.fields, kHomeFields);

      cubit.selectPage('chalet');
      expect(
        cubit.state.fields.map((f) => f.key),
        containsAll(<String>['chalet.description.0', 'chalet.experience.0']),
      );
      expect(
        cubit.state.valueFor('nl', 'chalet.experience.0'),
        'Ski-in/ski-out via de transportpiste.',
      );
      expect(
        cubit.state.valueFor('en', 'chalet.experience.0'),
        'Ski-in/ski-out via the transport track.',
      );
    });

    test('publish scope covers fields of every page', () async {
      final cubit = build();
      // Editing a chalet source field marks EN stale even while Home is open.
      cubit.editSourceField('chalet.experience.0', 'Nieuwe ervaring');
      await cubit.save();
      expect(cubit.state.pageKey, 'home');
      expect(cubit.state.isLanguageStale('en'), isTrue);

      await cubit.publishAll();
      expect(cubit.state.staleLanguages, isEmpty);
    });

    test('addHighlight appends an empty repeatable row in every language', () {
      final cubit = build();
      expect(
        cubit.state.fields.where((f) => f.card == EditorCard.highlights),
        hasLength(2),
      );

      cubit.addHighlight();

      final highlights = cubit.state.fields
          .where((f) => f.card == EditorCard.highlights)
          .toList();
      expect(highlights, hasLength(3));
      expect(cubit.state.valueFor('nl', 'highlights.2'), '');
      expect(
        cubit.state.translatedField('en', 'highlights.2')!.status,
        FieldTranslationStatus.auto,
      );
      expect(cubit.state.unsavedChanges, isTrue);
      // The new empty row is fresh, not stale.
      expect(cubit.state.isFieldStale('en', 'highlights.2'), isFalse);
    });

    test('an added row survives being typed into and emptied again', () {
      // The row only exists in the draft, so "back to the saved value" must not
      // be allowed to delete a key the saved layer never had.
      final cubit = build();
      cubit.addHighlight();

      cubit.editSourceField('highlights.2', 'Iets');
      cubit.editSourceField('highlights.2', '');

      expect(
        cubit.state.fields.where((f) => f.card == EditorCard.highlights),
        hasLength(3),
      );
      expect(cubit.state.unsavedChanges, isTrue);
    });

    test('reorderHighlights moves rows in every language incl. status', () {
      final cubit = build();
      cubit.editTranslationField('en', 'highlights.0', 'Locked first');

      // Drag row 0 below row 1 (ReorderableListView semantics: newIndex is
      // the insertion point before removal).
      cubit.reorderHighlights(0, 2);

      expect(
        cubit.state.valueFor('nl', 'highlights.0'),
        'Ontspan na een dag op de berg.',
      );
      expect(
        cubit.state.valueFor('nl', 'highlights.1'),
        'Direct de Trysilfjellet-pistes op.',
      );
      // The locked EN translation moved along with its row.
      final moved = cubit.state.translatedField('en', 'highlights.1')!;
      expect(moved.value, 'Locked first');
      expect(moved.status, FieldTranslationStatus.locked);
      expect(cubit.state.unsavedChanges, isTrue);
    });

    test('the locked counter is what the lane header reports', () async {
      // §11g: "% translated" can only read 100% once translation is automatic,
      // so the lane counts the fields the owner took over instead.
      final cubit = build();
      expect(cubit.state.lockedFieldCount('en'), 0);
      expect(cubit.state.translatableFieldCount, greaterThan(0));

      cubit.editTranslationField('en', 'hero.headline', 'Mine');
      expect(cubit.state.lockedFieldCount('en'), 1);

      // Editing the source makes a field stale; it does not make it "not
      // yours" — the counter is about ownership, not freshness.
      cubit.editSourceField('hero.subtitle', 'Nieuwe ondertitel');
      await cubit.save();
      expect(cubit.state.lockedFieldCount('en'), 1);
      expect(cubit.state.isLanguageStale('en'), isTrue);
    });

    test('switching a field back to automatic is undoable, once', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'hero.headline', 'Manual override');
      expect(cubit.state.pendingAutoSwitch, isNull);

      await cubit.resetFieldToAi('en', 'hero.headline');
      expect(cubit.state.pendingAutoSwitch?.previousValue, 'Manual override');
      expect(
        cubit.state.translatedField('en', 'hero.headline')!.status,
        FieldTranslationStatus.auto,
      );

      cubit.undoAutoSwitch();
      final restored = cubit.state.translatedField('en', 'hero.headline')!;
      expect(restored.value, 'Manual override');
      expect(restored.status, FieldTranslationStatus.locked);
      // One undo only: it is spent, not a history.
      expect(cubit.state.pendingAutoSwitch, isNull);
    });

    test('the undo does not survive leaving the field behind', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'hero.headline', 'Manual override');
      await cubit.resetFieldToAi('en', 'hero.headline');
      expect(cubit.state.pendingAutoSwitch, isNotNull);

      cubit.setPreviewLanguage('nl');
      expect(cubit.state.pendingAutoSwitch, isNull);
    });

    test('opening a stale language translates it, without a button', () async {
      // §11a: translation is lazy — on open, and on publish. There is no
      // trigger to press, and no eager translate on every source save.
      final cubit = build();
      cubit.editSourceField('hero.headline', 'Nieuwe titel');
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
      cubit.editSourceField('hero.headline', 'Nieuwe titel');
      await cubit.save();
      expect(cubit.state.staleLanguages, {'en', 'no'});
      expect(cubit.state.reviewedLanguages, isEmpty);

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
      final before = cubit.state.valueFor('en', 'hero.subtitle');

      cubit.lockField('en', 'hero.subtitle');

      final field = cubit.state.translatedField('en', 'hero.subtitle')!;
      expect(field.status, FieldTranslationStatus.locked);
      expect(field.value, before);
    });
  });

  group('SiteContentCubit — explicit save (§11i)', () {
    test('editField writes the draft only and leaves saved untouched', () {
      final cubit = build();
      final savedSource = cubit.state.source['hero.headline'];

      cubit.editSourceField('hero.headline', 'Half getypte zin');
      cubit.editTranslationField('en', 'hero.subtitle', 'Half typed line');

      final s = cubit.state;
      // What the fields show.
      expect(s.valueFor('nl', 'hero.headline'), 'Half getypte zin');
      expect(s.valueFor('en', 'hero.subtitle'), 'Half typed line');
      // What publish and translation would read.
      expect(s.source['hero.headline'], savedSource);
      expect(s.savedValueFor('en', 'hero.subtitle'), isNot('Half typed line'));
      expect(
        s.savedTranslatedField('en', 'hero.subtitle')!.status,
        FieldTranslationStatus.auto,
      );
      expect(s.unsavedChanges, isTrue);
      expect(s.dirty, isFalse);
    });

    test('typing a value back to the saved one is not an unsaved change', () {
      final cubit = build();
      final saved = cubit.state.source['hero.headline']!;

      cubit.editSourceField('hero.headline', 'Iets anders');
      expect(cubit.state.unsavedChanges, isTrue);

      cubit.editSourceField('hero.headline', saved);
      expect(cubit.state.unsavedChanges, isFalse);
    });

    test(
      'save merges the draft into saved, clears it and sets dirty',
      () async {
        final cubit = build();
        cubit.editSourceField('hero.headline', 'Nieuwe titel');
        cubit.editTranslationField('en', 'hero.subtitle', 'Mine');

        await cubit.save();

        final s = cubit.state;
        expect(s.unsavedChanges, isFalse);
        expect(s.draftSource, isEmpty);
        expect(s.draftTranslations, isEmpty);
        expect(s.source['hero.headline'], 'Nieuwe titel');
        expect(s.savedValueFor('en', 'hero.subtitle'), 'Mine');
        expect(
          s.savedTranslatedField('en', 'hero.subtitle')!.status,
          FieldTranslationStatus.locked,
        );
        expect(s.dirty, isTrue);
        expect(s.saving, isFalse);
        expect(s.lastSavedAt, isNotNull);
      },
    );

    test('saving one language also commits a draft left in another', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'hero.headline', 'English draft');
      cubit.setPreviewLanguage('no');
      cubit.editTranslationField('no', 'hero.headline', 'Norsk utkast');

      await cubit.save();

      expect(cubit.state.unsavedChanges, isFalse);
      expect(cubit.state.savedValueFor('en', 'hero.headline'), 'English draft');
      expect(cubit.state.savedValueFor('no', 'hero.headline'), 'Norsk utkast');
    });

    test('discard drops the draft for every language', () {
      final cubit = build();
      final savedHeadline = cubit.state.valueFor('nl', 'hero.headline');
      final savedEnglish = cubit.state.valueFor('en', 'hero.headline');
      cubit.editSourceField('hero.headline', 'Weg hiermee');
      cubit.editTranslationField('en', 'hero.headline', 'Gone');
      cubit.editTranslationField('no', 'hero.subtitle', 'Borte');

      cubit.discardDraft();

      final s = cubit.state;
      expect(s.unsavedChanges, isFalse);
      expect(s.valueFor('nl', 'hero.headline'), savedHeadline);
      expect(s.valueFor('en', 'hero.headline'), savedEnglish);
      expect(
        s.translatedField('en', 'hero.headline')!.status,
        FieldTranslationStatus.auto,
      );
      expect(s.dirty, isFalse);
    });

    test('publish is rejected while a draft exists', () async {
      final cubit = build();
      cubit.editSourceField('hero.headline', 'Nog niet af');

      cubit.openPublish();
      expect(cubit.state.publishOpen, isFalse);

      await cubit.publishAll();

      // Nothing shipped, nothing saved on the owner's behalf.
      expect(cubit.state.unsavedChanges, isTrue);
      expect(cubit.state.source['hero.headline'], isNot('Nog niet af'));
      expect(cubit.state.lastSavedAt, isNull);
    });

    test('translation reads the saved layer, never the draft', () async {
      final cubit = build();
      // A draft in EN must not be overwritten by machine output, and the source
      // it would be translated from is the saved text, not what is being typed.
      cubit.editTranslationField('en', 'hero.headline', 'My own headline');
      cubit.editSourceField('hero.subtitle', 'Half getypte ondertitel');

      await cubit.translateNow(['en']);

      expect(cubit.state.valueFor('en', 'hero.headline'), 'My own headline');
      expect(
        cubit.state.savedValueFor('en', 'hero.subtitle'),
        isNot(contains('Half getypte')),
      );
    });
  });
}
