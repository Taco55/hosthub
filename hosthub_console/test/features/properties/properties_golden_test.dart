import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'properties_page_test.dart' show pumpProperties;

/// Golden baselines for Properties: a row per property with its origin, the add
/// row at the end, and the empty state that offers the same two routes.
/// Rendered with the test font — compare layout and geometry against
/// `hosthub-design/HostHub CMS.dc.html`, not typography.
/// Regenerate with:
/// flutter test --update-goldens test/features/properties/properties_golden_test.dart
void main() {
  testWidgets('golden: the list, with origin per row', (tester) async {
    await pumpProperties(tester, surface: const Size(1180, 620));
    await expectLater(
      find.byType(StyledWebPageScaffold),
      matchesGoldenFile('goldens/03_properties_list.png'),
    );
  });

  testWidgets('golden: an account with nothing in it yet', (tester) async {
    await pumpProperties(
      tester,
      properties: const [],
      surface: const Size(1180, 620),
    );
    await expectLater(
      find.byType(StyledWebPageScaffold),
      matchesGoldenFile('goldens/04_properties_empty.png'),
    );
  });
}
