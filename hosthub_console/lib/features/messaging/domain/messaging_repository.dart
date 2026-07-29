import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/features/messaging/domain/models/models.dart';

/// Abstract interface for any guest-messaging source (Lodgify, Guesty,
/// Hostaway, a shared mailbox, …). Implementations own the API-specific DTOs
/// and map to/from these source-agnostic domain models.
///
/// It mirrors `ChannelManagerRepository` on purpose. Not because a second
/// source is scheduled, but because the one source that exists has a messaging
/// API so thin that a screen built straight onto it would have to be redesigned
/// the first time another one appears. Nothing under `application/` or
/// `presentation/` names a source; that is enforced by a test, not by intent.
abstract class MessagingRepository {
  /// What this source can actually do. Read once at startup; the UI asks this
  /// instead of asking "is this Lodgify?".
  MessagingCapabilities get capabilities;

  /// Threads for a set of console properties, as the console knows them now.
  ///
  /// Cheap and offline-ish: it does not go and ask the source — [syncThreads]
  /// does that. Splitting the two is what lets the rail's unread badge be
  /// correct at start-up without every app launch costing a round trip to a
  /// rate-limited API.
  ///
  /// [propertyIds] are the console's own `properties.id` — never the source's
  /// ids. Same rule as `fetchReservations()`: the two used to share a name and
  /// the source's id reached code that filtered on ours.
  Future<List<MessageThread>> fetchThreads({
    required List<int> propertyIds,
    DateTime? updatedSince,
  });

  /// Ask the source for anything new and record it.
  ///
  /// Called when Berichten is opened and on `Gegevens verversen` — there is no
  /// polling. A source with a webhook can narrow the work to one conversation
  /// through [sourceThreadId].
  Future<void> syncThreads({
    required List<int> propertyIds,
    String? sourceThreadId,
  });

  /// Full message history of one thread.
  Future<MessageThread> fetchThread(String threadId);

  /// Send a reply. Throws [UnsupportedSourceOperation] when
  /// [MessagingCapabilities.canSend] is false — callers must check first.
  Future<Message> sendMessage({required String threadId, required String body});

  /// This thread has been read.
  ///
  /// The console's own read state is always written — it is the only one that
  /// exists when [MessagingCapabilities.canMarkRead] is false — and the source
  /// is told as well when it can be. Returns the updated thread so the caller
  /// does not have to re-fetch to clear a badge.
  Future<MessageThread> markRead(String threadId);

  /// Sleep a thread until [until], or wake it when [until] is null.
  Future<MessageThread> snooze(String threadId, DateTime? until);

  /// Archive a thread, or bring it back when [archived] is false.
  Future<MessageThread> setArchived(String threadId, {required bool archived});

  /// Read [messageIds] of [threadId] in [targetLanguage].
  ///
  /// Never stored and never shown instead of the original: what the guest wrote
  /// stays the truth.
  Future<Map<String, String>> translateMessages({
    required String threadId,
    required List<String> messageIds,
    required String targetLanguage,
  });

  Future<void> testConnection();
}

/// Thrown when a caller asks a source for something
/// [MessagingCapabilities] says it cannot do.
///
/// It is a programming error rather than a runtime condition — the UI is
/// required to degrade visibly instead of calling and hoping — so it carries a
/// [DomainError] the shell can still present if one slips through.
class UnsupportedSourceOperation implements Exception {
  UnsupportedSourceOperation(this.operation, this.sourceName);

  final String operation;
  final String sourceName;

  DomainError toDomainError() => DomainErrorCode.badRequest.err(
    message: '$sourceName cannot $operation',
    context: {'operation': operation, 'source': sourceName},
  );

  @override
  String toString() =>
      'UnsupportedSourceOperation($operation not supported by $sourceName)';
}
