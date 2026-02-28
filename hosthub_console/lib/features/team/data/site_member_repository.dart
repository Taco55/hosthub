import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/domain/ports/email_templates_port.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/team/domain/site_invitation.dart';
import 'package:hosthub_console/features/team/domain/site_member.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';
import 'package:app_errors/app_errors.dart';

class SiteMemberRepository extends SupabaseRepository {
  SiteMemberRepository({
    required SupabaseClient supabase,
    required EmailTemplatesPort emailTemplates,
    required String setPasswordRedirectUri,
  }) : _emailTemplates = emailTemplates,
       _setPasswordRedirectUri = setPasswordRedirectUri,
       super(supabase);

  final EmailTemplatesPort _emailTemplates;
  final String _setPasswordRedirectUri;

  static const _membersTable = 'site_members';
  static const _invitationsTable = 'site_invitations';
  static const _memberSelect =
      'id, site_id, profile_id, role, created_at, profiles:profile_id(email, username)';

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  Future<List<SiteMember>> fetchMembers(String siteId) async {
    try {
      final response = await supabase
          .from(_membersTable)
          .select(_memberSelect)
          .eq('site_id', siteId)
          .order('created_at', ascending: true);
      return (response as List<dynamic>)
          .map((row) => SiteMember.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchMembers', 'siteId': siteId},
      );
    }
  }

