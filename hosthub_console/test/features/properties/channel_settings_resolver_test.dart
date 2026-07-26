import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/properties/domain/account_channel_defaults.dart';
import 'package:hosthub_console/features/properties/domain/booking_channel.dart';
import 'package:hosthub_console/features/properties/domain/channel_overrides.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings_resolver.dart';

/// The two settings tiers, and the one function that merges them. Mirrors the
/// Domain section of the multi-property handoff's CONFORMANCE.md: one
/// `effectiveChannelSettings(propertyId)`, callable for any property, over
/// overrides that are stored sparsely.
void main() {
  const accountDefaults = AccountChannelDefaults(
    airbnb: ChannelConfig(
      commissionPercentage: 3,
      rateMarkupPercentage: 5,
      cleaningCost: CostEntry(amount: 1200),
      linenCost: CostEntry(amount: 400),
    ),
    booking: ChannelConfig(commissionPercentage: 15),
    other: ChannelConfig(),
  );

  group('effectiveChannelSettings', () {
    test('a property that overrides nothing gets the account values', () {
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {},
      );

      final effective = resolver.effectiveChannelSettings(1);

      expect(effective.airbnb.commissionPercentage, 3);
      expect(effective.airbnb.rateMarkupPercentage, 5);
      expect(effective.airbnb.cleaningCost.amount, 1200);
      expect(effective.booking.commissionPercentage, 15);
    });

    test('answers for any property, not just one — with each own rates', () {
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {
          1: ChannelOverrides(
            airbnb: ChannelOverride(commissionPercentage: 12),
          ),
          2: ChannelOverrides(
            airbnb: ChannelOverride(commissionPercentage: 20),
          ),
        },
      );

      // The case §3 of the README calls out: a portfolio view holds one
      // resolver and asks it per booking, so two properties in one total keep
      // their own commissions.
      expect(
        resolver.effectiveChannelSettings(1).airbnb.commissionPercentage,
        12,
      );
      expect(
        resolver.effectiveChannelSettings(2).airbnb.commissionPercentage,
        20,
      );
      expect(
        resolver.effectiveChannelSettings(3).airbnb.commissionPercentage,
        3,
      );
    });

    test('the result carries the property it was resolved for', () {
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {},
      );

      expect(resolver.effectiveChannelSettings(42).propertyId, 42);
    });

    test('one overridden field leaves the rest following the account', () {
      const overrides = ChannelOverrides(
        airbnb: ChannelOverride(commissionPercentage: 12),
      );
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {1: overrides},
      );

      final effective = resolver.effectiveChannelSettings(1);

      expect(effective.airbnb.commissionPercentage, 12);
      // Untouched fields still come from the account.
      expect(effective.airbnb.rateMarkupPercentage, 5);
      expect(effective.airbnb.cleaningCost.amount, 1200);
      expect(effective.airbnb.linenCost.amount, 400);
    });

    test('changing an account default reaches every field not overridden', () {
      const overrides = ChannelOverrides(
        airbnb: ChannelOverride(commissionPercentage: 12),
      );
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {1: overrides},
      );

      final raised = resolver.copyWith(
        accountDefaults: accountDefaults.copyWithChannel(
          BookingChannel.airbnb,
          accountDefaults.airbnb.copyWith(
            commissionPercentage: 9,
            cleaningCost: const CostEntry(amount: 1500),
          ),
        ),
      );

      final effective = raised.effectiveChannelSettings(1);

      // The property states its own commission, so the account's new one does
      // not reach it — but the cleaning cost it never overrode does.
      expect(effective.airbnb.commissionPercentage, 12);
      expect(effective.airbnb.cleaningCost.amount, 1500);
    });

    test('an overridden cost of zero is an override, not an absence', () {
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {
          1: ChannelOverrides(
            airbnb: ChannelOverride(cleaningCost: CostEntry()),
          ),
        },
      );

      expect(
        resolver.effectiveChannelSettings(1).airbnb.cleaningCost.amount,
        0,
      );
    });

    test('a source string resolves through the same merge', () {
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {
          1: ChannelOverrides(
            booking: ChannelOverride(commissionPercentage: 11),
          ),
        },
      );

      final effective = resolver.effectiveChannelSettings(1);

      expect(effective.forSource('  BOOKING.COM ').commissionPercentage, 11);
      expect(effective.forSource('Airbnb').commissionPercentage, 3);
      for (final source in <String?>[null, '', 'Website', 'Vrbo']) {
        expect(
          effective.forSource(source).commissionPercentage,
          0,
          reason: 'source: $source',
        );
      }
    });

    test('settling a stay uses the resolved commission of that property', () {
      const resolver = ChannelSettingsResolver(
        accountDefaults: AccountChannelDefaults(
          airbnb: ChannelConfig(commissionPercentage: 3),
        ),
        overridesByPropertyId: {
          2: ChannelOverrides(
            airbnb: ChannelOverride(
              commissionPercentage: 20,
              cleaningCost: CostEntry(amount: 100),
            ),
          ),
        },
      );

      final onDefaults = resolver
          .effectiveChannelSettings(1)
          .settleForSource('airbnb', baseRate: 1000, nights: 2, guests: 2);
      final onOverrides = resolver
          .effectiveChannelSettings(2)
          .settleForSource('airbnb', baseRate: 1000, nights: 2, guests: 2);

      expect(onDefaults.gross, 2000);
      expect(onDefaults.commission, closeTo(60, 0.001));
      expect(onDefaults.fixedCosts, 0);

      expect(onOverrides.commission, closeTo(400, 0.001));
      expect(onOverrides.fixedCosts, 100);
      expect(onOverrides.net, closeTo(1500, 0.001));
    });
  });

  group('override counts', () {
    test('count the fields a property states, across channels', () {
      const overrides = ChannelOverrides(
        airbnb: ChannelOverride(
          commissionPercentage: 12,
          cleaningCost: CostEntry(amount: 900),
        ),
        booking: ChannelOverride(rateMarkupPercentage: 4),
      );

      expect(overrides.overriddenFieldCount, 3);
      expect(overrides.airbnb.overriddenFieldCount, 2);
      expect(overrides.other.overriddenFieldCount, 0);
    });

    test('a property that follows the account counts zero', () {
      const resolver = ChannelSettingsResolver(
        accountDefaults: accountDefaults,
        overridesByPropertyId: {},
      );

      expect(resolver.overriddenFieldCount(1), 0);
      expect(resolver.overridesFor(1).isEmpty, isTrue);
    });
  });

  group('a resolver over an account', () {
    test('answers every property its own overrides', () {
      final resolver = ChannelSettingsResolver.forProperties(
        accountDefaults: accountDefaults,
        properties: const [
          (
            id: 1,
            overrides: ChannelOverrides(
              airbnb: ChannelOverride(commissionPercentage: 12),
            ),
          ),
          (
            id: 2,
            overrides: ChannelOverrides(
              airbnb: ChannelOverride(commissionPercentage: 20),
            ),
          ),
          (id: 3, overrides: ChannelOverrides.none),
        ],
      );

      expect(
        resolver.effectiveChannelSettings(1).airbnb.commissionPercentage,
        12,
      );
      expect(
        resolver.effectiveChannelSettings(2).airbnb.commissionPercentage,
        20,
      );
      expect(
        resolver.effectiveChannelSettings(3).airbnb.commissionPercentage,
        3,
      );
    });

    test('built from one property, it answers defaults for the rest', () {
      // Why the call sites must pass the whole account: the per-booking lookup
      // is right, but it can only find what the resolver was given. A screen
      // that builds this from the property on display costs every other
      // property's bookings at the account's rates — §3.2 again, one layer down.
      final narrow = ChannelSettingsResolver.forProperties(
        accountDefaults: accountDefaults,
        properties: const [
          (
            id: 1,
            overrides: ChannelOverrides(
              airbnb: ChannelOverride(commissionPercentage: 12),
            ),
          ),
        ],
      );

      expect(
        narrow.effectiveChannelSettings(1).airbnb.commissionPercentage,
        12,
      );
      expect(
        narrow.effectiveChannelSettings(2).airbnb.commissionPercentage,
        3,
        reason: 'property 2 is unknown to this resolver',
      );
    });

    test('a property that overrides nothing is not stored at all', () {
      final resolver = ChannelSettingsResolver.forProperties(
        accountDefaults: accountDefaults,
        properties: const [
          (id: 1, overrides: ChannelOverrides.none),
          (id: 2, overrides: ChannelOverrides.none),
        ],
      );

      // Sparse per property as well as per field.
      expect(resolver.overridesByPropertyId, isEmpty);
      expect(resolver.overriddenFieldCount(1), 0);
    });

    test('an empty account resolves to the account defaults', () {
      final resolver = ChannelSettingsResolver.forProperties(
        accountDefaults: accountDefaults,
        properties: const [],
      );

      expect(
        resolver.effectiveChannelSettings(1).airbnb.commissionPercentage,
        3,
      );
    });
  });

  group('storage stays sparse', () {
    test('only overridden fields are written', () {
      const overrides = ChannelOverrides(
        airbnb: ChannelOverride(commissionPercentage: 12),
      );

      final stored = overrides.toMap();

      expect(stored.keys, [BookingChannel.airbnb.key]);
      final airbnb = stored[BookingChannel.airbnb.key] as Map<String, dynamic>;
      expect(airbnb.keys, ['commission_percentage']);
      // No cost keys at all — writing them as zero is what stopped later
      // account changes from propagating.
      expect(airbnb.containsKey('costs'), isFalse);
    });

    test('a round trip through the store keeps the same field count', () {
      const overrides = ChannelOverrides(
        airbnb: ChannelOverride(
          commissionPercentage: 12,
          serviceCost: CostEntry(amount: 50, type: CostType.perPerson),
        ),
        other: ChannelOverride(rateMarkupPercentage: 2),
      );

      final restored = ChannelOverrides.fromMap(overrides.toMap());

      expect(restored.overriddenFieldCount, overrides.overriddenFieldCount);
      expect(restored.equals(overrides), isTrue);
      expect(restored.airbnb.serviceCost?.type, CostType.perPerson);
    });

    test('a property with nothing to say writes an empty payload', () {
      expect(ChannelOverrides.none.toMap(), isEmpty);
      expect(ChannelOverrides.fromMap(const {}).isEmpty, isTrue);
      expect(ChannelOverrides.fromMap(null).isEmpty, isTrue);
    });

    test(
      'a row written before the tiers existed reads its zeros as stated',
      () {
        // The pre-tier shape: every cost present, every unset percentage null.
        final legacy = <String, dynamic>{
          'airbnb': {
            'commission_percentage': null,
            'rate_markup_percentage': null,
            'costs': {
              'cleaning': {'amount': 0, 'type': 'per_booking'},
              'linen': {'amount': 0, 'type': 'per_booking'},
              'service': {'amount': 0, 'type': 'per_booking'},
              'other': {'amount': 0, 'type': 'per_booking'},
            },
          },
        };

        final overrides = ChannelOverrides.fromMap(legacy);

        // The percentages are absent, so they follow the account.
        expect(overrides.airbnb.commissionPercentage, isNull);
        expect(overrides.airbnb.rateMarkupPercentage, isNull);
        // The zeros are explicit values in the payload and stay overrides:
        // clearing the field in Prijzen is what hands them back to the account.
        expect(overrides.airbnb.overriddenFieldCount, 4);
        expect(overrides.airbnb.cleaningCost?.amount, 0);
      },
    );
  });
}
