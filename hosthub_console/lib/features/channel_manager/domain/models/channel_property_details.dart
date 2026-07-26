import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_property_details.freezed.dart';
part 'channel_property_details.g.dart';

/// Everything a channel manager knows about one property: the record the console
/// mirrors onto its own property row.
///
/// Channel-agnostic on purpose — the field set follows what the console stores
/// and shows, not one API's payload shape. The json-ish members ([rooms],
/// [inOut], [currency]) stay [Object] because no channel guarantees their shape;
/// the record page reads what it can from them and shows the rest as raw data.
@freezed
sealed class ChannelPropertyDetails with _$ChannelPropertyDetails {
  const ChannelPropertyDetails._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChannelPropertyDetails({
    String? id,
    String? name,
    String? address,
    String? zip,
    String? city,
    String? country,
    String? imageUrl,
    bool? hasAddons,
    bool? hasAgreement,
    String? agreementText,
    String? agreementUrl,
    List<String>? ownerSpokenLanguages,
    num? rating,
    int? priceUnitInDays,
    num? minPrice,
    num? originalMinPrice,
    num? maxPrice,
    num? originalMaxPrice,
    Object? rooms,
    DateTime? inOutMaxDate,
    Object? inOut,
    Object? currency,
    List<String>? subscriptionPlans,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<String, dynamic>{})
    Map<String, dynamic> raw,
  }) = _ChannelPropertyDetails;

  factory ChannelPropertyDetails.fromJson(Map<String, dynamic> json) =>
      _$ChannelPropertyDetailsFromJson(json);
}
