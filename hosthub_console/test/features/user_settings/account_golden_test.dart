import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/team/domain/site_member.dart';

import 'account_page_test.dart' show pumpAccount;

/// Golden baseline for Account (design `HostHub CMS.dc.html`, the *Account*
/// rail item): three cards, one quiet role chip, one connection row, and no
/// listings block. Rendered with the test font — compare layout and geometry
/// against the design, not typography.
/// Regenerate with:
/// flutter test --update-goldens test/features/user_settings/account_golden_test.dart
void main() {
  testWidgets('golden: the account page', (tester) async {
    await pumpAccount(
      tester,
      surface: const Size(1180, 1180),
      members: [
        SiteMember(
          id: '1',
          siteId: 's1',
          profileId: 'p1',
          role: 'owner',
          createdAt: DateTime(2026, 1, 1),
          username: 'Marta Nyland',
          email: 'marta@trysilpanorama.com',
        ),
        SiteMember(
          id: '2',
          siteId: 's1',
          profileId: 'p2',
          role: 'editor',
          createdAt: DateTime(2026, 2, 1),
          email: 'ola@trysilpanorama.com',
        ),
      ],
    );

    await expectLater(
      find.byType(StyledWebPageScaffold),
      matchesGoldenFile('goldens/01_account.png'),
    );
  });
}
