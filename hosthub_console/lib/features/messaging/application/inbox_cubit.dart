import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/messaging/domain/messaging_repository.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';

enum InboxStatus { initial, loading, loaded, error }

/// The three views of the list.
///
/// `action` is a derived question — is the last word the guest's? — not a flag
/// anyone maintains, which is exactly why its count can be trusted.
enum InboxFilter { all, unread, action }

class InboxState extends Equatable {
  const InboxState({
    this.status = InboxStatus.initial,
    this.threads = const [],
    this.propertyIds = const [],
    this.selectedThreadId,
    this.selectedThread,
    this.filter = InboxFilter.all,
    this.query = '',
    this.draftsByThreadId = const {},
    this.translationsByMessageId = const {},
    this.translatedMessageIds = const {},
    this.translatingThreadId,
    this.isRefreshing = false,
    this.isSending = false,
    this.lastUpdated,
    this.error,
    this.loadFailed = false,
  });

  final InboxStatus status;

  /// Every thread of the properties in scope, newest conversation first.
  final List<MessageThread> threads;
  final List<int> propertyIds;

  final String? selectedThreadId;

  /// The open conversation with its history. Separate from [threads], whose
  /// rows only ever carry a preview.
  final MessageThread? selectedThread;

  final InboxFilter filter;
  final String query;

  /// Composer text per thread, kept here and never written to `messages`.
  ///
  /// Same model as the website editor's draft: a concept is explicit, not
  /// half-sent. It survives switching threads so the owner can draft a reply
  /// here and paste it at the source when this one cannot send.
  final Map<String, String> draftsByThreadId;

  /// Translations fetched for individual messages, never stored anywhere else.
  final Map<String, String> translationsByMessageId;

  /// Which messages are currently *showing* their translation. Toggling back to
  /// the original keeps the fetched text so it costs nothing the second time.
  final Set<String> translatedMessageIds;

  final String? translatingThreadId;
  final bool isRefreshing;
  final bool isSending;
  final DateTime? lastUpdated;
  final DomainError? error;

  /// The first load failed and there is nothing to show.
  ///
  /// A separate flag from [error] because the two get different treatment: a
  /// failed first load blocks with a retry, a failed action is a toast over the
  /// data that is still there.
  final bool loadFailed;

  /// Threads for the current filter and search, archived ones excluded.
  List<MessageThread> visibleThreads({
    Map<int, String> propertyNames = const {},
    DateTime? now,
  }) {
    final moment = now ?? DateTime.now();
    return [
      for (final thread in threads)
        if (!thread.isArchived &&
            !thread.isSnoozed(moment) &&
            _matchesFilter(thread) &&
            thread.matches(
              query,
              propertyName: propertyNames[thread.propertyId],
            ))
          thread,
    ];
  }

  bool _matchesFilter(MessageThread thread) {
    switch (filter) {
      case InboxFilter.all:
        return true;
      case InboxFilter.unread:
        return thread.isUnread;
      case InboxFilter.action:
        return thread.awaitingHost;
    }
  }

  /// The count on a filter segment, over the same set the segment would show —
  /// so a `3` always opens on three rows.
  int countFor(InboxFilter filter, {DateTime? now}) {
    final moment = now ?? DateTime.now();
    return threads.where((thread) {
      if (thread.isArchived || thread.isSnoozed(moment)) return false;
      switch (filter) {
        case InboxFilter.all:
          return true;
        case InboxFilter.unread:
          return thread.isUnread;
        case InboxFilter.action:
          return thread.awaitingHost;
      }
    }).length;
  }

  /// The rail badge: conversations still waiting on the owner, in this scope.
  ///
  /// Takes [now] like [countFor] does. A snoozed conversation leaves the badge
  /// and comes back when its time passes, so the count is a function of the
  /// clock — and a hidden clock read is one nobody can test and one that makes
  /// the badge disagree with the list it opens.
  int unreadCount({DateTime? now}) => countFor(InboxFilter.unread, now: now);

  String draftFor(String threadId) => draftsByThreadId[threadId] ?? '';

