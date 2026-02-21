import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/core/config/app_config.dart';
import 'package:hosthub_console/features/cms/data/cms_repository.dart';

enum CmsStatus { initial, loading, loaded, error }

class CmsState extends Equatable {
  const CmsState({
    required this.status,
    required this.documents,
    this.site,
    this.primaryDomain,
    this.selectedLocale,
    this.error,
    this.dirtyContent = const {},
    this.savingDocuments = const {},
    this.publishingDocuments = const {},
    this.versions,
    this.versionHistoryDocId,
  });

  const CmsState.initial()
    : status = CmsStatus.initial,
      documents = const [],
      site = null,
      primaryDomain = null,
      selectedLocale = null,
      error = null,
      dirtyContent = const {},
      savingDocuments = const {},
      publishingDocuments = const {},
      versions = null,
      versionHistoryDocId = null;

  final CmsStatus status;
  final SiteSummary? site;
  final String? primaryDomain;
  final List<ContentDocument> documents;
  final String? selectedLocale;
  final DomainError? error;

  /// Pending content edits keyed by document ID.
  final Map<String, Map<String, dynamic>> dirtyContent;

  /// Document IDs currently being saved.
  final Set<String> savingDocuments;

  /// Document IDs currently being published.
  final Set<String> publishingDocuments;

  /// Version history for the selected document (null = not loaded).
  final List<DocumentVersion>? versions;

  /// Which document's version history is currently shown.
  final String? versionHistoryDocId;

  bool get isDirty => dirtyContent.isNotEmpty;
  bool get isSaving => savingDocuments.isNotEmpty;
  bool get isPublishing => publishingDocuments.isNotEmpty;

  /// Documents filtered by the currently selected locale.
  List<ContentDocument> get filteredDocuments {
    if (selectedLocale == null) return documents;
    return documents.where((d) => d.locale == selectedLocale).toList();
  }

  ContentDocument? documentFor(String contentType, String slug) {
    return filteredDocuments.cast<ContentDocument?>().firstWhere(
      (d) => d!.contentType == contentType && d.slug == slug,
      orElse: () => null,
    );
  }

  /// The effective content for a document: dirty (edited) or persisted.
  Map<String, dynamic> effectiveContent(ContentDocument doc) {
    return dirtyContent[doc.id] ?? doc.content;
  }

  /// Preview URL for opening the website with CMS content.
  String get previewUrl {
    final locale = selectedLocale ?? site?.defaultLocale ?? 'en';
    final configuredDomain = kCmsPreviewDomain.trim();
    final resolvedDomain = configuredDomain.isNotEmpty
        ? configuredDomain
        : (primaryDomain ?? 'localhost:3001');
    final normalizedDomain = resolvedDomain
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
    final scheme =
        normalizedDomain.contains('localhost') ||
            normalizedDomain.startsWith('127.0.0.1')
        ? 'http'
        : 'https';
    return '$scheme://$normalizedDomain/preview/$locale';
  }

  CmsState copyWith({
    CmsStatus? status,
    SiteSummary? site,
    String? primaryDomain,
    List<ContentDocument>? documents,
    String? selectedLocale,
    DomainError? error,
    Map<String, Map<String, dynamic>>? dirtyContent,
    Set<String>? savingDocuments,
    Set<String>? publishingDocuments,
    List<DocumentVersion>? versions,
    String? versionHistoryDocId,
    bool clearVersions = false,
  }) {
    return CmsState(
      status: status ?? this.status,
      site: site ?? this.site,
      primaryDomain: primaryDomain ?? this.primaryDomain,
      documents: documents ?? this.documents,
      selectedLocale: selectedLocale ?? this.selectedLocale,
      error: error,
      dirtyContent: dirtyContent ?? this.dirtyContent,
      savingDocuments: savingDocuments ?? this.savingDocuments,
      publishingDocuments: publishingDocuments ?? this.publishingDocuments,
      versions: clearVersions ? null : (versions ?? this.versions),
      versionHistoryDocId: clearVersions
          ? null
          : (versionHistoryDocId ?? this.versionHistoryDocId),
    );
  }

  @override
  List<Object?> get props => [
    status,
    site,
    primaryDomain,
    documents,
    selectedLocale,
    error,
    dirtyContent,
    savingDocuments,
    publishingDocuments,
    versions,
    versionHistoryDocId,
  ];
}

class CmsCubit extends Cubit<CmsState> {
  CmsCubit({required CmsRepository cmsRepository})
    : _cmsRepository = cmsRepository,
      super(const CmsState.initial());

