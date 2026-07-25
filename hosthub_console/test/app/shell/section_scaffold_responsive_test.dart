import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/side_menu.dart';

import 'section_scaffold_harness.dart';

double _menuWidth(WidgetTester tester) => tester
    .widget<AnimatedContainer>(find.byKey(const ValueKey('styledSideMenu')))
    .constraints!
    .maxWidth;

void main() {
  testWidgets('≥1100px: the expanded menu is pinned beside the content', (
    tester,
  ) async {
    await pumpShell(tester, surface: const Size(1400, 900));

    expect(_menuWidth(tester), kSidebarExpandedWidth);
    expect(find.text('Reservations'), findsOneWidget);
    // No hamburger: the menu is pinned.
    expect(find.byIcon(Icons.menu), findsNothing);
  });

  testWidgets('600–1100px: the icon rail stays pinned — no hamburger', (
    tester,
  ) async {
    await pumpShell(tester, surface: const Size(900, 800));

    // The rail, not the drawer, and not the expanded menu.
    expect(_menuWidth(tester), kSidebarCompactWidth);
    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.text('Reservations'), findsNothing);
    // Icons remain reachable.
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    // Icon centred in the 72px rail, the same x as in the expanded menu.
    expect(
      tester.getCenter(find.byIcon(Icons.calendar_today)).dx,
      kSidebarCompactWidth / 2,
    );
  });

  testWidgets('600–1100px: the rail ignores the expanded width preference', (
    tester,
  ) async {
    final sidebarMode = await pumpShell(
      tester,
      surface: const Size(900, 800),
    );

    sidebarMode.setMode(StyledSideMenuMode.expanded);
    await tester.pumpAndSettle();

    // The preference only applies from 1100px up; here the rail is the only
    // form that fits.
    expect(_menuWidth(tester), kSidebarCompactWidth);
  });

  testWidgets('600–1100px: tapping the rail header expands it over the content',
      (tester) async {
    await pumpShell(tester, surface: const Size(900, 800));

    // Touch has no hover, so the header is the explicit way to the labels.
    await tester.tap(find.byTooltip('Show menu labels'));
    await tester.pumpAndSettle();

    expect(find.text('Reservations'), findsOneWidget);
    // Overlaid, not reflowed: the pinned rail keeps its width.
    expect(
      tester
          .widgetList<AnimatedContainer>(
            find.byKey(const ValueKey('styledSideMenu')),
          )
          .map((c) => c.constraints!.maxWidth),
      containsAll(<double>[kSidebarCompactWidth, kSidebarExpandedWidth]),
    );

    // A tap outside puts the rail back.
    await tester.tapAt(const Offset(700, 400));
    await tester.pumpAndSettle();
    expect(find.text('Reservations'), findsNothing);
  });

  testWidgets('<600px: the menu becomes a hamburger drawer', (tester) async {
    await pumpShell(tester, surface: const Size(420, 800));

    expect(find.byIcon(Icons.menu), findsOneWidget);
    // Nothing of the menu is on screen until the drawer opens.
    expect(find.byKey(const ValueKey('styledSideMenu')), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(_menuWidth(tester), kSidebarExpandedWidth);
    expect(find.text('Reservations'), findsOneWidget);
  });
}
