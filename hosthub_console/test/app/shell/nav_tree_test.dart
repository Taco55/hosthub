import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import 'shell_harness.dart';

/// The sidebar tree, rendered from the route. Covers the Navigation section of
/// the multi-property handoff's CONFORMANCE.md.
void main() {
  const account = [
    PropertySummary(id: 1, name: 'Trysil Panorama'),
    PropertySummary(id: 2, name: 'Hemsedal Lodge'),
    PropertySummary(id: 3, name: 'Geilo Fjellhytte'),
    PropertySummary(id: 4, name: 'Voss Fjordhus'),
  ];

  /// The sub-items of an open property. Nothing renders them unless a property
  /// is expanded, so counting them is how "expanded" is observed.
  Finder subItems() => find.text('Overview');

  testWidgets('every group and every property is in the tree', (tester) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
    );

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    for (final property in account) {
      expect(find.text(property.name), findsOneWidget);
    }
  });

  testWidgets('the Properties group carries the account\'s count', (
    tester,
  ) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
    );

    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('no property open means no sub-items', (tester) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
      route: const ConsoleRoute.portfolio(PortfolioSection.bookings),
    );

    expect(subItems(), findsNothing);
  });

  testWidgets('a deep link renders that property expanded, section active', (
    tester,
  ) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
      // The CONFORMANCE case: /properties/3/pricing, arrived at directly.
      route: ConsoleRoute.parse('/properties/3/pricing'),
    );

    // Exactly one property expanded — one set of sub-items, not four.
    expect(subItems(), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);

    // And it is Geilo's: its chip is the filled one.
    final tiles = tester.widgetList<StyledSideMenuTile>(
      find.byType(StyledSideMenuTile),
    );
    final selectedBranches = tiles.where(
      (tile) =>
          tile.depth == StyledSideMenuTileDepth.branch && tile.caretExpanded!,
    );
    expect(selectedBranches, hasLength(1));
    expect(selectedBranches.single.label, 'Geilo Fjellhytte');
  });

  testWidgets('the active sub-item is the one in the route', (tester) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
      route: ConsoleRoute.parse('/properties/3/pricing'),
    );

    final children = tester
        .widgetList<StyledSideMenuTile>(find.byType(StyledSideMenuTile))
        .where((tile) => tile.depth == StyledSideMenuTileDepth.child);
    final selected = children.where((tile) => tile.selected);

    expect(selected, hasLength(1));
    expect(selected.single.label, 'Pricing');
  });

  testWidgets('changing the route moves the expansion, never doubles it', (
    tester,
  ) async {
    for (final propertyId in [1, 2, 3, 4]) {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: account,
        route: ConsoleRoute.parse('/properties/$propertyId/overview'),
      );

      expect(subItems(), findsOneWidget, reason: 'property $propertyId');
    }
  });

  testWidgets('Boekingen and Omzet stay visible while a property is open', (
    tester,
  ) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
      route: ConsoleRoute.parse('/properties/2/website'),
    );

    // The whole point of the tree over a mode switch.
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Revenue'), findsOneWidget);
  });

  testWidgets('nothing in the tree is ever disabled', (tester) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
      route: ConsoleRoute.parse('/properties/2/website'),
    );

    for (final tile in tester.widgetList<StyledSideMenuTile>(
      find.byType(StyledSideMenuTile),
    )) {
      expect(
        tile.onTap,
        isNotNull,
        reason: 'a nav row without a handler renders dimmed: ${tile.label}',
      );
    }
  });

  group('the Prijzen override badge', () {
    testWidgets('counts the fields a property states itself', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: const [
          PropertySummary(
            id: 1,
            name: 'Trysil Panorama',
            channelOverrides: ChannelOverrides(
              airbnb: ChannelOverride(
                commissionPercentage: 12,
                cleaningCost: CostEntry(amount: 1500),
              ),
            ),
          ),
        ],
        route: ConsoleRoute.parse('/properties/1/overview'),
      );

      expect(find.byType(StyledSideMenuBadge), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('is absent for a property that follows the account', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: const [PropertySummary(id: 1, name: 'Trysil Panorama')],
        route: ConsoleRoute.parse('/properties/1/overview'),
      );

      // Absent, not a zero: the badge exists to point out the deviations.
      expect(find.byType(StyledSideMenuBadge), findsNothing);
    });
  });

  testWidgets('every property carries a distinct chip', (tester) async {
    await pumpShell(
      tester,
      surface: const Size(1400, 900),
      properties: account,
    );

    final chips = ['TP', 'HL', 'GF', 'VF'];
    for (final chip in chips) {
      expect(find.text(chip), findsOneWidget);
    }
  });
}