  Future<SiteMember> updateMemberRole(
    String memberId,
    SiteMemberRole role,
  ) async {
    try {
      final response = await supabase
          .from(_membersTable)
          .update({'role': role.name})
          .eq('id', memberId)
          .select(_memberSelect)
          .single();
      return SiteMember.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateMemberRole', 'memberId': memberId},
      );
    }
  }

  Future<void> removeMember(String memberId) async {
    try {
      await supabase.from(_membersTable).delete().eq('id', memberId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'removeMember', 'memberId': memberId},
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Invitations
  // ---------------------------------------------------------------------------

  Future<List<SiteInvitation>> fetchInvitations(String siteId) async {
    try {
      final response = await supabase
          .from(_invitationsTable)
          .select()
          .eq('site_id', siteId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((row) => SiteInvitation.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchInvitations', 'siteId': siteId},
      );
    }
  }

  /// Invite a member via the edge function, then send an invitation email.
  Future<SiteInvitation?> inviteMember({
    required String siteId,
    required String email,
    required SiteMemberRole role,
    required String siteName,
  }) async {
    try {
      // 1. Call edge function to generate link + create invitation record
      final response = await _invokeInviteSiteMember({
        'siteId': siteId,
        'email': email.trim().toLowerCase(),
        'role': role.name,
        'redirectTo': _setPasswordRedirectUri,
      });

      if (response.status != 200) {
        final data = _ensureMap(response.data);
        throw DomainError.of(
          DomainErrorCode.serverError,
          message: data['error']?.toString() ?? 'Invitation failed',
          context: {'status': response.status},
        );
      }

      final data = _ensureMap(response.data);
      final actionLink = data['action_link']?.toString() ?? '';
      final otp = data['email_otp']?.toString() ?? '';
      final isNewUser = data['is_new_user'] == true;

      // 2. Send invitation email
      await _emailTemplates.sendSiteInvitationEmail(
        email,
        actionLink: actionLink,
        otp: otp,
        siteName: siteName,
        isNewUser: isNewUser,
      );

      // 3. Fetch the created invitation
      final invitations = await fetchInvitations(siteId);
      return invitations
          .where((i) => i.email == email.trim().toLowerCase())
          .firstOrNull;
    } catch (error, stack) {
      if (error is DomainError) rethrow;
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'inviteMember', 'siteId': siteId, 'email': email},
      );
    }
  }

  /// Resend an invitation email by regenerating the auth link.
  Future<void> resendInvitation({
    required SiteInvitation invitation,
    required String siteName,
  }) async {
    try {
      final response = await _invokeInviteSiteMember({
        'siteId': invitation.siteId,
        'email': invitation.email,
        'role': invitation.role,
        'redirectTo': _setPasswordRedirectUri,
      });

      if (response.status != 200) {
        final data = _ensureMap(response.data);
        throw DomainError.of(
          DomainErrorCode.serverError,
          message: data['error']?.toString() ?? 'Resend failed',
          context: {'status': response.status},
        );
      }

      final data = _ensureMap(response.data);
      final actionLink = data['action_link']?.toString() ?? '';
      final otp = data['email_otp']?.toString() ?? '';
      final isNewUser = data['is_new_user'] == true;

      await _emailTemplates.sendSiteInvitationEmail(
        invitation.email,
        actionLink: actionLink,
        otp: otp,
        siteName: siteName,
        isNewUser: isNewUser,
      );
    } catch (error, stack) {
      if (error is DomainError) rethrow;
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'resendInvitation', 'invitationId': invitation.id},
      );
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    try {
      await supabase
          .from(_invitationsTable)
          .update({'status': 'cancelled'})
          .eq('id', invitationId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'cancelInvitation', 'invitationId': invitationId},
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Account-wide (all accessible sites)
  // ---------------------------------------------------------------------------

  /// Fetch all members across all accessible sites, excluding the current user.
  /// Deduplicates by profileId, keeping the highest role.
  Future<List<SiteMember>> fetchMembersForOwner() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final sites = await _fetchAccessibleSites();
      if (sites.isEmpty) return [];
      final siteIds = sites.map((s) => s['id'] as String).toList();

      final response = await supabase
          .from(_membersTable)
          .select(_memberSelect)
          .inFilter('site_id', siteIds)
          .neq('profile_id', userId)
          .order('created_at', ascending: true);
      final byProfile = <String, SiteMember>{};
      for (final row in response as List<dynamic>) {
        final member = SiteMember.fromMap(row as Map<String, dynamic>);
        final existing = byProfile[member.profileId];
        if (existing == null ||
            _roleRank(member.memberRole) > _roleRank(existing.memberRole)) {
          byProfile[member.profileId] = member;
        }
      }
      return byProfile.values.toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchMembersForOwner'},
      );
    }
  }

  /// Fetch all pending invitations across all accessible sites.
  /// Deduplicates by email.
  Future<List<SiteInvitation>> fetchInvitationsForOwner() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final sites = await _fetchAccessibleSites();
      if (sites.isEmpty) return [];
      final siteIds = sites.map((s) => s['id'] as String).toList();

      final response = await supabase
          .from(_invitationsTable)
          .select()
          .inFilter('site_id', siteIds)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      final byEmail = <String, SiteInvitation>{};
      for (final row in response as List<dynamic>) {
        final inv = SiteInvitation.fromMap(row as Map<String, dynamic>);
        byEmail.putIfAbsent(inv.email, () => inv);
      }
      return byEmail.values.toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchInvitationsForOwner'},
      );
    }
  }

  /// Invite a user to all accessible sites.
  /// Calls the edge function for each site but sends only one email.
  Future<void> inviteToAllSites({
    required String email,
    required SiteMemberRole role,
  }) async {
    try {
      final sites = await _fetchAccessibleSites();
      if (sites.isEmpty) {
        throw DomainError.of(
          DomainErrorCode.validationFailed,
          message: 'No sites found for this account.',
          context: {'op': 'inviteToAllSites', 'email': email},
        );
      }

      String actionLink = '';
      String otp = '';
      bool isNewUser = false;

      for (int i = 0; i < sites.length; i++) {
        final site = sites[i];
        final response = await _invokeInviteSiteMember({
          'siteId': site['id'],
          'email': email.trim().toLowerCase(),
          'role': role.name,
          'redirectTo': _setPasswordRedirectUri,
        });

        if (response.status != 200) {
          final data = _ensureMap(response.data);
          throw DomainError.of(
            DomainErrorCode.serverError,
            message: data['error']?.toString() ?? 'Invitation failed',
            context: {'status': response.status},
          );
        }

        if (i == 0) {
          final data = _ensureMap(response.data);
          actionLink = data['action_link']?.toString() ?? '';
          otp = data['email_otp']?.toString() ?? '';
          isNewUser = data['is_new_user'] == true;
        }
      }

      final siteNames = sites
          .map((s) => s['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .join(', ');

      await _emailTemplates.sendSiteInvitationEmail(
        email,
        actionLink: actionLink,
        otp: otp,
        siteName: siteNames,
        isNewUser: isNewUser,
      );
    } catch (error, stack) {
      if (error is DomainError) rethrow;
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'inviteToAllSites', 'email': email},
      );
    }
  }

  /// Remove a user from all accessible sites.
  Future<void> removeFromAllSites(String profileId) async {
    try {
      final sites = await _fetchAccessibleSites();
      final siteIds = sites
          .map((s) => s['id']?.toString())
          .whereType<String>()
          .toList();
      if (siteIds.isEmpty) return;

      await supabase
          .from(_membersTable)
          .delete()
          .eq('profile_id', profileId)
          .inFilter('site_id', siteIds);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'removeFromAllSites', 'profileId': profileId},
      );
    }
  }

  /// Cancel all pending invitations for an email across accessible sites.
  Future<void> cancelInvitationsByEmail(String email) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase
          .from(_invitationsTable)
          .update({'status': 'cancelled'})
          .eq('email', email)
          .eq('invited_by', userId)
          .eq('status', 'pending');
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'cancelInvitationsByEmail', 'email': email},
      );
    }
  }

  /// Fetch all sites the current user has access to (via RLS).
  Future<List<Map<String, dynamic>>> _fetchAccessibleSites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await supabase
        .from('sites')
        .select('id, name')
        .order('created_at', ascending: false);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static int _roleRank(SiteMemberRole role) {
    switch (role) {
      case SiteMemberRole.owner:
        return 3;
      case SiteMemberRole.editor:
        return 2;
      case SiteMemberRole.viewer:
        return 1;
    }
  }

  // ---------------------------------------------------------------------------
  // Invitation acceptance (called on login)
  // ---------------------------------------------------------------------------

  Future<void> acceptPendingInvitations() async {
    final user = supabase.auth.currentUser;
    if (user == null || user.email == null) return;
    try {
      await supabase.rpc(
        'accept_pending_invitations',
        params: {'p_user_id': user.id, 'p_user_email': user.email!},
      );
    } catch (_) {
      // Non-critical: silently ignore if function doesn't exist yet
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<FunctionResponse> _invokeInviteSiteMember(
    Map<String, dynamic> payload,
  ) async {
    Future<FunctionResponse> invokeOnce() async {
      final accessToken = supabase.auth.currentSession?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw DomainErrorCode.unauthorized.err(
          reason: DomainErrorReason.cannotSaveData,
          message: 'No access token available for invite call',
          context: const {'op': 'inviteSiteMember', 'auth_session': 'missing'},
        );
      }

      return supabase.functions.invoke(
        'invite_site_member',
        body: jsonEncode(payload),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    }

    await _ensureFreshSessionForInvite();
    try {
      return await invokeOnce();
    } on FunctionException catch (error) {
      if (error.status != 401 || !_isInvalidJwt(error.details)) {
        rethrow;
      }

      // Retry once after explicit refresh when edge runtime rejects JWT.
      await _refreshSessionForInvite();
      try {
        return await invokeOnce();
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> _ensureFreshSessionForInvite() async {
    if (supabase.auth.currentUser == null) {
      throw DomainErrorCode.unauthorized.err(
        reason: DomainErrorReason.cannotSaveData,
        message: 'User not logged in',
        context: const {'supabase_user': null},
      );
    }

    final session = supabase.auth.currentSession;
    if (session == null) {
      await _refreshSessionForInvite();
      if (supabase.auth.currentSession == null) {
        throw DomainErrorCode.unauthorized.err(
          reason: DomainErrorReason.cannotSaveData,
          message: 'No active auth session found',
        );
      }
      return;
    }

    final exp = session.expiresAt;
    if (exp == null) return;

    final expiration = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    if (DateTime.now().isAfter(
      expiration.subtract(const Duration(seconds: 30)),
    )) {
      await _refreshSessionForInvite();
    }
  }

  Future<void> _refreshSessionForInvite() async {
    try {
      await supabase.auth.refreshSession();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: const {'op': 'refreshSessionForInvite'},
      );
    }
  }

  bool _isInvalidJwt(Object? details) {
    final normalized = (details?.toString() ?? '').toLowerCase();
    return normalized.contains('invalid jwt');
  }

  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    return const {};
  }
}
