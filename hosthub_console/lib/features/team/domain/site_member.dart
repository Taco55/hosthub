import 'package:hosthub_console/features/team/domain/site_member_role.dart';

class SiteMember {
  const SiteMember({
    required this.id,
    required this.siteId,
    required this.profileId,
    required this.role,
    required this.createdAt,
    this.email,
    this.username,
  });

  final String id;
  final String siteId;
  final String profileId;
  final String role;
  final DateTime createdAt;
  final String? email;
  final String? username;

  SiteMemberRole get memberRole => SiteMemberRole.fromString(role);

  String get displayName {
    if (username != null && username!.isNotEmpty) return username!;
    if (email != null && email!.isNotEmpty) return email!;
    return profileId;
  }

  factory SiteMember.fromMap(Map<String, dynamic> map) {
    // Handle joined profile data from Supabase select
    final profiles = map['profiles'];
    String? email;
    String? username;
    if (profiles is Map<String, dynamic>) {
      email = profiles['email'] as String?;
      username = profiles['username'] as String?;
    }

    return SiteMember(
      id: map['id'] as String,
      siteId: map['site_id'] as String,
      profileId: map['profile_id'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      email: email,
      username: username,
    );
  }

  @override
  String toString() {
    return 'SiteMember(id: $id, siteId: $siteId, role: $role, '
        'email: $email, username: $username)';
  }
}
