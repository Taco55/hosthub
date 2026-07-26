// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_property_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChannelPropertyDetails _$ChannelPropertyDetailsFromJson(
  Map<String, dynamic> json,
) => _ChannelPropertyDetails(
  id: json['id'] as String?,
  name: json['name'] as String?,
  address: json['address'] as String?,
  zip: json['zip'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  imageUrl: json['image_url'] as String?,
  hasAddons: json['has_addons'] as bool?,
  hasAgreement: json['has_agreement'] as bool?,
  agreementText: json['agreement_text'] as String?,
  agreementUrl: json['agreement_url'] as String?,
  ownerSpokenLanguages: (json['owner_spoken_languages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  rating: json['rating'] as num?,
  priceUnitInDays: (json['price_unit_in_days'] as num?)?.toInt(),
  minPrice: json['min_price'] as num?,
  originalMinPrice: json['original_min_price'] as num?,
  maxPrice: json['max_price'] as num?,
  originalMaxPrice: json['original_max_price'] as num?,
  rooms: json['rooms'],
  inOutMaxDate: json['in_out_max_date'] == null
      ? null
      : DateTime.parse(json['in_out_max_date'] as String),
  inOut: json['in_out'],
  currency: json['currency'],
  subscriptionPlans: (json['subscription_plans'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ChannelPropertyDetailsToJson(
  _ChannelPropertyDetails instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'zip': instance.zip,
  'city': instance.city,
  'country': instance.country,
  'image_url': instance.imageUrl,
  'has_addons': instance.hasAddons,
  'has_agreement': instance.hasAgreement,
  'agreement_text': instance.agreementText,
  'agreement_url': instance.agreementUrl,
  'owner_spoken_languages': instance.ownerSpokenLanguages,
  'rating': instance.rating,
  'price_unit_in_days': instance.priceUnitInDays,
  'min_price': instance.minPrice,
  'original_min_price': instance.originalMinPrice,
  'max_price': instance.maxPrice,
  'original_max_price': instance.originalMaxPrice,
  'rooms': instance.rooms,
  'in_out_max_date': instance.inOutMaxDate?.toIso8601String(),
  'in_out': instance.inOut,
  'currency': instance.currency,
  'subscription_plans': instance.subscriptionPlans,
};
