import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/messaging/application/inbox_cubit.dart';
import 'package:hosthub_console/features/messaging/domain/messaging_repository.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';

void main() {
  final now = DateTime(2026, 7, 28, 12);

  MessageThread thread({
    required String id,
    bool awaitingHost = false,
    int unread = 0,
    DateTime? archivedAt,
    DateTime? snoozedUntil,
    String guestName = 'Ann',
    String preview = 'Kan de check-in later?',
  }) {
    return MessageThread(
      propertyId: 1,
      threadId: id,
      sourceThreadId: 'src-$id',
      channel: MessageChannel.airbnb,
      guestName: guestName,
      lastMessageAt: now,
      lastMessagePreview: preview,
      unreadCount: unread,
      awaitingHost: awaitingHost,
      archivedAt: archivedAt,
      snoozedUntil: snoozedUntil,
    );
  }

  group('InboxState filtering', () {
    test('Actie is the last word being the guest`s, not a stored flag', () {
      final state = InboxState(
        threads: [
          thread(id: 'a', awaitingHost: true),
          thread(id: 'b'),
          thread(id: 'c', awaitingHost: true, unread: 2),
        ],
        filter: InboxFilter.action,
      );

      expect(state.visibleThreads(now: now).map((t) => t.threadId), ['a', 'c']);
      expect(state.countFor(InboxFilter.action, now: now), 2);
    });

    test('a count opens on exactly the rows it promised', () {
      final state = InboxState(
        threads: [
          thread(id: 'a', unread: 1),
          thread(id: 'b'),
          // Archived and snoozed conversations are out of every count as well
          // as out of every list — a badge that opens on fewer rows than it
          // said is worse than no badge.
          thread(id: 'c', unread: 5, archivedAt: now),
          thread(
            id: 'd',
            unread: 3,
            snoozedUntil: now.add(const Duration(days: 1)),
          ),
        ],
      );

      for (final filter in InboxFilter.values) {
        final count = state.countFor(filter, now: now);
        final rows = InboxState(
          threads: state.threads,
          filter: filter,
        ).visibleThreads(now: now);
        expect(rows.length, count, reason: 'count mismatch for $filter');
      }
      expect(state.unreadCount(now: now), 1);
    });

    test('a snoozed conversation comes back when its time passes', () {
      final state = InboxState(
        threads: [
          thread(id: 'a', snoozedUntil: now.add(const Duration(hours: 2))),
        ],
      );

      expect(state.visibleThreads(now: now), isEmpty);
      expect(
        state
            .visibleThreads(now: now.add(const Duration(hours: 3)))
            .map((t) => t.threadId),
        ['a'],
      );
    });

    test('search looks at the guest, the message and the property', () {
      final state = InboxState(
        threads: [
          thread(id: 'a', guestName: 'Ann', preview: 'Parkeren?'),
          thread(id: 'b', guestName: 'Bo', preview: 'Late check-in'),
        ],
        query: 'late',
      );

      expect(state.visibleThreads(now: now).map((t) => t.threadId), ['b']);
    });
  });

  group('InboxCubit against a source that cannot send', () {
    test('sending is refused before it can fail', () async {
      final repository = _FakeMessagingRepository(
        capabilities: const MessagingCapabilities(
          sourceName: 'Testbron',
          canSend: false,
        ),
        threads: [thread(id: 'a')],
      );
      final cubit = InboxCubit(repository: repository);

      await cubit.load(propertyIds: const [1]);
      cubit.updateDraft('a', 'Hallo');
      await cubit.sendDraft('a');

      expect(repository.sendCalls, isEmpty);
      // The draft survives: the owner still has their words to paste at the
      // source.
      expect(cubit.state.draftFor('a'), 'Hallo');
      addTearDown(cubit.close);
    });

    test('a failing sync shows what is already stored', () async {
      final repository = _FakeMessagingRepository(
        capabilities: const MessagingCapabilities(sourceName: 'Testbron'),
        threads: [thread(id: 'a')],
        failSync: true,
      );
      final cubit = InboxCubit(repository: repository);

      await cubit.load(propertyIds: const [1]);

      expect(cubit.state.threads, hasLength(1));
      expect(cubit.state.loadFailed, isFalse);
      expect(cubit.state.error, isNotNull);
      addTearDown(cubit.close);
    });

    test('nothing stored plus a failing sync is the blocking case', () async {
      final repository = _FakeMessagingRepository(
        capabilities: const MessagingCapabilities(sourceName: 'Testbron'),
        threads: const [],
        failSync: true,
      );
      final cubit = InboxCubit(repository: repository);

      await cubit.load(propertyIds: const [1]);

      expect(cubit.state.loadFailed, isTrue);
      addTearDown(cubit.close);
    });

    test('opening a conversation reads it', () async {
      final repository = _FakeMessagingRepository(
        capabilities: const MessagingCapabilities(sourceName: 'Testbron'),
        threads: [thread(id: 'a', unread: 2)],
      );
      final cubit = InboxCubit(repository: repository);

      await cubit.load(propertyIds: const [1]);

      expect(repository.markReadCalls, ['a']);
      expect(cubit.state.threads.single.unreadCount, 0);
      addTearDown(cubit.close);
    });
  });
}

class _FakeMessagingRepository implements MessagingRepository {
  _FakeMessagingRepository({
    required this.capabilities,
    required List<MessageThread> threads,
    this.failSync = false,
  }) : _threads = [...threads];

  @override
  final MessagingCapabilities capabilities;

  final bool failSync;
  final List<MessageThread> _threads;

  final List<String> sendCalls = [];
  final List<String> markReadCalls = [];

  @override
  Future<List<MessageThread>> fetchThreads({
    required List<int> propertyIds,
    DateTime? updatedSince,
  }) async => _threads;

  @override
  Future<void> syncThreads({
    required List<int> propertyIds,
    String? sourceThreadId,
  }) async {
    if (failSync) throw StateError('source unreachable');
  }

  @override
  Future<MessageThread> fetchThread(String threadId) async =>
      _threads.firstWhere((thread) => thread.threadId == threadId);

  @override
  Future<Message> sendMessage({
    required String threadId,
    required String body,
  }) async {
    sendCalls.add(threadId);
    throw UnsupportedSourceOperation('send messages', capabilities.sourceName);
  }

  @override
  Future<MessageThread> markRead(String threadId) async {
    markReadCalls.add(threadId);
    final index = _threads.indexWhere((t) => t.threadId == threadId);
    _threads[index] = _threads[index].copyWith(
      unreadCount: 0,
      readAt: DateTime.now(),
    );
    return _threads[index];
  }

  @override
  Future<MessageThread> snooze(String threadId, DateTime? until) async {
    final index = _threads.indexWhere((t) => t.threadId == threadId);
    _threads[index] = _threads[index].copyWith(snoozedUntil: until);
    return _threads[index];
  }

  @override
  Future<MessageThread> setArchived(
    String threadId, {
    required bool archived,
  }) async {
    final index = _threads.indexWhere((t) => t.threadId == threadId);
    _threads[index] = _threads[index].copyWith(
      archivedAt: archived ? DateTime.now() : null,
    );
    return _threads[index];
  }

  @override
  Future<Map<String, String>> translateMessages({
    required String threadId,
    required List<String> messageIds,
    required String targetLanguage,
  }) async => const {};

  @override
  Future<void> testConnection() async {}
}
