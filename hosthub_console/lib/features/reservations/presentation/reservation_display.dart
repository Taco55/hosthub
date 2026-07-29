import 'package:intl/intl.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/revenue/domain/booking_revenue.dart';

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

/// The console's tone for a channel's own status word.
///
/// The label stays the channel's — the console does not own that vocabulary,
/// and the filter menu lists the same raw values — but the tone is ours, so a
/// cancellation is visible without reading the word. One mapping, so a booking
/// cannot read as cancelled on one screen and neutral on another.
StatusPillTone bookingStatusTone(String? status) {
  return switch (status?.trim().toLowerCase() ?? '') {
    final s when s.contains('cancel') || s.contains('declin') =>
      StatusPillTone.negative,
    final s
        when s.contains('tentative') ||
            s.contains('pending') ||
            s.contains('option') ||
            s.contains('hold') =>
      StatusPillTone.caution,
    final s when s.contains('book') || s.contains('confirm') =>
      StatusPillTone.positive,
    _ => StatusPillTone.neutral,
  };
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

/// A date in the viewer's local zone, or null when there is no date.
String? formatDateTime(DateTime? date, DateFormat formatter) {
  if (date == null) return null;
  return formatter.format(date.toLocal());
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// The label for a breakdown line. The domain classifies a line by
/// [BookingRevenueLineKind]; naming it is a presentation concern, which is why
/// the two screens can share one reader and still speak the user's language.
String revenueLineLabel(BookingRevenueLineKind kind, S l10n) {
  switch (kind) {
    case BookingRevenueLineKind.rent:
      return l10n.revenueBreakdownRent;
    case BookingRevenueLineKind.cleaning:
      return l10n.revenueBreakdownCleaning;
    case BookingRevenueLineKind.linen:
      return l10n.revenueBreakdownLinen;
    case BookingRevenueLineKind.service:
      return l10n.revenueBreakdownServiceCosts;
    case BookingRevenueLineKind.otherCosts:
      return l10n.revenueBreakdownOtherCosts;
    case BookingRevenueLineKind.channelFee:
      return l10n.revenueBreakdownChannelFee;
    case BookingRevenueLineKind.tax:
      return l10n.revenueBreakdownTax;
    case BookingRevenueLineKind.discount:
      return l10n.revenueBreakdownDiscounts;
    case BookingRevenueLineKind.deposit:
      return l10n.revenueBreakdownDeposit;
    case BookingRevenueLineKind.extra:
      return l10n.revenueBreakdownExtraCharges;
  }
}
