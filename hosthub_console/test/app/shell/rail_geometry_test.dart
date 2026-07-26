import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/side_menu.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import 'shell_harness.dart';

/// §7's rail, and its hard requirement: **nothing may move when the rail
/// collapses or expands** — only text appears and disappears.
///
/// The handoff says this took several iterations to get right and asks for it to
/// be treated as a regression test rather than a nicety, so this measures every
/// icon, chip and the logo in both states and requires the same rect.
void main() {
  const four = [
    PropertySummary(id: 1, name: 'Trysil Panorama'),
    PropertySummary(id: 2, name: 'Hemsedal Lodge'),
    PropertySummary(id: 3, name: 'Geilo Fjellhytte'),
    PropertySummary(id: 4, name: 'Voss Fjordhus'),
  ];

  /// Everything on the rail whose position must not change: the brand mark, the
  /// nav icons, and the property chips.
  List<Finder> _anchors() => [
    find.byIcon(Icons.holiday_village_outlined),
    find.byIcon(Icons.calendar_month_outlined),
    find.byIcon(Icons.bar_chart),
    find.byIcon(Icons.dashboard_outlined),
    find.byIcon(Icons.home_work_outlined),
    find.byIcon(Icons.language),
    find.byIcon(Icons.sell_outlined),
    find.byType(PropertyChip),
  ];

  /// Every rect of every anchor, in document order.
  List<Rect> _rects(WidgetTester tester) {
    final rects = <Rect>[];
    for (final finder in _anchors()) {
      for (final element in finder.evaluate()) {
        rects.add(tester.getRect(find.byWidget(element.widget)));
      }
    }
    return rects;
  }

  group('nothing moves between the two states', () {
    testWidgets('with a property open, so every row shape is on screen', (
      tester,
    ) async {
      final mode = await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/1/pricing'),
      );

      final expanded = _rects(tester);
      expect(expanded, isNotEmpty);

      mode.setMode(StyledSideMenuMode.compact);
      await tester.pumpAndSettle();
      final compact = _rects(tester);

      expect(
        compact.length,
        expanded.length,
        reason: 'a row disappeared: hiding one shifts everything below it',
      );
      for (var index = 0; index < expanded.length; index++) {
        expect(
          compact[index],
          expanded[index],
          reason: 'anchor $index moved when the rail collapsed',
        );
      }
    });

    testWidgets('and back again', (tester) async {
      final mode = await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/2/website'),
      );
      final first = _rects(tester);

      mode.setMode(StyledSideMenuMode.compact);
      await tester.pumpAndSettle();
      mode.setMode(StyledSideMenuMode.expanded);
      await tester.pumpAndSettle();

      expect(_rects(tester), first);
    });

    testWidgets('in a one-property account, where the rows are flat', (
      tester,
    ) async {
      final mode = await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: const [PropertySummary(id: 1, name: 'Trysil Panorama')],
      );
      final expanded = _rects(tester);

      mode.setMode(StyledSideMenuMode.compact);
      await tester.pumpAndSettle();

      expect(_rects(tester), expanded);
    });

    testWidgets('group labels keep their height, so rows do not shift up', (
      tester,
    ) async {
      final mode = await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
      );
      final expanded = tester
          .widgetList<StyledSideMenuGroupLabel>(
            find.byType(StyledSideMenuGroupLabel),
          )
          .map((label) => tester.getSize(find.byWidget(label)).height)
          .toList();

      mode.setMode(StyledSideMenuMode.compact);
      await tester.pumpAndSettle();
      final compact = tester
          .widgetList<StyledSideMenuGroupLabel>(
            find.byType(StyledSideMenuGroupLabel),
          )
          .map((label) => tester.getSize(find.byWidget(label)).height)
          .toList();

      expect(compact, expanded);
    });
  });

  group('the measurements §7 states', () {
    testWidgets('every icon centre is 34px from the rail\'s left edge', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/1/overview'),
      );

      // 12px of nav padding plus half of the fixed 44px icon box.
      const expectedCentre = kSidebarSideInset + kSidebarIconBox / 2;
      expect(expectedCentre, 34);

      for (final icon in [
        Icons.calendar_month_outlined,
        Icons.bar_chart,
        Icons.dashboard_outlined,
      ]) {
        expect(
          tester.getCenter(find.byIcon(icon)).dx,
          expectedCentre,
          reason: '$icon',
        );
      }
      // A property's chip sits on the same axis as the icons.
      expect(
        tester.getCenter(find.byType(PropertyChip).first).dx,
        expectedCentre,
      );
    });

    testWidgets('a sub-item is indented, and stays inside the rail', (
      tester,
    ) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/1/overview'),
      );

      // 12 + 16 + 32/2: indented by design, on its own axis.
      expect(
        tester.getCenter(find.byIcon(Icons.home_work_outlined)).dx,
        kSidebarSideInset + kSidebarSubItemIndent + kSidebarSubItemIconBox / 2,
      );
      // And the row it sits in ends inside the collapsed rail: 12 + 16 + 32 = 60
      // of the 72 available, so its active background cannot spill onto the page.
      expect(
        kSidebarSideInset + kSidebarSubItemIndent + kSidebarSubItemIconBox,
        lessThanOrEqualTo(sidebarTokens.railWidth),
      );
    });

    testWidgets('no row reaches past the collapsed rail', (tester) async {
      final mode = await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/1/pricing'),
      );
      mode.setMode(StyledSideMenuMode.compact);
      await tester.pumpAndSettle();

      for (final tile in find.byType(StyledSideMenuTile).evaluate()) {
        final rect = tester.getRect(find.byWidget(tile.widget));
        expect(
          rect.right,
          lessThanOrEqualTo(sidebarTokens.railWidth),
          reason: 'a row spilled outside the 72px rail',
        );
      }
    });

    testWidgets('the row heights are the three §7 states', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/1/overview'),
      );

      // The row box, not the tile's outer padding: the heights §7 gives are the
      // rows themselves.
      double heightOf(StyledSideMenuTileDepth depth) {
        final tile = tester
            .widgetList<StyledSideMenuTile>(find.byType(StyledSideMenuTile))
            .firstWhere((tile) => tile.depth == depth);
        return tester
            .getSize(
              find.descendant(
                of: find.byWidget(tile),
                matching: find.byType(InkWell),
              ),
            )
            .height;
      }

      expect(
        heightOf(StyledSideMenuTileDepth.topLevel),
        kSidebarTopLevelRowHeight,
      );
      expect(
        heightOf(StyledSideMenuTileDepth.branch),
        kSidebarPropertyRowHeight,
      );
      expect(heightOf(StyledSideMenuTileDepth.child), kSidebarSubItemRowHeight);
    });

    testWidgets('the rail is 72 and the menu 284', (tester) async {
      expect(sidebarTokens.railWidth, 72);
      expect(sidebarTokens.expandedWidth, 284);
    });

    testWidgets('the property chip is 26 square with a 7px radius', (
      tester,
    ) async {
      await pumpShell(tester, surface: const Size(1400, 900), properties: four);

      final chip = tester.widget<PropertyChip>(find.byType(PropertyChip).first);
      expect(chip.size, kPropertyChipSize);
      expect(chip.borderRadius, kPropertyChipRadius);
      expect(
        tester.getSize(find.byType(PropertyChip).first),
        const Size(26, 26),
      );
    });

    testWidgets('the open property\'s chip is the filled one', (tester) async {
      await pumpShell(
        tester,
        surface: const Size(1400, 900),
        properties: four,
        route: ConsoleRoute.parse('/properties/3/pricing'),
      );

      final chips = tester.widgetList<PropertyChip>(find.byType(PropertyChip));
      final filled = chips.where((chip) => chip.filled);
      expect(filled, hasLength(1));
      expect(filled.single.abbreviation, 'GF');
    });
  });

  group('the hover-intent delay', () {
    testWidgets('is the 0.35s §7 asks for', (tester) async {
      expect(kSidebarHoverIntentDelay, const Duration(milliseconds: 350));
    });
  });
}
