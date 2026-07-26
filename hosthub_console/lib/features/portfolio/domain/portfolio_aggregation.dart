import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings_resolver.dart';

/// The three portfolio aggregation rules, in one place.
///
/// Each of them replaces something that was right for one property and silently
/// wrong for several. The handoff (§3) names the failure behind each; the tests
/// beside this file reproduce them.

/// ① The filtered booking set.
///
/// Every total, KPI, chart bucket, export row and detail modal reads this one
/// list. A booking whose property is outside the selection never enters any of
/// them — including bookings for properties outside the account, which is why
/// the check is "is it selected" and not "is it not deselected".
List<Reservation> bookingsForSelection(
  Iterable<Reservation> bookings,
  PropertySelection selection,
) {
  return bookings
      .where((booking) => selection.contains(booking.propertyId))
      .toList(growable: false);
}

/// ② The settings a booking is costed with: its **own** property's.
///
/// Not the selection's and not the open property's. A portfolio view mixes
/// properties with different commissions and costs, so resolving once for the
/// screen prices some of the bookings wrong without ever looking wrong. Reading
/// this through a named function keeps the `booking.propertyId` argument visible
/// at the call site.
EffectiveChannelSettings channelSettingsForBooking(
  ChannelSettingsResolver resolver,
  Reservation booking,
) => resolver.effectiveChannelSettings(booking.propertyId);

/// ③ Occupied nights inside a period, over the whole selection.
///
/// Half-open per stay, `[checkIn, checkOut)`: the departure day is not an
/// occupied night, and a stay that straddles a boundary contributes only the
/// nights inside the period. Both were wrong in the screens this replaces — they
/// counted the check-out day, so two back-to-back stays could report 32 nights
/// in a 31-day month.
///
/// [periodEnd] is exclusive.
int occupiedNightsInPeriod(
  Iterable<Reservation> bookings, {
  required DateTime periodStart,
  required DateTime periodEnd,
}) {
  final from = _dateOnly(periodStart);
  final until = _dateOnly(periodEnd);
  if (!until.isAfter(from)) return 0;

  var nights = 0;
  for (final booking in bookings) {
    nights += _clippedNights(booking, periodStart: from, periodEnd: until);
  }
  return nights;
}

/// The nights of one stay that fall inside `[periodStart, periodEnd)`.
int _clippedNights(
  Reservation booking, {
  required DateTime periodStart,
  required DateTime periodEnd,
}) {
  final start = booking.startDate;
  final end = booking.endDate;
  // A stay with no dates cannot occupy anything; one with no departure is a
  // single night, which is how the calendar renders it.
  if (start == null) return 0;
  final checkIn = _dateOnly(start);
  final checkOut = end == null
      ? checkIn.add(const Duration(days: 1))
      : _dateOnly(end);

  final from = checkIn.isBefore(periodStart) ? periodStart : checkIn;
  final until = checkOut.isAfter(periodEnd) ? periodEnd : checkOut;
  final nights = until.difference(from).inDays;
  return nights < 0 ? 0 : nights;
}

/// ③ Occupancy as a rate: capacity scales with the selection.
///
/// `occupiedNights / (daysInPeriod × selectedPropertyCount)`. Dividing by a
/// single property's calendar inflates a four-property view by about four times
/// — the figure would read over 100% and still look plausible.
///
/// Zero when there is nothing to divide by, rather than infinity or a crash.
double occupancyRate({
  required int occupiedNights,
  required int daysInPeriod,
  required int selectedPropertyCount,
}) {
  if (daysInPeriod <= 0 || selectedPropertyCount <= 0) return 0;
  final capacity = daysInPeriod * selectedPropertyCount;
  return occupiedNights / capacity;
}

/// [occupancyRate] as the whole percentage the KPI tiles show.
int occupancyPercentage({
  required int occupiedNights,
  required int daysInPeriod,
  required int selectedPropertyCount,
}) {
  return (occupancyRate(
            occupiedNights: occupiedNights,
            daysInPeriod: daysInPeriod,
            selectedPropertyCount: selectedPropertyCount,
          ) *
          100)
      .round();
}

/// Days in `[start, end)` — the denominator's first factor.
int daysInPeriod({required DateTime start, required DateTime end}) {
  final days = _dateOnly(end).difference(_dateOnly(start)).inDays;
  return days < 0 ? 0 : days;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
