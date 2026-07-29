import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/properties/domain/account_channel_defaults.dart';
import 'package:hosthub_console/features/properties/domain/booking_channel.dart';
import 'package:hosthub_console/features/properties/domain/channel_field.dart';
import 'package:hosthub_console/features/properties/domain/channel_overrides.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings_resolver.dart';

void main() {
  group('the account tier round-trips through its rows', () {
    test('every field survives a write and a read', () {
      const defaults = AccountChannelDefaults(
        airbnb: ChannelConfig(
          commissionPercentage: 15.5,
          rateMarkupPercentage: 3,
          cleaningCost: CostEntry(amount: 90),
          linenCost: CostEntry(amount: 25),
          serviceCost: CostEntry(amount: 12, type: CostType.perPerson),
          otherCost: CostEntry(amount: 5, type: CostType.perNight),
        ),
      );

      final rows = defaults.toRows('owner-1');
      final restored = AccountChannelDefaults.fromRows(rows);

      expect(restored.equals(defaults), isTrue);
      expect(rows, hasLength(BookingChannel.values.length));
      expect(rows.every((row) => row['owner_profile_id'] == 'owner-1'), isTrue);
    });

    test('a channel with no row resolves to zero, not to nothing', () {
      // This is the bottom of the fallback chain: there is nothing under it to
      // defer to, so "absent" cannot mean "unspecified" here.
      final restored = AccountChannelDefaults.fromRows(const [
        {'channel': 'airbnb', 'commission_percentage': 15},
      ]);

      expect(restored.airbnb.commissionPercentage, 15);
      expect(restored.booking.commissionPercentage, 0);
    });

    test('an unrecognised channel is skipped, never read as direct', () {
      final restored = AccountChannelDefaults.fromRows(const [
        {'channel': 'tiktok', 'commission_percentage': 99},
      ]);

      expect(restored.other.commissionPercentage, 0);
    });
  });

  group('coverage is the same question the impact line asks', () {
    /// Four properties: two follow everything, one states its own Airbnb
    /// commission, one states its own Airbnb cleaning fee.
    ChannelSettingsResolver resolverForFour() {
      return ChannelSettingsResolver.forProperties(
        accountDefaults: const AccountChannelDefaults(
          airbnb: ChannelConfig(commissionPercentage: 15),
        ),
        properties: [
          (id: 1, overrides: ChannelOverrides.none),
          (id: 2, overrides: ChannelOverrides.none),
          (
            id: 3,
            overrides: const ChannelOverrides(
              airbnb: ChannelOverride(commissionPercentage: 12),
            ),
          ),
          (
            id: 4,
            overrides: const ChannelOverrides(
              airbnb: ChannelOverride(cleaningCost: CostEntry(amount: 120)),
            ),
          ),
        ],
      );
    }

    const ids = [1, 2, 3, 4];

    test('a field counts only the properties that follow that field', () {
      final resolver = resolverForFour();

      expect(
        resolver.propertiesFollowing(
          ids,
          BookingChannel.airbnb,
          ChannelField.commission,
        ),
        [1, 2, 4],
      );
      expect(
        resolver.propertiesFollowing(
          ids,
          BookingChannel.airbnb,
          ChannelField.cleaning,
        ),
        [1, 2, 3],
      );
    });

    test('who deviates is named per channel, not per field', () {
      expect(
        resolverForFour().propertiesOverriding(ids, BookingChannel.airbnb),
        [3, 4],
      );
      expect(
        resolverForFour().propertiesOverriding(ids, BookingChannel.booking),
        isEmpty,
      );
    });

    test('a draft impacts the union of what its fields reach', () {
      // Changing both commission and cleaning reaches everyone: 3 follows the
      // cleaning fee and 4 follows the commission.
      expect(
        resolverForFour().propertiesAffectedBy(ids, const [
          (channel: BookingChannel.airbnb, field: ChannelField.commission),
          (channel: BookingChannel.airbnb, field: ChannelField.cleaning),
        ]),
        [1, 2, 3, 4],
      );
    });

    test('a default nobody follows still says so honestly', () {
      final resolver = ChannelSettingsResolver.forProperties(
        accountDefaults: AccountChannelDefaults.empty,
        properties: [
          (
            id: 1,
            overrides: const ChannelOverrides(
              airbnb: ChannelOverride(commissionPercentage: 12),
            ),
          ),
        ],
      );

      expect(
        resolver.propertiesAffectedBy(
          const [1],
          const [
            (channel: BookingChannel.airbnb, field: ChannelField.commission),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('inheritance is resolution, never a copy', () {
    test('moving the default reaches a property that never spoke', () {
      const overrides = ChannelOverrides.none;

      final before = ChannelSettingsResolver.forProperties(
        accountDefaults: const AccountChannelDefaults(
          airbnb: ChannelConfig(commissionPercentage: 15),
        ),
        properties: [(id: 1, overrides: overrides)],
      );
      final after = before.copyWith(
        accountDefaults: const AccountChannelDefaults(
          airbnb: ChannelConfig(commissionPercentage: 18),
        ),
      );

      expect(
        before.effectiveChannelSettings(1).airbnb.commissionPercentage,
        15,
      );
      // Nothing was written to the property; it simply resolves to the new
      // default, which is the whole reason a change is one row.
      expect(after.effectiveChannelSettings(1).airbnb.commissionPercentage, 18);
    });

    test('an override that equals the default is still an override', () {
      final resolver = ChannelSettingsResolver.forProperties(
        accountDefaults: const AccountChannelDefaults(
          airbnb: ChannelConfig(commissionPercentage: 15),
        ),
        properties: [
          (
            id: 1,
            overrides: const ChannelOverrides(
              airbnb: ChannelOverride(commissionPercentage: 15),
            ),
          ),
        ],
      );

      expect(resolver.overriddenFieldCount(1), 1);
      expect(
        resolver.propertiesFollowing(
          const [1],
          BookingChannel.airbnb,
          ChannelField.commission,
        ),
        isEmpty,
      );
    });
  });
}
