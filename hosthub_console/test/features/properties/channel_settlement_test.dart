import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/properties/domain/channel_settings.dart';

/// The settlement formula must exist once and be right — the Revenue table and
/// the Pricing payout preview both read it, so an error here is wrong money in
/// two places. Mirrors the domain checks in the handoff's CONFORMANCE.md.
void main() {
  group('ChannelConfig.settle', () {
    test('subtracts commission and fixed costs from gross', () {
      const config = ChannelConfig(
        commissionPercentage: 15,
        rateMarkupPercentage: 0,
        cleaningCost: CostEntry(amount: 1200),
        linenCost: CostEntry(amount: 400),
      );

      final result = config.settle(
        baseRate: 3200,
        nights: 7,
        guests: 4,
        commissionPercentage: 15,
      );

      expect(result.gross, 22400);
      expect(result.commission, closeTo(3360, 0.001));
      expect(result.fixedCosts, 1600);
      expect(result.net, closeTo(22400 - 3360 - 1600, 0.001));
      expect(result.payout, closeTo(22400 - 3360, 0.001));
    });

    test('markup raises gross and therefore the commission too', () {
      const config = ChannelConfig(rateMarkupPercentage: 10);

      final result = config.settle(
        baseRate: 1000,
        nights: 2,
        guests: 2,
        commissionPercentage: 10,
      );

      // 1000 + 10% = 1100 per night.
      expect(result.gross, 2200);
      expect(result.markup, 200);
      expect(result.commission, closeTo(220, 0.001));
      expect(result.net, closeTo(2200 - 220, 0.001));
    });

    test('each cost type resolves against the right multiplier', () {
      const config = ChannelConfig(
        cleaningCost: CostEntry(amount: 500), // per booking
        linenCost: CostEntry(amount: 50, type: CostType.perPerson),
        serviceCost: CostEntry(amount: 20, type: CostType.perNight),
      );

      final result = config.settle(
        baseRate: 100,
        nights: 3,
        guests: 4,
        commissionPercentage: 0,
      );

      // 500 + (50 * 4 guests) + (20 * 3 nights)
      expect(result.fixedCosts, 500 + 200 + 60);
    });

    test('a zero-night stay settles to nothing rather than a negative', () {
      const config = ChannelConfig(cleaningCost: CostEntry(amount: 100));

      final result = config.settle(
        baseRate: 1000,
        nights: 0,
        guests: 1,
        commissionPercentage: 10,
      );

      expect(result.gross, 0);
      expect(result.commission, 0);
      // Fixed per-booking costs still apply, so net goes negative — that is a
      // real outcome, not a clamp.
      expect(result.net, -100);
    });

    test('a negative night count is treated as zero', () {
      const config = ChannelConfig();
      final result = config.settle(
        baseRate: 1000,
        nights: -3,
        guests: 1,
        commissionPercentage: 0,
      );
      expect(result.nights, 0);
      expect(result.gross, 0);
    });

    test('guests below one are treated as one, so per-guest costs apply once',
        () {
      const config = ChannelConfig(
        serviceCost: CostEntry(amount: 25, type: CostType.perPerson),
      );

      final result = config.settle(
        baseRate: 100,
        nights: 1,
        guests: 0,
        commissionPercentage: 0,
      );

      expect(result.guests, 1);
      expect(result.fixedCosts, 25);
    });

    test('no commission and no costs means net equals gross', () {
      const config = ChannelConfig();
      final result = config.settle(
        baseRate: 800,
        nights: 5,
        guests: 2,
        commissionPercentage: 0,
      );

      expect(result.gross, 4000);
      expect(result.net, 4000);
      expect(result.payout, 4000);
    });
  });

  group('commissionPercentageForSource', () {
    const settings = ChannelSettings(
      airbnb: ChannelConfig(commissionPercentage: 12),
      booking: ChannelConfig(),
      other: ChannelConfig(),
    );

    test('a per-channel override wins over the account default', () {
      expect(
        settings.commissionPercentageForSource(
          'Airbnb',
          airbnbDefault: 3,
          bookingDefault: 15,
          otherDefault: 0,
        ),
        12,
      );
    });

    test('without an override the channel default applies', () {
      expect(
        settings.commissionPercentageForSource(
          'Booking.com',
          airbnbDefault: 3,
          bookingDefault: 15,
          otherDefault: 0,
        ),
        15,
      );
    });

    test('an unknown or absent source falls to the other default', () {
      for (final source in <String?>[null, '', 'Website', 'direct', 'Vrbo']) {
        expect(
          settings.commissionPercentageForSource(
            source,
            airbnbDefault: 3,
            bookingDefault: 15,
            otherDefault: 7,
          ),
          7,
          reason: 'source: $source',
        );
      }
    });

    test('source matching ignores case and surrounding whitespace', () {
      expect(
        settings.commissionPercentageForSource(
          '  BOOKING.COM ',
          airbnbDefault: 3,
          bookingDefault: 15,
          otherDefault: 0,
        ),
        15,
      );
    });
  });

  group('settleForSource', () {
    test('routes to the channel config and resolves the commission', () {
      const settings = ChannelSettings(
        airbnb: ChannelConfig(
          commissionPercentage: 20,
          cleaningCost: CostEntry(amount: 100),
        ),
        booking: ChannelConfig(),
        other: ChannelConfig(),
      );

      final result = settings.settleForSource(
        'airbnb',
        baseRate: 1000,
        nights: 2,
        guests: 2,
        airbnbDefaultCommission: 3,
        bookingDefaultCommission: 15,
        otherDefaultCommission: 0,
      );

      expect(result.gross, 2000);
      // The 20% override, not the 3% default.
      expect(result.commission, closeTo(400, 0.001));
      expect(result.fixedCosts, 100);
      expect(result.net, closeTo(1500, 0.001));
    });

    test('an unknown source settles against the other channel', () {
      const settings = ChannelSettings(
        other: ChannelConfig(cleaningCost: CostEntry(amount: 55)),
      );

      final result = settings.settleForSource(
        'some-new-portal',
        baseRate: 100,
        nights: 1,
        guests: 1,
        airbnbDefaultCommission: 3,
        bookingDefaultCommission: 15,
        otherDefaultCommission: 0,
      );

      expect(result.fixedCosts, 55);
      expect(result.commission, 0);
    });
  });
}
