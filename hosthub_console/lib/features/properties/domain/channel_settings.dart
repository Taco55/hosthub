/// How a cost is calculated per booking.
enum CostType {
  /// Flat amount per reservation.
  perBooking,

  /// Multiplied by the number of guests.
  perPerson,

  /// Multiplied by the number of nights.
  perNight,
}

CostType _costTypeFromString(String? value) {
  switch (value) {
    case 'per_person':
      return CostType.perPerson;
    case 'per_night':
      return CostType.perNight;
    default:
      return CostType.perBooking;
  }
}

String _costTypeToString(CostType type) {
  switch (type) {
    case CostType.perBooking:
      return 'per_booking';
    case CostType.perPerson:
      return 'per_person';
    case CostType.perNight:
      return 'per_night';
  }
}

String costTypeLabel(CostType type) {
  switch (type) {
    case CostType.perBooking:
      return 'per boeking';
    case CostType.perPerson:
      return 'per persoon';
    case CostType.perNight:
      return 'per nacht';
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
      amount: _toDouble(map['amount']) ?? 0,
      type: _costTypeFromString(map['type'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'type': _costTypeToString(type),
  };

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
      _close(amount, other.amount) && type == other.type;
}

/// Settings for a single booking channel (e.g. Airbnb, Booking.com, Other).
class ChannelConfig {
  const ChannelConfig({
    this.commissionPercentage,
    this.rateMarkupPercentage,
    this.cleaningCost = const CostEntry(),
    this.linenCost = const CostEntry(),
    this.serviceCost = const CostEntry(),
    this.otherCost = const CostEntry(),
  });

  /// Channel commission percentage. Null means use admin default.
  final double? commissionPercentage;

  /// Rate markup percentage applied to the base nightly price for this channel.
  final double? rateMarkupPercentage;

  final CostEntry cleaningCost;
  final CostEntry linenCost;
  final CostEntry serviceCost;
  final CostEntry otherCost;

  factory ChannelConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChannelConfig();
    final costs = map['costs'] as Map<String, dynamic>? ?? {};
    return ChannelConfig(
      commissionPercentage: _toDouble(map['commission_percentage']),
      rateMarkupPercentage: _toDouble(map['rate_markup_percentage']),
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
  /// [commissionPercentage] is the already-resolved percentage: pass
  /// [ChannelSettings.commissionPercentageForSource] so a per-channel override
  /// wins over the admin default. Passing it in keeps this free of any
  /// dependency on where those defaults are stored.
  ///
  /// This is the only place the payout arithmetic lives — the Revenue table and
  /// the Pricing preview both call it, so a change lands in both at once.
  ChannelSettlement settle({
    required double baseRate,
    required int nights,
    required int guests,
    required double commissionPercentage,
  }) {
    final safeNights = nights < 0 ? 0 : nights;
    final safeGuests = guests < 1 ? 1 : guests;

    final markupPerNight = baseRate * ((rateMarkupPercentage ?? 0) / 100);
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
      _close(commissionPercentage, other.commissionPercentage) &&
      _close(rateMarkupPercentage, other.rateMarkupPercentage) &&
      cleaningCost.equals(other.cleaningCost) &&
      linenCost.equals(other.linenCost) &&
      serviceCost.equals(other.serviceCost) &&
      otherCost.equals(other.otherCost);

  ChannelConfig copyWith({
    double? Function()? commissionPercentage,
    double? Function()? rateMarkupPercentage,
    CostEntry? cleaningCost,
    CostEntry? linenCost,
    CostEntry? serviceCost,
    CostEntry? otherCost,
  }) {
    return ChannelConfig(
      commissionPercentage: commissionPercentage != null
          ? commissionPercentage()
          : this.commissionPercentage,
      rateMarkupPercentage: rateMarkupPercentage != null
          ? rateMarkupPercentage()
          : this.rateMarkupPercentage,
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

/// Container for all channel settings on a property.
class ChannelSettings {
  const ChannelSettings({
    this.booking = const ChannelConfig(),
    this.airbnb = const ChannelConfig(),
    this.other = const ChannelConfig(),
  });

  final ChannelConfig booking;
  final ChannelConfig airbnb;
  final ChannelConfig other;

  factory ChannelSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChannelSettings();
    return ChannelSettings(
      booking: ChannelConfig.fromMap(map['booking'] as Map<String, dynamic>?),
      airbnb: ChannelConfig.fromMap(map['airbnb'] as Map<String, dynamic>?),
      other: ChannelConfig.fromMap(map['other'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'booking': booking.toMap(),
    'airbnb': airbnb.toMap(),
    'other': other.toMap(),
  };

  /// Resolve the channel config for a given source string.
  ChannelConfig configForSource(String? source) {
    final normalized = source?.trim().toLowerCase() ?? '';
    if (normalized.contains('booking')) return booking;
    if (normalized.contains('airbnb')) return airbnb;
    return other;
  }

  /// The commission percentage that applies to [source]: a per-channel override
  /// when the property sets one, otherwise the account default for that channel.
  ///
  /// The defaults are passed in rather than read from `AdminSettings`, so this
  /// rule can live in the domain without reaching into another feature.
  double commissionPercentageForSource(
    String? source, {
    required double airbnbDefault,
    required double bookingDefault,
    required double otherDefault,
  }) {
    final config = configForSource(source);
    final override = config.commissionPercentage;
    if (override != null) return override;

    final normalized = source?.trim().toLowerCase() ?? '';
    if (normalized.contains('booking')) return bookingDefault;
    if (normalized.contains('airbnb')) return airbnbDefault;
    return otherDefault;
  }

  /// Settle a stay booked through [source] against that channel's rules.
  ChannelSettlement settleForSource(
    String? source, {
    required double baseRate,
    required int nights,
    required int guests,
    required double airbnbDefaultCommission,
    required double bookingDefaultCommission,
    required double otherDefaultCommission,
  }) {
    return configForSource(source).settle(
      baseRate: baseRate,
      nights: nights,
      guests: guests,
      commissionPercentage: commissionPercentageForSource(
        source,
        airbnbDefault: airbnbDefaultCommission,
        bookingDefault: bookingDefaultCommission,
        otherDefault: otherDefaultCommission,
      ),
    );
  }

  bool equals(ChannelSettings other) =>
      booking.equals(other.booking) &&
      airbnb.equals(other.airbnb) &&
      this.other.equals(other.other);

  ChannelSettings copyWith({
    ChannelConfig? booking,
    ChannelConfig? airbnb,
    ChannelConfig? other,
  }) {
    return ChannelSettings(
      booking: booking ?? this.booking,
      airbnb: airbnb ?? this.airbnb,
      other: other ?? this.other,
    );
  }
}

bool _close(double? a, double? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  return (a - b).abs() < 0.001;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }
  return null;
}
