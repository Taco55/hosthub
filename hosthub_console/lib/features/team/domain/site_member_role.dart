enum SiteMemberRole {
  owner,
  editor,
  viewer;

  String get label {
    switch (this) {
      case SiteMemberRole.owner:
        return 'Owner';
      case SiteMemberRole.editor:
        return 'Editor';
      case SiteMemberRole.viewer:
        return 'Viewer';
    }
  }

  static SiteMemberRole fromString(String value) {
    return SiteMemberRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SiteMemberRole.viewer,
    );
  }

  /// Roles that can be assigned via invitation (not owner).
  static List<SiteMemberRole> get assignableRoles => [editor, viewer];
}
