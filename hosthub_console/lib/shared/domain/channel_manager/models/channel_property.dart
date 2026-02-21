import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_property.freezed.dart';
part 'channel_property.g.dart';

@freezed
sealed class ChannelProperty with _$ChannelProperty {
  const ChannelProperty._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChannelProperty({
    String? id,
    String? name,
  }) = _ChannelProperty;

  factory ChannelProperty.fromJson(Map<String, dynamic> json) =>
      _$ChannelPropertyFromJson(json);
}
