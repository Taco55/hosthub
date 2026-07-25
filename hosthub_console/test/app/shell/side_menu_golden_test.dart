import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'section_scaffold_harness.dart';

/// Golden baselines for the responsive navigation strategy (design handoff
/// `design_handoff_hosthub_nav`): expanded ≥1100, the pinned 72px icon rail
/// between 600 and 1100 (with its hover flyout and tap-to-expand overlay), and
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

  testWidgets('golden: rail hover flyout label', (tester) async {
    await pumpShell(tester, surface: const Size(900, 800));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    // Hover the icon itself, not the rail: entering the rail opens the flyout
    // overlay, hovering a row adds its label bubble.
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.show_chart)));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/nav_03_rail_flyout.png'),
    );
  });

  testWidgets('golden: rail expanded by tapping the header', (tester) async {
    await pumpShell(tester, surface: const Size(900, 800));

    await tester.tap(find.byTooltip('Show menu labels'));
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
