import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/messaging/domain/messaging_repository.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';
import 'package:hosthub_console/features/messaging/infrastructure/store/supabase_message_store.dart';

/// [MessagingRepository] over Lodgify.
///
/// ## What the Lodgify public API can actually do
///
/// | | Lodgify public API v2 |
/// |---|---|
/// | Read a thread | `GET /v2/messaging/{threadGuid}` — the *only* endpoint |
/// | List threads | does not exist publicly |
/// | Send a message | does not exist publicly |
/// | Set read / archive | does not exist publicly |
/// | New-message signal | webhook `guest_message_received` |
///
/// Three consequences, all of them design decisions rather than workarounds:
///
/// 1. **Threads are discovered through bookings.** The thread GUID sits in the
///    booking payload, so `messaging-sync` walks bookings → GUID → thread. Only
///    conversations attached to a booking or an enquiry arrive. That covers
///    virtually everything an owner must answer, and it is a permanent property
///    of the source, so it is documented here and never shown in the UI.
/// 2. **`canSend` is false.** The composer stays visible and disabled with the
///    reason and one way out — open the conversation at the source. A send
///    button that fails is worse than one that says honestly that it cannot.
/// 3. **Read state is ours.** `canMarkRead` is false, so the console is the only
///    place "read" exists. Consistency is all that is needed, and the store
///    provides it.
///
/// When Lodgify opens sending up, [capabilities] is the one line that changes.
class LodgifyMessagingRepository extends SupabaseRepository
    implements MessagingRepository {
  LodgifyMessagingRepository({
    required SupabaseClient supabase,
    required SupabaseMessageStore store,
  }) : _store = store,
       super(supabase);

  static const String syncFunctionName = 'messaging-sync';
  static const String translateFunctionName = 'translate-message';

  final SupabaseMessageStore _store;

  @override
  final MessagingCapabilities capabilities = const MessagingCapabilities(
    sourceName: 'Lodgify',
    canSend: false,
    canMarkRead: false,
    canArchive: false,
    canListThreads: false,
    supportsWebhook: true,
    sourceDeepLinkTemplate: 'https://app.lodgify.com/#/inbox/{threadId}',
  );

  @override
  Future<List<MessageThread>> fetchThreads({
    required List<int> propertyIds,
    DateTime? updatedSince,
  }) =>
      _store.fetchThreads(propertyIds: propertyIds, updatedSince: updatedSince);

  @override
  Future<void> syncThreads({
    required List<int> propertyIds,
    String? sourceThreadId,
  }) => _sync(propertyIds: propertyIds, sourceThreadId: sourceThreadId);

  @override
  Future<MessageThread> fetchThread(String threadId) =>
      _store.fetchThread(threadId);

  @override
  Future<Message> sendMessage({
    required String threadId,
    required String body,
  }) async {
    // Not a fallback and not a silent no-op: callers check `canSend` and
    // degrade visibly. Reaching this line is a bug, and it says so.
    throw UnsupportedSourceOperation('send messages', capabilities.sourceName);
  }

  @override
  Future<MessageThread> markRead(String threadId) {
    // Lodgify has no endpoint for it, so `read` exists only here. Nothing to
    // mirror; when a source gains one, this is where the mirror goes.
    return _store.markRead(threadId);
  }

  @override
  Future<MessageThread> snooze(String threadId, DateTime? until) =>
      _store.setSnoozed(threadId, until);

  @override
  Future<MessageThread> setArchived(
    String threadId, {
    required bool archived,
  }) => _store.setArchived(threadId, archived: archived);

  @override
  Future<Map<String, String>> translateMessages({
    required String threadId,
    required List<String> messageIds,
    required String targetLanguage,
  }) async {
    if (messageIds.isEmpty) return const {};
    try {
      final response = await supabase.functions.invoke(
        translateFunctionName,
        body: {
          'threadId': threadId,
          'messageIds': messageIds,
          'targetLanguage': targetLanguage,
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw DomainErrorCode.dataFetchFailed.err(
          message: 'Unexpected translate-message response shape',
          context: {'data': data.runtimeType.toString()},
        );
      }
      final translations = (data['translations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>();
      return {
        for (final translation in translations)
          if (translation['messageId'] is String &&
              translation['value'] is String)
            translation['messageId'] as String: translation['value'] as String,
      };
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {
          'op': 'translateMessages',
          'thread_id': threadId,
          'language': targetLanguage,
        },
      );
    }
  }

  @override
  Future<void> testConnection() => supabase.functions
      .invoke(syncFunctionName, body: const {'propertyIds': <int>[]})
      .then((_) {});

  Future<void> _sync({
    required List<int> propertyIds,
    String? sourceThreadId,
  }) async {
    if (propertyIds.isEmpty) return;
    try {
      final response = await supabase.functions.invoke(
        syncFunctionName,
        body: {
          'propertyIds': propertyIds,
          if (sourceThreadId != null) 'sourceThreadId': sourceThreadId,
        },
      );
      if (response.status != 200) {
        throw DomainErrorCode.dataFetchFailed.err(
          message: 'messaging-sync returned ${response.status}',
          context: {
            'function_status': response.status,
            'function_details': response.data?.toString(),
          },
        );
      }
    } catch (error, stack) {
      if (error is DomainError) rethrow;
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'syncThreads', 'properties': propertyIds.length},
      );
    }
  }
}
