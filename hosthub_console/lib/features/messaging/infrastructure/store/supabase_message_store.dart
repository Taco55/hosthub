import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';

/// The console's own copy of the conversations, and the only place its own
/// state about them lives: read, snoozed, archived, and any message it produced
/// itself.
///
/// Bookings are proxied live and nothing is kept; messaging cannot work that
/// way. Read state has no counterpart at the source, and one request per thread
/// per render is not survivable at forty threads. So the source fills this
/// store through `messaging-sync`, and every screen reads the store.
///
/// It knows nothing about which source filled it — that is the adapter's job —
/// so a second source needs no change here.
class SupabaseMessageStore extends SupabaseRepository {
  SupabaseMessageStore({required SupabaseClient supabase}) : super(supabase);

  static const String threadsTable = 'message_threads';
  static const String messagesTable = 'messages';

  static const String _threadColumns =
      'id, property_id, source, source_thread_id, channel, reservation_id, '
      'guest_name, guest_locale, last_message_at, last_message_preview, '
      'awaiting_host, read_at, snoozed_until, archived_at, synced_at';

  static const String _messageColumns =
      'id, thread_id, source_message_id, direction, body, sent_at, '
      'author_name, delivery_state';

  /// Every thread of [propertyIds], newest conversation first.
  Future<List<MessageThread>> fetchThreads({
    required List<int> propertyIds,
    DateTime? updatedSince,
  }) async {
    if (propertyIds.isEmpty) return const [];
    try {
      var query = supabase
          .from(threadsTable)
          .select(_threadColumns)
          .inFilter('property_id', propertyIds);
      if (updatedSince != null) {
        query = query.gte('last_message_at', updatedSince.toIso8601String());
      }
      final rows = await query.order('last_message_at', ascending: false);

      final threads = [
        for (final row in rows) _threadFromRow(Map<String, dynamic>.from(row)),
      ];
      return await _withUnreadCounts(threads);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchThreads', 'properties': propertyIds.length},
      );
    }
  }

  /// One thread with its full history, oldest message first.
  Future<MessageThread> fetchThread(String threadId) async {
    try {
      final row = await supabase
          .from(threadsTable)
          .select(_threadColumns)
          .eq('id', threadId)
          .single();
      final thread = _threadFromRow(Map<String, dynamic>.from(row));

      final messageRows = await supabase
          .from(messagesTable)
          .select(_messageColumns)
          .eq('thread_id', threadId)
          .order('sent_at', ascending: true);

      final messages = [
        for (final message in messageRows)
          _messageFromRow(Map<String, dynamic>.from(message), thread.channel),
      ];
      return thread.copyWith(
        messages: messages,
        unreadCount: _unreadCount(messages, thread.readAt),
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchThread', 'thread_id': threadId},
      );
    }
  }

  /// Mark the whole thread read, here. The source is a separate question the
  /// adapter answers with its capabilities.
  Future<MessageThread> markRead(String threadId, {DateTime? at}) =>
      _patchThread(threadId, {
        'read_at': (at ?? DateTime.now()).toUtc().toIso8601String(),
      }, op: 'markRead');

  Future<MessageThread> setSnoozed(String threadId, DateTime? until) =>
      _patchThread(threadId, {
        'snoozed_until': until?.toUtc().toIso8601String(),
      }, op: 'setSnoozed');

  Future<MessageThread> setArchived(
    String threadId, {
    required bool archived,
  }) => _patchThread(threadId, {
    'archived_at': archived ? DateTime.now().toUtc().toIso8601String() : null,
  }, op: 'setArchived');

  /// Record a message the console itself produced.
  ///
  /// [deliveryState] is the caller's answer, not ours: a reply the source
  /// rejected stays in the thread as `failed` so the owner can see they did not
  /// actually answer.
  Future<Message> appendOutgoing({
    required String threadId,
    required String body,
    required MessageDeliveryState deliveryState,
    String? authorName,
    String? sourceMessageId,
    MessageChannel channel = MessageChannel.other,
  }) async {
    try {
      final row = await supabase
          .from(messagesTable)
          .insert({
            'thread_id': threadId,
            'source_message_id': sourceMessageId,
            'direction': 'outbound',
            'body': body,
            'sent_at': DateTime.now().toUtc().toIso8601String(),
            'author_name': authorName,
            'delivery_state': deliveryState.name.toSnakeCase(),
          })
          .select(_messageColumns)
          .single();
      return _messageFromRow(Map<String, dynamic>.from(row), channel);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'appendOutgoing', 'thread_id': threadId},
      );
    }
  }

  Future<MessageThread> _patchThread(
    String threadId,
    Map<String, dynamic> payload, {
    required String op,
  }) async {
    try {
      final row = await supabase
          .from(threadsTable)
          .update(payload)
          .eq('id', threadId)
          .select(_threadColumns)
          .single();
      return _threadFromRow(Map<String, dynamic>.from(row));
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': op, 'thread_id': threadId},
      );
    }
  }

  /// Fill in `unreadCount` for a list of threads with one extra query.
  ///
  /// Unread is derived — inbound messages newer than our `read_at` — rather
  /// than stored, so a sync that brings in a new message cannot leave a counter
  /// behind. One query for the whole list, not one per row.
  Future<List<MessageThread>> _withUnreadCounts(
    List<MessageThread> threads,
  ) async {
    if (threads.isEmpty) return threads;
    final ids = [for (final thread in threads) thread.threadId];
    final rows = await supabase
        .from(messagesTable)
        .select('thread_id, sent_at, direction')
        .inFilter('thread_id', ids)
        .eq('direction', 'inbound');

    final sentAtByThread = <String, List<DateTime>>{};
    for (final row in rows) {
      final threadId = row['thread_id'] as String?;
      final sentAt = _dateTime(row['sent_at']);
      if (threadId == null || sentAt == null) continue;
      sentAtByThread.putIfAbsent(threadId, () => []).add(sentAt);
    }

    return [
      for (final thread in threads)
        thread.copyWith(
          unreadCount: _countAfter(
            sentAtByThread[thread.threadId] ?? const [],
            thread.readAt,
          ),
        ),
    ];
  }

  static int _unreadCount(List<Message> messages, DateTime? readAt) =>
      _countAfter([
        for (final message in messages)
          if (message.isInbound) message.sentAt,
      ], readAt);

  static int _countAfter(List<DateTime> timestamps, DateTime? readAt) {
    if (readAt == null) return timestamps.length;
    return timestamps.where((sentAt) => sentAt.isAfter(readAt)).length;
  }

  static MessageThread _threadFromRow(Map<String, dynamic> row) {
    return MessageThread(
      propertyId: row['property_id'] as int,
      threadId: row['id'] as String,
      sourceThreadId: (row['source_thread_id'] as String?) ?? '',
      channel: MessageChannel.fromKey(row['channel'] as String?),
      reservationId: (row['reservation_id'] as String?)?.trim(),
      guestName: (row['guest_name'] as String?)?.trim(),
      guestLocale: (row['guest_locale'] as String?)?.trim(),
      lastMessageAt: _dateTime(row['last_message_at']),
      lastMessagePreview: (row['last_message_preview'] as String?)?.trim(),
      awaitingHost: row['awaiting_host'] as bool? ?? false,
      readAt: _dateTime(row['read_at']),
      snoozedUntil: _dateTime(row['snoozed_until']),
      archivedAt: _dateTime(row['archived_at']),
    );
  }

  static Message _messageFromRow(
    Map<String, dynamic> row,
    MessageChannel channel,
  ) {
    return Message(
      messageId: row['id'] as String,
      threadId: row['thread_id'] as String,
      direction: (row['direction'] as String?) == 'outbound'
          ? MessageDirection.outbound
          : MessageDirection.inbound,
      body: (row['body'] as String?) ?? '',
      sentAt: _dateTime(row['sent_at']) ?? DateTime.now(),
      authorName: (row['author_name'] as String?)?.trim(),
      channel: channel,
      deliveryState: switch (row['delivery_state'] as String?) {
        'pending' => MessageDeliveryState.pending,
        'failed' => MessageDeliveryState.failed,
        _ => MessageDeliveryState.sent,
      },
    );
  }

  static DateTime? _dateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value)?.toLocal();
    return null;
  }
}

extension on String {
  /// `deliveryState.name` is camelCase; the column takes snake_case.
  String toSnakeCase() => replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
}
