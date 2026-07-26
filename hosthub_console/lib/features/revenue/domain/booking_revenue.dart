import 'package:flutter/foundation.dart';

import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/reservations/presentation/reservation_display.dart';

/// Reading money out of a channel payload.
///
/// A Lodgify booking carries its financials in a dozen different shapes
/// depending on the channel that produced it, so every figure is a search over
/// a list of candidate paths rather than a field read. That search used to live
/// twice in the presentation layer — once in the reservations page, once in the
/// revenue page — which is how the two screens drifted apart on which paths
/// they knew about. It lives here now, and the screens only label the result.
///
/// Nothing in this file is localised: a line carries its
/// [BookingRevenueLineKind], and the screen turns that into a label.

/// What a breakdown line represents, independent of language.
enum BookingRevenueLineKind {
  /// The stay itself.
  rent,
  cleaning,
  linen,
  service,

  /// Costs configured per channel that the payload didn't state.
  otherCosts,

  /// What the channel withheld (commission / OTA fee).
  channelFee,
  tax,
  discount,
  deposit,

  /// Anything the payload charged on top and didn't classify.
  extra,
}

/// One line between gross and net.
@immutable
class BookingRevenueLine {
  const BookingRevenueLine({required this.kind, required this.amount});

  final BookingRevenueLineKind kind;
  final num amount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingRevenueLine &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(kind, amount);
}

/// Everything the booking detail dialog shows about money.
@immutable
class BookingPayloadRevenue {
  const BookingPayloadRevenue({
    required this.currency,
    required this.nightlyRate,
    required this.total,
    required this.paid,
    required this.outstanding,
    required this.net,
    required this.payout,
    required this.lines,
  });

  final String? currency;
  final num? nightlyRate;
  final num? total;
  final num? paid;
  final num? outstanding;
  final num? net;
  final num? payout;
  final List<BookingRevenueLine> lines;

  bool get hasAnyData =>
      total != null || net != null || outstanding != null || lines.isNotEmpty;
}

class BookingRowRevenue {
  const BookingRowRevenue({
    required this.currency,
    required this.total,
    required this.nightlyRate,
    required this.fixedCosts,
    required this.channelFees,
    required this.fees,
    required this.net,
  });

  final String? currency;
  final num? total;
  final num? nightlyRate;
  final num? fixedCosts;
  final num? channelFees;
  final num? fees;
  final num? net;
}

enum BookingLineItemKind { unknown, nightly, fee, tax }

class BookingLineItem {
  const BookingLineItem({
    required this.label,
    required this.amount,
    required this.kind,
  });

  final String label;
  final num amount;
  final BookingLineItemKind kind;
}

