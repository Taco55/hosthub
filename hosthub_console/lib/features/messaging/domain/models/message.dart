import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hosthub_console/features/messaging/domain/models/message_channel.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum MessageDirection { inbound, outbound }

/// Where a message stands on its way out.
///
/// `failed` is a state the thread keeps showing: a reply that vanished because
/// it could not be delivered would leave the owner believing they answered.
@JsonEnum(fieldRename: FieldRename.snake)
enum MessageDeliveryState { pending, sent, failed }

@freezed
sealed class Message with _$Message {
  const Message._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Message({
    required String messageId,
    required String threadId,
    required MessageDirection direction,
    required String body,
    required DateTime sentAt,
    String? authorName,
    @Default(MessageChannel.other) MessageChannel channel,
    @Default(MessageDeliveryState.sent) MessageDeliveryState deliveryState,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<String, dynamic>{})
    Map<String, dynamic> raw,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  bool get isInbound => direction == MessageDirection.inbound;

  bool get hasFailed => deliveryState == MessageDeliveryState.failed;
}
