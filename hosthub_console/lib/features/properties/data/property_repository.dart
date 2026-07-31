import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/properties/domain/channel_overrides.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings_resolver.dart';

class PropertySummary {
  const PropertySummary({
    required this.id,
    required this.name,
    this.lodgifyId,
    this.channelOverrides = ChannelOverrides.none,
  });

  final int id;
  final String name;
  final String? lodgifyId;

  /// Only what this property states for itself. What it actually charges is
  /// [ChannelSettingsResolver.effectiveChannelSettings] of its id — a property
  /// row is one of two tiers and never the answer on its own.
  final ChannelOverrides channelOverrides;

  factory PropertySummary.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as int;
    final name = (map['name'] as String?)?.trim();
    return PropertySummary(
      id: id,
      name: name?.isNotEmpty == true ? name! : id.toString(),
      lodgifyId: (map['lodgify_id'] as String?)?.trim(),
      channelOverrides: ChannelOverrides.fromMap(
        map['channel_settings'] as Map<String, dynamic>?,
      ),
    );
  }

  @override
  String toString() {
    final lodgify = (lodgifyId ?? '').trim();
    return 'PropertySummary('
        'id: $id, '
        'name: $name, '
        'lodgifyId: ${lodgify.isEmpty ? '-' : lodgify})';
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
    this.lodgifySyncedAt,
    this.channelOverrides = ChannelOverrides.none,
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

  /// When the Lodgify-owned columns above were last written from Lodgify.
  ///
  /// Null means never: they hold their defaults, not Lodgify's answer. This is
  /// per property, unlike `UserSettings.lodgifyLastSyncedAt`, which only records
  /// when the account last looked for *new* properties.
  final DateTime? lodgifySyncedAt;

  /// This property's own deviations from the account defaults, sparsely — see
  /// [PropertySummary.channelOverrides].
  final ChannelOverrides channelOverrides;

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
      lodgifySyncedAt: _toDateTime(map['lodgify_synced_at']),
      channelOverrides: ChannelOverrides.fromMap(
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
    'subscription_plans, lodgify_synced_at, channel_settings';

class PropertyRepository extends SupabaseRepository {
  PropertyRepository({required SupabaseClient supabase}) : super(supabase);

  Future<List<PropertySummary>> fetchProperties() async {
    try {
      final response = await supabase.from('properties').select();
      final properties = response
          .map((row) => PropertySummary.fromMap(row))
          .toList();
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

  Future<void> deleteProperty(int id) async {
    try {
      await supabase.from('properties').delete().eq('id', id);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'deleteProperty', 'property_id': id},
      );
    }
  }

  /// Point an existing property at a Lodgify listing, or stop pointing at one.
  ///
  /// Both directions are one write because they are the same column, and both
  /// keep the row: linking is how a listing arrives on the property the owner
  /// already built a website for, and unlinking is what "delete" means for a
  /// synced property — the listing stays in Lodgify, so removing the row would
  /// only make the next sync recreate it empty.
  ///
  /// The sync stamp goes with it: after unlinking, the Lodgify-owned columns are
  /// no longer maintained, and a date claiming otherwise is worse than none.
  Future<PropertySummary> setLodgifyLink({
    required int propertyId,
    required String? lodgifyId,
  }) async {
    final trimmed = lodgifyId?.trim();
    final linking = trimmed != null && trimmed.isNotEmpty;
    try {
      final response = await supabase
          .from('properties')
          .update({
            'lodgify_id': linking ? trimmed : null,
            if (!linking) 'lodgify_synced_at': null,
          })
          .eq('id', propertyId)
          .select('id, name, lodgify_id, channel_settings')
          .single();
      return PropertySummary.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {
          'op': linking ? 'linkLodgifyProperty' : 'unlinkLodgifyProperty',
          'property_id': propertyId,
        },
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

  /// Mirror a channel manager's property record onto the local property row.
  ///
  /// This is the write that makes the record page show anything: creating a
  /// property only stores its name and channel id, so every other column keeps
  /// its default until a sync fills it in.
  ///
  /// A mirror, not a merge — the channel's record is the truth, so a field the
  /// channel does not report is cleared here too. The exceptions are the columns
  /// that cannot take a null: [ChannelPropertyDetails.name] and the two presence
  /// flags are only written when the channel actually reported them.
  Future<PropertyDetails> saveChannelDetails({
    required int propertyId,
    required ChannelPropertyDetails details,
    DateTime? syncedAt,
  }) async {
    try {
      final payload = <String, dynamic>{
        'address': details.address,
        'zip': details.zip,
        'city': details.city,
        'country': details.country,
        'image_url': details.imageUrl,
        'agreement_text': details.agreementText,
        'agreement_url': details.agreementUrl,
        'owner_spoken_languages': details.ownerSpokenLanguages,
        'rating': details.rating,
        'price_unit_in_days': details.priceUnitInDays,
        'min_price': details.minPrice,
        'original_min_price': details.originalMinPrice,
        'max_price': details.maxPrice,
        'original_max_price': details.originalMaxPrice,
        'rooms': details.rooms,
        'in_out_max_date': details.inOutMaxDate?.toUtc().toIso8601String(),
        'in_out': details.inOut,
        'currency': details.currency,
        'subscription_plans': details.subscriptionPlans,
        'lodgify_synced_at': (syncedAt ?? DateTime.now())
            .toUtc()
            .toIso8601String(),
      };

      final name = details.name?.trim();
      if (name != null && name.isNotEmpty) payload['name'] = name;
      if (details.hasAddons != null) payload['has_addons'] = details.hasAddons;
      if (details.hasAgreement != null) {
        payload['has_agreement'] = details.hasAgreement;
      }

      final response = await supabase
          .from('properties')
          .update(payload)
          .eq('id', propertyId)
          .select(_propertyDetailsColumns)
          .single();
      return PropertyDetails.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'saveChannelDetails', 'property_id': propertyId},
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

  /// Write this property's deviations from the account defaults.
  ///
  /// Sparse on purpose: [ChannelOverrides.toMap] omits every field the property
  /// does not state, so a later change to an account default still reaches it.
  Future<PropertyDetails> updateChannelOverrides({
    required int propertyId,
    required ChannelOverrides channelOverrides,
  }) async {
    try {
      final response = await supabase
          .from('properties')
          .update({'channel_settings': channelOverrides.toMap()})
          .eq('id', propertyId)
          .select(_propertyDetailsColumns)
          .single();
      return PropertyDetails.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateChannelOverrides', 'property_id': propertyId},
      );
    }
  }
}

/// The account's properties as [ChannelSettingsResolver.forProperties] wants
/// them.
///
/// The sidebar's badges, the properties list and the portfolio screens all need a
/// resolver over the *whole* account; going through one function is what keeps
/// them from each building a narrower one.
Iterable<({int id, ChannelOverrides overrides})> channelOverridesOf(
  Iterable<PropertySummary> properties,
) => [
  for (final property in properties)
    (id: property.id, overrides: property.channelOverrides),
];

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
