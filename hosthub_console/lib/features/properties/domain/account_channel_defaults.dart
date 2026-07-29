import 'package:hosthub_console/features/properties/domain/booking_channel.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';

/// The account-wide tier: commission, markup and costs per channel, for every
/// property that does not state its own value.
///
/// This is the bottom of the fallback chain, so every field is resolved — there
/// is nothing under it to defer to. A property's [ChannelOverrides] sits on top,
/// field by field.
class AccountChannelDefaults {
  const AccountChannelDefaults({
    this.booking = const ChannelConfig(),
    this.airbnb = const ChannelConfig(),
    this.other = const ChannelConfig(),
  });

  static const AccountChannelDefaults empty = AccountChannelDefaults();

  final ChannelConfig booking;
  final ChannelConfig airbnb;
  final ChannelConfig other;

  /// The account tier as `account_channel_defaults` stores it: one row per
  /// channel, every column filled.
  ///
  /// A channel with no row resolves to zeroes rather than to nothing — this is
  /// the bottom of the chain, so there is no "unspecified" here to defer to.
  factory AccountChannelDefaults.fromRows(Iterable<Map<String, dynamic>> rows) {
    var defaults = AccountChannelDefaults.empty;
    for (final row in rows) {
      final channel = bookingChannelForKey(row['channel'] as String?);
      if (channel == null) continue;
      defaults = defaults.copyWithChannel(channel, _configFromRow(row));
    }
    return defaults;
  }

  /// One upsertable row per channel.
  List<Map<String, dynamic>> toRows(String ownerProfileId) => [
    for (final channel in BookingChannel.values)
      {
        'owner_profile_id': ownerProfileId,
        'channel': channel.key,
        ..._rowFromConfig(forChannel(channel)),
      },
  ];

  static ChannelConfig _configFromRow(Map<String, dynamic> row) {
    CostEntry cost(String prefix) => CostEntry(
      amount: parseChannelDouble(row['${prefix}_amount']) ?? 0,
      type: costTypeFromKey(row['${prefix}_type'] as String?),
    );

    return ChannelConfig(
      commissionPercentage:
          parseChannelDouble(row['commission_percentage']) ?? 0,
      rateMarkupPercentage:
          parseChannelDouble(row['rate_markup_percentage']) ?? 0,
      cleaningCost: cost('cleaning'),
      linenCost: cost('linen'),
      serviceCost: cost('service'),
      otherCost: cost('other'),
    );
  }

  static Map<String, dynamic> _rowFromConfig(ChannelConfig config) => {
    'commission_percentage': config.commissionPercentage,
    'rate_markup_percentage': config.rateMarkupPercentage,
    'cleaning_amount': config.cleaningCost.amount,
    'cleaning_type': costTypeKey(config.cleaningCost.type),
    'linen_amount': config.linenCost.amount,
    'linen_type': costTypeKey(config.linenCost.type),
    'service_amount': config.serviceCost.amount,
    'service_type': costTypeKey(config.serviceCost.type),
    'other_amount': config.otherCost.amount,
    'other_type': costTypeKey(config.otherCost.type),
  };

  factory AccountChannelDefaults.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;
    return AccountChannelDefaults(
      booking: ChannelConfig.fromMap(
        map[BookingChannel.booking.key] as Map<String, dynamic>?,
      ),
      airbnb: ChannelConfig.fromMap(
        map[BookingChannel.airbnb.key] as Map<String, dynamic>?,
      ),
      other: ChannelConfig.fromMap(
        map[BookingChannel.other.key] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    BookingChannel.booking.key: booking.toMap(),
    BookingChannel.airbnb.key: airbnb.toMap(),
    BookingChannel.other.key: other.toMap(),
  };

  ChannelConfig forChannel(BookingChannel channel) {
    switch (channel) {
      case BookingChannel.booking:
        return booking;
      case BookingChannel.airbnb:
        return airbnb;
      case BookingChannel.other:
        return other;
    }
  }

  AccountChannelDefaults copyWithChannel(
    BookingChannel channel,
    ChannelConfig config,
  ) {
    switch (channel) {
      case BookingChannel.booking:
        return AccountChannelDefaults(
          booking: config,
          airbnb: airbnb,
          other: other,
        );
      case BookingChannel.airbnb:
        return AccountChannelDefaults(
          booking: booking,
          airbnb: config,
          other: other,
        );
      case BookingChannel.other:
        return AccountChannelDefaults(
          booking: booking,
          airbnb: airbnb,
          other: config,
        );
    }
  }

  bool equals(AccountChannelDefaults other) =>
      booking.equals(other.booking) &&
      airbnb.equals(other.airbnb) &&
      this.other.equals(other.other);
}
