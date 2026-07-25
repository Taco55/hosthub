import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/revenue/domain/revenue_breakdown.dart';

/// The arithmetic behind the revenue chart (design §8c) and the channel split
/// (§8d). Both read the same settled rows as the booking table, so a
/// disagreement between the chart and the table would be a bug here.
void main() {
  RevenueBreakdownEntry stay({
    DateTime? checkIn,
    double? gross,
    double? net,
    String? source,
  }) {
    return RevenueBreakdownEntry(
      checkIn: checkIn,
      gross: gross,
      net: net,
      source: source,
    );
  }

  group('monthsInRange', () {
    test('covers every month the period touches, ends included', () {
      final months = monthsInRange(DateTime(2026), DateTime(2026, 12, 31));

      expect(months.length, 12);
      expect(months.first, DateTime(2026));
      expect(months.last, DateTime(2026, 12));
    });

    test('a quarter is three months', () {
      final months = monthsInRange(DateTime(2026, 7), DateTime(2026, 9, 30));

      expect(months, [DateTime(2026, 7), DateTime(2026, 8), DateTime(2026, 9)]);
    });

    test('a single month is one bucket — the page hides the chart there', () {
      expect(monthsInRange(DateTime(2026, 7), DateTime(2026, 7, 31)).length, 1);
    });

    test('crosses a year boundary', () {
      final months = monthsInRange(DateTime(2026, 11), DateTime(2027, 2, 1));

      expect(months, [
        DateTime(2026, 11),
        DateTime(2026, 12),
        DateTime(2027),
        DateTime(2027, 2),
      ]);
    });

    test('an inverted range is empty rather than infinite', () {
      expect(monthsInRange(DateTime(2026, 5), DateTime(2026, 4)), isEmpty);
    });
  });

  group('monthlyRevenue', () {
    test('sums gross and net per check-in month', () {
      final byMonth = monthlyRevenue([
        stay(checkIn: DateTime(2026, 7, 3), gross: 1000, net: 800),
        stay(checkIn: DateTime(2026, 7, 20), gross: 500, net: 390),
        stay(checkIn: DateTime(2026, 8, 1), gross: 300, net: 240),
      ]);

      expect(byMonth[DateTime(2026, 7)], const MonthRevenue(gross: 1500, net: 1190));
      expect(byMonth[DateTime(2026, 8)], const MonthRevenue(gross: 300, net: 240));
    });

    test('a stay counts whole in the month it starts', () {
      // 28 Dec → 4 Jan is December revenue, exactly as the table reports it.
      final byMonth = monthlyRevenue([
        stay(checkIn: DateTime(2026, 12, 28), gross: 7000, net: 5800),
      ]);

      expect(byMonth[DateTime(2026, 12)]?.gross, 7000);
      expect(byMonth.containsKey(DateTime(2027)), isFalse);
    });

    test('unknown amounts count as zero, not as a missing month', () {
      final byMonth = monthlyRevenue([
        stay(checkIn: DateTime(2026, 7, 3), gross: 1000, net: null),
        stay(checkIn: DateTime(2026, 7, 9), gross: null, net: null),
      ]);

      expect(byMonth[DateTime(2026, 7)], const MonthRevenue(gross: 1000, net: 0));
    });

    test('a stay without a check-in date is left out', () {
      expect(monthlyRevenue([stay(gross: 900, net: 700)]), isEmpty);
    });

    test('the day of the month never creates a second bucket', () {
      final byMonth = monthlyRevenue([
        stay(checkIn: DateTime(2026, 7, 1), gross: 100, net: 100),
        stay(checkIn: DateTime(2026, 7, 31, 15, 30), gross: 100, net: 100),
      ]);

      expect(byMonth.keys, [DateTime(2026, 7)]);
      expect(byMonth[DateTime(2026, 7)]?.gross, 200);
    });
  });

  group('channelTotals', () {
    String labelOf(String? source) {
      final value = source?.toLowerCase() ?? '';
      if (value.contains('airbnb')) return 'Airbnb';
      if (value.contains('booking')) return 'Booking.com';
      return 'Website';
    }

    test('groups by display name and sorts largest first', () {
      final channels = channelTotals([
        stay(gross: 100, source: 'airbnb'),
        stay(gross: 900, source: 'Booking.com'),
        stay(gross: 400, source: 'direct'),
      ], labelOf: labelOf);

      expect(
        channels.map((channel) => channel.label),
        ['Booking.com', 'Website', 'Airbnb'],
      );
      expect(channels.first.gross, 900);
    });

    test('two spellings of one channel are one row', () {
      final channels = channelTotals([
        stay(gross: 100, source: 'Airbnb'),
        stay(gross: 250, source: 'airbnb.com'),
      ], labelOf: labelOf);

      expect(channels.length, 1);
      expect(channels.single.gross, 350);
      // Keeps a source string so the row can still draw the channel's logo.
      expect(channels.single.source, 'Airbnb');
    });

    test('stays with an unknown amount do not create a channel', () {
      final channels = channelTotals([
        stay(gross: null, source: 'airbnb'),
        stay(gross: 200, source: 'booking'),
      ], labelOf: labelOf);

      expect(channels.map((channel) => channel.label), ['Booking.com']);
    });

    test('equal amounts get a stable alphabetical order', () {
      final channels = channelTotals([
        stay(gross: 100, source: 'direct'),
        stay(gross: 100, source: 'booking'),
        stay(gross: 100, source: 'airbnb'),
      ], labelOf: labelOf);

      expect(
        channels.map((channel) => channel.label),
        ['Airbnb', 'Booking.com', 'Website'],
      );
    });

    test('no rows means no split card', () {
      expect(channelTotals(const [], labelOf: labelOf), isEmpty);
    });
  });
}
