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

  /// The account defaults when only the three commission percentages are
  /// stored account-wide.
  ///
  /// That is today's shape: `admin_settings` carries a commission per channel
  /// and nothing else, so markup and costs default to zero until the account
  /// tier has a column of its own. Callers pass the percentages rather than the
  /// settings row, so this stays free of any dependency on where they live.
  factory AccountChannelDefaults.fromCommissionPercentages({
    required double booking,
    required double airbnb,
    required double other,
  }) {
    return AccountChannelDefaults(
      booking: ChannelConfig(commissionPercentage: booking),
      airbnb: ChannelConfig(commissionPercentage: airbnb),
      other: ChannelConfig(commissionPercentage: other),
    );
  }

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
