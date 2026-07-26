import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/core/services/api_services/api_parsing.dart';

/// Lodgify-specific DTO for property details data.
///
/// Handles all the flexible key-name variations from Lodgify's API
/// and maps to the channel-agnostic [ChannelPropertyDetails] domain model.
///
/// The console's property columns were modelled on this payload, so most keys
/// line up one-to-one. They are still read through key lists rather than
/// directly: Lodgify serves both snake_case and camelCase depending on the
/// endpoint, and puts the postal fields either flat on the property or inside a
/// nested address object. A key that is absent leaves the field null — which the
/// record page shows as "—", rather than as a zero or an empty string that would
/// read as if Lodgify had said so.
class LodgifyPropertyDetailsDto {
  const LodgifyPropertyDetailsDto({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String? id;
  final String? name;
  final Map<String, dynamic> raw;

  factory LodgifyPropertyDetailsDto.fromMap(Map<String, dynamic> map) {
    return LodgifyPropertyDetailsDto(
      id: map.readString(const ['id', 'property_id', 'propertyId']),
      name: map.readString(const ['name', 'property_name', 'title']),
      raw: map,
    );
  }

  ChannelPropertyDetails toDomain() {
    final nested = _map(raw['address']) ?? _map(raw['location']);

    return ChannelPropertyDetails(
      id: id,
      name: name,
      // `address` is either the street itself or the object holding it.
      address:
          _string(raw['address']) ??
          nested?.readString(const ['street', 'address', 'line1']) ??
          raw.readString(const ['street', 'address_line_1', 'addressLine1']),
      zip:
          raw.readString(const ['zip', 'zipcode', 'zip_code', 'postal_code']) ??
          nested?.readString(const ['zip', 'zipcode', 'postal_code']),
      city:
          raw.readString(const ['city', 'town']) ??
          nested?.readString(const ['city', 'town']),
      country:
          raw.readString(const ['country', 'country_name', 'countryName']) ??
          nested?.readString(const ['country', 'country_name']),
      imageUrl: raw.readString(const ['image_url', 'imageUrl', 'image']),
      hasAddons: _bool(raw, const ['has_addons', 'hasAddons']),
      hasAgreement: _bool(raw, const ['has_agreement', 'hasAgreement']),
      agreementText: raw.readString(const ['agreement_text', 'agreementText']),
      agreementUrl: raw.readString(const ['agreement_url', 'agreementUrl']),
      ownerSpokenLanguages: _stringList(raw, const [
        'owner_spoken_languages',
        'ownerSpokenLanguages',
        'spoken_languages',
      ]),
      rating: _num(raw, const ['rating', 'review_score', 'reviewScore']),
      priceUnitInDays: _num(raw, const [
        'price_unit_in_days',
        'priceUnitInDays',
      ])?.toInt(),
      minPrice: _num(raw, const ['min_price', 'minPrice']),
      originalMinPrice: _num(raw, const [
        'original_min_price',
        'originalMinPrice',
      ]),
      maxPrice: _num(raw, const ['max_price', 'maxPrice']),
      originalMaxPrice: _num(raw, const [
        'original_max_price',
        'originalMaxPrice',
      ]),
      rooms: raw['rooms'] ?? raw['room_types'] ?? raw['roomTypes'],
      inOutMaxDate: raw.readDateTime(const ['in_out_max_date', 'inOutMaxDate']),
      inOut: raw['in_out'] ?? raw['inOut'],
      currency: raw['currency'] ?? raw['currency_code'] ?? raw['currencyCode'],
      subscriptionPlans: _stringList(raw, const [
        'subscription_plans',
        'subscriptionPlans',
      ]),
      raw: raw,
    );
  }
}

String? _string(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

Map<String, dynamic>? _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

bool? _bool(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
  }
  return null;
}

num? _num(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value.trim().replaceAll(',', '.'));
      if (parsed != null) return parsed;
    }
  }
  return null;
}

/// An empty list is a real answer here ("Lodgify sent no languages"), so it is
/// kept as an empty list rather than folded into null.
List<String>? _stringList(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is! List) continue;
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return null;
}
