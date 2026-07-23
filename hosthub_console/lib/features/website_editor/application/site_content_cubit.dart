import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/translation_service.dart';
import '../domain/website_content.dart';

/// Preview device frame.
enum PreviewDevice { web, mobile }

/// State for the website editor: the source content, per-language translations
/// (each field `auto`/`locked` with a source hash), and preview UI state.
class SiteContentState extends Equatable {
  const SiteContentState({
    required this.propertyName,
    required this.sourceLanguage,
    required this.locales,
    required this.pageKey,
    required this.previewLanguage,
    required this.previewDevice,
    required this.source,
    required this.translations,
    required this.dirty,
    required this.publishOpen,
    required this.translating,
    this.errorMessage,
  });

  final String propertyName;
  final String sourceLanguage;
  final List<String> locales;
  final String pageKey;
  final String previewLanguage;
  final PreviewDevice previewDevice;

  /// Source-language text per field key.
  final Map<String, String> source;

  /// `language -> (fieldKey -> TranslatedField)` for every non-source locale.
  final Map<String, Map<String, TranslatedField>> translations;

  /// Whether there are unpublished changes.
  final bool dirty;
  final bool publishOpen;

  /// Languages currently being (re)translated.
  final Set<String> translating;
  final String? errorMessage;

  bool get isSourceMode => previewLanguage == sourceLanguage;

  /// Target locales in display order (source first, then the rest).
  List<String> get orderedLocales => [
        sourceLanguage,
        ...locales.where((l) => l != sourceLanguage),
      ];

  List<String> get targetLanguages =>
      locales.where((l) => l != sourceLanguage).toList();

  /// The editable fields for the current page (only Home is fully specified).
  List<EditorFieldDef> get fields =>
      pageKey == 'home' ? kHomeFields : const [];

  int currentSourceHash(String key) => sourceHashOf(source[key] ?? '');

  TranslatedField? translatedField(String language, String key) =>
      translations[language]?[key];

  /// Value shown for a field in a given language (source text in source mode).
  String valueFor(String language, String key) {
    if (language == sourceLanguage) return source[key] ?? '';
    return translations[language]?[key]?.value ?? '';
  }

  bool isFieldStale(String language, String key) {
    if (language == sourceLanguage) return false;
    final field = translations[language]?[key];
    if (field == null) return false;
    return field.isStaleFor(currentSourceHash(key));
  }

  bool isLanguageStale(String language) =>
      fields.any((f) => isFieldStale(language, f.key));

  /// Target languages that have at least one stale field.
  Set<String> get staleLanguages =>
      targetLanguages.where(isLanguageStale).toSet();

  /// Fraction (0..1) of a target language's fields that are up to date
  /// (locked, or fresh auto). Used for the coverage meter.
  double coverage(String language) {
    if (fields.isEmpty) return 1;
    final upToDate =
        fields.where((f) => !isFieldStale(language, f.key)).length;
    return upToDate / fields.length;
  }

