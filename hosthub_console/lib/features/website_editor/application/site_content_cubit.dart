import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/translation_service.dart';
import '../data/website_content_repository.dart';
import '../domain/website_content.dart';

/// Preview device frame.
enum PreviewDevice { web, mobile }

/// Whether the state holds the site's own content.
///
/// A persistent editor starts [loading] with empty fields and only reaches
/// [ready] once the site's documents are in. It must never show the demo seed
/// while it waits or after it fails: seed copy in a form that says "Trysil"
/// above it reads as this site's content, and saving it would write the demo
/// text over the owner's pages.
enum ContentLoadStatus { loading, ready, failed }

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
    this.listOrder = const {},
    this.mediaKeys = const {},
    this.publishedByLocale = const {},
    this.draftSource = const {},
    this.draftTranslations = const {},
    this.draftListOrder = const {},
    this.draftMediaKeys = const {},
    this.errorMessage,
    this.loadError,
    this.previewDomain,
    this.lastSavedAt,
    this.saving = false,
    this.reviewedPages = const {},
    this.pendingAutoSwitch,
    this.pendingRowDelete,
    this.loadStatus = ContentLoadStatus.ready,
    this.onlyChangedFields = false,
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

  /// Saved `listKey -> row ids` in display order. Identity lives in the id,
  /// order lives here — reordering changes this and nothing else.
  final Map<String, List<String>> listOrder;

  /// What is live per locale (`language -> fieldKey -> text`). The delta the
  /// lane header and the publish dialog report is measured against this:
  /// "changed since the last publish" is the question, and a re-translation
  /// refreshing the wording does not answer it.
  final Map<String, Map<String, String>> publishedByLocale;

  /// Uncommitted source-language edits. Only holds fields whose value differs
  /// from [source].
  final Map<String, String> draftSource;

  /// Uncommitted target-language edits — text *and* the auto/locked mode, which
  /// is editorial metadata that travels with the copy it belongs to (§11h).
  final Map<String, Map<String, TranslatedField>> draftTranslations;

  /// Uncommitted row-order/row-set changes per list (add, reorder).
  final Map<String, List<String>> draftListOrder;

  /// Saved `mediaKey -> storage paths`, in display order. Photos are
  /// language-independent (README §C.4): one set per site, not per locale.
  final Map<String, List<String>> mediaKeys;

  /// Uncommitted photo choices and orders.
  final Map<String, List<String>> draftMediaKeys;

  /// Whether there are saved-but-unpublished changes. Set by a save, cleared by
  /// publish: typing does not set it, because typing does not save (§11i).
  final bool dirty;
  final bool publishOpen;

  /// Languages currently being (re)translated.
  final Set<String> translating;

  /// Non-blocking failures that keep the editor usable (save, translate, reset,
  /// publish): the owner's text is still on screen, so these degrade to a toast.
  final String? errorMessage;

  /// A failed [SiteContentCubit.loadContent]. Unlike [errorMessage] this is not
  /// a degradation: nothing of the site's own content made it in, so the editor
  /// is showing something that is not this site. It travels as a [DomainError]
  /// and is presented with `showAppError`.
  final DomainError? loadError;

  /// The site's primary public domain; when set, the preview pane embeds the
  /// real website's draft-preview route instead of the schematic mock.
  final String? previewDomain;

  /// Bumped after a successful save/publish so the embedded live preview
  /// reloads and shows the fresh draft.
  final DateTime? lastSavedAt;

  /// Whether a save is in flight, for the save button's progress state.
  final bool saving;

  /// Which pages the owner opened, per target language, this session.
  ///
  /// With 14 fields "have you seen this language?" was a fair question; with
  /// 250 it is not (§D.2). Reviewing is page-granular because that is how
  /// reading works — you read a page, not a field — and it is cheap to measure
  /// honestly. Opening a page *is* reviewing it; there is no separate flag for
  /// somebody to forget to set.
  final Map<String, Set<String>> reviewedPages;

  /// The one in-session undo for switching a field back to automatic — the
  /// only genuinely destructive action on this screen (§11g). Holds the
  /// owner's previous wording until they navigate away or publish.
  final PendingAutoSwitch? pendingAutoSwitch;

  /// The one in-session undo for a deleted list row — same shape and same
  /// promise as [pendingAutoSwitch]: one misclick is undoable, and the row
  /// comes back on its original position.
  final PendingRowDelete? pendingRowDelete;

  /// Whether [source]/[translations] hold this site's content. The editor form
  /// only renders when this is [ContentLoadStatus.ready]; the demo seed is
  /// [ContentLoadStatus.ready] from the start, because there the seed *is* the
  /// content.
  final ContentLoadStatus loadStatus;

  /// Whether the review lane shows only what changed (§B.4). Off by default;
  /// `Openen` in the publish dialog turns it on, because that is the one route
  /// where the owner already said which changes they came for.
  final bool onlyChangedFields;

  bool get isSourceMode => previewLanguage == sourceLanguage;

  /// Whether the draft holds anything the saved layer does not (§11i). This is
  /// a comparison, not a "was touched" flag: typing a value back to what is
  /// saved clears it again. It dims `Publish` and drives the exit warning.
  bool get unsavedChanges =>
      draftSource.isNotEmpty ||
      draftListOrder.isNotEmpty ||
      draftMediaKeys.isNotEmpty ||
      draftTranslations.values.any((fields) => fields.isNotEmpty);

  /// Source text as the fields show it: the draft on top of the saved layer.
  Map<String, String> get effectiveSource =>
      draftSource.isEmpty ? source : {...source, ...draftSource};

  /// Photos as the strip shows them: the draft on top of the saved layer.
  Map<String, List<String>> get effectiveMediaKeys => draftMediaKeys.isEmpty
      ? mediaKeys
      : {...mediaKeys, ...draftMediaKeys};

  /// The storage paths of one media slot, in display order.
  List<String> mediaPathsOf(String mediaKey) =>
      effectiveMediaKeys[mediaKey] ?? const [];

  /// Row order as the editor shows it: the draft on top of the saved layer.
  Map<String, List<String>> get effectiveListOrder => draftListOrder.isEmpty
      ? listOrder
      : {...listOrder, ...draftListOrder};

  /// Target locales in display order (source first, then the rest).
  List<String> get orderedLocales => [
    sourceLanguage,
    ...locales.where((l) => l != sourceLanguage),
  ];

  List<String> get targetLanguages =>
      locales.where((l) => l != sourceLanguage).toList();

  /// The editable fields for the current page (list rows are repeatable
  /// and derived from the content the owner sees, drafts included).
  List<EditorField> get fields =>
      effectiveFieldsFor(pageKey, effectiveListOrder);

  /// Every editable field across all pages (translate/publish scope).
  List<EditorField> get allFields => [
    for (final page in kPageCards.keys)
      ...effectiveFieldsFor(page, effectiveListOrder),
  ];

  /// The field with this key on the current page, or null when the schema and
  /// the content disagree (a row that is not there).
  EditorField? fieldFor(String key) {
    for (final field in fields) {
      if (field.key == key) return field;
    }
    return null;
  }

  /// The fields of one repeatable list on this page, in display order.
  List<EditorField> fieldsOfList(String listKey) =>
      fields.where((field) => field.listKey == listKey).toList();

  /// The row ids of one repeatable list, in display order.
  List<String> rowIdsOfList(String listKey) =>
      effectiveListOrder[listKey] ?? const [];

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

  /// Whether a field is **new** in this language: the row exists in the source
  /// but this language has never had a translation for it (§B.4). It shows as
  /// `Nieuw` rather than as an empty locked field — an empty string must never
  /// pass for "the owner's words".
  bool isFieldNew(String language, String key) {
    if (language == sourceLanguage) return false;
    // Nothing to translate is not something to review: an empty optional
    // field would otherwise sit in the changed count forever. The *effective*
    // source, because a row the owner just added and typed into is on screen
    // and its target counterpart is visibly empty — that is exactly the row
    // the design wants badged `Nieuw` (§B.4).
    if ((effectiveSource[key] ?? '').isEmpty) return false;
    final field = translatedField(language, key);
    if (field == null) return true;
    return field.isAuto && field.value.isEmpty;
  }

  /// Whether this field will read differently on the live site after the next
  /// publish — the delta the lane header, the card rollups and the publish
  /// dialog report (§D.1: "changed since the last publish").
  ///
  /// Three ways that happens, and all three count:
  ///
  /// * the row is new in this language (nothing to compare, everything to see);
  /// * the saved value differs from what is live (the owner wrote it, or a
  ///   translation already refreshed it);
  /// * the value is stale — machine output behind its source, which publish
  ///   *will* rewrite, so the live page changes even though nothing has been
  ///   typed.
  ///
  /// Measuring against what is live rather than against staleness alone is what
  /// keeps the number honest: a background re-translation refreshes wording the
  /// owner still has not seen, and a counter it can reset answers no question.
  bool isFieldChanged(String language, String key) {
    if (isFieldNew(language, key)) return true;
    if (isFieldStale(language, key)) return true;
    final published = publishedByLocale[language];
    // Nothing published yet means there is nothing to compare with; the two
    // checks above have already answered for the cases that matter.
    if (published == null) return false;
    return savedValueFor(language, key) != (published[key] ?? '');
  }

  /// Changed fields across the **whole site** for one language. Site-wide on
  /// purpose: it answers "what is there to review in this language", which
  /// does not depend on which tab happens to be open.
  int changedFieldCount(String language) =>
      allFields.where((f) => isFieldChanged(language, f.key)).length;

  /// Changed fields of one card on the current page — the `N gewijzigd`
  /// rollup in its header (§B.4). Derived from the built field paths, so a
  /// key without a field cannot be counted.
  int changedCountForCard(String language, String cardId) => fields
      .where((f) => f.cardId == cardId && isFieldChanged(language, f.key))
      .length;

  /// The changed fields of one page in one language — the number the publish
  /// dialog's per-page breakdown reports.
  List<EditorField> changedFieldsOnPage(String language, String page) => [
    for (final field in effectiveFieldsFor(page, effectiveListOrder))
      if (isFieldChanged(language, field.key)) field,
  ];

  /// The changed pages of a language the owner has opened this session.
  int reviewedChangedPageCount(String language) {
    final seen = reviewedPages[language] ?? const <String>{};
    return changedPages(language).where(seen.contains).length;
  }

  /// Whether every page with changes has been opened in this language — what
  /// the publish dialog reports as `Bekeken` (§D.2).
  bool isLanguageReviewed(String language) {
    final changed = changedPages(language);
    if (changed.isEmpty) return true;
    return reviewedChangedPageCount(language) == changed.length;
  }

  /// Pages of the site that have at least one changed field in this language
  /// — what the publish dialog reports per language (§D.2).
  List<String> changedPages(String language) => [
    for (final page in kPageCards.keys)
      if (effectiveFieldsFor(page, effectiveListOrder)
          .any((f) => isFieldChanged(language, f.key)))
        page,
  ];

  /// How many of the site's fields the owner has taken over in this language
  /// (§D.1, the second figure). Site-wide, like [changedFieldCount].
  int lockedFieldCount(String language) => allFields
      .where((f) => translatedField(language, f.key)?.isLocked ?? false)
      .length;

  /// Translatable fields of the site — the denominator of that counter.
  int get translatableFieldCount => allFields.length;

  /// The cards of the current page the review lane shows. With
  /// [onlyChangedFields] on, a card without a single changed field is gone
  /// entirely — header included (CONFORMANCE §5): a card kept as an empty
  /// husk is what makes a filtered lane unreadable.
  List<EditorCard> get visibleCards {
    final cards = kPageCards[pageKey] ?? const <EditorCard>[];
    if (!onlyChangedFields || isSourceMode) return cards;
    return [
      for (final card in cards)
        if (changedCountForCard(previewLanguage, card.id) > 0) card,
    ];
  }

  /// Every field's value for the previewed language, keyed by CMS address
  /// (`cabin/main:hero.title`). This is what the live preview renders: the
  /// draft included, so the frame shows what is in the fields and not what was
  /// last saved. Fields across all pages, because the preview is the whole site.
  Map<String, String> get previewFieldValues => {
    for (final field in allFields)
      if (WebsiteContentRepository.locationOf(field.key) case final location?)
        location.address: valueFor(previewLanguage, field.key),
  };

  SiteContentState copyWith({
    String? sourceLanguage,
    List<String>? locales,
    String? pageKey,
    String? previewLanguage,
    PreviewDevice? previewDevice,
    bool? previewVisible,
    Map<String, String>? source,
    Map<String, Map<String, TranslatedField>>? translations,
    Map<String, List<String>>? listOrder,
    Map<String, List<String>>? mediaKeys,
    Map<String, Map<String, String>>? publishedByLocale,
    Map<String, List<String>>? draftMediaKeys,
    Map<String, String>? draftSource,
    Map<String, Map<String, TranslatedField>>? draftTranslations,
    Map<String, List<String>>? draftListOrder,
    bool? dirty,
    bool? publishOpen,
    Set<String>? translating,
    String? errorMessage,
    DomainError? loadError,
    String? previewDomain,
    DateTime? lastSavedAt,
    bool? saving,
    Map<String, Set<String>>? reviewedPages,
    PendingAutoSwitch? pendingAutoSwitch,
    PendingRowDelete? pendingRowDelete,
    ContentLoadStatus? loadStatus,
    bool? onlyChangedFields,
    bool clearDraft = false,
    bool clearPendingAutoSwitch = false,
    bool clearPendingRowDelete = false,
    bool clearError = false,
    bool clearLoadError = false,
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
      listOrder: listOrder ?? this.listOrder,
      mediaKeys: mediaKeys ?? this.mediaKeys,
      publishedByLocale: publishedByLocale ?? this.publishedByLocale,
      draftMediaKeys: clearDraft
          ? const {}
          : (draftMediaKeys ?? this.draftMediaKeys),
      draftSource: clearDraft ? const {} : (draftSource ?? this.draftSource),
      draftTranslations: clearDraft
          ? const {}
          : (draftTranslations ?? this.draftTranslations),
      draftListOrder: clearDraft
          ? const {}
          : (draftListOrder ?? this.draftListOrder),
      dirty: dirty ?? this.dirty,
      publishOpen: publishOpen ?? this.publishOpen,
      translating: translating ?? this.translating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      previewDomain: previewDomain ?? this.previewDomain,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      saving: saving ?? this.saving,
      reviewedPages: reviewedPages ?? this.reviewedPages,
      pendingAutoSwitch: clearPendingAutoSwitch
          ? null
          : (pendingAutoSwitch ?? this.pendingAutoSwitch),
      pendingRowDelete: clearPendingRowDelete
          ? null
          : (pendingRowDelete ?? this.pendingRowDelete),
      loadStatus: loadStatus ?? this.loadStatus,
      onlyChangedFields: onlyChangedFields ?? this.onlyChangedFields,
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
    listOrder,
    mediaKeys,
    publishedByLocale,
    draftMediaKeys,
    draftSource,
    draftTranslations,
    draftListOrder,
    dirty,
    publishOpen,
    translating,
    errorMessage,
    loadError,
    previewDomain,
    lastSavedAt,
    saving,
    reviewedPages,
    pendingAutoSwitch,
    pendingRowDelete,
    loadStatus,
    onlyChangedFields,
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

/// A list row the owner just deleted, kept in memory so one misclick is
/// undoable. Carries the row's position so undo puts it back where it was —
/// not at the end, which would be a second surprise.
class PendingRowDelete extends Equatable {
  const PendingRowDelete({
    required this.listKey,
    required this.rowId,
    required this.index,
    required this.sourceValues,
    required this.translations,
    required this.nestedOrder,
  });

  final String listKey;
  final String rowId;
  final int index;

  /// The row's source-language values, keyed by field key.
  final Map<String, String> sourceValues;

  /// The row's translated fields, per language.
  final Map<String, Map<String, TranslatedField>> translations;

  /// Row orders of lists nested inside this row (a group's items), so undo
  /// brings the whole group back and not just its title.
  final Map<String, List<String>> nestedOrder;

  @override
  List<Object?> get props => [
    listKey,
    rowId,
    index,
    sourceValues,
    translations,
    nestedOrder,
  ];
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
    String Function()? rowIdGenerator,
  }) : _translationService = translationService,
       _repository = repository,
       _siteId = siteId,
       _rowIdGenerator = rowIdGenerator ?? generateRowId,
       // A persistent editor has no content until loadContent brings it in.
       // Starting it on the seed would put demo copy in the owner's fields.
       super(
         repository != null && siteId != null ? _pendingState() : _seedState(),
       );

  final TranslationService _translationService;
  final WebsiteContentRepository? _repository;
  final String? _siteId;

  /// Makes the id a new row carries for life. Injectable so tests are
  /// deterministic; the default is [generateRowId].
  final String Function() _rowIdGenerator;

  bool get _persistent => _repository != null && _siteId != null;

  /// Hydrates the state from the repository. No-op without persistence; on
  /// failure the state stays empty, [loadStatus] becomes
  /// [ContentLoadStatus.failed] and the [DomainError] is surfaced as a blocking
  /// error — the editor shows why it is empty instead of a form full of content
  /// that belongs to no site.
  Future<void> loadContent() async {
    if (!_persistent) return;
    emit(state.copyWith(loadStatus: ContentLoadStatus.loading));
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
          listOrder: content.listOrder,
          mediaKeys: content.mediaKeys,
          publishedByLocale: content.publishedByLocale,
          previewDomain: content.previewDomain,
          dirty: false,
          loadStatus: ContentLoadStatus.ready,
          clearDraft: true,
          clearError: true,
          clearLoadError: true,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          loadStatus: ContentLoadStatus.failed,
          loadError: error is DomainError
              ? error
              : DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// The state of a persistent editor before its content arrives: no fields, no
  /// translations, no property name — nothing to mistake for the site's own
  /// copy. Language and locales are placeholders until the site's row says what
  /// they are.
  static SiteContentState _pendingState() => const SiteContentState(
    propertyName: '',
    sourceLanguage: kDefaultSourceLanguage,
    locales: [kDefaultSourceLanguage],
    pageKey: 'home',
    previewLanguage: kDefaultSourceLanguage,
    previewDevice: PreviewDevice.web,
    previewVisible: true,
    source: {},
    translations: {},
    dirty: false,
    publishOpen: false,
    translating: {},
    loadStatus: ContentLoadStatus.loading,
  );

  static SiteContentState _seedState() {
    final source = Map<String, String>.from(WebsiteSeed.home['nl']!);
    final seedFields = [
      for (final page in kPageCards.keys)
        ...effectiveFieldsFor(page, WebsiteSeed.listOrder),
    ];
    final translations = <String, Map<String, TranslatedField>>{};
    for (final lang in WebsiteSeed.locales.where((l) => l != 'nl')) {
      final seed = WebsiteSeed.home[lang]!;
      translations[lang] = {
        for (final field in seedFields)
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
      listOrder: WebsiteSeed.listOrder,
      // The demo site presents itself as published (nothing dirty, nothing
      // stale), so what it starts with *is* what is live: the delta counters
      // then measure the same thing they measure against a real site.
      publishedByLocale: {
        for (final language in WebsiteSeed.locales)
          language: {
            for (final field in seedFields)
              field.key: language == WebsiteSeed.sourceLanguage
                  ? (source[field.key] ?? '')
                  : (translations[language]?[field.key]?.value ?? ''),
          },
      },
      dirty: false,
      publishOpen: false,
      translating: const {},
    );
  }

  void selectPage(String pageKey) => emit(
    state.copyWith(
      pageKey: pageKey,
      // Opening a page in a target language is reviewing that page.
      reviewedPages: state.isSourceMode
          ? state.reviewedPages
          : _withPageSeen(state.previewLanguage, pageKey),
      clearPendingAutoSwitch: true,
    ),
  );

  /// The reviewed map with one more (language, page) recorded.
  Map<String, Set<String>> _withPageSeen(String language, String page) => {
    ...state.reviewedPages,
    language: {...?state.reviewedPages[language], page},
  };

  /// Opens the review lane exactly where the publish dialog pointed: this
  /// language, this page, with the changed-only filter on (§D.2). That route is
  /// the only one that makes reviewing 250 fields tractable, so it sets all
  /// three at once instead of leaving the owner to.
  void openReview(String language, String page) {
    final isTarget = language != state.sourceLanguage;
    emit(
      state.copyWith(
        previewLanguage: language,
        pageKey: page,
        onlyChangedFields: isTarget,
        reviewedPages: isTarget
            ? _withPageSeen(language, page)
            : state.reviewedPages,
        clearPendingAutoSwitch: true,
      ),
    );
    if (isTarget && state.isLanguageStale(language)) {
      // ignore: discarded_futures — the lane renders the result when it lands.
      translateNow([language]);
    }
  }

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
        reviewedPages: isTarget
            ? _withPageSeen(language, state.pageKey)
            : state.reviewedPages,
        clearPendingAutoSwitch: true,
      ),
    );
    if (isTarget && state.isLanguageStale(language)) {
      // ignore: discarded_futures — the lane renders the result when it lands;
      // failures surface as a message, the old text stays.
      translateNow([language]);
    }
  }

  /// Records the photos chosen for one media slot, in the order the picker
  /// handed them back. A draft like every other edit; photos are shared across
  /// languages, so this is only the source language's to change.
  void setMediaPaths(String mediaKey, List<String> paths) {
    assert(
      state.isSourceMode,
      'Photos are shared across every language; they are chosen in the source.',
    );
    final draft = Map<String, List<String>>.from(state.draftMediaKeys);
    if (_sameOrder(paths, state.mediaKeys[mediaKey])) {
      draft.remove(mediaKey);
    } else {
      draft[mediaKey] = paths;
    }
    emit(state.copyWith(draftMediaKeys: draft));
  }

  /// Moves one photo within its slot. The first photo is the share image, so
  /// this order is content and not a preference.
  void moveMediaPath(String mediaKey, int oldIndex, int newIndex) {
    assert(
      state.isSourceMode,
      'Photos are shared across every language; they are ordered in the source.',
    );
    final paths = [...state.mediaPathsOf(mediaKey)];
    if (oldIndex < 0 || oldIndex >= paths.length) return;
    newIndex = newIndex.clamp(0, paths.length - 1);
    if (newIndex == oldIndex) return;
    paths.insert(newIndex, paths.removeAt(oldIndex));
    setMediaPaths(mediaKey, paths);
  }

  /// Drops one photo from a slot. The strip keeps the minimum honest, so this
  /// only has to do the removal.
  void removeMediaPath(String mediaKey, int index) {
    final paths = [...state.mediaPathsOf(mediaKey)];
    if (index < 0 || index >= paths.length) return;
    paths.removeAt(index);
    setMediaPaths(mediaKey, paths);
  }

  /// Turns the review lane's `Alleen gewijzigd` filter on or off (§B.4).
  void setOnlyChangedFields(bool value) =>
      emit(state.copyWith(onlyChangedFields: value));

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

  /// Appends an empty row to a repeatable list (source language; targets
  /// start as fresh empty auto fields so they translate on publish). A draft,
  /// like every edit — the new row's id goes into the draft order.
  void addRow(String listKey) {
    // §B.4: structure is the source language's. The UI turns these actions off
    // in a target language, but an assert is the rule — a convention that only
    // lives in a widget is one refactor away from being gone.
    assert(
      state.isSourceMode,
      'Rows are added, removed and reordered in the source language only; '
      'a target language owns its text, not the structure.',
    );

    assert(
      state.isSourceMode,
      'Structure belongs to the source language: addRow must not be reachable '
      'from a translation lane (README fase 2 §B.4).',
    );
    final rowId = _rowIdGenerator();
    final keys = _rowFieldKeys(listKey, rowId);

    final order = [...?state.effectiveListOrder[listKey], rowId];
    final draftListOrder = Map<String, List<String>>.from(
      state.draftListOrder,
    )..[listKey] = order;
    // A new group starts with an empty item list, so its nested list exists.
    for (final nested in _nestedListKeys(listKey, rowId)) {
      draftListOrder[nested] = const [];
    }

    final draftSource = Map<String, String>.from(state.draftSource);
    final draftTranslations = _cloneDraftTranslations();
    for (final key in keys) {
      draftSource[key] = '';
      for (final language in state.targetLanguages) {
        // A row added in the source shows up in every target language as a
        // fresh *auto* field, never as an empty locked one — a blank string
        // must not pass for "the owner's words" (§B.4).
        (draftTranslations[language] ??= {})[key] = TranslatedField(
          value: '',
          status: FieldTranslationStatus.auto,
          sourceHash: sourceHashOf(''),
        );
      }
    }
    emit(
      state.copyWith(
        draftSource: draftSource,
        draftTranslations: draftTranslations,
        draftListOrder: draftListOrder,
        clearPendingRowDelete: true,
      ),
    );
  }

  /// Deletes the row at [index] of a repeatable list, in every language, with
  /// one in-session undo that restores it on its original position.
  void removeRow(String listKey, int index) {
    final order = [...?state.effectiveListOrder[listKey]];
    if (index < 0 || index >= order.length) return;
    removeRowById(listKey, order[index]);
  }

  /// Deletes one row by its stable id.
  void removeRowById(String listKey, String rowId) {
    // §B.4: structure is the source language's. The UI turns these actions off
    // in a target language, but an assert is the rule — a convention that only
    // lives in a widget is one refactor away from being gone.
    assert(
      state.isSourceMode,
      'Rows are added, removed and reordered in the source language only; '
      'a target language owns its text, not the structure.',
    );

    assert(
      state.isSourceMode,
      'Structure belongs to the source language: removeRow must not be '
      'reachable from a translation lane (README fase 2 §B.4).',
    );
    final order = [...?state.effectiveListOrder[listKey]];
    final index = order.indexOf(rowId);
    if (index < 0) return;

    final keys = _rowFieldKeys(listKey, rowId);
    final nested = _nestedListKeys(listKey, rowId);
    // Everything the row owns, held for the undo: its own fields, its
    // translations, and — for a group — the rows nested inside it.
    final nestedKeys = <String>[];
    final nestedOrder = <String, List<String>>{};
    for (final key in nested) {
      final ids = [...?state.effectiveListOrder[key]];
      nestedOrder[key] = ids;
      for (final id in ids) {
        nestedKeys.addAll(_rowFieldKeys(key, id));
      }
    }
    final allKeys = [...keys, ...nestedKeys];

    final pending = PendingRowDelete(
      listKey: listKey,
      rowId: rowId,
      index: index,
      sourceValues: {
        for (final key in allKeys) key: state.valueFor(state.sourceLanguage, key),
      },
      translations: {
        for (final language in state.targetLanguages)
          language: {
            for (final key in allKeys)
              if (state.translatedField(language, key) case final field?)
                key: field,
          },
      },
      nestedOrder: nestedOrder,
    );

    order.removeAt(index);
    final draftListOrder = Map<String, List<String>>.from(state.draftListOrder)
      ..[listKey] = order;
    for (final key in nested) {
      draftListOrder.remove(key);
    }

    // The row's values leave the draft with it; the saved layer still holds
    // them until the save, which is what makes the undo cheap.
    final draftSource = Map<String, String>.from(state.draftSource)
      ..removeWhere((key, _) => allKeys.contains(key));
    final draftTranslations = _cloneDraftTranslations();
    for (final fields in draftTranslations.values) {
      fields.removeWhere((key, _) => allKeys.contains(key));
    }

    emit(
      state.copyWith(
        draftSource: draftSource,
        draftTranslations: draftTranslations,
        draftListOrder: draftListOrder,
        pendingRowDelete: pending,
      ),
    );
  }

  /// Puts the last deleted row back, on its original position, with its text
  /// and its translations (§B.4: undo brings the row *and* its translations).
  void undoRowDelete() {
    final pending = state.pendingRowDelete;
    if (pending == null) return;

    final order = [...?state.effectiveListOrder[pending.listKey]];
    final at = pending.index.clamp(0, order.length);
    order.insert(at, pending.rowId);

    final draftListOrder = Map<String, List<String>>.from(state.draftListOrder)
      ..[pending.listKey] = order
      ..addAll(pending.nestedOrder);

    final draftSource = Map<String, String>.from(state.draftSource)
      ..addAll(pending.sourceValues);
    final draftTranslations = _cloneDraftTranslations();
    pending.translations.forEach((language, fields) {
      (draftTranslations[language] ??= {}).addAll(fields);
    });

    emit(
      state.copyWith(
        draftSource: draftSource,
        draftTranslations: draftTranslations,
        draftListOrder: draftListOrder,
        clearPendingRowDelete: true,
      ),
    );
  }

  /// Reorders a repeatable list's rows (drag grip). Only the order changes:
  /// every value — source text, translations, locked/auto status — is keyed
  /// by the row's stable id and travels with it untouched.
  void moveRow(String listKey, int oldIndex, int newIndex) {
    // §B.4: structure is the source language's. The UI turns these actions off
    // in a target language, but an assert is the rule — a convention that only
    // lives in a widget is one refactor away from being gone.
    assert(
      state.isSourceMode,
      'Rows are added, removed and reordered in the source language only; '
      'a target language owns its text, not the structure.',
    );

    assert(
      state.isSourceMode,
      'Structure belongs to the source language: moveRow must not be reachable '
      'from a translation lane (README fase 2 §B.4).',
    );
    final order = [...?state.effectiveListOrder[listKey]];
    if (oldIndex < 0 || oldIndex >= order.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    newIndex = newIndex.clamp(0, order.length - 1);
    if (newIndex == oldIndex) return;

    final id = order.removeAt(oldIndex);
    order.insert(newIndex, id);

    final draftListOrder = Map<String, List<String>>.from(
      state.draftListOrder,
    );
    // Ordering back to the saved order is not a change.
    if (_sameOrder(order, state.listOrder[listKey])) {
      draftListOrder.remove(listKey);
    } else {
      draftListOrder[listKey] = order;
    }
    emit(state.copyWith(draftListOrder: draftListOrder));
  }

  static bool _sameOrder(List<String> a, List<String>? b) {
    if (b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Every field key a row of [listKey] owns, for the row id given.
  List<String> _rowFieldKeys(String listKey, String rowId) {
    final row = schemaRowForList(listKey);
    switch (row) {
      case ListRow(:final sub):
        return [listFieldKey(listKey, rowId, sub)];
      case PairListRow(:final labelSub, :final valueSub):
        return [
          listFieldKey(listKey, rowId, labelSub),
          listFieldKey(listKey, rowId, valueSub),
        ];
      case RowListRow(:final subs, :final media):
        return [
          for (final sub in subs) listFieldKey(listKey, rowId, sub.sub),
          if (media) listFieldKey(listKey, rowId, 'alt'),
        ];
      case GroupListRow(
        :final titleSub,
        :final introSub,
        :final itemsSub,
        :final itemsListKey,
      ):
        // A group's own list key ends in the items suffix; its rows are items.
        if (listKey.endsWith('.$itemsListKey')) {
          return [listFieldKey(listKey, rowId, itemsSub)];
        }
        return [
          listFieldKey(listKey, rowId, titleSub),
          if (introSub != null) listFieldKey(listKey, rowId, introSub),
        ];
      case FieldRow() || MediaRow() || ExternalRow() || null:
        return const [];
    }
  }

  /// The nested list keys a row of [listKey] encloses (a group's items).
  List<String> _nestedListKeys(String listKey, String rowId) {
    final row = schemaRowForList(listKey);
    if (row is! GroupListRow) return const [];
    if (listKey.endsWith('.${row.itemsListKey}')) return const [];
    return [groupItemsListKey(listKey, rowId, row.itemsListKey)];
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
    // Nothing on screen is this site's content yet; writing it back would
    // overwrite the owner's pages with an empty or borrowed form.
    if (state.loadStatus != ContentLoadStatus.ready) return;

    final mergedSource = {...state.source, ...state.draftSource};
    final mergedOrder = {...state.listOrder, ...state.draftListOrder};
    final mergedMedia = {...state.mediaKeys, ...state.draftMediaKeys};
    final changedFields = <(String, String, TranslatedField)>[
      for (final entry in state.draftTranslations.entries)
        for (final field in entry.value.entries)
          (entry.key, field.key, field.value),
    ];
    final sourceChanged = state.draftSource.isNotEmpty ||
        state.draftListOrder.isNotEmpty ||
        state.draftMediaKeys.isNotEmpty;

    emit(state.copyWith(saving: true, clearError: true));
    if (_persistent) {
      try {
        if (sourceChanged) {
          await _repository!.saveSourceDraft(
            siteId: _siteId!,
            sourceLanguage: state.sourceLanguage,
            fields: mergedSource,
            listOrders: state.draftListOrder,
            mediaKeys: state.draftMediaKeys,
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
    final remainingOrder = {
      for (final entry in state.draftListOrder.entries)
        if (!_sameOrder(entry.value, mergedOrder[entry.key]))
          entry.key: entry.value,
    };

    emit(
      state.copyWith(
        source: mergedSource,
        translations: translations,
        listOrder: mergedOrder,
        mediaKeys: mergedMedia,
        draftMediaKeys: const {},
        draftSource: remainingSource,
        draftTranslations: remainingTranslations,
        draftListOrder: remainingOrder,
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

  /// Clears the load failure after its dialog has been dismissed, so a retried
  /// load that fails again is shown again.
  void clearLoadError() => emit(state.copyWith(clearLoadError: true));

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
    if (state.loadStatus != ContentLoadStatus.ready) return;
    final targets = state.targetLanguages
        .where((language) => !skipLanguages.contains(language))
        .toList();
    await translateNow(targets);
    if (_persistent) {
      try {
        await _repository!.publishAll(
          siteId: _siteId!,
          sourceLocale: state.sourceLanguage,
          listOrders: state.listOrder,
          mediaKeys: state.mediaKeys,
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
    // What just went out *is* live now, so the delta starts from here. A
    // skipped language keeps its old baseline, because its live pages did not
    // change either.
    final published = {
      for (final entry in state.publishedByLocale.entries) entry.key: entry.value,
      state.sourceLanguage: {
        for (final field in state.allFields)
          field.key: state.savedValueFor(state.sourceLanguage, field.key),
      },
      for (final language in targets)
        language: {
          for (final field in state.allFields)
            field.key: state.savedValueFor(language, field.key),
        },
    };

    emit(
      state.copyWith(
        dirty: false,
        publishOpen: false,
        publishedByLocale: published,
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
