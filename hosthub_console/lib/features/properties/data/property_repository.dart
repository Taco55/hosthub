import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';

class PropertySummary {
  const PropertySummary({
    required this.id,
    required this.name,
    this.lodgifyId,
    this.channelSettings = const ChannelSettings(),
  });

  final int id;
  final String name;
  final String? lodgifyId;
  final ChannelSettings channelSettings;

  factory PropertySummary.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as int;
    final name = (map['name'] as String?)?.trim();
    return PropertySummary(
      id: id,
      name: name?.isNotEmpty == true ? name! : id.toString(),
      lodgifyId: (map['lodgify_id'] as String?)?.trim(),
      channelSettings: ChannelSettings.fromMap(
        map['channel_settings'] as Map<String, dynamic>?,
      ),
    );
  }
}

class PropertyDetails {
  const PropertyDetails({
    required this.id,
    required this.name,
    this.lodgifyId,
    this.address,
    this.zip,
    this.city,
    this.country,
    this.imageUrl,
    this.hasAddons,
    this.hasAgreement,
    this.agreementText,
    this.agreementUrl,
    this.ownerSpokenLanguages,
    this.rating,
    this.priceUnitInDays,
    this.minPrice,
    this.originalMinPrice,
    this.maxPrice,
    this.originalMaxPrice,
    this.rooms,
    this.inOutMaxDate,
    this.inOut,
    this.currency,
    this.subscriptionPlans,
    this.channelSettings = const ChannelSettings(),
  });

  final int id;
  final String name;
  final String? lodgifyId;
  final String? address;
  final String? zip;
  final String? city;
  final String? country;
  final String? imageUrl;
  final bool? hasAddons;
  final bool? hasAgreement;
  final String? agreementText;
  final String? agreementUrl;
  final List<String>? ownerSpokenLanguages;
  final num? rating;
  final int? priceUnitInDays;
  final num? minPrice;
  final num? originalMinPrice;
  final num? maxPrice;
  final num? originalMaxPrice;
  final Object? rooms;
  final DateTime? inOutMaxDate;
  final Object? inOut;
  final Object? currency;
  final List<String>? subscriptionPlans;
  final ChannelSettings channelSettings;

  /// Resolved currency code from the Lodgify currency field.
  String get currencyCode {
    final c = currency;
    if (c is String) {
      final trimmed = c.trim();
      if (trimmed.isNotEmpty) return trimmed.toUpperCase();
    }
    if (c is Map) {
      for (final key in const [
        'code',
        'currency',
        'currencyCode',
        'currency_code',
        'isoCode',
        'iso_code',
      ]) {
        final value = c[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim().toUpperCase();
        }
      }
    }
    return 'EUR';
  }

  factory PropertyDetails.fromMap(Map<String, dynamic> map) {
    return PropertyDetails(
      id: map['id'] as int,
      name: map['name'] as String,
      lodgifyId: (map['lodgify_id'] as String?)?.trim(),
      address: map['address'] as String?,
      zip: map['zip'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      imageUrl: map['image_url'] as String?,
      hasAddons: map['has_addons'] as bool?,
      hasAgreement: map['has_agreement'] as bool?,
      agreementText: map['agreement_text'] as String?,
      agreementUrl: map['agreement_url'] as String?,
      ownerSpokenLanguages: _toStringList(map['owner_spoken_languages']),
      rating: _toNum(map['rating']),
      priceUnitInDays: (map['price_unit_in_days'] as int?),
      minPrice: _toNum(map['min_price']),
      originalMinPrice: _toNum(map['original_min_price']),
      maxPrice: _toNum(map['max_price']),
      originalMaxPrice: _toNum(map['original_max_price']),
      rooms: map['rooms'],
      inOutMaxDate: _toDateTime(map['in_out_max_date']),
      inOut: map['in_out'],
      currency: map['currency'],
      subscriptionPlans: _toStringList(map['subscription_plans']),
      channelSettings: ChannelSettings.fromMap(
        map['channel_settings'] as Map<String, dynamic>?,
      ),
    );
  }
}

const _propertyDetailsColumns =
    'id, name, lodgify_id, address, zip, city, country, image_url, '
    'has_addons, '
    'has_agreement, agreement_text, agreement_url, owner_spoken_languages, '
    'rating, price_unit_in_days, min_price, original_min_price, max_price, '
    'original_max_price, rooms, in_out_max_date, in_out, currency, '
    'subscription_plans, channel_settings';

class PropertyRepository extends SupabaseRepository {
  PropertyRepository({required SupabaseClient supabase}) : super(supabase);

  Future<List<PropertySummary>> fetchProperties() async {
    try {
      final response = await supabase.from('properties').select();
      final properties =
          response.map((row) => PropertySummary.fromMap(row)).toList();
      properties.sort((a, b) => a.name.compareTo(b.name));
      return properties;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: const {'op': 'fetchProperties'},
      );
    }
  }

  Future<PropertySummary> createProperty({
    required String name,
    String? lodgifyId,
  }) async {
    try {
      final payload = <String, dynamic>{'name': name};
      final trimmedLodgifyId = lodgifyId?.trim();
      if (trimmedLodgifyId != null && trimmedLodgifyId.isNotEmpty) {
        payload['lodgify_id'] = trimmedLodgifyId;
      }
      final response = await supabase
          .from('properties')
          .insert(payload)
          .select('id, name, lodgify_id, channel_settings')
          .single();
      return PropertySummary.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'createProperty', 'name': name},
      );
    }
  }

  Future<PropertyDetails> fetchPropertyDetails(int id) async {
    try {
      final response = await supabase
          .from('properties')
          .select(_propertyDetailsColumns)
          .eq('id', id)
          .single();
      return PropertyDetails.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchPropertyDetails', 'property_id': id},
      );
    }
  }

  /// Persist the currency code (e.g. from Lodgify rate_settings) on the
  /// property row so that the pricing page can display the correct currency.
  Future<void> updatePropertyCurrency(int propertyId, String currency) async {
    try {
      await supabase
          .from('properties')
          .update({'currency': currency.trim().toUpperCase()})
          .eq('id', propertyId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updatePropertyCurrency', 'property_id': propertyId},
      );
    }
  }

  Future<PropertyDetails> updateChannelSettings({
    required int propertyId,
    required ChannelSettings channelSettings,
  }) async {
    try {
      final response = await supabase
          .from('properties')
          .update({'channel_settings': channelSettings.toMap()})
          .eq('id', propertyId)
          .select(_propertyDetailsColumns)
          .single();
      return PropertyDetails.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateChannelSettings', 'property_id': propertyId},
      );
    }
  }
}

num? _toNum(Object? value) => value is num ? value : null;

DateTime? _toDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String>? _toStringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return null;
}
