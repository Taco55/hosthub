import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shell_harness.dart';

/// Golden baselines for the responsive navigation strategy (design handoff
/// `design_handoff_hosthub_nav`): expanded ≥1100, the pinned 72px icon rail
/// between 600 and 1100 (which expands on hover and on a header tap), and
/// the hamburger drawer below 600. Rendered with the test font — compare
/// layout/geometry, not typography.
/// Regenerate with: flutter test --update-goldens test/app/shell/side_menu_golden_test.dart
void main() {
  testWidgets('golden: expanded menu (>=1100)', (tester) async {
    await pumpShell(tester, surface: const Size(1400, 900));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/nav_01_expanded.png'),
    );
  });

  testWidgets('golden: pinned icon rail (600-1100)', (tester) async {
    await pumpShell(tester, surface: const Size(900, 800));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/nav_02_rail.png'),
    );
  });

  testWidgets('golden: pinned rail at rest', (tester) async {
    await pumpShell(tester, surface: const Size(900, 800));

    // No hover: the 72px rail as it sits. Its hovered state is the expanded
    // panel below, and the row label that used to live here (first a flyout,
    // then a tooltip) is gone — the panel arrives before either could show.
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/nav_03_rail.png'),
    );
  });

  testWidgets('golden: rail expanded by tapping the header', (tester) async {
    await pumpShell(tester, surface: const Size(900, 800));

    // The header is the explicit way to the labels on touch; hitting it by
    // label would find the expanded copy, so target the brand mark itself.
    await tester.tap(find.byIcon(Icons.holiday_village_outlined));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/nav_04_rail_tap_expanded.png'),
    );
  });

  testWidgets('golden: hamburger drawer (<600)', (tester) async {
    await pumpShell(tester, surface: const Size(420, 800));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/nav_05_drawer.png'),
    );
  });
}
