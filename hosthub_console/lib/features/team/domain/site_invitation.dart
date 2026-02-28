import 'package:hosthub_console/features/team/domain/site_member_role.dart';

class SiteInvitation {
  const SiteInvitation({
    required this.id,
    required this.siteId,
    required this.email,
    required this.role,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.invitedBy,
  });

  final String id;
  final String siteId;
  final String email;
  final String role;
  final String status;
  final String? invitedBy;
  final DateTime expiresAt;
  final DateTime createdAt;

  bool get isPending => status == 'pending';
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  SiteMemberRole get memberRole => SiteMemberRole.fromString(role);

  factory SiteInvitation.fromMap(Map<String, dynamic> map) {
    return SiteInvitation(
      id: map['id'] as String,
      siteId: map['site_id'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      status: map['status'] as String,
      invitedBy: map['invited_by'] as String?,
      expiresAt: DateTime.parse(map['expires_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'SiteInvitation(id: $id, email: $email, role: $role, '
        'status: $status)';
  }
}
