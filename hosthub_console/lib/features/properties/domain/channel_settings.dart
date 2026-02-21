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
  const CostEntry({
    this.amount = 0,
    this.type = CostType.perBooking,
  });

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
      linenCost: CostEntry.fromMap(
        costs['linen'] as Map<String, dynamic>?,
      ),
      serviceCost: CostEntry.fromMap(
        costs['service'] as Map<String, dynamic>?,
      ),
      otherCost: CostEntry.fromMap(
        costs['other'] as Map<String, dynamic>?,
      ),
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
      booking: ChannelConfig.fromMap(
        map['booking'] as Map<String, dynamic>?,
      ),
      airbnb: ChannelConfig.fromMap(
        map['airbnb'] as Map<String, dynamic>?,
      ),
      other: ChannelConfig.fromMap(
        map['other'] as Map<String, dynamic>?,
      ),
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