  SiteContentState copyWith({
    String? pageKey,
    String? previewLanguage,
    PreviewDevice? previewDevice,
    Map<String, String>? source,
    Map<String, Map<String, TranslatedField>>? translations,
    bool? dirty,
    bool? publishOpen,
    Set<String>? translating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SiteContentState(
      propertyName: propertyName,
      sourceLanguage: sourceLanguage,
      locales: locales,
      pageKey: pageKey ?? this.pageKey,
      previewLanguage: previewLanguage ?? this.previewLanguage,
      previewDevice: previewDevice ?? this.previewDevice,
      source: source ?? this.source,
      translations: translations ?? this.translations,
      dirty: dirty ?? this.dirty,
      publishOpen: publishOpen ?? this.publishOpen,
      translating: translating ?? this.translating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        propertyName,
        sourceLanguage,
        locales,
        pageKey,
        previewLanguage,
        previewDevice,
        source,
        translations,
        dirty,
        publishOpen,
        translating,
        errorMessage,
      ];
}

/// Drives the website editor: the source-language + auto/locked translation
/// model. Editing the source marks dependent auto fields stale; editing a
/// target field locks it; publish re-translates every auto field and clears
/// stale for all languages. Translation runs through an injected
/// [TranslationService].
class SiteContentCubit extends Cubit<SiteContentState> {
  SiteContentCubit({
    required TranslationService translationService,
  })  : _translationService = translationService,
        super(_seedState());

  final TranslationService _translationService;

  static SiteContentState _seedState() {
    final source = Map<String, String>.from(WebsiteSeed.home['nl']!);
    final translations = <String, Map<String, TranslatedField>>{};
    for (final lang in WebsiteSeed.locales.where((l) => l != 'nl')) {
      final seed = WebsiteSeed.home[lang]!;
      translations[lang] = {
        for (final field in kHomeFields)
          field.key: TranslatedField(
            value: seed[field.key] ?? '',
            status: FieldTranslationStatus.auto,
            sourceHash: sourceHashOf(source[field.key] ?? ''),
          ),
      };
    }
    return SiteContentState(
      propertyName: WebsiteSeed.propertyName,
      sourceLanguage: WebsiteSeed.sourceLanguage,
      locales: WebsiteSeed.locales,
      pageKey: 'home',
      previewLanguage: WebsiteSeed.sourceLanguage,
      previewDevice: PreviewDevice.web,
      source: source,
      translations: translations,
      dirty: false,
      publishOpen: false,
      translating: const {},
    );
  }

  void selectPage(String pageKey) => emit(state.copyWith(pageKey: pageKey));

  void setPreviewLanguage(String language) =>
      emit(state.copyWith(previewLanguage: language));

  void setPreviewDevice(PreviewDevice device) =>
      emit(state.copyWith(previewDevice: device));

  /// Edits the source text of a field. Dependent auto fields in other
  /// languages become stale automatically (their source hash no longer
  /// matches); locked fields are untouched.
  void editSourceField(String key, String value) {
    final source = Map<String, String>.from(state.source)..[key] = value;
    emit(state.copyWith(source: source, dirty: true));
  }

  /// Edits a target-language field, locking it so translation never overwrites
  /// the owner's wording.
  void editTranslationField(String language, String key, String value) {
    if (language == state.sourceLanguage) return;
    final updated = _cloneTranslations();
    final langMap = updated.putIfAbsent(language, () => {});
    langMap[key] = TranslatedField(
      value: value,
      status: FieldTranslationStatus.locked,
    );
    emit(state.copyWith(translations: updated, dirty: true));
  }

  /// Reverts a locked field back to auto and regenerates it from the source.
  Future<void> resetFieldToAi(String language, String key) async {
    if (language == state.sourceLanguage) return;
    try {
      final translated = await _translationService.translateFields(
        sourceLanguage: state.sourceLanguage,
        targetLanguage: language,
        sourceFields: {key: state.source[key] ?? ''},
      );
      final updated = _cloneTranslations();
      final langMap = updated.putIfAbsent(language, () => {});
      langMap[key] = TranslatedField(
        value: translated[key] ?? state.source[key] ?? '',
        status: FieldTranslationStatus.auto,
        sourceHash: state.currentSourceHash(key),
      );
      emit(state.copyWith(translations: updated, dirty: true, clearError: true));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'reset_failed'));
    }
  }

  /// Optional early look: (re)translate the auto fields of a single language.
  Future<void> previewTranslation(String language) => translateNow([language]);

  /// Re-translates all `auto` fields for the given target languages, refreshing
  /// their value + source hash (which clears their stale flag). Locked fields
  /// are never touched.
  Future<void> translateNow(List<String> languages) async {
    final targets = languages
        .where((l) => l != state.sourceLanguage && state.locales.contains(l))
        .toList();
    if (targets.isEmpty) return;

    emit(state.copyWith(translating: {...state.translating, ...targets}));
    try {
      final updated = _cloneTranslations();
      for (final language in targets) {
        final langMap = updated.putIfAbsent(language, () => {});
        final autoSources = <String, String>{
          for (final field in state.fields)
            if ((langMap[field.key]?.status ??
                    FieldTranslationStatus.auto) ==
                FieldTranslationStatus.auto)
              field.key: state.source[field.key] ?? '',
        };
        final translated = await _translationService.translateFields(
          sourceLanguage: state.sourceLanguage,
          targetLanguage: language,
          sourceFields: autoSources,
        );
        translated.forEach((key, value) {
          langMap[key] = TranslatedField(
            value: value,
            status: FieldTranslationStatus.auto,
            sourceHash: state.currentSourceHash(key),
          );
        });
      }
      emit(
        state.copyWith(
          translations: updated,
          translating: state.translating.difference(targets.toSet()),
          clearError: true,
        ),
      );
    } catch (_) {
      // Degrade gracefully: keep the last good translations, surface an error.
      emit(
        state.copyWith(
          translating: state.translating.difference(targets.toSet()),
          errorMessage: 'translate_failed',
        ),
      );
    }
  }

  void openPublish() => emit(state.copyWith(publishOpen: true));
  void closePublish() => emit(state.copyWith(publishOpen: false));

  /// Publishes all enabled languages at once: re-translates every auto field of
  /// every target language (clearing stale), then clears the dirty flag.
  Future<void> publishAll() async {
    await translateNow(state.targetLanguages);
    emit(state.copyWith(dirty: false, publishOpen: false, clearError: true));
  }

  Map<String, Map<String, TranslatedField>> _cloneTranslations() => {
        for (final entry in state.translations.entries)
          entry.key: Map<String, TranslatedField>.from(entry.value),
      };
}
