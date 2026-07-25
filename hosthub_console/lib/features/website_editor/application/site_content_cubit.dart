import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/translation_service.dart';
import '../data/website_content_repository.dart';
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
    required this.previewVisible,
    required this.source,
    required this.translations,
    required this.dirty,
    required this.publishOpen,
    required this.translating,
    this.errorMessage,
    this.previewDomain,
    this.lastSavedAt,
    this.saving = false,
    this.reviewedLanguages = const {},
    this.pendingAutoSwitch,
  });

  final String propertyName;
  final String sourceLanguage;
  final List<String> locales;
  final String pageKey;
  final String previewLanguage;
  final PreviewDevice previewDevice;

  /// Whether the right-hand live preview pane is shown. Editing works the same
  /// either way; hiding it just gives the editor column the full width.
  final bool previewVisible;

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

  /// The site's primary public domain; when set, the preview pane embeds the
  /// real website's draft-preview route instead of the schematic mock.
  final String? previewDomain;

  /// Bumped after a successful autosave/publish so the embedded live preview
  /// reloads and shows the fresh draft.
  final DateTime? lastSavedAt;

  /// Whether an autosave is in flight, for the save indicator (§11h: the mode
  /// is editorial metadata and saves immediately — the user has to be able to
  /// see that happen).
  final bool saving;

  /// Target languages the owner opened this session. Opening a language *is*
  /// reviewing it (§11a), so this is what the publish dialog reports as
  /// `Reviewed` rather than a separate flag nobody sets.
  final Set<String> reviewedLanguages;

  /// The one in-session undo for switching a field back to automatic — the
  /// only genuinely destructive action on this screen (§11g). Holds the
  /// owner's previous wording until they navigate away or publish.
  final PendingAutoSwitch? pendingAutoSwitch;

  bool get isSourceMode => previewLanguage == sourceLanguage;

  /// Target locales in display order (source first, then the rest).
  List<String> get orderedLocales => [
    sourceLanguage,
    ...locales.where((l) => l != sourceLanguage),
  ];

  List<String> get targetLanguages =>
      locales.where((l) => l != sourceLanguage).toList();

  /// The editable fields for the current page (highlight rows are repeatable
  /// and derived from the source content).
  List<EditorFieldDef> get fields => effectiveFieldsFor(pageKey, source);

  /// Every editable field across all pages (translate/publish scope).
  List<EditorFieldDef> get allFields => [
    for (final page in kPageFields.keys) ...effectiveFieldsFor(page, source),
  ];

  String currentSourceHash(String key) => sourceHashOf(source[key] ?? '');

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
      allFields.any((f) => isFieldStale(language, f.key));

  /// Target languages that have at least one stale field.
  Set<String> get staleLanguages =>
      targetLanguages.where(isLanguageStale).toSet();

  /// How many of this page's fields the owner has taken over (§11g). This is
  /// the figure that actually varies per language — a "% translated" meter can
  /// only ever read 100% once translation is automatic.
  int lockedFieldCount(String language) => fields
      .where((f) => translations[language]?[f.key]?.isLocked ?? false)
      .length;

  /// Translatable fields on this page — the denominator of that counter.
  int get translatableFieldCount => fields.length;

  SiteContentState copyWith({
    String? sourceLanguage,
    List<String>? locales,
    String? pageKey,
    String? previewLanguage,
    PreviewDevice? previewDevice,
    bool? previewVisible,
    Map<String, String>? source,
    Map<String, Map<String, TranslatedField>>? translations,
    bool? dirty,
    bool? publishOpen,
    Set<String>? translating,
    String? errorMessage,
    String? previewDomain,
    DateTime? lastSavedAt,
    bool? saving,
    Set<String>? reviewedLanguages,
    PendingAutoSwitch? pendingAutoSwitch,
    bool clearPendingAutoSwitch = false,
    bool clearError = false,
  }) {
    return SiteContentState(
      propertyName: propertyName,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      locales: locales ?? this.locales,
      pageKey: pageKey ?? this.pageKey,
      previewLanguage: previewLanguage ?? this.previewLanguage,
      previewDevice: previewDevice ?? this.previewDevice,
      previewVisible: previewVisible ?? this.previewVisible,
      source: source ?? this.source,
      translations: translations ?? this.translations,
      dirty: dirty ?? this.dirty,
      publishOpen: publishOpen ?? this.publishOpen,
      translating: translating ?? this.translating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      previewDomain: previewDomain ?? this.previewDomain,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      saving: saving ?? this.saving,
      reviewedLanguages: reviewedLanguages ?? this.reviewedLanguages,
      pendingAutoSwitch: clearPendingAutoSwitch
          ? null
          : (pendingAutoSwitch ?? this.pendingAutoSwitch),
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
    previewVisible,
    source,
    translations,
    dirty,
    publishOpen,
    translating,
    errorMessage,
    previewDomain,
    lastSavedAt,
    saving,
    reviewedLanguages,
    pendingAutoSwitch,
  ];
}

