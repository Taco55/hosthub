import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hosthub_console/features/messaging/domain/models/message.dart';
import 'package:hosthub_console/features/messaging/domain/models/message_channel.dart';

part 'message_thread.freezed.dart';
part 'message_thread.g.dart';

@freezed
sealed class MessageThread with _$MessageThread {
  const MessageThread._();

  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MessageThread({
    /// The property this conversation belongs to — the console's own
    /// `properties.id`, never the source's.
    ///
    /// Required for the same reason [Reservation.propertyId] is: every filter
    /// and every counter is `property_id IN (:selection)`, and a thread that
    /// cannot say which property it is about cannot be scoped.
    required int propertyId,

    /// Our id for the thread (`message_threads.id`).
    required String threadId,

    /// The id the source knows it by. Half of the uniqueness that makes a
    /// re-sync an upsert instead of a duplicate.
    required String sourceThreadId,
    @Default(MessageChannel.other) MessageChannel channel,

    /// Not every conversation hangs off a booking — an enquiry does not.
    String? reservationId,
    String? guestName,
    String? guestLocale,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    @Default(0) int unreadCount,

    /// The last word is the guest's. Derived at sync time from the direction of
    /// the last message, never a flag anybody maintains — which is why the
    /// `Actie` filter can be trusted.
    @Default(false) bool awaitingHost,

    /// Our own read state. The source has no concept of one, so this is where
    /// "read" exists at all.
    DateTime? readAt,
    DateTime? snoozedUntil,
    DateTime? archivedAt,

    /// Loaded by [MessagingRepository.fetchThread]; empty in a list fetch,
    /// where a preview is all the row shows.
    @Default(<Message>[]) List<Message> messages,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<String, dynamic>{})
    Map<String, dynamic> raw,
  }) = _MessageThread;

  factory MessageThread.fromJson(Map<String, dynamic> json) =>
      _$MessageThreadFromJson(json);

  bool get isUnread => unreadCount > 0;

  bool get isArchived => archivedAt != null;

  /// Whether the thread is still sleeping at [now].
  bool isSnoozed(DateTime now) {
    final until = snoozedUntil;
    return until != null && until.isAfter(now);
  }

  /// Everything the search field looks at: who, what, and — through the caller's
  /// property name — where.
  bool matches(String query, {String? propertyName}) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    final haystack = [
      guestName,
      lastMessagePreview,
      propertyName,
      for (final message in messages) message.body,
    ].whereType<String>().join(' ').toLowerCase();
    return haystack.contains(needle);
  }
}
