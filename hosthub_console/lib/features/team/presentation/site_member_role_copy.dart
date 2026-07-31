import 'package:flutter/widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';

/// How the console words the three account roles.
///
/// One definition on purpose: the account list said `Beheerder` while the invite
/// picker and the site team table still showed the enum's hardcoded English
/// (`Editor`, `Viewer`), so the same role had two names depending on where you
/// read it. The enum itself carries no copy anymore.
extension SiteMemberRoleCopy on SiteMemberRole {
  String roleLabel(BuildContext context) => switch (this) {
    SiteMemberRole.owner => context.s.accountRoleOwner,
    SiteMemberRole.editor => context.s.accountRoleAdmin,
    SiteMemberRole.viewer => context.s.accountRoleViewer,
  };

  /// What the role may do — the sentence the invite picker shows under its
  /// choice. The account list does not repeat it per row; its section footer
  /// says it once.
  String roleDescription(BuildContext context) => switch (this) {
    SiteMemberRole.owner => context.s.accountRoleOwnerDescription,
    SiteMemberRole.editor => context.s.accountRoleAdminDescription,
    SiteMemberRole.viewer => context.s.accountRoleViewerDescription,
  };
}