  final CmsRepository _cmsRepository;

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadSiteContent({required String siteId}) async {
    if (state.status == CmsStatus.loading) return;
    emit(state.copyWith(status: CmsStatus.loading, error: null));
    try {
      final results = await Future.wait([
        _cmsRepository.fetchSite(siteId),
        _cmsRepository.fetchSiteDocuments(siteId: siteId),
        _cmsRepository.fetchPrimaryDomain(siteId),
      ]);
      if (isClosed) return;
      final site = results[0] as SiteSummary?;
      final documents = results[1] as List<ContentDocument>;
      final domain = results[2] as String?;
      emit(
        state.copyWith(
          status: CmsStatus.loaded,
          site: site,
          documents: documents,
          primaryDomain: domain,
          selectedLocale: site?.defaultLocale ?? 'en',
        ),
      );
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CmsStatus.error,
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Locale
  // ---------------------------------------------------------------------------

  void selectLocale(String locale) {
    emit(state.copyWith(selectedLocale: locale));
  }

  // ---------------------------------------------------------------------------
  // Dirty tracking
  // ---------------------------------------------------------------------------

  /// Mark a document as having unsaved edits.
  void markDocumentDirty(String documentId, Map<String, dynamic> content) {
    final dirty = Map<String, Map<String, dynamic>>.from(state.dirtyContent);
    dirty[documentId] = content;
    emit(state.copyWith(dirtyContent: dirty));
  }

  /// Discard unsaved edits for a document.
  void discardChanges(String documentId) {
    final dirty = Map<String, Map<String, dynamic>>.from(state.dirtyContent);
    dirty.remove(documentId);
    emit(state.copyWith(dirtyContent: dirty));
  }

  /// Discard all unsaved edits.
  void discardAllChanges() {
    emit(state.copyWith(dirtyContent: const {}));
  }

  // ---------------------------------------------------------------------------
  // Save draft
  // ---------------------------------------------------------------------------

  /// Save a single document as draft.
  Future<void> saveDraft(String documentId) async {
    final content = state.dirtyContent[documentId];
    if (content == null) return;

    emit(
      state.copyWith(savingDocuments: {...state.savingDocuments, documentId}),
    );
    try {
      await _cmsRepository.saveDocumentDraft(
        documentId: documentId,
        content: content,
      );
      if (isClosed) return;

      final docs = await _cmsRepository.fetchSiteDocuments(
        siteId: state.site!.id,
      );
      if (isClosed) return;

      final dirty = Map<String, Map<String, dynamic>>.from(state.dirtyContent)
        ..remove(documentId);
      emit(
        state.copyWith(
          documents: docs,
          dirtyContent: dirty,
          savingDocuments: {...state.savingDocuments}..remove(documentId),
        ),
      );
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          savingDocuments: {...state.savingDocuments}..remove(documentId),
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// Save all dirty documents as drafts.
  Future<void> saveAllDrafts() async {
    final dirtyIds = state.dirtyContent.keys.toList();
    for (final docId in dirtyIds) {
      await saveDraft(docId);
      if (isClosed) return;
    }
  }

  // ---------------------------------------------------------------------------
  // Publish
  // ---------------------------------------------------------------------------

  /// Publish a single document (creates version snapshot).
  Future<void> publishDoc(String documentId) async {
    final doc = state.documents.firstWhere((d) => d.id == documentId);
    final content = state.dirtyContent[documentId] ?? doc.content;

    emit(
      state.copyWith(
        publishingDocuments: {...state.publishingDocuments, documentId},
      ),
    );
    try {
      await _cmsRepository.publishDocument(
        documentId: documentId,
        content: content,
      );
      if (isClosed) return;

      final docs = await _cmsRepository.fetchSiteDocuments(
        siteId: state.site!.id,
      );
      if (isClosed) return;

      final dirty = Map<String, Map<String, dynamic>>.from(state.dirtyContent)
        ..remove(documentId);
      emit(
        state.copyWith(
          documents: docs,
          dirtyContent: dirty,
          publishingDocuments: {...state.publishingDocuments}
            ..remove(documentId),
        ),
      );
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          publishingDocuments: {...state.publishingDocuments}
            ..remove(documentId),
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// Publish all documents for the current locale.
  Future<void> publishAllForLocale() async {
    final docs = state.filteredDocuments;
    for (final doc in docs) {
      await publishDoc(doc.id);
      if (isClosed) return;
    }
  }

  // ---------------------------------------------------------------------------
  // Version history
  // ---------------------------------------------------------------------------

  Future<void> loadVersionHistory(String documentId) async {
    try {
      final versions = await _cmsRepository.fetchDocumentVersions(documentId);
      if (isClosed) return;
      emit(state.copyWith(versions: versions, versionHistoryDocId: documentId));
    } catch (error, stack) {
      if (isClosed) return;
      emit(state.copyWith(error: DomainError.from(error, stack: stack)));
    }
  }

  void clearVersionHistory() {
    emit(state.copyWith(clearVersions: true));
  }

  /// Restore a version's content as a draft for review.
  Future<void> restoreVersion(
    String documentId,
    DocumentVersion version,
  ) async {
    try {
      await _cmsRepository.saveDocumentDraft(
        documentId: documentId,
        content: version.content,
      );
      if (isClosed) return;

      final docs = await _cmsRepository.fetchSiteDocuments(
        siteId: state.site!.id,
      );
      if (isClosed) return;

      // Clear dirty state for this doc since content is now persisted as draft
      final dirty = Map<String, Map<String, dynamic>>.from(state.dirtyContent)
        ..remove(documentId);
      emit(state.copyWith(documents: docs, dirtyContent: dirty));
    } catch (error, stack) {
      if (isClosed) return;
      emit(state.copyWith(error: DomainError.from(error, stack: stack)));
    }
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  void clearError() {
    if (state.error == null) return;
    emit(state.copyWith(error: null));
  }
}