BookingRowRevenue readBookingRowRevenue(Reservation entry) {
  final raw = entry.raw;
  final currency =
      readFirstString(raw, const [
        ['currency'],
        ['currencyCode'],
        ['currency_code'],
        ['pricing', 'currency'],
        ['financials', 'currency'],
        ['money', 'currency'],
      ]) ??
      entry.currency;

  final total = normalizeMoney(
    entry.totalAmount ??
        readFirstNum(raw, const [
          ['totalAmount'],
          ['total_amount'],
          ['total'],
          ['amount'],
          ['price'],
          ['pricing', 'total'],
          ['quote', 'total'],
          ['financials', 'total'],
        ]),
  );

  final nightlyRate = normalizeMoney(
    readFirstNum(raw, const [
      ['nightlyRate'],
      ['nightly_rate'],
      ['pricing', 'nightlyRate'],
      ['pricing', 'nightly_rate'],
      ['financials', 'nightlyRate'],
      ['financials', 'nightly_rate'],
    ]),
  );

  final lines = readBookingLineItems(raw);

  final directFixedCosts = sumMoney([
    readFirstNum(raw, const [
      ['serviceFee'],
      ['service_fee'],
      ['fees', 'service'],
      ['pricing', 'serviceFee'],
      ['pricing', 'service_fee'],
      ['financials', 'service'],
      ['financials', 'serviceFee'],
    ]),
    readFirstNum(raw, const [
      ['cleaningFee'],
      ['cleaning_fee'],
      ['cleaning'],
      ['cleaningCost'],
      ['cleaning_cost'],
      ['cleaningCosts'],
      ['cleaning_costs'],
      ['fees', 'cleaning'],
      ['pricing', 'cleaningFee'],
      ['pricing', 'cleaning_fee'],
      ['pricing', 'cleaning'],
      ['financials', 'cleaning'],
    ]),
    readFirstNum(raw, const [
      ['linenFee'],
      ['linen_fee'],
      ['linensFee'],
      ['linens_fee'],
      ['linen'],
      ['linens'],
      ['bedlinen'],
      ['bed_linen'],
      ['bedLinen'],
      ['bedLinenCost'],
      ['bed_linen_cost'],
      ['linenRental'],
      ['linen_rental'],
      ['bedLinenFee'],
      ['bed_linen_fee'],
      ['fees', 'linen'],
      ['fees', 'linens'],
      ['pricing', 'linenFee'],
      ['pricing', 'linensFee'],
      ['pricing', 'linen'],
      ['pricing', 'linens'],
      ['financials', 'linen'],
      ['financials', 'linens'],
    ]),
  ]);

  final directChannelFees = _extractDirectChannelFee(raw);

  final derivedFixedCosts = _sumLineItemsWhere(
    lines,
    (line) =>
        _isFixedCostLabel(line.label) ||
        (line.kind == BookingLineItemKind.fee &&
            !_isChannelFeeLabel(line.label)),
  );

  final derivedChannelFees = _sumLineItemsWhere(
    lines,
    (line) => _isChannelFeeLabel(line.label),
  );

  num? fixedCosts = normalizeMoney(directFixedCosts ?? derivedFixedCosts);
  num? channelFees = normalizeMoney(directChannelFees ?? derivedChannelFees);
  channelFees = _sanitizeChannelFee(channelFees, total);
  num? fees = normalizeMoney(channelFees);

  final net = normalizeMoney(
    readFirstNum(raw, const [
      ['net'],
      ['netAmount'],
      ['net_amount'],
      ['financials', 'net'],
      ['revenue', 'net'],
    ]),
  );

  return BookingRowRevenue(
    currency: currency,
    total: total,
    nightlyRate: nightlyRate,
    fixedCosts: fixedCosts,
    channelFees: channelFees,
    fees: fees,
    net: net,
  );
}

