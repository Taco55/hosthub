// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  messageId: json['message_id'] as String,
  threadId: json['thread_id'] as String,
  direction: $enumDecode(_$MessageDirectionEnumMap, json['direction']),
  body: json['body'] as String,
  sentAt: DateTime.parse(json['sent_at'] as String),
  authorName: json['author_name'] as String?,
  channel:
      $enumDecodeNullable(_$MessageChannelEnumMap, json['channel']) ??
      MessageChannel.other,
  deliveryState:
      $enumDecodeNullable(
        _$MessageDeliveryStateEnumMap,
        json['delivery_state'],
      ) ??
      MessageDeliveryState.sent,
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'message_id': instance.messageId,
  'thread_id': instance.threadId,
  'direction': _$MessageDirectionEnumMap[instance.direction]!,
  'body': instance.body,
  'sent_at': instance.sentAt.toIso8601String(),
  'author_name': instance.authorName,
  'channel': _$MessageChannelEnumMap[instance.channel]!,
  'delivery_state': _$MessageDeliveryStateEnumMap[instance.deliveryState]!,
};

const _$MessageDirectionEnumMap = {
  MessageDirection.inbound: 'inbound',
  MessageDirection.outbound: 'outbound',
};

const _$MessageChannelEnumMap = {
  MessageChannel.airbnb: 'airbnb',
  MessageChannel.bookingCom: 'booking_com',
  MessageChannel.vrbo: 'vrbo',
  MessageChannel.direct: 'direct',
  MessageChannel.email: 'email',
  MessageChannel.other: 'other',
};

const _$MessageDeliveryStateEnumMap = {
  MessageDeliveryState.pending: 'pending',
  MessageDeliveryState.sent: 'sent',
  MessageDeliveryState.failed: 'failed',
};
