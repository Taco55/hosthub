import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'shell_harness.dart';

/// The design's rule for the rail: "icons don't move between modes (44 px icon
/// box)" — everything in the compact rail shares one vertical axis, and
/// switching modes must not shift it. The nav rows get that from the library;
/// the brand mark is the app's own widget, so it needs its own guard.
void main() {
  testWidgets('the brand mark keeps its centre when the menu expands', (
    tester,
  ) async {
    final mode = await pumpShell(tester, surface: const Size(1400, 900));
    final brand = find.byIcon(Icons.holiday_village_outlined);

    final expandedCentre = tester.getCenter(brand).dx;

    mode.setMode(StyledSideMenuMode.compact);
    await tester.pumpAndSettle();
    final compactCentre = tester.getCenter(brand).dx;

    expect(compactCentre, expandedCentre);
  });

  testWidgets('the brand mark shares the nav rows\' axis', (tester) async {
    await pumpShell(tester, surface: const Size(1400, 900));

    // One axis, so the eye reads a column rather than a staircase. Boekingen is
    // the first nav row now that the menu is a tree.
    expect(
      tester.getCenter(find.byIcon(Icons.holiday_village_outlined)).dx,
      tester.getCenter(find.byIcon(Icons.calendar_month_outlined)).dx,
    );
  });
}