List<BookingLineItem> readBookingLineItems(Map<String, dynamic> raw) {
  final items = <BookingLineItem>[];
  final seen = <String>{};

  void addLineItem(
    String? label,
    num? amount, {
    BookingLineItemKind kind = BookingLineItemKind.unknown,
  }) {
    final resolvedLabel = label?.trim();
    final normalizedAmount = normalizeMoney(amount);
    if (resolvedLabel == null ||
        resolvedLabel.isEmpty ||
        normalizedAmount == null) {
      return;
    }
    final key =
        '${resolvedLabel.toLowerCase()}|${normalizedAmount.toStringAsFixed(6)}|$kind';
    if (!seen.add(key)) return;
    items.add(
      BookingLineItem(
        label: resolvedLabel,
        amount: normalizedAmount,
        kind: kind,
      ),
    );
  }

  void readLabelValueItems(
    Object? source, {
    BookingLineItemKind kind = BookingLineItemKind.unknown,
  }) {
    if (source is! List) return;
    for (final entry in source) {
      final map = asStringDynamicMap(entry);
      if (map == null) continue;
      final label = readFirstString(map, const [
        ['label'],
        ['name'],
        ['description'],
        ['title'],
        ['type'],
        ['itemType'],
        ['item_type'],
        ['feeType'],
        ['fee_type'],
        ['code'],
      ]);
      final amount = readFirstNum(map, const [
        ['amount'],
        ['price'],
        ['total'],
        ['subtotal'],
        ['value'],
        ['fee'],
        ['cost'],
        ['gross'],
        ['net'],
      ]);
      final resolvedKind = kind == BookingLineItemKind.unknown
          ? _kindFromLabel(label)
          : kind;
      addLineItem(label, amount, kind: resolvedKind);
    }
  }

  final roomTypes =
      readByPath(raw, const ['room_types']) ??
      readByPath(raw, const ['roomTypes']);
  if (roomTypes is List) {
    for (final roomType in roomTypes) {
      final roomMap = asStringDynamicMap(roomType);
      if (roomMap == null) continue;
      final priceTypes =
          readByPath(roomMap, const ['price_types']) ??
          readByPath(roomMap, const ['priceTypes']);
      if (priceTypes is! List) continue;

      for (final priceType in priceTypes) {
        final typeMap = asStringDynamicMap(priceType);
        if (typeMap == null) continue;

        final rawType = readByPath(typeMap, const ['type']);
        final typeValue = coerceInt(rawType);
        final kind = switch (typeValue) {
          0 => BookingLineItemKind.nightly,
          2 => BookingLineItemKind.fee,
          4 => BookingLineItemKind.tax,
          _ => BookingLineItemKind.unknown,
        };

        final subtotal = readFirstNum(typeMap, const [
          ['subtotal'],
          ['amount'],
          ['total'],
        ]);
        final typeLabel = readFirstString(typeMap, const [
          ['description'],
          ['name'],
          ['title'],
        ]);
        addLineItem(typeLabel, subtotal, kind: kind);

        final nestedPrices =
            readByPath(typeMap, const ['prices']) ??
            readByPath(typeMap, const ['items']);
        readLabelValueItems(nestedPrices, kind: kind);
      }
    }
  }

  const genericSources = [
    ['add_ons'],
    ['addOns'],
    ['other_items'],
    ['otherItems'],
    ['lines'],
    ['items'],
    ['priceLines'],
    ['breakdown'],
    ['fees'],
    ['pricing', 'fees'],
    ['pricing', 'breakdown'],
    ['financials', 'fees'],
    ['financials', 'breakdown'],
  ];
  for (final path in genericSources) {
    readLabelValueItems(readByPath(raw, path));
  }

  void walkDynamic(Object? node) {
    if (node is List) {
      for (final item in node) {
        walkDynamic(item);
      }
      return;
    }

    final map = asStringDynamicMap(node);
    if (map == null) return;

    final label = readFirstString(map, const [
      ['label'],
      ['name'],
      ['description'],
      ['title'],
      ['type'],
      ['itemType'],
      ['item_type'],
      ['feeType'],
      ['fee_type'],
      ['code'],
    ]);
    final amount = readFirstNum(map, const [
      ['amount'],
      ['price'],
      ['total'],
      ['subtotal'],
      ['value'],
      ['fee'],
      ['cost'],
      ['gross'],
      ['net'],
    ]);
    if (label != null && amount != null) {
      addLineItem(label, amount, kind: _kindFromLabel(label));
    }

    for (final entry in map.entries) {
      final key = entry.key.trim();
      final amountFromValue = parseAmount(entry.value);
      if (amountFromValue != null && _looksLikeCostOrFeeKey(key)) {
        addLineItem(key, amountFromValue, kind: _kindFromLabel(key));
      }
      walkDynamic(entry.value);
    }
  }

  walkDynamic(raw);

  return items;
}

BookingLineItemKind _kindFromLabel(String? label) {
  final normalized = label?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return BookingLineItemKind.unknown;
  if (normalized.contains('tax') || normalized.contains('vat')) {
    return BookingLineItemKind.tax;
  }
  if (normalized.contains('nightly') ||
      normalized.contains('rent') ||
      normalized.contains('base rate') ||
      normalized.contains('nachttarief') ||
      normalized.contains('huur')) {
    return BookingLineItemKind.nightly;
  }
  if (normalized.contains('fee') ||
      normalized.contains('clean') ||
      normalized.contains('schoon') ||
      normalized.contains('linen') ||
      normalized.contains('linnen') ||
      normalized.contains('towel') ||
      normalized.contains('service') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota') ||
      _hasBookingChannelSignal(normalized) ||
      normalized.contains('airbnb')) {
    return BookingLineItemKind.fee;
  }
  return BookingLineItemKind.unknown;
}

bool _looksLikeCostOrFeeKey(String key) {
  final normalized = key.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return normalized.contains('fee') ||
      normalized.contains('cost') ||
      normalized.contains('clean') ||
      normalized.contains('schoon') ||
      normalized.contains('linen') ||
      normalized.contains('linnen') ||
      normalized.contains('service') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota') ||
      _hasBookingChannelSignal(normalized) ||
      normalized.contains('airbnb');
}

