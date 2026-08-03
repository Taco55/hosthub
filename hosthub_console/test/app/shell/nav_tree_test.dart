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

    expect(find.text('PORTFOLIO'), findsOneWidget);
    expect(find.text('PROPERTIES'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
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

  group('adding a property from the rail', () {
    /// The `+` in the Properties heading. Found by its tooltip rather than by
    /// the icon, because the tooltip is what says which action it is.
    Finder addAction() => find.byTooltip('Add property');

    testWidgets('the Properties heading offers it', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: account,
      );

      expect(addAction(), findsOneWidget);
    });

    testWidgets('tapping it opens the same two routes as the list', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: account,
      );

      await tester.tap(addAction());
      await tester.pumpAndSettle();

      // Lodgify first, manual second — the modal the list's add row opens too.
      expect(find.text('Bring over from Lodgify'), findsOneWidget);
      expect(find.text('Create manually'), findsOneWidget);
    });

    testWidgets('a one-property account has it too', (tester) async {
      await pumpShell(tester, surface: const Size(1400, 900));

      // The heading there is the property's own name (§5), and the action rides
      // on it all the same: what a one-property account is spared is the
      // portfolio chrome, not the way to get a second property — which is more
      // likely here than in an account of ten.
      expect(find.text('PROPERTIES'), findsNothing);
      expect(addAction(), findsOneWidget);

      await tester.tap(addAction());
      await tester.pumpAndSettle();

      expect(find.text('Bring over from Lodgify'), findsOneWidget);
    });

    testWidgets('the heading itself is a label, not a destination', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: account,
      );

      // It carries the same treatment as ACCOUNT, which is not a destination
      // either, so a click target behind it would be invisible by definition.
      // This harness has no GoRouter: a heading that navigated would surface as
      // a thrown lookup rather than as a route change.
      await tester.tap(find.text('PROPERTIES'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the collapsed rail does not take taps on the faded heading', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(900, 800),
        properties: account,
      );

      // The heading keeps its box on the rail so nothing below it moves, and
      // fades its contents instead. Faded out, the action must not still be a
      // target.
      await tester.tap(addAction(), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Bring over from Lodgify'), findsNothing);
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
