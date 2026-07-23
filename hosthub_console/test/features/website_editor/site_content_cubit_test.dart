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

    test('coverage drops when a field goes stale', () {
      final cubit = build();
      expect(cubit.state.coverage('en'), 1.0);

      cubit.editSourceField('hero.headline', 'Nieuwe titel');

      // One of four fields is now stale.
      expect(cubit.state.coverage('en'), closeTo(0.75, 0.0001));
    });
  });
}
