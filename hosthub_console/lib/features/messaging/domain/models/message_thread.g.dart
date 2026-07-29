// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageThread _$MessageThreadFromJson(Map<String, dynamic> json) =>
    _MessageThread(
      propertyId: (json['property_id'] as num).toInt(),
      threadId: json['thread_id'] as String,
      sourceThreadId: json['source_thread_id'] as String,
      channel:
          $enumDecodeNullable(_$MessageChannelEnumMap, json['channel']) ??
          MessageChannel.other,
      reservationId: json['reservation_id'] as String?,
      guestName: json['guest_name'] as String?,
      guestLocale: json['guest_locale'] as String?,
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      lastMessagePreview: json['last_message_preview'] as String?,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      awaitingHost: json['awaiting_host'] as bool? ?? false,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      snoozedUntil: json['snoozed_until'] == null
          ? null
          : DateTime.parse(json['snoozed_until'] as String),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Message>[],
    );

Map<String, dynamic> _$MessageThreadToJson(_MessageThread instance) =>
    <String, dynamic>{
      'property_id': instance.propertyId,
      'thread_id': instance.threadId,
      'source_thread_id': instance.sourceThreadId,
      'channel': _$MessageChannelEnumMap[instance.channel]!,
      'reservation_id': instance.reservationId,
      'guest_name': instance.guestName,
      'guest_locale': instance.guestLocale,
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'last_message_preview': instance.lastMessagePreview,
      'unread_count': instance.unreadCount,
      'awaiting_host': instance.awaitingHost,
      'read_at': instance.readAt?.toIso8601String(),
      'snoozed_until': instance.snoozedUntil?.toIso8601String(),
      'archived_at': instance.archivedAt?.toIso8601String(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

const _$MessageChannelEnumMap = {
  MessageChannel.airbnb: 'airbnb',
  MessageChannel.bookingCom: 'booking_com',
  MessageChannel.vrbo: 'vrbo',
  MessageChannel.direct: 'direct',
  MessageChannel.email: 'email',
  MessageChannel.other: 'other',
};
