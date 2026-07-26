import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_aggregation.dart';
import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';
import 'package:hosthub_console/features/properties/domain/account_channel_defaults.dart';
import 'package:hosthub_console/features/properties/domain/channel_overrides.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings_resolver.dart';
import 'package:hosthub_console/features/revenue/domain/booking_revenue.dart';

/// The three portfolio aggregation rules. Each group states the failure it
/// prevents, per §3 of the multi-property handoff, and covers the matching
/// Aggregation checks in its CONFORMANCE.md.
void main() {
  Reservation booking({
    required int propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    String source = 'airbnb',
    num? total,
  }) {
    return Reservation(
      propertyId: propertyId,
      reservationId: '$propertyId-${checkIn.toIso8601String()}',
      startDate: checkIn,
      endDate: checkOut,
      source: source,
      totalAmount: total,
      raw: total == null ? const {} : {'totalAmount': total},
    );
  }

  // Four properties; two of them charge a different Airbnb commission.
  const resolver = ChannelSettingsResolver(
    accountDefaults: AccountChannelDefaults(
      airbnb: ChannelConfig(commissionPercentage: 3),
      booking: ChannelConfig(commissionPercentage: 15),
    ),
    overridesByPropertyId: {
      2: ChannelOverrides(airbnb: ChannelOverride(commissionPercentage: 20)),
      3: ChannelOverrides(airbnb: ChannelOverride(commissionPercentage: 10)),
    },
  );

  final allProperties = [1, 2, 3, 4];

  group('① the filtered booking set', () {
    // Prevents: a property outside the selection — or outside the account —
    // slipping into a total.
    final bookings = [
      booking(
        propertyId: 1,
        checkIn: DateTime(2027, 7, 1),
        checkOut: DateTime(2027, 7, 5),
      ),
      booking(
        propertyId: 2,
        checkIn: DateTime(2027, 7, 3),
        checkOut: DateTime(2027, 7, 6),
      ),
      booking(
        propertyId: 4,
        checkIn: DateTime(2027, 7, 8),
        checkOut: DateTime(2027, 7, 9),
      ),
    ];

    test('keeps only the bookings of the selected properties', () {
      final selection = PropertySelection.of(
        allProperties,
        selectedPropertyIds: const [1, 2],
      );

      final filtered = bookingsForSelection(bookings, selection);

      expect(filtered.map((b) => b.propertyId), [1, 2]);
    });

    test('a booking for a property outside the account never enters', () {
      final selection = PropertySelection.all(allProperties);
      final stranger = booking(
        propertyId: 99,
        checkIn: DateTime(2027, 7, 1),
        checkOut: DateTime(2027, 7, 2),
      );

      final filtered = bookingsForSelection([...bookings, stranger], selection);

      expect(filtered.map((b) => b.propertyId), isNot(contains(99)));
      expect(filtered, hasLength(bookings.length));
    });

    test('selecting all keeps everything, in the order it came', () {
      final filtered = bookingsForSelection(
        bookings,
        PropertySelection.all(allProperties),
      );

      expect(filtered.map((b) => b.propertyId), [1, 2, 4]);
    });

    test('two of four sum to the same as those two viewed alone', () {
      int nightsFor(List<int> selected) {
        final selection = PropertySelection.of(
          allProperties,
          selectedPropertyIds: selected,
        );
        return occupiedNightsInPeriod(
          bookingsForSelection(bookings, selection),
          periodStart: DateTime(2027, 7, 1),
          periodEnd: DateTime(2027, 8, 1),
        );
      }

      expect(nightsFor([1, 2]), nightsFor([1]) + nightsFor([2]));
    });
  });

  group('② revenue costed per booking\'s own property', () {
    // Prevents the bug §3.2 names: costing a mixed portfolio with one
    // property's rates. Silently wrong — the figures still look plausible.
    num channelFeeFor(Reservation entry, EffectiveChannelSettings settings) {
      final revenue = readBookingPayloadRevenue(
        entry,
        channelSettings: settings,
      );
      for (final line in revenue.lines) {
        if (line.kind == BookingRevenueLineKind.channelFee) return line.amount;
      }
      return 0;
    }

    final onProperty1 = booking(
      propertyId: 1,
      checkIn: DateTime(2027, 7, 1),
      checkOut: DateTime(2027, 7, 3),
      total: 1000,
    );
    final onProperty2 = booking(
      propertyId: 2,
      checkIn: DateTime(2027, 7, 4),
      checkOut: DateTime(2027, 7, 6),
      total: 1000,
    );

    test('each booking is charged its own property\'s commission', () {
      expect(
        channelFeeFor(
          onProperty1,
          channelSettingsForBooking(resolver, onProperty1),
        ),
        closeTo(30, 0.001), // account default 3%
      );
      expect(
        channelFeeFor(
          onProperty2,
          channelSettingsForBooking(resolver, onProperty2),
        ),
        closeTo(200, 0.001), // property 2 overrides to 20%
      );
    });

    test('a four-property total is the sum of each own costing', () {
      final bookings = [onProperty1, onProperty2];
      final selection = PropertySelection.all(allProperties);

      var total = 0.0;
      for (final entry in bookingsForSelection(bookings, selection)) {
        total += channelFeeFor(
          entry,
          channelSettingsForBooking(resolver, entry),
        );
      }

      expect(total, closeTo(30 + 200, 0.001));
    });

    test('resolving once for the screen would price the others wrong', () {
      // What the earlier revision did: one lookup, applied to every booking.
      final openProperty = resolver.effectiveChannelSettings(1);

      var wrongTotal = 0.0;
      for (final entry in [onProperty1, onProperty2]) {
        wrongTotal += channelFeeFor(entry, openProperty);
      }

      // 3% on both instead of 3% and 20% — a €170 error on €2000 of bookings.
      expect(wrongTotal, closeTo(60, 0.001));
      expect(wrongTotal, isNot(closeTo(230, 0.001)));
    });

    test('the same booking on a property that follows the account', () {
      final onProperty4 = booking(
        propertyId: 4,
        checkIn: DateTime(2027, 7, 1),
        checkOut: DateTime(2027, 7, 3),
        total: 1000,
      );

      expect(
        channelFeeFor(
          onProperty4,
          channelSettingsForBooking(resolver, onProperty4),
        ),
        closeTo(30, 0.001),
      );
    });
  });

  group('③ occupancy divides by days × selected properties', () {
    // Prevents: dividing by one property's calendar, which inflates a
    // four-property view by about four times and can read over 100%.
    test(
      'four selected properties read about a quarter of the naive figure',
      () {
        // One full-month stay on each of the four properties: every property is
        // fully booked, so the portfolio is at 100% — not 400%.
        final bookings = [
          for (final propertyId in allProperties)
            booking(
              propertyId: propertyId,
              checkIn: DateTime(2027, 7, 1),
              checkOut: DateTime(2027, 8, 1),
            ),
        ];

        final nights = occupiedNightsInPeriod(
          bookings,
          periodStart: DateTime(2027, 7, 1),
          periodEnd: DateTime(2027, 8, 1),
        );
        expect(nights, 31 * 4);

        final naive = occupancyPercentage(
          occupiedNights: nights,
          daysInPeriod: 31,
          selectedPropertyCount: 1,
        );
        final correct = occupancyPercentage(
          occupiedNights: nights,
          daysInPeriod: 31,
          selectedPropertyCount: 4,
        );

        expect(naive, 400);
        expect(correct, 100);
        expect(correct, (naive / 4).round());
      },
    );

    test('one property selected matches that property viewed alone', () {
      final bookings = [
        booking(
          propertyId: 1,
          checkIn: DateTime(2027, 7, 1),
          checkOut: DateTime(2027, 7, 16),
        ),
        booking(
          propertyId: 2,
          checkIn: DateTime(2027, 7, 1),
          checkOut: DateTime(2027, 7, 31),
        ),
      ];

      int percentageFor(List<int> selected) {
        final selection = PropertySelection.of(
          allProperties,
          selectedPropertyIds: selected,
        );
        return occupancyPercentage(
          occupiedNights: occupiedNightsInPeriod(
            bookingsForSelection(bookings, selection),
            periodStart: DateTime(2027, 7, 1),
            periodEnd: DateTime(2027, 8, 1),
          ),
          daysInPeriod: 31,
          selectedPropertyCount: selection.selectedCount,
        );
      }

      // 15 of 31 nights.
      expect(percentageFor([1]), 48);
      // 30 of 31.
      expect(percentageFor([2]), 97);
      // Together: 45 nights over 62 property-nights.
      expect(percentageFor([1, 2]), 73);
    });

    test('a departure day is not an occupied night', () {
      // 24 → 31 July is seven nights; the 31st is free for the next guest.
      final nights = occupiedNightsInPeriod(
        [
          booking(
            propertyId: 1,
            checkIn: DateTime(2027, 7, 24),
            checkOut: DateTime(2027, 7, 31),
          ),
        ],
        periodStart: DateTime(2027, 7, 1),
        periodEnd: DateTime(2027, 8, 1),
      );

      expect(nights, 7);
    });

    test('back-to-back stays cannot exceed the days in the period', () {
      // The off-by-one this replaces counted the shared changeover day twice,
      // so these two reported 32 nights in a 31-day month.
      final nights = occupiedNightsInPeriod(
        [
          booking(
            propertyId: 1,
            checkIn: DateTime(2027, 6, 20),
            checkOut: DateTime(2027, 7, 10),
          ),
          booking(
            propertyId: 1,
            checkIn: DateTime(2027, 7, 10),
            checkOut: DateTime(2027, 8, 10),
          ),
        ],
        periodStart: DateTime(2027, 7, 1),
        periodEnd: DateTime(2027, 8, 1),
      );

      expect(nights, 31);
      expect(
        occupancyPercentage(
          occupiedNights: nights,
          daysInPeriod: 31,
          selectedPropertyCount: 1,
        ),
        100,
      );
    });

    test('a stay is clipped to the period at both ends', () {
      final nights = occupiedNightsInPeriod(
        [
          booking(
            propertyId: 1,
            checkIn: DateTime(2027, 6, 15),
            checkOut: DateTime(2027, 9, 15),
          ),
        ],
        periodStart: DateTime(2027, 7, 1),
        periodEnd: DateTime(2027, 8, 1),
      );

      expect(nights, 31);
    });

    test('a stay entirely outside the period contributes nothing', () {
      final nights = occupiedNightsInPeriod(
        [
          booking(
            propertyId: 1,
            checkIn: DateTime(2027, 5, 1),
            checkOut: DateTime(2027, 5, 8),
          ),
          booking(
            propertyId: 1,
            checkIn: DateTime(2027, 9, 1),
            checkOut: DateTime(2027, 9, 8),
          ),
        ],
        periodStart: DateTime(2027, 7, 1),
        periodEnd: DateTime(2027, 8, 1),
      );

      expect(nights, 0);
    });

    test('a stay without a departure date counts a single night', () {
      final nights = occupiedNightsInPeriod(
        [Reservation(propertyId: 1, startDate: DateTime(2027, 7, 4))],
        periodStart: DateTime(2027, 7, 1),
        periodEnd: DateTime(2027, 8, 1),
      );

      expect(nights, 1);
    });

    test('a booking with no dates at all is skipped', () {
      final nights = occupiedNightsInPeriod(
        const [Reservation(propertyId: 1)],
        periodStart: DateTime(2027, 7, 1),
        periodEnd: DateTime(2027, 8, 1),
      );

      expect(nights, 0);
    });

    test('nothing to divide by reads zero rather than dividing by zero', () {
      expect(
        occupancyPercentage(
          occupiedNights: 5,
          daysInPeriod: 0,
          selectedPropertyCount: 2,
        ),
        0,
      );
      expect(
        occupancyPercentage(
          occupiedNights: 5,
          daysInPeriod: 31,
          selectedPropertyCount: 0,
        ),
        0,
      );
      expect(
        occupancyRate(
          occupiedNights: 5,
          daysInPeriod: 31,
          selectedPropertyCount: 0,
        ),
        0,
      );
    });

    test('days in a period are the real calendar length', () {
      expect(
        daysInPeriod(start: DateTime(2027, 2, 1), end: DateTime(2027, 3, 1)),
        28,
      );
      expect(
        daysInPeriod(start: DateTime(2028, 2, 1), end: DateTime(2028, 3, 1)),
        29, // leap
      );
      expect(
        daysInPeriod(start: DateTime(2027, 3, 1), end: DateTime(2027, 2, 1)),
        0, // an inverted range has no days rather than negative ones
      );
    });
  });
}
