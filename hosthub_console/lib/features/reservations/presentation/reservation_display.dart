import 'package:intl/intl.dart';

import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';

/// Formatting the reservations and revenue screens share.
///
/// Both pages showed the same booking in a table and in the same detail
/// dialog, and both had their own copy of these six functions. One copy means
/// a guest count or an amount cannot read differently depending on which
/// screen you opened it from.

/// Nights of a stay, half-open: check-out day is not a night.
///
/// A same-day or inverted range counts as one night rather than zero — a
/// booking that exists occupied the property.
int? stayNights(DateTime? start, DateTime? end) {
  if (start == null || end == null) return null;
  final nights = _dateOnly(end).difference(_dateOnly(start)).inDays;
  return nights <= 0 ? 1 : nights;
}

/// The booker's name, or [fallback] when the channel didn't supply one.
String guestDisplayName(Reservation entry, {required String fallback}) {
  final name = entry.guestName?.trim();
  if (name == null || name.isEmpty) return fallback;
  return name;
}

/// `4 (2 + 2)` — total guests with the adults/children split behind it.
///
/// Falls back to just the total when the channel only reports a head count,
/// and to [unknownLabel] when it reports nothing at all.
String guestBreakdown(Reservation entry, {String unknownLabel = '-'}) {
  final adults = entry.adultCount;
  final children = entry.childCount;
  final hasBreakdown = adults != null || children != null;
  final totalGuests = resolvedGuestTotal(entry);

  if (totalGuests == null && !hasBreakdown) {
    return unknownLabel;
  }

  if (!hasBreakdown) {
    return totalGuests?.toString() ?? unknownLabel;
  }

  final adultsText = adults?.toString() ?? '?';
  final childrenText = children?.toString() ?? '?';
  final adultsAndChildren = (adults ?? 0) + (children ?? 0);
  final resolvedTotal = adults != null && children != null
      ? adultsAndChildren
      : (totalGuests ?? adultsAndChildren);
  return '$resolvedTotal ($adultsText + $childrenText)';
}

/// Head count, derived from the party when the channel doesn't state one.
int? resolvedGuestTotal(Reservation entry) {
  if (entry.guestCount != null) return entry.guestCount;

  final adults = entry.adultCount;
  final children = entry.childCount;
  final infants = entry.infantCount;
  if (adults == null && children == null && infants == null) return null;
  return (adults ?? 0) + (children ?? 0) + (infants ?? 0);
}

/// A trimmed value, or an em dash stand-in when there is nothing to show.
String valueOrDash(String? value) {
  if (value == null) return '-';
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '-';
  return trimmed;
}

/// An amount with its currency code, whole numbers without decimals.
String formatAmount(num? amount, String? currency) {
  if (amount == null) return '-';
  final value = amount % 1 == 0
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);
  if (currency == null || currency.trim().isEmpty) return value;
  return '$value ${currency.trim().toUpperCase()}';
}

/// Drops values that cannot be money (NaN, infinity) and rounds a fraction of
/// a cent to zero, so `-0.00` never reaches the screen.
num? normalizeMoney(num? value) {
  if (value == null) return null;
  final asDouble = value.toDouble();
  if (asDouble.isNaN || asDouble.isInfinite) return null;
  if (asDouble.abs() < 0.005) return 0;
  return value;
}

/// A date in the viewer's local zone, or null when there is no date.
String? formatDateTime(DateTime? date, DateFormat formatter) {
  if (date == null) return null;
  return formatter.format(date.toLocal());
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
