import 'package:hosthub_console/features/properties/domain/booking_channel.dart';

/// How a cost is calculated per booking.
enum CostType {
  /// Flat amount per reservation.
  perBooking,

  /// Multiplied by the number of guests.
  perPerson,

  /// Multiplied by the number of nights.
  perNight,
}

/// The [CostType] a stored key means. Unknown or absent reads as per booking —
/// the shape a cost written before the type existed had.
CostType costTypeFromKey(String? value) {
  switch (value) {
    case 'per_person':
      return CostType.perPerson;
    case 'per_night':
      return CostType.perNight;
    default:
      return CostType.perBooking;
  }
}

/// The stored key for a [CostType].
String costTypeKey(CostType type) {
  switch (type) {
    case CostType.perBooking:
      return 'per_booking';
    case CostType.perPerson:
      return 'per_person';
    case CostType.perNight:
      return 'per_night';
  }
}

/// A single cost entry with an amount and calculation type.
class CostEntry {
  const CostEntry({this.amount = 0, this.type = CostType.perBooking});

  final double amount;
  final CostType type;

  factory CostEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CostEntry();
    return CostEntry(
      amount: parseChannelDouble(map['amount']) ?? 0,
      type: costTypeFromKey(map['type'] as String?),
    );
  }

  /// The entry as stored, or null when [map] states no amount at all.
  ///
  /// A cost that carries no amount is not a cost of zero — it is a field the
  /// property does not speak about, which is what
  /// [ChannelOverride] needs to stay sparse.
  static CostEntry? fromMapOrNull(Map<String, dynamic>? map) {
    if (map == null) return null;
    final amount = parseChannelDouble(map['amount']);
    if (amount == null) return null;
    return CostEntry(
      amount: amount,
      type: costTypeFromKey(map['type'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {'amount': amount, 'type': costTypeKey(type)};

  /// Calculate the effective cost given booking context.
  double resolve({int guests = 1, int nights = 1}) {
    switch (type) {
      case CostType.perBooking:
        return amount;
      case CostType.perPerson:
        return amount * guests;
      case CostType.perNight:
        return amount * nights;
    }
  }

  bool equals(CostEntry other) =>
      channelDoublesClose(amount, other.amount) && type == other.type;
}

/// One channel's settings, fully resolved.
///
/// Every field carries a value: this is the answer for a specific property, not
/// a tier that can defer to another one. Only
/// [ChannelSettingsResolver.effectiveChannelSettings] produces it for a
/// property, so the arithmetic below can never run on half-merged input.
class ChannelConfig {
  const ChannelConfig({
    this.commissionPercentage = 0,
    this.rateMarkupPercentage = 0,
    this.cleaningCost = const CostEntry(),
    this.linenCost = const CostEntry(),
    this.serviceCost = const CostEntry(),
    this.otherCost = const CostEntry(),
  });

  /// What the channel withholds, as a percentage of gross.
  final double commissionPercentage;

  /// Rate markup percentage applied to the base nightly price for this channel.
  final double rateMarkupPercentage;

  final CostEntry cleaningCost;
  final CostEntry linenCost;
  final CostEntry serviceCost;
  final CostEntry otherCost;

  factory ChannelConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChannelConfig();
    final costs = map['costs'] as Map<String, dynamic>? ?? const {};
    return ChannelConfig(
      commissionPercentage:
          parseChannelDouble(map['commission_percentage']) ?? 0,
      rateMarkupPercentage:
          parseChannelDouble(map['rate_markup_percentage']) ?? 0,
      cleaningCost: CostEntry.fromMap(
        costs['cleaning'] as Map<String, dynamic>?,
      ),
      linenCost: CostEntry.fromMap(costs['linen'] as Map<String, dynamic>?),
      serviceCost: CostEntry.fromMap(costs['service'] as Map<String, dynamic>?),
      otherCost: CostEntry.fromMap(costs['other'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'commission_percentage': commissionPercentage,
    'rate_markup_percentage': rateMarkupPercentage,
    'costs': {
      'cleaning': cleaningCost.toMap(),
      'linen': linenCost.toMap(),
      'service': serviceCost.toMap(),
      'other': otherCost.toMap(),
    },
  };

  /// Settle one stay against this channel's rules.
  ///
  /// `net = (base + markup) − commission − (cleaning + linen + service + other)`
  ///
  /// The commission is this config's own, which is only correct because the
  /// config is already resolved for the booking's property — see
  /// [ChannelSettingsResolver]. Passing a percentage in is what allowed a
  /// portfolio view to cost every booking with one property's rates.
  ///
  /// This is the only place the payout arithmetic lives — the Revenue table and
  /// the Pricing preview both call it, so a change lands in both at once.
  ChannelSettlement settle({
    required double baseRate,
    required int nights,
    required int guests,
  }) {
    final safeNights = nights < 0 ? 0 : nights;
    final safeGuests = guests < 1 ? 1 : guests;

    final markupPerNight = baseRate * (rateMarkupPercentage / 100);
    final markup = markupPerNight * safeNights;
    final gross = (baseRate + markupPerNight) * safeNights;
    final commission = gross * (commissionPercentage / 100);

    return ChannelSettlement(
      baseRate: baseRate,
      nights: safeNights,
      guests: safeGuests,
      markup: markup,
      gross: gross,
      commission: commission,
      fixedCosts: totalCosts(guests: safeGuests, nights: safeNights),
    );
  }

  /// Total fixed costs for a booking given guest count and number of nights.
  double totalCosts({int guests = 1, int nights = 1}) {
    return cleaningCost.resolve(guests: guests, nights: nights) +
        linenCost.resolve(guests: guests, nights: nights) +
        serviceCost.resolve(guests: guests, nights: nights) +
        otherCost.resolve(guests: guests, nights: nights);
  }

  bool equals(ChannelConfig other) =>
      channelDoublesClose(commissionPercentage, other.commissionPercentage) &&
      channelDoublesClose(rateMarkupPercentage, other.rateMarkupPercentage) &&
      cleaningCost.equals(other.cleaningCost) &&
      linenCost.equals(other.linenCost) &&
      serviceCost.equals(other.serviceCost) &&
      otherCost.equals(other.otherCost);

  ChannelConfig copyWith({
    double? commissionPercentage,
    double? rateMarkupPercentage,
    CostEntry? cleaningCost,
    CostEntry? linenCost,
    CostEntry? serviceCost,
    CostEntry? otherCost,
  }) {
    return ChannelConfig(
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      rateMarkupPercentage: rateMarkupPercentage ?? this.rateMarkupPercentage,
      cleaningCost: cleaningCost ?? this.cleaningCost,
      linenCost: linenCost ?? this.linenCost,
      serviceCost: serviceCost ?? this.serviceCost,
      otherCost: otherCost ?? this.otherCost,
    );
  }
}

/// What a booking is worth once the channel's rules are applied.
///
/// The single settlement result used by both the Revenue table and the Pricing
/// payout preview, so the two can never disagree. Every field is derived, so a
/// caller reads rather than recomputes.
class ChannelSettlement {
  const ChannelSettlement({
    required this.baseRate,
    required this.nights,
    required this.guests,
    required this.markup,
    required this.gross,
    required this.commission,
    required this.fixedCosts,
  });

  /// Nightly rate before this channel's markup.
  final double baseRate;
  final int nights;
  final int guests;

  /// Amount the channel markup adds across the whole stay.
  final double markup;

  /// What the guest pays: `(baseRate + markup per night) * nights`.
  final double gross;

  /// The channel's cut of [gross].
  final double commission;

  /// Cleaning, linen, service and other costs, each resolved per its own
  /// [CostType].
  final double fixedCosts;

  /// What the host keeps.
  double get net => gross - commission - fixedCosts;

  /// Gross minus commission, before the host's own costs — the channel payout.
  double get payout => gross - commission;
}

/// Every channel's settings for one property, fully resolved.
///
/// Produced only by [ChannelSettingsResolver.effectiveChannelSettings], for a
/// property id. A screen that holds one of these holds the answer for exactly
/// one property and cannot accidentally apply it to another.
class EffectiveChannelSettings {
  const EffectiveChannelSettings({
    required this.propertyId,
    required this.booking,
    required this.airbnb,
    required this.other,
  });

  /// The property these settings were resolved for.
  final int propertyId;

  final ChannelConfig booking;
  final ChannelConfig airbnb;
  final ChannelConfig other;

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

  /// The config for a provider's source string.
  ChannelConfig forSource(String? source) =>
      forChannel(bookingChannelForSource(source));

  /// Settle a stay booked through [source] against that channel's rules.
  ChannelSettlement settleForSource(
    String? source, {
    required double baseRate,
    required int nights,
    required int guests,
  }) {
    return forSource(
      source,
    ).settle(baseRate: baseRate, nights: nights, guests: guests);
  }
}

/// Whether two channel amounts are the same money.
///
/// Percentages and costs arrive as text and as JSON numbers, so an exact
/// comparison reports a change the user did not make.
bool channelDoublesClose(double? a, double? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  return (a - b).abs() < 0.001;
}

/// A channel amount from JSON or from a text field, or null when absent.
double? parseChannelDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }
  return null;
}