/// A field that just switched from the owner's wording back to automatic, kept
/// in memory so one misclick is undoable. No persistence, no history — the
/// problem being solved is a misclick.
class PendingAutoSwitch extends Equatable {
  const PendingAutoSwitch({
    required this.language,
    required this.fieldKey,
    required this.previousValue,
  });

  final String language;
  final String fieldKey;
  final String previousValue;

  @override
  List<Object?> get props => [language, fieldKey, previousValue];
}

/// Drives the website editor: the source-language + auto/locked translation
/// model. Editing the source marks dependent auto fields stale; editing a
/// target field locks it; publish re-translates every auto field and clears
/// stale for all languages. Translation runs through an injected
/// [TranslationService].
///
/// With a [repository] + [siteId] the cubit is persistent: [loadContent]
/// hydrates from the site's documents + `site_translations`, edits autosave as
/// drafts (debounced), and publish folds everything back into the documents.
/// Without them it runs on the in-memory seed (demo/tests).
class SiteContentCubit extends Cubit<SiteContentState> {
  SiteContentCubit({
    required TranslationService translationService,
    WebsiteContentRepository? repository,
    String? siteId,
    Duration autosaveDebounce = const Duration(milliseconds: 800),
  }) : _translationService = translationService,
       _repository = repository,
       _siteId = siteId,
       _autosaveDebounce = autosaveDebounce,
       super(_seedState());

  final TranslationService _translationService;
  final WebsiteContentRepository? _repository;
  final String? _siteId;
  final Duration _autosaveDebounce;

  Timer? _autosaveTimer;
  bool _sourceDirty = false;
  final Set<(String, String)> _dirtyTranslationFields = {};

  bool get _persistent => _repository != null && _siteId != null;

  /// Hydrates the state from the repository. No-op without persistence; on
  /// failure the seed state stays and an error message is surfaced.
  Future<void> loadContent() async {
    if (!_persistent) return;
    try {
      final content = await _repository!.loadPageContent(
        siteId: _siteId!,
        sourceLanguage: state.sourceLanguage,
        locales: state.locales,
      );
      final sourceLanguage = content.sourceLanguage ?? state.sourceLanguage;
      emit(
        state.copyWith(
          sourceLanguage: sourceLanguage,
          locales: content.locales,
          // Keep the preview on a valid locale when the source changed.
          previewLanguage:
              (content.locales ?? state.locales).contains(state.previewLanguage)
              ? state.previewLanguage
              : sourceLanguage,
          source: content.source,
          translations: content.translations,
          previewDomain: content.previewDomain,
          dirty: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'load_failed'));
    }
  }