  InboxState copyWith({
    InboxStatus? status,
    List<MessageThread>? threads,
    List<int>? propertyIds,
    String? selectedThreadId,
    MessageThread? selectedThread,
    bool clearSelection = false,
    InboxFilter? filter,
    String? query,
    Map<String, String>? draftsByThreadId,
    Map<String, String>? translationsByMessageId,
    Set<String>? translatedMessageIds,
    String? translatingThreadId,
    bool clearTranslating = false,
    bool? isRefreshing,
    bool? isSending,
    DateTime? lastUpdated,
    DomainError? error,
    bool clearError = false,
    bool? loadFailed,
  }) {
    return InboxState(
      status: status ?? this.status,
      threads: threads ?? this.threads,
      propertyIds: propertyIds ?? this.propertyIds,
      selectedThreadId: clearSelection
          ? null
          : (selectedThreadId ?? this.selectedThreadId),
      selectedThread: clearSelection
          ? null
          : (selectedThread ?? this.selectedThread),
      filter: filter ?? this.filter,
      query: query ?? this.query,
      draftsByThreadId: draftsByThreadId ?? this.draftsByThreadId,
      translationsByMessageId:
          translationsByMessageId ?? this.translationsByMessageId,
      translatedMessageIds: translatedMessageIds ?? this.translatedMessageIds,
      translatingThreadId: clearTranslating
          ? null
          : (translatingThreadId ?? this.translatingThreadId),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSending: isSending ?? this.isSending,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: clearError ? null : (error ?? this.error),
      loadFailed: loadFailed ?? this.loadFailed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    threads,
    propertyIds,
    selectedThreadId,
    selectedThread,
    filter,
    query,
    draftsByThreadId,
    translationsByMessageId,
    translatedMessageIds,
    translatingThreadId,
    isRefreshing,
    isSending,
    lastUpdated,
    error,
    loadFailed,
  ];
}

/// The inbox's state.
///
/// It talks to [MessagingRepository] and to nothing else — no source is named
/// anywhere in this file, and the capabilities it reads are the source's own
/// answer about what it can do.
class InboxCubit extends Cubit<InboxState> {
  InboxCubit({required MessagingRepository repository})
    : _repository = repository,
      super(const InboxState());

  final MessagingRepository _repository;

  int _loadSeq = 0;

  MessagingCapabilities get capabilities => _repository.capabilities;

  /// Load the conversations of [propertyIds].
  ///
  /// [sync] asks the source for anything new first — true when Berichten is
  /// opened and when the owner refreshes, false for the cheap read the rail's
  /// unread badge lives on.
  Future<void> load({
    required List<int> propertyIds,
    bool sync = true,
    bool refresh = false,
  }) async {
    final seq = ++_loadSeq;
    emit(
      state.copyWith(
        status: state.threads.isEmpty ? InboxStatus.loading : state.status,
        propertyIds: propertyIds,
        isRefreshing: refresh,
        clearError: true,
        loadFailed: false,
      ),
    );

    // A failing source must not blank conversations the console already has:
    // the sync error is remembered and reported over whatever the store yields.
    DomainError? syncError;
    if (sync && propertyIds.isNotEmpty) {
      try {
        await _repository.syncThreads(propertyIds: propertyIds);
      } catch (error, stack) {
        syncError = DomainError.from(error, stack: stack);
      }
      if (seq != _loadSeq || isClosed) return;
    }

    try {
      final threads = await _repository.fetchThreads(propertyIds: propertyIds);
      if (seq != _loadSeq || isClosed) return;

      final selectedId = _resolveSelection(threads);
      emit(
        state.copyWith(
          status: InboxStatus.loaded,
          threads: threads,
          selectedThreadId: selectedId,
          clearSelection: selectedId == null,
          isRefreshing: false,
          lastUpdated: DateTime.now(),
          loadFailed: threads.isEmpty && syncError != null,
          error: syncError,
        ),
      );
      if (selectedId != null) await openThread(selectedId);
    } catch (error, stack) {
      if (seq != _loadSeq || isClosed) return;
      emit(
        state.copyWith(
          // Nothing to show and the load failed: that is the blocking case.
          // With threads already on screen it is a toast over live data.
          status: state.threads.isEmpty ? InboxStatus.error : state.status,
          isRefreshing: false,
          error: DomainError.from(error, stack: stack),
          loadFailed: state.threads.isEmpty,
        ),
      );
    }
  }

  /// The thread the list should open on: the one already open when it survived
  /// the reload, otherwise the first row. Only an empty list shows no
  /// conversation.
  String? _resolveSelection(List<MessageThread> threads) {
    final current = state.selectedThreadId;
    if (current != null &&
        threads.any((thread) => thread.threadId == current)) {
      return current;
    }
    final visible = InboxState(
      threads: threads,
      filter: state.filter,
      query: state.query,
    ).visibleThreads();
    if (visible.isNotEmpty) return visible.first.threadId;
    return threads.isEmpty ? null : threads.first.threadId;
  }

  /// Open a conversation, and read it.
  ///
  /// Opening *is* reading — there is no separate "mark as read" for the owner
  /// to remember. Whether that reaches the source is the source's business.
  Future<void> openThread(String threadId) async {
    emit(state.copyWith(selectedThreadId: threadId));
    try {
      final thread = await _repository.fetchThread(threadId);
      if (isClosed) return;
      emit(state.copyWith(selectedThread: thread));
      if (thread.isUnread) await _markRead(threadId);
    } catch (error, stack) {
      if (isClosed) return;
      emit(state.copyWith(error: DomainError.from(error, stack: stack)));
    }
  }