bool _isFixedCostLabel(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return normalized.contains('clean') ||
      normalized.contains('schoon') ||
      normalized.contains('linen') ||
      normalized.contains('linnen') ||
      normalized.contains('towel') ||
      normalized.contains('service');
}

bool _isChannelFeeLabel(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return _hasBookingChannelSignal(normalized) ||
      normalized.contains('airbnb') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota') ||
      normalized.contains('platform');
}

bool _hasBookingChannelSignal(String normalized) {
  if (!normalized.contains('booking')) return false;
  if (normalized.contains('booking.com') ||
      normalized.contains('booking com')) {
    return true;
  }
  return normalized.contains('fee') ||
      normalized.contains('cost') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota');
}

num? _sumLineItemsWhere(
  List<BookingLineItem> lines,
  bool Function(BookingLineItem line) predicate,
) {
  num total = 0;
  var hasValue = false;
  for (final line in lines) {
    if (!predicate(line)) continue;
    total += line.amount;
    hasValue = true;
  }
  return hasValue ? normalizeMoney(total) : null;
}

num? sumMoney(List<num?> values) {
  num total = 0;
  var hasValue = false;
  for (final value in values) {
    final normalized = normalizeMoney(value);
    if (normalized == null) continue;
    total += normalized;
    hasValue = true;
  }
  return hasValue ? normalizeMoney(total) : null;
}

num? _extractDirectChannelFee(Map<String, dynamic> raw) {
  final explicitChannelFee = readFirstNum(raw, const [
    ['commission'],
    ['commissionFee'],
    ['commission_fee'],
    ['bookingComission'],
    ['bookingComissionFee'],
    ['bookingCommission'],
    ['booking_commission'],
    ['channelFee'],
    ['channel_fee'],
    ['otaFee'],
    ['ota_fee'],
    ['platformFee'],
    ['platform_fee'],
    ['airbnbFee'],
    ['airbnb_fee'],
    ['airbnbCommission'],
    ['airbnb_commission'],
    ['fees', 'commission'],
    ['fees', 'channel'],
    ['fees', 'ota'],
    ['fees', 'airbnb'],
    ['pricing', 'commission'],
    ['pricing', 'channelFee'],
    ['pricing', 'otaFee'],
    ['pricing', 'airbnbFee'],
    ['financials', 'commission'],
    ['financials', 'channelFee'],
    ['financials', 'otaFee'],
    ['financials', 'airbnbFee'],
  ]);

  final bookingSpecificFee = readFirstNum(raw, const [
    ['bookingFee'],
    ['booking_fee'],
    ['fees', 'booking'],
    ['pricing', 'bookingFee'],
    ['financials', 'bookingFee'],
  ]);

  return normalizeMoney(explicitChannelFee ?? bookingSpecificFee);
}

num? _sanitizeChannelFee(num? channelFee, num? total) {
  final normalizedFee = normalizeMoney(channelFee);
  if (normalizedFee == null) return null;

  final normalizedTotal = normalizeMoney(total);
  if (normalizedTotal == null) return normalizedFee;

  final totalAbsolute = normalizedTotal.abs();
  if (totalAbsolute < 0.01) return normalizedFee;

  final ratio = normalizedFee.abs() / totalAbsolute;
  if (ratio >= 0.95) {
    return null;
  }

  return normalizedFee;
}

num? feeFromPriceTypes(
  Map<String, dynamic> raw,
  bool Function(String label) labelMatcher,
) {
  final roomTypes =
      readByPath(raw, const ['room_types']) ??
      readByPath(raw, const ['roomTypes']);
  if (roomTypes is! List) return null;
  for (final roomType in roomTypes) {
    final roomMap = asStringDynamicMap(roomType);
    if (roomMap == null) continue;
    final priceTypes =
        readByPath(roomMap, const ['price_types']) ??
        readByPath(roomMap, const ['priceTypes']);
    if (priceTypes is! List) continue;
    for (final priceType in priceTypes) {
      final typeMap = asStringDynamicMap(priceType);
      if (typeMap == null) continue;
      final rawType = readByPath(typeMap, const ['type']);
      final typeValue = coerceInt(rawType);
      if (typeValue != 2) continue; // only fee-type items
      final description = readFirstString(typeMap, const [
        ['description'],
        ['name'],
        ['title'],
      ]);
      if (description != null && labelMatcher(description)) {
        final subtotal = readFirstNum(typeMap, const [
          ['subtotal'],
          ['amount'],
          ['total'],
        ]);
        final normalized = normalizeMoney(subtotal);
        if (normalized != null) return normalized;
      }
    }
  }
  return null;
}

