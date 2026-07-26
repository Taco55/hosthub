import 'package:hosthub_console/features/properties/domain/booking_channel.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';

/// What one property states for itself, per channel — and nothing more.
///
/// Sparse by construction: a null field means "follows the account", not "zero".
/// That distinction is the whole point of the two tiers. Store a property's full
/// settings instead and a later change to an account default stops reaching it,
/// which is how the two tiers silently drift apart.
class ChannelOverride {
  const ChannelOverride({
    this.commissionPercentage,
    this.rateMarkupPercentage,
    this.cleaningCost,
    this.linenCost,
    this.serviceCost,
    this.otherCost,
  });

  static const ChannelOverride none = ChannelOverride();

  final double? commissionPercentage;
  final double? rateMarkupPercentage;
  final CostEntry? cleaningCost;
  final CostEntry? linenCost;
  final CostEntry? serviceCost;
  final CostEntry? otherCost;

  /// Reads one channel's stored overrides.
  ///
  /// A cost the payload does not state, or states without an amount, is not an
  /// override. Rows written before the tiers existed carry every cost with
  /// `amount: 0` — an explicit zero, which is read back as an override of zero
  /// because that is what it says. Clearing the field in Prijzen is what returns
  /// it to the account value.
  factory ChannelOverride.fromMap(Map<String, dynamic>? map) {
    if (map == null) return none;
    final costs = map['costs'] as Map<String, dynamic>? ?? const {};
    return ChannelOverride(
      commissionPercentage: parseChannelDouble(map['commission_percentage']),
      rateMarkupPercentage: parseChannelDouble(map['rate_markup_percentage']),
      cleaningCost: CostEntry.fromMapOrNull(
        costs['cleaning'] as Map<String, dynamic>?,
      ),
      linenCost: CostEntry.fromMapOrNull(
        costs['linen'] as Map<String, dynamic>?,
      ),
      serviceCost: CostEntry.fromMapOrNull(
        costs['service'] as Map<String, dynamic>?,
      ),
      otherCost: CostEntry.fromMapOrNull(
        costs['other'] as Map<String, dynamic>?,
      ),
    );
  }

  /// Only the fields this property actually overrides.
  ///
  /// Keys are omitted rather than written as null, so a round trip through the
  /// store cannot turn "follows the account" into "overridden with nothing".
  Map<String, dynamic> toMap() {
    final costs = <String, dynamic>{
      if (cleaningCost != null) 'cleaning': cleaningCost!.toMap(),
      if (linenCost != null) 'linen': linenCost!.toMap(),
      if (serviceCost != null) 'service': serviceCost!.toMap(),
      if (otherCost != null) 'other': otherCost!.toMap(),
    };

    return <String, dynamic>{
      if (commissionPercentage != null)
        'commission_percentage': commissionPercentage,
      if (rateMarkupPercentage != null)
        'rate_markup_percentage': rateMarkupPercentage,
      if (costs.isNotEmpty) 'costs': costs,
    };
  }

  /// This channel's config with the overrides applied, field by field.
  ChannelConfig applyTo(ChannelConfig accountDefault) {
    return ChannelConfig(
      commissionPercentage:
          commissionPercentage ?? accountDefault.commissionPercentage,
      rateMarkupPercentage:
          rateMarkupPercentage ?? accountDefault.rateMarkupPercentage,
      cleaningCost: cleaningCost ?? accountDefault.cleaningCost,
      linenCost: linenCost ?? accountDefault.linenCost,
      serviceCost: serviceCost ?? accountDefault.serviceCost,
      otherCost: otherCost ?? accountDefault.otherCost,
    );
  }

  /// How many of this channel's fields deviate from the account.
  int get overriddenFieldCount {
    var count = 0;
    if (commissionPercentage != null) count++;
    if (rateMarkupPercentage != null) count++;
    if (cleaningCost != null) count++;
    if (linenCost != null) count++;
    if (serviceCost != null) count++;
    if (otherCost != null) count++;
    return count;
  }

  bool get isEmpty => overriddenFieldCount == 0;

  bool equals(ChannelOverride other) =>
      channelDoublesClose(commissionPercentage, other.commissionPercentage) &&
      channelDoublesClose(rateMarkupPercentage, other.rateMarkupPercentage) &&
      _costsEqual(cleaningCost, other.cleaningCost) &&
      _costsEqual(linenCost, other.linenCost) &&
      _costsEqual(serviceCost, other.serviceCost) &&
      _costsEqual(otherCost, other.otherCost);

  static bool _costsEqual(CostEntry? a, CostEntry? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.equals(b);
  }
}

/// A property's overrides across all channels — the per-property tier.
class ChannelOverrides {
  const ChannelOverrides({
    this.booking = ChannelOverride.none,
    this.airbnb = ChannelOverride.none,
    this.other = ChannelOverride.none,
  });

  /// A property that follows the account in everything.
  static const ChannelOverrides none = ChannelOverrides();

  final ChannelOverride booking;
  final ChannelOverride airbnb;
  final ChannelOverride other;

  factory ChannelOverrides.fromMap(Map<String, dynamic>? map) {
    if (map == null) return none;
    return ChannelOverrides(
      booking: ChannelOverride.fromMap(
        map[BookingChannel.booking.key] as Map<String, dynamic>?,
      ),
      airbnb: ChannelOverride.fromMap(
        map[BookingChannel.airbnb.key] as Map<String, dynamic>?,
      ),
      other: ChannelOverride.fromMap(
        map[BookingChannel.other.key] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    final booking = this.booking.toMap();
    final airbnb = this.airbnb.toMap();
    final other = this.other.toMap();
    return <String, dynamic>{
      if (booking.isNotEmpty) BookingChannel.booking.key: booking,
      if (airbnb.isNotEmpty) BookingChannel.airbnb.key: airbnb,
      if (other.isNotEmpty) BookingChannel.other.key: other,
    };
  }

  ChannelOverride forChannel(BookingChannel channel) {
    switch (channel) {
      case BookingChannel.booking:
        return booking;
      case BookingChannel.airbnb:
        return airbnb;
      case BookingChannel.other:
        return other;
    }
  }

  /// The count behind the `[n]` badge on Prijzen: how many channel fields this
  /// property states itself. Absent, not zero, when it follows the account
  /// everywhere.
  int get overriddenFieldCount =>
      booking.overriddenFieldCount +
      airbnb.overriddenFieldCount +
      other.overriddenFieldCount;

  bool get isEmpty => overriddenFieldCount == 0;

  bool equals(ChannelOverrides other) =>
      booking.equals(other.booking) &&
      airbnb.equals(other.airbnb) &&
      this.other.equals(other.other);
}