  Future<void> _markRead(String threadId) async {
    try {
      final read = await _repository.markRead(threadId);
      if (isClosed) return;
      emit(
        state.copyWith(
          threads: _replaceThread(read),
          selectedThread: state.selectedThread?.threadId == threadId
              ? state.selectedThread!.copyWith(
                  readAt: read.readAt,
                  unreadCount: 0,
                )
              : state.selectedThread,
        ),
      );
    } catch (_) {
      // Recording that something was read is a convenience; failing at it must
      // not interrupt reading it.
    }
  }

  void changeFilter(InboxFilter filter) {
    if (state.filter == filter) return;
    emit(state.copyWith(filter: filter));
    _reselectWithinFilter();
  }

  void search(String query) {
    if (state.query == query) return;
    emit(state.copyWith(query: query));
    _reselectWithinFilter();
  }

  /// Keep a conversation on screen whenever the filter still has one.
  void _reselectWithinFilter() {
    final visible = state.visibleThreads();
    if (visible.isEmpty) return;
    final current = state.selectedThreadId;
    if (current != null &&
        visible.any((thread) => thread.threadId == current)) {
      return;
    }
    openThread(visible.first.threadId);
  }

  void updateDraft(String threadId, String body) {
    emit(
      state.copyWith(
        draftsByThreadId: {...state.draftsByThreadId, threadId: body},
      ),
    );
  }

  /// Send the current draft.
  ///
  /// Callers must check [MessagingCapabilities.canSend] first — the UI degrades
  /// visibly rather than letting a button fail. This guard is the backstop, not
  /// the design.
  Future<void> sendDraft(String threadId) async {
    if (!_repository.capabilities.canSend) return;
    final body = state.draftFor(threadId).trim();
    if (body.isEmpty) return;

    emit(state.copyWith(isSending: true, clearError: true));
    try {
      await _repository.sendMessage(threadId: threadId, body: body);
      if (isClosed) return;
      final drafts = {...state.draftsByThreadId}..remove(threadId);
      emit(state.copyWith(isSending: false, draftsByThreadId: drafts));
      await openThread(threadId);
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSending: false,
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> snooze(String threadId, DateTime? until) async {
    await _mutateThread(() => _repository.snooze(threadId, until));
  }

  Future<void> setArchived(String threadId, {required bool archived}) async {
    await _mutateThread(
      () => _repository.setArchived(threadId, archived: archived),
    );
    if (isClosed) return;
    // An archived conversation leaves the list, so the list picks the next one
    // rather than leaving an empty column behind.
    if (archived) _reselectAfterRemoval(threadId);
  }

  Future<void> _mutateThread(Future<MessageThread> Function() action) async {
    try {
      final updated = await action();
      if (isClosed) return;
      emit(
        state.copyWith(
          threads: _replaceThread(updated),
          selectedThread: state.selectedThread?.threadId == updated.threadId
              ? state.selectedThread!.copyWith(
                  snoozedUntil: updated.snoozedUntil,
                  archivedAt: updated.archivedAt,
                  readAt: updated.readAt,
                )
              : state.selectedThread,
        ),
      );
    } catch (error, stack) {
      if (isClosed) return;
      emit(state.copyWith(error: DomainError.from(error, stack: stack)));
    }
  }

  void _reselectAfterRemoval(String threadId) {
    if (state.selectedThreadId != threadId) return;
    final visible = state.visibleThreads();
    if (visible.isEmpty) {
      emit(state.copyWith(clearSelection: true));
      return;
    }
    openThread(visible.first.threadId);
  }

  /// Read one message in [targetLanguage]. Never automatic and never instead of
  /// the original.
  Future<void> toggleTranslation({
    required String threadId,
    required String messageId,
    required String targetLanguage,
  }) async {
    if (state.translatedMessageIds.contains(messageId)) {
      emit(
        state.copyWith(
          translatedMessageIds: {...state.translatedMessageIds}
            ..remove(messageId),
        ),
      );
      return;
    }
    if (state.translationsByMessageId.containsKey(messageId)) {
      emit(
        state.copyWith(
          translatedMessageIds: {...state.translatedMessageIds, messageId},
        ),
      );
      return;
    }

    emit(state.copyWith(translatingThreadId: threadId, clearError: true));
    try {
      final translations = await _repository.translateMessages(
        threadId: threadId,
        messageIds: [messageId],
        targetLanguage: targetLanguage,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          clearTranslating: true,
          translationsByMessageId: {
            ...state.translationsByMessageId,
            ...translations,
          },
          translatedMessageIds: translations.containsKey(messageId)
              ? {...state.translatedMessageIds, messageId}
              : state.translatedMessageIds,
        ),
      );
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          clearTranslating: true,
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  void clearError() {
    if (state.error == null) return;
    emit(state.copyWith(clearError: true));
  }

  List<MessageThread> _replaceThread(MessageThread updated) => [
    for (final thread in state.threads)
      if (thread.threadId == updated.threadId) updated else thread,
  ];
}
