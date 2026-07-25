import 'package:flutter_test/flutter_test.dart';

/// Occupancy is a percentage of the month, and the nights behind it are clipped
/// to that month — a stay straddling the boundary must not count its nights on
/// the other side. Mirrors the occupancy checks in the handoff's CONFORMANCE.md.
///
/// The page's `_MonthSummary` is private, so these pin the arithmetic it
/// implements: half-open `[start, end)` nights, clipped to the month, over the
/// number of days in that month.
void main() {
  int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 1).difference(DateTime(year, month, 1)).inDays;

  int occupancyPercentage(int occupiedNights, int days) {
    if (days <= 0) return 0;
    return ((occupiedNights / days) * 100).round();
  }

  /// Nights of `[start, end)` that fall inside `[monthStart, monthEnd)`.
  int clippedNights(
    DateTime start,
    DateTime end,
    DateTime monthStart,
    DateTime monthEnd,
  ) {
    final from = start.isBefore(monthStart) ? monthStart : start;
    final to = end.isAfter(monthEnd) ? monthEnd : end;
    final nights = to.difference(from).inDays;
    return nights < 0 ? 0 : nights;
  }

  group('days in month', () {
    test('is the real length, including February in a leap year', () {
      expect(daysInMonth(2027, 1), 31);
      expect(daysInMonth(2027, 2), 28);
      expect(daysInMonth(2028, 2), 29); // leap
      expect(daysInMonth(2027, 4), 30);
      expect(daysInMonth(2027, 12), 31);
    });
  });

  group('occupancy percentage', () {
    test('is nights over the month, rounded', () {
      expect(occupancyPercentage(31, 31), 100);
      expect(occupancyPercentage(0, 31), 0);
      // 21/31 = 67.7% -> 68
      expect(occupancyPercentage(21, 31), 68);
      // 15/30 = exactly half
      expect(occupancyPercentage(15, 30), 50);
    });

    test('a month with no days reads zero rather than dividing by zero', () {
      expect(occupancyPercentage(5, 0), 0);
    });
  });

  group('nights are half-open and clipped to the month', () {
    final julyStart = DateTime(2026, 7, 1);
    final julyEnd = DateTime(2026, 8, 1);

    test('a check-out day is not an occupied night', () {
      // 24 -> 31 July is 7 nights, and the 31st itself is free.
      final nights = clippedNights(
        DateTime(2026, 7, 24),
        DateTime(2026, 7, 31),
        julyStart,
        julyEnd,
      );
      expect(nights, 7);
    });

    test('a stay starting before the month only counts its nights inside', () {
      // 28 June -> 3 July: two of the nights (1st, 2nd) fall in July.
      final nights = clippedNights(
        DateTime(2026, 6, 28),
        DateTime(2026, 7, 3),
        julyStart,
        julyEnd,
      );
      expect(nights, 2);
    });

    test('a stay running past the month is cut at the boundary', () {
      // 30 July -> 4 August: the 30th and 31st are in July.
      final nights = clippedNights(
        DateTime(2026, 7, 30),
        DateTime(2026, 8, 4),
        julyStart,
        julyEnd,
      );
      expect(nights, 2);
    });

    test('a stay spanning the whole month counts every night once', () {
      final nights = clippedNights(
        DateTime(2026, 6, 15),
        DateTime(2026, 9, 15),
        julyStart,
        julyEnd,
      );
      expect(nights, 31);
      expect(occupancyPercentage(nights, daysInMonth(2026, 7)), 100);
    });

    test('a stay entirely outside the month contributes nothing', () {
      expect(
        clippedNights(
          DateTime(2026, 5, 1),
          DateTime(2026, 5, 8),
          julyStart,
          julyEnd,
        ),
        0,
      );
      expect(
        clippedNights(
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 8),
          julyStart,
          julyEnd,
        ),
        0,
      );
    });

    test('two stays that straddle the same boundary do not double count', () {
      // Sum of clipped nights can never exceed the days in the month.
      final a = clippedNights(
        DateTime(2026, 6, 20),
        DateTime(2026, 7, 10),
        julyStart,
        julyEnd,
      );
      final b = clippedNights(
        DateTime(2026, 7, 10),
        DateTime(2026, 8, 10),
        julyStart,
        julyEnd,
      );
      expect(a, 9);
      expect(b, 22);
      expect(a + b, daysInMonth(2026, 7));
      expect(occupancyPercentage(a + b, daysInMonth(2026, 7)), 100);
    });
  });
}
