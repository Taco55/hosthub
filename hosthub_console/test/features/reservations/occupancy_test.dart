import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_aggregation.dart';

/// Occupancy of one month, as Boekingen's KPI tile reports it.
///
/// These used to reimplement the arithmetic the page kept private, which let the
/// two drift: the page added a day, so it counted the departure night. The
/// arithmetic now lives in `portfolio_aggregation.dart` and this exercises that
/// function directly. The portfolio side of the same rule — dividing by the
/// number of selected properties — is covered in
/// `test/features/portfolio/portfolio_aggregation_test.dart`.
void main() {
  Reservation stay(DateTime checkIn, DateTime checkOut) =>
      Reservation(propertyId: 1, startDate: checkIn, endDate: checkOut);

  int nightsInJuly(List<Reservation> stays) => occupiedNightsInPeriod(
    stays,
    periodStart: DateTime(2026, 7, 1),
    periodEnd: DateTime(2026, 8, 1),
  );

  int percentageInJuly(List<Reservation> stays) => occupancyPercentage(
    occupiedNights: nightsInJuly(stays),
    daysInPeriod: daysInPeriod(
      start: DateTime(2026, 7, 1),
      end: DateTime(2026, 8, 1),
    ),
    selectedPropertyCount: 1,
  );

  group('days in a month', () {
    test('is the real length, including February in a leap year', () {
      int days(int year, int month) => daysInPeriod(
        start: DateTime(year, month, 1),
        end: DateTime(year, month + 1, 1),
      );

      expect(days(2027, 1), 31);
      expect(days(2027, 2), 28);
      expect(days(2028, 2), 29); // leap
      expect(days(2027, 4), 30);
      expect(days(2027, 12), 31);
    });
  });

  group('occupancy percentage', () {
    test('is nights over the month, rounded', () {
      int percentage(int nights, int days) => occupancyPercentage(
        occupiedNights: nights,
        daysInPeriod: days,
        selectedPropertyCount: 1,
      );

      expect(percentage(31, 31), 100);
      expect(percentage(0, 31), 0);
      // 21/31 = 67.7% -> 68
      expect(percentage(21, 31), 68);
      // 15/30 = exactly half
      expect(percentage(15, 30), 50);
    });

    test('a month with no days reads zero rather than dividing by zero', () {
      expect(
        occupancyPercentage(
          occupiedNights: 5,
          daysInPeriod: 0,
          selectedPropertyCount: 1,
        ),
        0,
      );
    });
  });

  group('nights are half-open and clipped to the month', () {
    test('a check-out day is not an occupied night', () {
      // 24 -> 31 July is 7 nights, and the 31st itself is free.
      expect(
        nightsInJuly([stay(DateTime(2026, 7, 24), DateTime(2026, 7, 31))]),
        7,
      );
    });

    test('a stay starting before the month only counts its nights inside', () {
      // 28 June -> 3 July: two of the nights (1st, 2nd) fall in July.
      expect(
        nightsInJuly([stay(DateTime(2026, 6, 28), DateTime(2026, 7, 3))]),
        2,
      );
    });

    test('a stay running past the month is cut at the boundary', () {
      // 30 July -> 4 August: the 30th and 31st are in July.
      expect(
        nightsInJuly([stay(DateTime(2026, 7, 30), DateTime(2026, 8, 4))]),
        2,
      );
    });

    test('a stay spanning the whole month counts every night once', () {
      final stays = [stay(DateTime(2026, 6, 15), DateTime(2026, 9, 15))];

      expect(nightsInJuly(stays), 31);
      expect(percentageInJuly(stays), 100);
    });

    test('a stay entirely outside the month contributes nothing', () {
      expect(
        nightsInJuly([stay(DateTime(2026, 5, 1), DateTime(2026, 5, 8))]),
        0,
      );
      expect(
        nightsInJuly([stay(DateTime(2026, 9, 1), DateTime(2026, 9, 8))]),
        0,
      );
    });

    test('two stays that straddle the same boundary do not double count', () {
      final stays = [
        stay(DateTime(2026, 6, 20), DateTime(2026, 7, 10)),
        stay(DateTime(2026, 7, 10), DateTime(2026, 8, 10)),
      ];

      // 9 + 22 = the days in July: the changeover day belongs to one stay only.
      expect(nightsInJuly(stays), 31);
      expect(percentageInJuly(stays), 100);
    });
  });
}
