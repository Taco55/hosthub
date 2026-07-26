import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'property_details_page_test.dart' show pumpPage;

/// Golden baselines for the property record (design "PROPERTY DETAILS"):
/// connection row, source note, the two definition cards, and the raw payload
/// both folded and open. Rendered with the test font — compare layout and
/// geometry against `hosthub-design/HostHub CMS.dc.html`, not typography.
/// Regenerate with:
/// flutter test --update-goldens test/features/properties/property_details_golden_test.dart
void main() {
  testWidgets('golden: the record, raw payload folded', (tester) async {
    await pumpPage(tester, surface: const Size(1180, 900));
    await expectLater(
      find.byType(StyledWebPageScaffold),
      matchesGoldenFile('goldens/01_property_record.png'),
    );
  });

  testWidgets('golden: raw payload open', (tester) async {
    await pumpPage(tester, surface: const Size(1180, 1100));
    await tester.tap(find.text('Raw data from Lodgify'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StyledWebPageScaffold),
      matchesGoldenFile('goldens/02_property_record_raw.png'),
    );
  });
}