num? readFirstNum(Map<String, dynamic> map, List<List<String>> paths) {
  for (final path in paths) {
    final value = readByPath(map, path);
    final amount = parseAmount(value);
    if (amount != null) return amount;
  }
  return null;
}

String? readFirstString(Map<String, dynamic> map, List<List<String>> paths) {
  for (final path in paths) {
    final value = readByPath(map, path);
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}

Object? readByPath(Map<String, dynamic> map, List<String> path) {
  Object? current = map;

  for (final segment in path) {
    if (current is! Map) return null;

    Object? next;
    if (current is Map<String, dynamic>) {
      next = current[segment];
      if (next == null) {
        final lower = segment.toLowerCase();
        for (final entry in current.entries) {
          if (entry.key.toLowerCase() == lower) {
            next = entry.value;
            break;
          }
        }
      }
    } else {
      for (final entry in current.entries) {
        final key = entry.key.toString();
        if (key == segment || key.toLowerCase() == segment.toLowerCase()) {
          next = entry.value;
          break;
        }
      }
    }

    if (next == null) return null;
    current = next;
  }

  return current;
}

Map<String, dynamic>? asStringDynamicMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    final converted = <String, dynamic>{};
    for (final entry in value.entries) {
      converted[entry.key.toString()] = entry.value;
    }
    return converted;
  }
  return null;
}

int? coerceInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed) ??
        num.tryParse(trimmed.replaceAll(',', '.'))?.toInt();
  }
  return null;
}

num? parseAmount(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final cleaned = trimmed.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (cleaned.isEmpty || cleaned == '-' || cleaned == '.' || cleaned == ',') {
      return null;
    }

    var normalized = cleaned;
    if (cleaned.contains(',') && cleaned.contains('.')) {
      if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
        normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        normalized = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      normalized = cleaned.replaceAll(',', '.');
    }

    return num.tryParse(normalized);
  }
  return null;
}

num? normalizeMoney(num? value) {
  if (value == null) return null;
  final asDouble = value.toDouble();
  if (asDouble.isNaN || asDouble.isInfinite) return null;
  if (asDouble.abs() < 0.005) return 0;
  return value;
}

/// Fixed costs from the channel configuration, for a booking whose payload
/// states none.
///
/// [channelSettings] must be the settings of *this booking's own* property —
/// `resolver.effectiveChannelSettings(booking.propertyId)`. A portfolio view
/// mixes properties with different rates, so costing every booking with one
/// property's configuration is silently wrong.
num? fallbackFixedCosts(
  EffectiveChannelSettings channelSettings,
  String? source, {
  int guests = 1,
  int nights = 1,
}) {
  final config = channelSettings.forSource(source);
  final total = config.totalCosts(guests: guests, nights: nights);
  return total > 0 ? normalizeMoney(total) : null;
}

num? channelCostFallback(
  EffectiveChannelSettings channelSettings,
  Reservation entry,
  CostEntry Function(ChannelConfig) selector,
) {
  final config = channelSettings.forSource(entry.source);
  final cost = selector(config);
  if (cost.amount <= 0) return null;
  final nights = stayNights(entry.startDate, entry.endDate) ?? 1;
  final resolved = cost.resolve(guests: entry.guestCount ?? 1, nights: nights);
  return resolved > 0 ? normalizeMoney(resolved) : null;
}