  void _scheduleAutosave() {
    if (!_persistent) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, () {
      // ignore: discarded_futures — fire-and-forget autosave tick.
      _flushPendingSaves();
    });
  }

  /// Persists pending edits: the source draft and/or changed translation
  /// fields. Errors surface as a non-blocking message; edits stay in memory.
  Future<void> _flushPendingSaves() async {
    if (!_persistent) return;
    final saveSource = _sourceDirty;
    final fields = List.of(_dirtyTranslationFields);
    if (!saveSource && fields.isEmpty) return;
    _sourceDirty = false;
    _dirtyTranslationFields.clear();
    if (!isClosed) emit(state.copyWith(saving: true));
    try {
      if (saveSource) {
        await _repository!.saveSourceDraft(
          siteId: _siteId!,
          sourceLanguage: state.sourceLanguage,
          fields: state.source,
        );
      }
      for (final (language, key) in fields) {
        final field = state.translatedField(language, key);
        if (field == null) continue;
        await _repository!.saveTranslationField(
          siteId: _siteId!,
          language: language,
          fieldKey: key,
          field: field,
        );
      }
      if (!isClosed) {
        // Nudge the embedded live preview to reload the fresh draft.
        emit(state.copyWith(lastSavedAt: DateTime.now(), saving: false));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'save_failed', saving: false));
      }
    }
  }

  @override
  Future<void> close() async {
    _autosaveTimer?.cancel();
    await _flushPendingSaves();
    return super.close();
  }

  static SiteContentState _seedState() {
    final source = Map<String, String>.from(WebsiteSeed.home['nl']!);
    final translations = <String, Map<String, TranslatedField>>{};
    for (final lang in WebsiteSeed.locales.where((l) => l != 'nl')) {
      final seed = WebsiteSeed.home[lang]!;
      translations[lang] = {
        for (final field in kAllFields)
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
      previewVisible: true,
      source: source,
      translations: translations,
      dirty: false,
      publishOpen: false,
      translating: const {},
    );
  }

  void selectPage(String pageKey) =>
      emit(state.copyWith(pageKey: pageKey, clearPendingAutoSwitch: true));

  void setPreviewLanguage(String language) {
    emit(
      state.copyWith(
        previewLanguage: language,
        reviewedLanguages: language == state.sourceLanguage
            ? state.reviewedLanguages
            : {...state.reviewedLanguages, language},
        clearPendingAutoSwitch: true,
      ),
    );
  }

  void setPreviewDevice(PreviewDevice device) =>
      emit(state.copyWith(previewDevice: device));

  /// Shows/hides the live preview pane. When hidden the editor column takes the
  /// full width; the preview keeps its language/device selection for when it's
  /// shown again.
  void togglePreview() =>
      emit(state.copyWith(previewVisible: !state.previewVisible));

  /// Edits the source text of a field. Dependent auto fields in other
  /// languages become stale automatically (their source hash no longer
  /// matches); locked fields are untouched.
  void editSourceField(String key, String value) {
    final source = Map<String, String>.from(state.source)..[key] = value;
    emit(state.copyWith(source: source, dirty: true));
    _sourceDirty = true;
    _scheduleAutosave();
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
    _dirtyTranslationFields.add((language, key));
    _scheduleAutosave();
  }

  /// Takes the field over: keeps the text as it stands and stops future
  /// re-translations from overwriting it.
  void lockField(String language, String key) {
    if (language == state.sourceLanguage) return;
    final updated = _cloneTranslations();
    final langMap = updated.putIfAbsent(language, () => {});
    langMap[key] = TranslatedField(
      value: state.valueFor(language, key),
      status: FieldTranslationStatus.locked,
    );
    emit(
      state.copyWith(
        translations: updated,
        dirty: true,
        clearPendingAutoSwitch: true,
      ),
    );
    _dirtyTranslationFields.add((language, key));
    _scheduleAutosave();
  }

  /// Puts the owner's wording back after switching a field to automatic.
  void undoAutoSwitch() {
    final pending = state.pendingAutoSwitch;
    if (pending == null) return;
    final updated = _cloneTranslations();
    final langMap = updated.putIfAbsent(pending.language, () => {});
    langMap[pending.fieldKey] = TranslatedField(
      value: pending.previousValue,
      status: FieldTranslationStatus.locked,
    );
    emit(
      state.copyWith(
        translations: updated,
        dirty: true,
        clearPendingAutoSwitch: true,
      ),
    );
    _dirtyTranslationFields.add((pending.language, pending.fieldKey));
    _scheduleAutosave();
  }

  /// Reverts a locked field back to auto and regenerates it from the source.
  ///
  /// The previous wording is held for one in-session undo: this is the only
  /// action on the screen that destroys something the owner typed.
  Future<void> resetFieldToAi(String language, String key) async {
    if (language == state.sourceLanguage) return;
    final previousValue = state.valueFor(language, key);
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
      emit(
        state.copyWith(
          translations: updated,
          dirty: true,
          clearError: true,
          pendingAutoSwitch: PendingAutoSwitch(
            language: language,
            fieldKey: key,
            previousValue: previousValue,
          ),
        ),
      );
      _dirtyTranslationFields.add((language, key));
      _scheduleAutosave();
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
          for (final field in state.allFields)
            if ((langMap[field.key]?.status ?? FieldTranslationStatus.auto) ==
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
          // Idempotent with the Edge Function's own upsert; keeps
          // site_translations correct for any TranslationService.
          _dirtyTranslationFields.add((language, key));
        });
      }
      emit(
        state.copyWith(
          translations: updated,
          translating: state.translating.difference(targets.toSet()),
          clearError: true,
        ),
      );
      _scheduleAutosave();
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

  /// Appends an empty highlight row (source language; targets start as fresh
  /// empty auto fields so they translate on publish).
  void addHighlight() {
    final index = state.fields
        .where((f) => f.card == EditorCard.highlights)
        .length;
    final key = 'highlights.$index';
    final source = Map<String, String>.from(state.source)..[key] = '';
    final updated = _cloneTranslations();
    for (final language in state.targetLanguages) {
      final langMap = updated.putIfAbsent(language, () => {});
      langMap[key] = TranslatedField(
        value: '',
        status: FieldTranslationStatus.auto,
        sourceHash: sourceHashOf(''),
      );
    }
    emit(state.copyWith(source: source, translations: updated, dirty: true));
    _sourceDirty = true;
    _scheduleAutosave();
  }

  /// Reorders the highlight rows (drag grip). Values move in every language,
  /// including their locked/auto status, so translations stay attached to
  /// their row.
  void reorderHighlights(int oldIndex, int newIndex) {
    final keys = state.fields
        .where((f) => f.card == EditorCard.highlights)
        .map((f) => f.key)
        .toList();
    if (oldIndex < 0 || oldIndex >= keys.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    newIndex = newIndex.clamp(0, keys.length - 1);
    if (newIndex == oldIndex) return;

    List<T> moved<T>(List<T> values) {
      final list = List<T>.from(values);
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      return list;
    }

    final source = Map<String, String>.from(state.source);
    final sourceValues = moved([for (final k in keys) source[k] ?? '']);
    for (var i = 0; i < keys.length; i++) {
      source[keys[i]] = sourceValues[i];
    }

    final updated = _cloneTranslations();
    for (final language in state.targetLanguages) {
      final langMap = updated.putIfAbsent(language, () => {});
      final fieldValues = moved([
        for (final k in keys)
          langMap[k] ??
              TranslatedField(
                value: '',
                status: FieldTranslationStatus.auto,
                sourceHash: sourceHashOf(''),
              ),
      ]);
      for (var i = 0; i < keys.length; i++) {
        langMap[keys[i]] = fieldValues[i];
        _dirtyTranslationFields.add((language, keys[i]));
      }
    }

    emit(state.copyWith(source: source, translations: updated, dirty: true));
    _sourceDirty = true;
    _scheduleAutosave();
  }

  /// Clears the surfaced error after the UI has shown it (so an identical
  /// follow-up failure triggers feedback again).
  void clearErrorMessage() => emit(state.copyWith(clearError: true));

  void openPublish() => emit(state.copyWith(publishOpen: true));
  void closePublish() => emit(state.copyWith(publishOpen: false));

  /// Publishes all enabled languages at once: re-translates every auto field of
  /// every target language (clearing stale), persists everything into the
  /// site's documents, then clears the dirty flag. Persistence failures keep
  /// the dirty state so publish can be retried.
  /// Publishes the source plus every target language that wasn't unchecked in
  /// the dialog (§11a). A skipped language keeps whatever is live now — it is
  /// not translated and not written.
  Future<void> publishAll({Set<String> skipLanguages = const {}}) async {
    final targets = state.targetLanguages
        .where((language) => !skipLanguages.contains(language))
        .toList();
    await translateNow(targets);
    if (_persistent) {
      try {
        await _flushPendingSaves();
        await _repository!.publishAll(
          siteId: _siteId!,
          valuesByLocale: {
            state.sourceLanguage: Map<String, String>.from(state.source),
            for (final language in targets)
              language: {
                for (final field in state.allFields)
                  field.key: state.valueFor(language, field.key),
              },
          },
        );
      } catch (_) {
        emit(state.copyWith(errorMessage: 'publish_failed'));
        return;
      }
    }
    emit(
      state.copyWith(
        dirty: false,
        publishOpen: false,
        lastSavedAt: DateTime.now(),
        clearPendingAutoSwitch: true,
        clearError: true,
      ),
    );
  }

  Map<String, Map<String, TranslatedField>> _cloneTranslations() => {
    for (final entry in state.translations.entries)
      entry.key: Map<String, TranslatedField>.from(entry.value),
  };
}
