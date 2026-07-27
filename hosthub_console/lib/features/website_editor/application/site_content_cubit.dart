import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/translation_service.dart';
import '../data/website_content_repository.dart';
import '../domain/website_content.dart';

/// Preview device frame.
enum PreviewDevice { web, mobile }

/// State for the website editor: the source content, per-language translations
/// (each field `auto`/`locked` with a source hash), the uncommitted draft on
/// top of both, and preview UI state.
///
/// §11i — three content layers, in this order:
///
/// 1. **base** — what came back from the server ([SiteContentCubit.loadContent]).
/// 2. **saved** — [source] + [translations], committed by `Save changes`. This
///    is what publish ships and what translation reads.
/// 3. **draft** — [draftSource] + [draftTranslations]: what is in the fields
///    right now, per language, in memory only.
///
/// Effective value = draft ?? saved. Nothing moves from draft to saved except
/// [SiteContentCubit.save]; there is no autosave anywhere in this cubit.
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
    this.draftSource = const {},
    this.draftTranslations = const {},
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

  /// Saved source-language text per field key.
  final Map<String, String> source;

  /// Saved `language -> (fieldKey -> TranslatedField)` for every non-source
  /// locale.
  final Map<String, Map<String, TranslatedField>> translations;

  /// Uncommitted source-language edits. Only holds fields whose value differs
  /// from [source].
  final Map<String, String> draftSource;

  /// Uncommitted target-language edits — text *and* the auto/locked mode, which
  /// is editorial metadata that travels with the copy it belongs to (§11h).
  final Map<String, Map<String, TranslatedField>> draftTranslations;

  /// Whether there are saved-but-unpublished changes. Set by a save, cleared by
  /// publish: typing does not set it, because typing does not save (§11i).
  final bool dirty;
  final bool publishOpen;

  /// Languages currently being (re)translated.
  final Set<String> translating;
  final String? errorMessage;

  /// The site's primary public domain; when set, the preview pane embeds the
  /// real website's draft-preview route instead of the schematic mock.
  final String? previewDomain;

  /// Bumped after a successful save/publish so the embedded live preview
  /// reloads and shows the fresh draft.
  final DateTime? lastSavedAt;

  /// Whether a save is in flight, for the save button's progress state.
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

  /// Whether the draft holds anything the saved layer does not (§11i). This is
  /// a comparison, not a "was touched" flag: typing a value back to what is
  /// saved clears it again. It dims `Publish` and drives the exit warning.
  bool get unsavedChanges =>
      draftSource.isNotEmpty ||
      draftTranslations.values.any((fields) => fields.isNotEmpty);

  /// Source text as the fields show it: the draft on top of the saved layer.
  Map<String, String> get effectiveSource =>
      draftSource.isEmpty ? source : {...source, ...draftSource};

  /// Target locales in display order (source first, then the rest).
  List<String> get orderedLocales => [
    sourceLanguage,
    ...locales.where((l) => l != sourceLanguage),
  ];

  List<String> get targetLanguages =>
      locales.where((l) => l != sourceLanguage).toList();

  /// The editable fields for the current page (highlight rows are repeatable
  /// and derived from the content the owner sees, drafts included).
  List<EditorFieldDef> get fields =>
      effectiveFieldsFor(pageKey, effectiveSource);

  /// Every editable field across all pages (translate/publish scope).
  List<EditorFieldDef> get allFields => [
    for (final page in kPageFields.keys)
      ...effectiveFieldsFor(page, effectiveSource),
  ];

  /// Hash of the **saved** source text. Translation reads the saved layer, so
  /// staleness is measured against it too (§11i): a field the owner is still
  /// typing does not make its translations stale — saving it does.
  String currentSourceHash(String key) => sourceHashOf(source[key] ?? '');

  /// The field as shown: the draft entry when there is one, else the saved one.
  TranslatedField? translatedField(String language, String key) =>
      draftTranslations[language]?[key] ?? translations[language]?[key];

  /// The saved field, ignoring any draft — what publish and translation read.
  TranslatedField? savedTranslatedField(String language, String key) =>
      translations[language]?[key];

  /// Value shown for a field in a given language (source text in source mode).
  String valueFor(String language, String key) {
    if (language == sourceLanguage) {
      return draftSource[key] ?? source[key] ?? '';
    }
    return translatedField(language, key)?.value ?? '';
  }

  /// Saved value for a field — what publish ships.
  String savedValueFor(String language, String key) {
    if (language == sourceLanguage) return source[key] ?? '';
    return savedTranslatedField(language, key)?.value ?? '';
  }

  bool isFieldStale(String language, String key) {
    if (language == sourceLanguage) return false;
    final field = savedTranslatedField(language, key);
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
      .where((f) => translatedField(language, f.key)?.isLocked ?? false)
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
    Map<String, String>? draftSource,
    Map<String, Map<String, TranslatedField>>? draftTranslations,
    bool? dirty,
    bool? publishOpen,
    Set<String>? translating,
    String? errorMessage,
    String? previewDomain,
    DateTime? lastSavedAt,
    bool? saving,
    Set<String>? reviewedLanguages,
    PendingAutoSwitch? pendingAutoSwitch,
    bool clearDraft = false,
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
      draftSource: clearDraft ? const {} : (draftSource ?? this.draftSource),
      draftTranslations: clearDraft
          ? const {}
          : (draftTranslations ?? this.draftTranslations),
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
    draftSource,
    draftTranslations,
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
/// Saving is explicit and nothing autosaves (§11i). Every edit lands in the
/// draft layer; [save] is the only thing that commits it, [discardDraft] throws
/// it away, and [publishAll] refuses to run while a draft exists. Writing while
/// the owner types turns every half-finished sentence into the text that gets
/// machine-translated into every other language — and on a live site a draft
/// save takes the document out of publication, which is not something to do
/// behind the owner's back.
///
/// With a [repository] + [siteId] the cubit is persistent: [loadContent]
/// hydrates from the site's documents + `site_translations`, [save] writes the
/// draft back as document drafts, and publish folds everything into the
/// documents. Without them it runs on the in-memory seed (demo/tests), where
/// the same three layers apply — only the server round-trip is skipped.
class SiteContentCubit extends Cubit<SiteContentState> {
  SiteContentCubit({
    required TranslationService translationService,
    WebsiteContentRepository? repository,
    String? siteId,
  }) : _translationService = translationService,
       _repository = repository,
       _siteId = siteId,
       super(_seedState());

  final TranslationService _translationService;
  final WebsiteContentRepository? _repository;
  final String? _siteId;

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
          clearDraft: true,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'load_failed'));
    }
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

  /// Opens a language for editing — and translates it if it needs it (§11a).
  ///
  /// Translation is lazy on purpose: not on every source save (that pays for
  /// languages nobody looks at) and not behind a button (there is never a
  /// reason to answer "no" to it). It happens at the two moments the
  /// translation is actually needed — when the owner opens the language, and
  /// at publish for languages they never opened.
  ///
  /// Switching language does not save: the draft is per language, so unsaved
  /// edits stay in the language they were typed in and travel to the server
  /// together at the next [save] (§11i).
  void setPreviewLanguage(String language) {
    final isTarget = language != state.sourceLanguage;
    emit(
      state.copyWith(
        previewLanguage: language,
        reviewedLanguages: isTarget
            ? {...state.reviewedLanguages, language}
            : state.reviewedLanguages,
        clearPendingAutoSwitch: true,
      ),
    );
    if (isTarget && state.isLanguageStale(language)) {
      // ignore: discarded_futures — the lane renders the result when it lands;
      // failures surface as a message, the old text stays.
      translateNow([language]);
    }
  }

  void setPreviewDevice(PreviewDevice device) =>
      emit(state.copyWith(previewDevice: device));

  /// Shows/hides the live preview pane. When hidden the editor column takes the
  /// full width; the preview keeps its language/device selection for when it's
  /// shown again.
  void togglePreview() =>
      emit(state.copyWith(previewVisible: !state.previewVisible));

  // -- editing: draft layer only --------------------------------------------

  /// Edits the source text of a field. The edit lands in the draft; the auto
  /// fields that depend on it go stale once it is saved, because staleness is
  /// measured against the saved source.
  void editSourceField(String key, String value) {
    final draft = Map<String, String>.from(state.draftSource);
    // Typing a value back to what is saved is not a change. A key the saved
    // layer does not have yet — a freshly added highlight row — always stays,
    // or clearing its text would delete the row.
    if (state.source.containsKey(key) && state.source[key] == value) {
      draft.remove(key);
    } else {
      draft[key] = value;
    }
    emit(state.copyWith(draftSource: draft));
  }

  /// Edits a target-language field, locking it so translation never overwrites
  /// the owner's wording. Typing *is* the lock (§3): the owner does not press
  /// the chip first.
  void editTranslationField(String language, String key, String value) {
    if (language == state.sourceLanguage) return;
    _putDraftField(
      language,
      key,
      TranslatedField(value: value, status: FieldTranslationStatus.locked),
    );
  }

  /// Takes the field over: keeps the text as it stands and stops future
  /// re-translations from overwriting it.
  void lockField(String language, String key) {
    if (language == state.sourceLanguage) return;
    _putDraftField(
      language,
      key,
      TranslatedField(
        value: state.valueFor(language, key),
        status: FieldTranslationStatus.locked,
      ),
      clearPendingAutoSwitch: true,
    );
  }

  /// Puts the owner's wording back after switching a field to automatic.
  void undoAutoSwitch() {
    final pending = state.pendingAutoSwitch;
    if (pending == null) return;
    _putDraftField(
      pending.language,
      pending.fieldKey,
      TranslatedField(
        value: pending.previousValue,
        status: FieldTranslationStatus.locked,
      ),
      clearPendingAutoSwitch: true,
    );
  }

  /// Reverts a locked field back to auto and regenerates it from the source.
  ///
  /// Like every other edit this is a draft change: the mode is editorial
  /// metadata and is committed by `Save changes` together with the copy it
  /// belongs to (§11h). The previous wording is held for one in-session undo —
  /// this is the only action on the screen that destroys something the owner
  /// typed.
  Future<void> resetFieldToAi(String language, String key) async {
    if (language == state.sourceLanguage) return;
    final previousValue = state.valueFor(language, key);
    try {
      final translated = await _translationService.translateFields(
        sourceLanguage: state.sourceLanguage,
        targetLanguage: language,
        sourceFields: {key: state.source[key] ?? ''},
      );
      _putDraftField(
        language,
        key,
        TranslatedField(
          value: translated[key] ?? state.source[key] ?? '',
          status: FieldTranslationStatus.auto,
          sourceHash: state.currentSourceHash(key),
        ),
        pendingAutoSwitch: PendingAutoSwitch(
          language: language,
          fieldKey: key,
          previousValue: previousValue,
        ),
        clearError: true,
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'reset_failed'));
    }
  }

  /// Appends an empty highlight row (source language; targets start as fresh
  /// empty auto fields so they translate on publish). A draft, like every edit.
  void addHighlight() {
    final index = state.fields
        .where((f) => f.card == EditorCard.highlights)
        .length;
    final key = 'highlights.$index';
    final draftSource = Map<String, String>.from(state.draftSource)..[key] = '';
    final draftTranslations = _cloneDraftTranslations();
    for (final language in state.targetLanguages) {
      (draftTranslations[language] ??= {})[key] = TranslatedField(
        value: '',
        status: FieldTranslationStatus.auto,
        sourceHash: sourceHashOf(''),
      );
    }
    emit(
      state.copyWith(
        draftSource: draftSource,
        draftTranslations: draftTranslations,
      ),
    );
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

    final draftSource = Map<String, String>.from(state.draftSource);
    final sourceValues = moved([
      for (final k in keys) state.valueFor(state.sourceLanguage, k),
    ]);
    for (var i = 0; i < keys.length; i++) {
      draftSource[keys[i]] = sourceValues[i];
    }

    final draftTranslations = _cloneDraftTranslations();
    for (final language in state.targetLanguages) {
      final langDraft = draftTranslations[language] ??= {};
      final fieldValues = moved([
        for (final k in keys)
          state.translatedField(language, k) ??
              TranslatedField(
                value: '',
                status: FieldTranslationStatus.auto,
                sourceHash: sourceHashOf(''),
              ),
      ]);
      for (var i = 0; i < keys.length; i++) {
        langDraft[keys[i]] = fieldValues[i];
      }
    }

    emit(
      state.copyWith(
        draftSource: draftSource,
        draftTranslations: draftTranslations,
      ),
    );
  }

  // -- save / discard --------------------------------------------------------

  /// Commits the draft: writes it to the server, folds it into the saved layer
  /// and marks the page as having unpublished changes. The only path from draft
  /// to saved (§11i).
  ///
  /// Idempotent and per language: saving while editing `EN` also commits an
  /// `NL` draft the owner left behind. A failed write keeps the draft exactly
  /// as it is, so nothing the owner typed is lost and pressing Save again
  /// retries the same work.
  Future<void> save() async {
    if (!state.unsavedChanges || state.saving) return;

    final mergedSource = {...state.source, ...state.draftSource};
    final changedFields = <(String, String, TranslatedField)>[
      for (final entry in state.draftTranslations.entries)
        for (final field in entry.value.entries)
          (entry.key, field.key, field.value),
    ];
    final sourceChanged = state.draftSource.isNotEmpty;

    emit(state.copyWith(saving: true, clearError: true));
    if (_persistent) {
      try {
        if (sourceChanged) {
          await _repository!.saveSourceDraft(
            siteId: _siteId!,
            sourceLanguage: state.sourceLanguage,
            fields: mergedSource,
          );
        }
        for (final (language, key, field) in changedFields) {
          await _repository!.saveTranslationField(
            siteId: _siteId!,
            language: language,
            fieldKey: key,
            field: field,
          );
        }
      } catch (_) {
        if (!isClosed) {
          emit(state.copyWith(saving: false, errorMessage: 'save_failed'));
        }
        return;
      }
      if (isClosed) return;
    }

    final translations = _cloneTranslations();
    for (final (language, key, field) in changedFields) {
      (translations[language] ??= {})[key] = field;
    }
    // Edits made while the save was in flight are still in the draft; only the
    // fields that were written are folded into the saved layer.
    final remainingSource = {
      for (final entry in state.draftSource.entries)
        if (entry.value != mergedSource[entry.key]) entry.key: entry.value,
    };
    final remainingTranslations = <String, Map<String, TranslatedField>>{};
    for (final entry in state.draftTranslations.entries) {
      final remaining = {
        for (final field in entry.value.entries)
          if (field.value != translations[entry.key]?[field.key])
            field.key: field.value,
      };
      if (remaining.isNotEmpty) remainingTranslations[entry.key] = remaining;
    }

    emit(
      state.copyWith(
        source: mergedSource,
        translations: translations,
        draftSource: remainingSource,
        draftTranslations: remainingTranslations,
        dirty: true,
        saving: false,
        // The embedded live preview reloads on this marker.
        lastSavedAt: DateTime.now(),
      ),
    );
  }

  /// Drops the draft for **all** languages and returns the fields to their
  /// saved values (§11i).
  void discardDraft() {
    if (!state.unsavedChanges) return;
    emit(state.copyWith(clearDraft: true, clearPendingAutoSwitch: true));
  }

  // -- translation -----------------------------------------------------------

  /// Optional early look: (re)translate the auto fields of a single language.
  Future<void> previewTranslation(String language) => translateNow([language]);

  /// Re-translates all `auto` fields for the given target languages, refreshing
  /// their value + source hash (which clears their stale flag). Locked fields
  /// are never touched.
  ///
  /// Reads and writes the **saved** layer only (§11i): the text it translates
  /// is what was saved, never half-typed copy, and a field the owner has open
  /// in the draft is skipped so machine output cannot overwrite it.
  Future<void> translateNow(List<String> languages) async {
    final targets = languages
        .where((l) => l != state.sourceLanguage && state.locales.contains(l))
        .toList();
    if (targets.isEmpty) return;

    emit(state.copyWith(translating: {...state.translating, ...targets}));
    try {
      final updated = _cloneTranslations();
      final written = <(String, String, TranslatedField)>[];
      for (final language in targets) {
        final langMap = updated.putIfAbsent(language, () => {});
        final draft = state.draftTranslations[language] ?? const {};
        final autoSources = <String, String>{
          for (final field in state.allFields)
            if (!draft.containsKey(field.key) &&
                (langMap[field.key]?.status ?? FieldTranslationStatus.auto) ==
                    FieldTranslationStatus.auto)
              field.key: state.source[field.key] ?? '',
        };
        final translated = await _translationService.translateFields(
          sourceLanguage: state.sourceLanguage,
          targetLanguage: language,
          sourceFields: autoSources,
        );
        translated.forEach((key, value) {
          final field = TranslatedField(
            value: value,
            status: FieldTranslationStatus.auto,
            sourceHash: state.currentSourceHash(key),
          );
          langMap[key] = field;
          written.add((language, key, field));
        });
      }
      emit(
        state.copyWith(
          translations: updated,
          translating: state.translating.difference(targets.toSet()),
          clearError: true,
        ),
      );
      // Machine output belongs to the saved layer and is written straight
      // through — it is not something the owner typed, so it is not a draft and
      // there is nothing for them to save. Idempotent with the Edge Function's
      // own upsert; required for any other TranslationService. A write failure
      // is a save failure, not a translation failure: the text is on screen.
      try {
        await _persistTranslations(written);
      } catch (_) {
        if (!isClosed) emit(state.copyWith(errorMessage: 'save_failed'));
      }
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

  // -- publish ---------------------------------------------------------------

  /// Clears the surfaced error after the UI has shown it (so an identical
  /// follow-up failure triggers feedback again).
  void clearErrorMessage() => emit(state.copyWith(clearError: true));

  void openPublish() {
    // The button is disabled while a draft exists; this is the same rule at the
    // one place that cannot be bypassed (§11i).
    if (state.unsavedChanges) return;
    emit(state.copyWith(publishOpen: true));
  }

  void closePublish() => emit(state.copyWith(publishOpen: false));

  /// Publishes the source plus every target language that wasn't unchecked in
  /// the dialog (§11a). A skipped language keeps whatever is live now — it is
  /// not translated and not written.
  ///
  /// Re-translates every auto field of the published languages (clearing
  /// stale), persists everything into the site's documents, then clears the
  /// dirty flag. Persistence failures keep the dirty state so publish can be
  /// retried.
  ///
  /// Rejected outright while a draft exists: publish ships the saved layer and
  /// never saves on the owner's behalf (§11i).
  Future<void> publishAll({Set<String> skipLanguages = const {}}) async {
    if (state.unsavedChanges) return;
    final targets = state.targetLanguages
        .where((language) => !skipLanguages.contains(language))
        .toList();
    await translateNow(targets);
    if (_persistent) {
      try {
        await _repository!.publishAll(
          siteId: _siteId!,
          sourceLocale: state.sourceLanguage,
          valuesByLocale: {
            state.sourceLanguage: Map<String, String>.from(state.source),
            for (final language in targets)
              language: {
                for (final field in state.allFields)
                  field.key: state.savedValueFor(language, field.key),
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

  // -- internals -------------------------------------------------------------

  /// Writes one field into the draft, dropping the entry again when it matches
  /// what is already saved — so `unsavedChanges` stays a comparison rather than
  /// a "was touched" flag.
  void _putDraftField(
    String language,
    String key,
    TranslatedField field, {
    PendingAutoSwitch? pendingAutoSwitch,
    bool clearPendingAutoSwitch = false,
    bool clearError = false,
  }) {
    final drafts = _cloneDraftTranslations();
    final langDraft = drafts[language] ??= {};
    if (state.savedTranslatedField(language, key) == field) {
      langDraft.remove(key);
      if (langDraft.isEmpty) drafts.remove(language);
    } else {
      langDraft[key] = field;
    }
    emit(
      state.copyWith(
        draftTranslations: drafts,
        pendingAutoSwitch: pendingAutoSwitch,
        clearPendingAutoSwitch: clearPendingAutoSwitch,
        clearError: clearError,
      ),
    );
  }

  Future<void> _persistTranslations(
    List<(String, String, TranslatedField)> fields,
  ) async {
    if (!_persistent || fields.isEmpty) return;
    for (final (language, key, field) in fields) {
      await _repository!.saveTranslationField(
        siteId: _siteId!,
        language: language,
        fieldKey: key,
        field: field,
      );
    }
  }

  Map<String, Map<String, TranslatedField>> _cloneTranslations() => {
    for (final entry in state.translations.entries)
      entry.key: Map<String, TranslatedField>.from(entry.value),
  };

  Map<String, Map<String, TranslatedField>> _cloneDraftTranslations() => {
    for (final entry in state.draftTranslations.entries)
      entry.key: Map<String, TranslatedField>.from(entry.value),
  };
}