/// The commission a channel withholds, when the payload does not state it.
///
/// The percentage is this booking's own property's — see [fallbackFixedCosts].
num? fallbackChannelFeeFromRules(
  Reservation entry,
  num? totalRevenue,
  EffectiveChannelSettings channelSettings,
) {
  final total = normalizeMoney(totalRevenue);
  if (total == null || total <= 0) return null;

  final percentage = channelSettings
      .forSource(entry.source)
      .commissionPercentage;
  if (percentage <= 0) return null;
  return normalizeMoney(total * (percentage / 100));
}

void _addLine(
  List<BookingRevenueLine> lines,
  BookingRevenueLineKind kind,
  num? amount,
) {
  final normalized = normalizeMoney(amount);
  if (normalized == null) return;
  lines.add(BookingRevenueLine(kind: kind, amount: normalized));
}

/// Reads what one booking earned, straight from its payload.
///
/// [channelSettings] is optional: with it, costs and commission the payload
/// leaves out are filled in from the channel configuration (what the revenue
/// screen does); without it the result is payload-only (what the reservations
/// screen did before both screens shared this function). When passed, it must be
/// the settings of `entry.propertyId` — see [fallbackFixedCosts].
BookingPayloadRevenue readBookingPayloadRevenue(
  Reservation entry, {
  EffectiveChannelSettings? channelSettings,
}) {
  final raw = entry.raw;

  /// A cost the payload does not state, taken from the channel configuration —
  /// or nothing at all when the caller asked for a payload-only read.
  num? costFallback(CostEntry Function(ChannelConfig config) selector) {
    if (channelSettings == null) return null;
    return channelCostFallback(channelSettings, entry, selector);
  }

  final currency =
      readFirstString(raw, const [
        ['currency'],
        ['currencyCode'],
        ['currency_code'],
        ['pricing', 'currency'],
        ['financials', 'currency'],
        ['money', 'currency'],
      ]) ??
      entry.currency;

  final nightlyRate = normalizeMoney(
    readFirstNum(raw, const [
      ['nightlyRate'],
      ['nightly_rate'],
      ['ratePerNight'],
      ['rate_per_night'],
      ['pricing', 'nightlyRate'],
      ['pricing', 'nightly_rate'],
      ['financials', 'nightlyRate'],
      ['financials', 'nightly_rate'],
    ]),
  );

  var total = normalizeMoney(
    entry.totalAmount ??
        readFirstNum(raw, const [
          ['totalAmount'],
          ['total_amount'],
          ['total'],
          ['amount'],
          ['price'],
          ['pricing', 'total'],
          ['quote', 'total'],
          ['financials', 'total'],
          ['revenue', 'total'],
        ]),
  );
  var paid = normalizeMoney(
    readFirstNum(raw, const [
      ['paid'],
      ['paidAmount'],
      ['paid_amount'],
      ['amountPaid'],
      ['amount_paid'],
      ['collectedAmount'],
      ['collected_amount'],
      ['payments', 'paid'],
      ['payment', 'paid'],
      ['financials', 'paid'],
    ]),
  );
  var outstanding = normalizeMoney(
    readFirstNum(raw, const [
      ['outstanding'],
      ['amountDue'],
      ['amount_due'],
      ['balanceDue'],
      ['balance_due'],
      ['remainingAmount'],
      ['remaining_amount'],
      ['payments', 'due'],
      ['payment', 'due'],
      ['financials', 'due'],
      ['financials', 'outstanding'],
    ]),
  );
  final net = normalizeMoney(
    readFirstNum(raw, const [
      ['net'],
      ['netAmount'],
      ['net_amount'],
      ['financials', 'net'],
      ['revenue', 'net'],
    ]),
  );
  final payout = normalizeMoney(
    readFirstNum(raw, const [
      ['payout'],
      ['ownerPayout'],
      ['owner_payout'],
      ['financials', 'payout'],
      ['revenue', 'payout'],
    ]),
  );

  if (total != null) {
    if (paid == null && outstanding != null) {
      paid = normalizeMoney(total - outstanding);
    }
    if (outstanding == null && paid != null) {
      outstanding = normalizeMoney(total - paid);
    }
  } else if (paid != null && outstanding != null) {
    total = normalizeMoney(paid + outstanding);
  }

  final lines = <BookingRevenueLine>[];
  _addLine(
    lines,
    BookingRevenueLineKind.rent,
    readFirstNum(raw, const [
      ['rent'],
      ['rentAmount'],
      ['rent_amount'],
      ['baseRate'],
      ['base_rate'],
      ['baseAmount'],
      ['base_amount'],
      ['pricing', 'rent'],
      ['pricing', 'base'],
      ['financials', 'rent'],
    ]),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.rent,
    readFirstNum(raw, const [
      ['rent'],
      ['rentAmount'],
      ['rent_amount'],
      ['baseRate'],
      ['base_rate'],
      ['baseAmount'],
      ['base_amount'],
      ['pricing', 'rent'],
      ['pricing', 'base'],
      ['financials', 'rent'],
    ]),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.cleaning,
    readFirstNum(raw, const [
          ['cleaningFee'],
          ['cleaning_fee'],
          ['cleaning'],
          ['cleaningCost'],
          ['cleaning_cost'],
          ['cleaningCosts'],
          ['cleaning_costs'],
          ['fees', 'cleaning'],
          ['pricing', 'cleaningFee'],
          ['pricing', 'cleaning_fee'],
          ['pricing', 'cleaning'],
          ['financials', 'cleaning'],
        ]) ??
        feeFromPriceTypes(raw, (label) {
          final l = label.toLowerCase();
          return l.contains('clean') || l.contains('schoon');
        }) ??
        costFallback((config) => config.cleaningCost),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.linen,
    readFirstNum(raw, const [
          ['linenFee'],
          ['linen_fee'],
          ['linensFee'],
          ['linens_fee'],
          ['linen'],
          ['linens'],
          ['bedlinen'],
          ['bed_linen'],
          ['bedLinen'],
          ['bedLinenCost'],
          ['bed_linen_cost'],
          ['linenRental'],
          ['linen_rental'],
          ['fees', 'linen'],
          ['fees', 'linens'],
          ['pricing', 'linenFee'],
          ['pricing', 'linensFee'],
          ['pricing', 'linen'],
          ['pricing', 'linens'],
          ['financials', 'linen'],
          ['financials', 'linens'],
        ]) ??
        feeFromPriceTypes(raw, (label) {
          final l = label.toLowerCase();
          return l.contains('linen') ||
              l.contains('linnen') ||
              l.contains('bedlinen') ||
              l.contains('bed linen');
        }) ??
        costFallback((config) => config.linenCost),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.service,
    readFirstNum(raw, const [
          ['serviceFee'],
          ['service_fee'],
          ['fees', 'service'],
          ['pricing', 'serviceFee'],
          ['pricing', 'service_fee'],
          ['financials', 'service'],
        ]) ??
        costFallback((config) => config.serviceCost),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.otherCosts,
    costFallback((config) => config.otherCost),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.channelFee,
    _sanitizeChannelFee(
      _extractDirectChannelFee(raw) ??
          (channelSettings == null
              ? null
              : fallbackChannelFeeFromRules(entry, total, channelSettings)),
      total,
    ),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.tax,
    readFirstNum(raw, const [
      ['tax'],
      ['taxes'],
      ['vat'],
      ['taxAmount'],
      ['tax_amount'],
      ['pricing', 'tax'],
      ['financials', 'tax'],
      ['financials', 'taxes'],
    ]),
  );

  _addLine(
    lines,
    BookingRevenueLineKind.discount,
    readFirstNum(raw, const [
      ['discount'],
      ['discountAmount'],
      ['discount_amount'],
      ['pricing', 'discount'],
      ['financials', 'discount'],
    ]),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.deposit,
    readFirstNum(raw, const [
      ['deposit'],
      ['securityDeposit'],
      ['security_deposit'],
      ['pricing', 'deposit'],
      ['financials', 'deposit'],
    ]),
  );
  _addLine(
    lines,
    BookingRevenueLineKind.extra,
    readFirstNum(raw, const [
      ['extras'],
      ['extraFees'],
      ['extra_fees'],
      ['fees', 'extras'],
      ['pricing', 'extras'],
      ['financials', 'extras'],
    ]),
  );

  return BookingPayloadRevenue(
    currency: currency,
    nightlyRate: nightlyRate,
    total: total,
    paid: paid,
    outstanding: outstanding,
    net: net,
    payout: payout,
    lines: lines,
  );
}
