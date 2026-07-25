import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/properties/domain/channel_settings.dart';

/// The Pricing payout preview shows one fixed example stay: 7 nights, 4 guests,
/// a base rate of 3200. These pin the arithmetic behind the rows the panel
/// renders, so the panel and the Revenue table can be trusted to agree — both
/// settle through [ChannelConfig.settle].
void main() {
  const nights = 7;
  const guests = 4;
  const baseRate = 3200.0;

  ChannelSettlement settle(ChannelConfig config, {double? commission}) {
    return config.settle(
      baseRate: baseRate,
      nights: nights,
      guests: guests,
      commissionPercentage: commission ?? config.commissionPercentage ?? 0,
    );
  }

  test('the example stay matches the figures in the design', () {
    const config = ChannelConfig(
      commissionPercentage: 15,
      cleaningCost: CostEntry(amount: 1200),
      linenCost: CostEntry(amount: 400),
    );

    final result = settle(config);

    expect(result.gross, 22400);
    expect(result.commission, closeTo(3360, 0.001));
    expect(result.fixedCosts, 1600);
    expect(result.net, closeTo(17440, 0.001));
  });

  test('editing the commission moves the net, live', () {
    const before = ChannelConfig(commissionPercentage: 15);
    const after = ChannelConfig(commissionPercentage: 18);

    final netBefore = settle(before).net;
    final netAfter = settle(after).net;

    // 3 percentage points of 22400.
    expect(netBefore - netAfter, closeTo(672, 0.001));
  });

  test('a commission override replaces the account default', () {
    const withOverride = ChannelConfig(commissionPercentage: 20);
    const withoutOverride = ChannelConfig();

    expect(settle(withOverride, commission: 20).commission, closeTo(4480, 0.001));
    // Falls back to whatever default the page passes in.
    expect(settle(withoutOverride, commission: 3).commission, closeTo(672, 0.001));
  });

  test('markup raises gross, and the commission rides along', () {
    const config = ChannelConfig(
      commissionPercentage: 10,
      rateMarkupPercentage: 5,
    );

    final result = settle(config);

    // 3200 + 5% = 3360 per night.
    expect(result.gross, closeTo(23520, 0.001));
    expect(result.markup, closeTo(1120, 0.001));
    expect(result.commission, closeTo(2352, 0.001));
  });

  test('the rows the panel splits out sum back to fixedCosts', () {
    const config = ChannelConfig(
      cleaningCost: CostEntry(amount: 1200),
      linenCost: CostEntry(amount: 400),
      serviceCost: CostEntry(amount: 50, type: CostType.perPerson),
      otherCost: CostEntry(amount: 30, type: CostType.perNight),
    );

    final cleaningAndLinen =
        config.cleaningCost.resolve(guests: guests, nights: nights) +
        config.linenCost.resolve(guests: guests, nights: nights);
    final service = config.serviceCost.resolve(guests: guests, nights: nights);
    final other = config.otherCost.resolve(guests: guests, nights: nights);

    expect(cleaningAndLinen, 1600);
    expect(service, 200); // 50 x 4 guests
    expect(other, 210); // 30 x 7 nights
    expect(cleaningAndLinen + service + other, settle(config).fixedCosts);
  });

  test('an empty channel config previews gross unchanged', () {
    final result = settle(const ChannelConfig());

    expect(result.gross, 22400);
    expect(result.fixedCosts, 0);
    expect(result.commission, 0);
    expect(result.net, 22400);
  });

  test('costs beyond the revenue make the net negative rather than clamping',
      () {
    const config = ChannelConfig(
      commissionPercentage: 50,
      cleaningCost: CostEntry(amount: 20000),
    );

    final result = settle(config);

    expect(result.net, lessThan(0));
    expect(result.net, closeTo(22400 - 11200 - 20000, 0.001));
  });
}
