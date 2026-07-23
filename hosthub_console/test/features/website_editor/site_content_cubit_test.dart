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
      expect(s.staleLanguages, isEmpty);
      expect(s.valueFor('en', 'hero.headline'), 'Your mountain home in Trysil');
      expect(s.coverage('en'), 1.0);
    });

    test('editing source marks dependent auto fields stale, leaves locked', () {
      final cubit = build();
      // Lock the subtitle in EN so it must survive a source edit.
      cubit.editTranslationField('en', 'hero.subtitle', 'Locked subtitle');

      cubit.editSourceField('hero.headline', 'Nieuwe titel');

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
    });

    test('editing a translation field locks it', () {
      final cubit = build();

      cubit.editTranslationField('en', 'hero.headline', 'My own headline');

      final field = cubit.state.translatedField('en', 'hero.headline')!;
      expect(field.status, FieldTranslationStatus.locked);
      expect(field.value, 'My own headline');
      expect(cubit.state.dirty, isTrue);
    });

    test('translateNow refreshes only auto fields and clears stale', () async {
      final cubit = build();
      cubit.editTranslationField('en', 'hero.subtitle', 'Locked subtitle');
      cubit.editSourceField('hero.headline', 'Nieuwe titel');
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

    test('resetFieldToAi reverts a locked field to source-derived auto',
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
    });

    test('publishAll clears dirty and stale for all languages', () async {
      final cubit = build();
      cubit.editSourceField('hero.headline', 'Nieuwe titel');
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
      expect(cubit.state.valueFor('nl', 'chalet.experience.0'),
          'Ski-in/ski-out via de transportpiste.');
      expect(cubit.state.valueFor('en', 'chalet.experience.0'),
          'Ski-in/ski-out via the transport track.');
    });

    test('publish scope covers fields of every page', () async {
      final cubit = build();
      // Editing a chalet source field marks EN stale even while Home is open.
      cubit.editSourceField('chalet.experience.0', 'Nieuwe ervaring');
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
      expect(cubit.state.dirty, isTrue);
      // The new empty row is fresh, not stale.
      expect(cubit.state.isFieldStale('en', 'highlights.2'), isFalse);
    });

    test('reorderHighlights moves rows in every language incl. status', () {
      final cubit = build();
      cubit.editTranslationField('en', 'highlights.0', 'Locked first');

      // Drag row 0 below row 1 (ReorderableListView semantics: newIndex is
      // the insertion point before removal).
      cubit.reorderHighlights(0, 2);

      expect(cubit.state.valueFor('nl', 'highlights.0'),
          'Ontspan na een dag op de berg.');
      expect(cubit.state.valueFor('nl', 'highlights.1'),
          'Direct de Trysilfjellet-pistes op.');
      // The locked EN translation moved along with its row.
      final moved = cubit.state.translatedField('en', 'highlights.1')!;
      expect(moved.value, 'Locked first');
      expect(moved.status, FieldTranslationStatus.locked);
      expect(cubit.state.dirty, isTrue);
    });

    test('coverage drops when a field goes stale', () {
      final cubit = build();
      expect(cubit.state.coverage('en'), 1.0);

      cubit.editSourceField('hero.headline', 'Nieuwe titel');

      // One of four fields is now stale.
      expect(cubit.state.coverage('en'), closeTo(0.75, 0.0001));
    });
  });
}
