import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_property_details.freezed.dart';
part 'channel_property_details.g.dart';

@freezed
sealed class ChannelPropertyDetails with _$ChannelPropertyDetails {
  const ChannelPropertyDetails._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChannelPropertyDetails({
    String? id,
    String? name,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<String, dynamic>{})
    Map<String, dynamic> raw,
  }) = _ChannelPropertyDetails;

  factory ChannelPropertyDetails.fromJson(Map<String, dynamic> json) =>
      _$ChannelPropertyDetailsFromJson(json);
}
