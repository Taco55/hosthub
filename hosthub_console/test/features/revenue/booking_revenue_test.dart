import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/revenue/domain/booking_revenue.dart';

/// A Lodgify booking states its money in whatever shape the channel that
/// produced it used, so every figure is a search over candidate paths. These
/// pin that search: the paths both screens rely on, the arithmetic that fills
/// in what the payload leaves out, and the guards that keep a nonsense value
/// off the screen.
void main() {
  Reservation booking(Map<String, dynamic> raw, {num? totalAmount}) =>
      Reservation(
        propertyId: 1,
        reservationId: 'B-1',
        startDate: DateTime(2027, 2, 7),
        endDate: DateTime(2027, 2, 12),
        source: 'airbnb',
        totalAmount: totalAmount,
        raw: raw,
      );

  num? amountOf(BookingPayloadRevenue revenue, BookingRevenueLineKind kind) {
    for (final line in revenue.lines) {
      if (line.kind == kind) return line.amount;
    }
    return null;
  }

  group('currency and totals', () {
    test('reads the currency from any of the known shapes', () {
      for (final raw in [
        {'currency': 'NOK'},
        {'currencyCode': 'NOK'},
        {
          'pricing': {'currency': 'NOK'},
        },
        {
          'financials': {'currency': 'NOK'},
        },
      ]) {
        expect(readBookingPayloadRevenue(booking(raw)).currency, 'NOK');
      }
    });

    test('the reservation total wins over the payload', () {
      final revenue = readBookingPayloadRevenue(
        booking({'total': 900}, totalAmount: 1200),
      );

      expect(revenue.total, 1200);
    });

    test('falls back through totalAmount → total → amount → price', () {
      expect(readBookingPayloadRevenue(booking({'price': 700})).total, 700);
      expect(
        readBookingPayloadRevenue(
          booking({
            'quote': {'total': 800},
          }),
        ).total,
        800,
      );
    });

    test('a string amount with a comma decimal still parses', () {
      expect(
        readBookingPayloadRevenue(booking({'total': '1.234,50'})).total,
        1234.5,
      );
    });
  });

  group('paid / outstanding arithmetic', () {
    test('derives outstanding from total and paid', () {
      final revenue = readBookingPayloadRevenue(
        booking({'total': 1000, 'paid': 400}),
      );

      expect(revenue.outstanding, 600);
    });

    test('derives paid from total and outstanding', () {
      final revenue = readBookingPayloadRevenue(
        booking({'total': 1000, 'amountDue': 250}),
      );

      expect(revenue.paid, 750);
    });

    test('derives the total from paid plus outstanding', () {
      final revenue = readBookingPayloadRevenue(
        booking({'paid': 300, 'outstanding': 200}),
      );

      expect(revenue.total, 500);
    });
  });

  group('breakdown lines', () {
    test('classifies each cost by kind, not by label', () {
      final revenue = readBookingPayloadRevenue(
        booking({
          'rent': 4000,
          'cleaningFee': 1200,
          'linenFee': 400,
          'serviceFee': 200,
          'tax': 300,
          'commission': 500,
          'discount': 100,
          'deposit': 1000,
          'extras': 50,
          'total': 6000,
        }),
      );

      expect(amountOf(revenue, BookingRevenueLineKind.rent), 4000);
      expect(amountOf(revenue, BookingRevenueLineKind.cleaning), 1200);
      expect(amountOf(revenue, BookingRevenueLineKind.linen), 400);
      expect(amountOf(revenue, BookingRevenueLineKind.service), 200);
      expect(amountOf(revenue, BookingRevenueLineKind.tax), 300);
      expect(amountOf(revenue, BookingRevenueLineKind.channelFee), 500);
      expect(amountOf(revenue, BookingRevenueLineKind.discount), 100);
      expect(amountOf(revenue, BookingRevenueLineKind.deposit), 1000);
      expect(amountOf(revenue, BookingRevenueLineKind.extra), 50);
    });

    test('a missing cost produces no line at all', () {
      final revenue = readBookingPayloadRevenue(booking({'total': 1000}));

      expect(amountOf(revenue, BookingRevenueLineKind.cleaning), isNull);
      expect(revenue.lines, isEmpty);
    });

    test('reads a cleaning fee out of Lodgify price types', () {
      final revenue = readBookingPayloadRevenue(
        booking({
          'total': 5000,
          'room_types': [
            {
              'price_types': [
                {'type': 2, 'description': 'Cleaning fee', 'subtotal': 1200},
                // type 1 is the stay itself, not a fee.
                {'type': 1, 'description': 'Rent', 'subtotal': 3800},
              ],
            },
          ],
        }),
      );

      expect(amountOf(revenue, BookingRevenueLineKind.cleaning), 1200);
    });

    test('an amount below half a cent counts as zero and is dropped', () {
      final revenue = readBookingPayloadRevenue(
        booking({'total': 1000, 'cleaningFee': 0.001}),
      );

      expect(amountOf(revenue, BookingRevenueLineKind.cleaning), 0);
    });
  });

  group('channel commission', () {
    test('without account settings the payload is all there is', () {
      final revenue = readBookingPayloadRevenue(booking({'total': 1000}));

      expect(amountOf(revenue, BookingRevenueLineKind.channelFee), isNull);
    });

    test('a commission larger than the booking is rejected', () {
      // A payload that reports the channel's own gross as a "fee" would
      // otherwise wipe out the net figure.
      final revenue = readBookingPayloadRevenue(
        booking({'total': 1000, 'commission': 5000}),
      );

      expect(amountOf(revenue, BookingRevenueLineKind.channelFee), isNull);
    });
  });

  group('row revenue (the booking table)', () {
    test('reads total, nightly rate and net', () {
      final row = readBookingRowRevenue(
        booking({'total': 5000, 'nightlyRate': 1000, 'net': 4200}),
      );

      expect(row.total, 5000);
      expect(row.nightlyRate, 1000);
      expect(row.net, 4200);
    });

    test('an empty payload yields nulls, not zeroes', () {
      final row = readBookingRowRevenue(booking(const {}));

      expect(row.total, isNull);
      expect(row.net, isNull);
      expect(row.currency, isNull);
    });
  });
}
