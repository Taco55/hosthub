import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import 'shell_harness.dart';

/// §5: a one-property account gets the collapsed navigation — the same entries
/// and the same routes, without the machinery of several properties.
void main() {
  const single = [PropertySummary(id: 1, name: 'Trysil Panorama')];
  const four = [
    PropertySummary(id: 1, name: 'Trysil Panorama'),
    PropertySummary(id: 2, name: 'Hemsedal Lodge'),
    PropertySummary(id: 3, name: 'Geilo Fjellhytte'),
    PropertySummary(id: 4, name: 'Voss Fjordhus'),
  ];

  Iterable<StyledSideMenuTile> tiles(WidgetTester tester) =>
      tester.widgetList<StyledSideMenuTile>(find.byType(StyledSideMenuTile));

  group('the groups', () {
    testWidgets('the first group is "Rental", not "Portfolio"', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      expect(find.text('RENTAL'), findsOneWidget);
      expect(find.text('PORTFOLIO'), findsNothing);
    });

    testWidgets('the second group is the property\'s own name', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      // Not "Properties · 1" — that would head a list of one.
      expect(find.text('PROPERTIES'), findsNothing);
      expect(find.text('Trysil Panorama'), findsOneWidget);
    });

    testWidgets('there is no count pill', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      expect(find.text('1'), findsNothing);
    });

    testWidgets('the Account group is unchanged', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Account settings'), findsOneWidget);
    });
  });

  group('the property node', () {
    testWidgets('is not rendered', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      final branches = tiles(
        tester,
      ).where((tile) => tile.depth == StyledSideMenuTileDepth.branch);
      expect(branches, isEmpty);
    });

    testWidgets('and neither is its chip or caret', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      expect(find.text('TP'), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('the property\'s sections', () {
    testWidgets('sit flat at the top level', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      final children = tiles(
        tester,
      ).where((tile) => tile.depth == StyledSideMenuTileDepth.child);
      expect(children, isEmpty, reason: 'nothing is nested under anything');

      for (final label in ['Overview', 'Website', 'Pricing', 'Site settings']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('share the axis of Bookings, with no indent', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      expect(
        tester.getCenter(find.byIcon(Icons.home_work_outlined)).dx,
        tester.getCenter(find.byIcon(Icons.calendar_month_outlined)).dx,
      );
    });

    testWidgets('are visible from a portfolio screen too — always there', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
        route: const ConsoleRoute.portfolio(PortfolioSection.bookings),
      );

      // Nothing to expand, so nothing that could be collapsed.
      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('still route to the property they belong to', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
        route: ConsoleRoute.parse('/properties/1/pricing'),
      );

      final selected = tiles(tester).where((tile) => tile.selected);
      expect(selected.map((tile) => tile.label), contains('Pricing'));
    });

    testWidgets('carry the override badge just as nested ones do', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: const [
          PropertySummary(
            id: 1,
            name: 'Trysil Panorama',
            channelOverrides: ChannelOverrides(
              airbnb: ChannelOverride(commissionPercentage: 12),
            ),
          ),
        ],
      );

      expect(find.byType(StyledSideMenuBadge), findsOneWidget);
    });
  });

  group('nothing else changes', () {
    testWidgets('Bookings and Revenue are still there', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
    });

    testWidgets('nothing is disabled', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );

      for (final tile in tiles(tester)) {
        expect(tile.onTap, isNotNull, reason: tile.label);
      }
    });

    testWidgets('the same widgets are used — no single-property fork', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: single,
      );
      final collapsedTypes = tiles(
        tester,
      ).map((tile) => tile.runtimeType).toSet();

      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/1/overview'),
      );
      final fullTypes = tiles(tester).map((tile) => tile.runtimeType).toSet();

      expect(collapsedTypes, fullTypes);
      expect(collapsedTypes, {StyledSideMenuTile});
    });
  });

  group('a second property brings the portfolio chrome back', () {
    testWidgets('groups, node, count and chips all return', (tester) async {
      await pumpShell(tester, surface: const Size(1400, 900), properties: four);

      expect(find.text('PORTFOLIO'), findsOneWidget);
      expect(find.text('PROPERTIES'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('TP'), findsOneWidget);
      expect(find.text('RENTAL'), findsNothing);

      final branches = tiles(
        tester,
      ).where((tile) => tile.depth == StyledSideMenuTileDepth.branch);
      expect(branches, hasLength(4));
    });
  });
}
