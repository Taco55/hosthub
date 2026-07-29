import 'package:hosthub_console/features/properties/domain/account_channel_defaults.dart';
import 'package:hosthub_console/features/properties/domain/booking_channel.dart';
import 'package:hosthub_console/features/properties/domain/channel_field.dart';
import 'package:hosthub_console/features/properties/domain/channel_overrides.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';

/// The one place the two settings tiers meet.
///
/// [effectiveChannelSettings] answers for **any** property in the account, not
/// for "the current property". That is what lets a portfolio screen cost each
/// booking with its own property's rates: it holds one resolver and asks it per
/// booking. Every other merge of account defaults and property overrides is a
/// bug — there is deliberately no second one to grep for.
class ChannelSettingsResolver {
  const ChannelSettingsResolver({
    required this.accountDefaults,
    required this.overridesByPropertyId,
  });

  /// A resolver for an account with no defaults and no overrides — everything
  /// resolves to zero. The shape a screen starts in before its data arrives.
  static const ChannelSettingsResolver empty = ChannelSettingsResolver(
    accountDefaults: AccountChannelDefaults.empty,
    overridesByPropertyId: <int, ChannelOverrides>{},
  );

  /// A resolver over a whole account.
  ///
  /// Every property has to be in here, not just the one on screen: a resolver
  /// built from one property answers the account's defaults for all the others,
  /// which is the §3.2 failure wearing a different hat — the lookup is per
  /// booking, but it can only find what the resolver was given.
  factory ChannelSettingsResolver.forProperties({
    required AccountChannelDefaults accountDefaults,
    required Iterable<({int id, ChannelOverrides overrides})> properties,
  }) {
    return ChannelSettingsResolver(
      accountDefaults: accountDefaults,
      overridesByPropertyId: {
        for (final property in properties)
          if (!property.overrides.isEmpty) property.id: property.overrides,
      },
    );
  }

  final AccountChannelDefaults accountDefaults;

  /// Sparse per property as well: a property absent from this map follows the
  /// account in everything, which is the state a newly added property is in.
  final Map<int, ChannelOverrides> overridesByPropertyId;

  /// What [propertyId] actually charges, per channel.
  EffectiveChannelSettings effectiveChannelSettings(int propertyId) {
    final overrides = overridesFor(propertyId);
    return EffectiveChannelSettings(
      propertyId: propertyId,
      booking: overrides.booking.applyTo(accountDefaults.booking),
      airbnb: overrides.airbnb.applyTo(accountDefaults.airbnb),
      other: overrides.other.applyTo(accountDefaults.other),
    );
  }

  /// One channel's resolved config for one property.
  ChannelConfig effectiveChannelConfig(
    int propertyId,
    BookingChannel channel,
  ) => effectiveChannelSettings(propertyId).forChannel(channel);

  /// The overrides [propertyId] states, or none.
  ChannelOverrides overridesFor(int propertyId) =>
      overridesByPropertyId[propertyId] ?? ChannelOverrides.none;

  /// The number behind the Prijzen badge for [propertyId].
  int overriddenFieldCount(int propertyId) =>
      overridesFor(propertyId).overriddenFieldCount;

  /// Which of [propertyIds] take the account's value for one field.
  ///
  /// The coverage line next to a default (`3 van 4 volgen`) and the impact of
  /// changing it are the same question asked twice, so they read the same
  /// answer. A property absent from [overridesByPropertyId] follows everything.
  List<int> propertiesFollowing(
    Iterable<int> propertyIds,
    BookingChannel channel,
    ChannelField field,
  ) => [
    for (final propertyId in propertyIds)
      if (!field.isOverriddenIn(overridesFor(propertyId).forChannel(channel)))
        propertyId,
  ];

  /// Which of [propertyIds] state a value of their own for [channel].
  ///
  /// The counterpart of a coverage number: without naming who deviates, "3 van
  /// 4 volgen" is a riddle.
  List<int> propertiesOverriding(
    Iterable<int> propertyIds,
    BookingChannel channel,
  ) => [
    for (final propertyId in propertyIds)
      if (!overridesFor(propertyId).forChannel(channel).isEmpty) propertyId,
  ];

  /// The union of properties that follow at least one of [fields].
  ///
  /// What a draft's impact line counts: several fields and several channels can
  /// sit in one draft, and a property is affected if any single one of them
  /// reaches it.
  List<int> propertiesAffectedBy(
    Iterable<int> propertyIds,
    Iterable<({BookingChannel channel, ChannelField field})> fields,
  ) {
    final affected = <int>{};
    for (final entry in fields) {
      affected.addAll(
        propertiesFollowing(propertyIds, entry.channel, entry.field),
      );
    }
    return [
      for (final propertyId in propertyIds)
        if (affected.contains(propertyId)) propertyId,
    ];
  }

  ChannelSettingsResolver copyWith({
    AccountChannelDefaults? accountDefaults,
    Map<int, ChannelOverrides>? overridesByPropertyId,
  }) {
    return ChannelSettingsResolver(
      accountDefaults: accountDefaults ?? this.accountDefaults,
      overridesByPropertyId:
          overridesByPropertyId ?? this.overridesByPropertyId,
    );
  }
}
