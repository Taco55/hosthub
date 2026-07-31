/// The role a member holds, account-wide.
///
/// Carries no copy: the labels and descriptions live in
/// `SiteMemberRoleCopy` (presentation) so they come out of the ARB files
/// instead of being hardcoded English here.
enum SiteMemberRole {
  owner,
  editor,
  viewer;

  static SiteMemberRole fromString(String value) {
    return SiteMemberRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SiteMemberRole.viewer,
    );
  }

  /// Roles that can be assigned via invitation (not owner).
  static List<SiteMemberRole> get assignableRoles => [editor, viewer];
}
