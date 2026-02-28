import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/features/team/data/site_member_repository.dart';
import 'package:hosthub_console/features/team/domain/site_invitation.dart';
import 'package:hosthub_console/features/team/domain/site_member.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';

enum SiteMembersStatus { initial, loading, ready, inviting, error }

class SiteMembersState extends Equatable {
  const SiteMembersState({
    this.status = SiteMembersStatus.initial,
    this.members = const [],
    this.invitations = const [],
    this.siteId,
    this.error,
  });

  final SiteMembersStatus status;
  final List<SiteMember> members;
  final List<SiteInvitation> invitations;
  final String? siteId;
  final DomainError? error;

  bool get isLoading => status == SiteMembersStatus.loading;
  bool get isInviting => status == SiteMembersStatus.inviting;

  List<SiteInvitation> get pendingInvitations =>
      invitations.where((i) => i.isPending && !i.isExpired).toList();

  SiteMembersState copyWith({
    SiteMembersStatus? status,
    List<SiteMember>? members,
    List<SiteInvitation>? invitations,
    String? siteId,
    DomainError? error,
  }) {
    return SiteMembersState(
      status: status ?? this.status,
      members: members ?? this.members,
      invitations: invitations ?? this.invitations,
      siteId: siteId ?? this.siteId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, members, invitations, siteId, error];
}

class SiteMembersCubit extends Cubit<SiteMembersState> {
  SiteMembersCubit({required SiteMemberRepository repository})
      : _repository = repository,
        super(const SiteMembersState());

  final SiteMemberRepository _repository;

  Future<void> loadTeam(String siteId) async {
    emit(state.copyWith(status: SiteMembersStatus.loading, siteId: siteId));
    try {
      final results = await Future.wait([
        _repository.fetchMembers(siteId),
        _repository.fetchInvitations(siteId),
      ]);
      emit(state.copyWith(
        status: SiteMembersStatus.ready,
        members: results[0] as List<SiteMember>,
        invitations: results[1] as List<SiteInvitation>,
      ));
    } catch (error, stack) {
      emit(state.copyWith(
        status: SiteMembersStatus.error,
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  Future<bool> inviteMember({
    required String email,
    required SiteMemberRole role,
    required String siteName,
  }) async {
    final siteId = state.siteId;
    if (siteId == null) return false;

    emit(state.copyWith(status: SiteMembersStatus.inviting));
    try {
      await _repository.inviteMember(
        siteId: siteId,
        email: email,
        role: role,
        siteName: siteName,
      );
      await loadTeam(siteId);
      return true;
    } catch (error, stack) {
      emit(state.copyWith(
        status: SiteMembersStatus.ready,
        error: DomainError.from(error, stack: stack),
      ));
      return false;
    }
  }

  Future<void> resendInvitation({
    required SiteInvitation invitation,
    required String siteName,
  }) async {
    try {
      await _repository.resendInvitation(
        invitation: invitation,
        siteName: siteName,
      );
    } catch (error, stack) {
      emit(state.copyWith(
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  Future<void> updateRole(SiteMember member, SiteMemberRole newRole) async {
    final siteId = state.siteId;
    if (siteId == null) return;

    try {
      await _repository.updateMemberRole(member.id, newRole);
      await loadTeam(siteId);
    } catch (error, stack) {
      emit(state.copyWith(
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  Future<void> removeMember(SiteMember member) async {
    final siteId = state.siteId;
    if (siteId == null) return;

    try {
      await _repository.removeMember(member.id);
      await loadTeam(siteId);
    } catch (error, stack) {
      emit(state.copyWith(
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  Future<void> cancelInvitation(SiteInvitation invitation) async {
    final siteId = state.siteId;
    if (siteId == null) return;

    try {
      await _repository.cancelInvitation(invitation.id);
      await loadTeam(siteId);
    } catch (error, stack) {
      emit(state.copyWith(
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Account-wide (all owned sites)
  // ---------------------------------------------------------------------------

  /// Load all partners and invitations across all sites owned by the user.
  Future<void> loadAccountTeam() async {
    emit(state.copyWith(status: SiteMembersStatus.loading));
    try {
      final results = await Future.wait([
        _repository.fetchMembersForOwner(),
        _repository.fetchInvitationsForOwner(),
      ]);
      emit(state.copyWith(
        status: SiteMembersStatus.ready,
        members: results[0] as List<SiteMember>,
        invitations: results[1] as List<SiteInvitation>,
      ));
    } catch (error, stack) {
      emit(state.copyWith(
        status: SiteMembersStatus.error,
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  /// Invite a partner to all sites owned by the user.
  Future<bool> invitePartner({
    required String email,
    required SiteMemberRole role,
  }) async {
    emit(state.copyWith(status: SiteMembersStatus.inviting));
    try {
      await _repository.inviteToAllSites(email: email, role: role);
      await loadAccountTeam();
      return true;
    } catch (error, stack) {
      emit(state.copyWith(
        status: SiteMembersStatus.ready,
        error: DomainError.from(error, stack: stack),
      ));
      return false;
    }
  }

  /// Remove a partner from all owned sites.
  Future<void> removePartner(SiteMember member) async {
    try {
      await _repository.removeFromAllSites(member.profileId);
      await loadAccountTeam();
    } catch (error, stack) {
      emit(state.copyWith(
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  /// Cancel all pending invitations for an email across owned sites.
  Future<void> cancelPartnerInvitation(SiteInvitation invitation) async {
    try {
      await _repository.cancelInvitationsByEmail(invitation.email);
      await loadAccountTeam();
    } catch (error, stack) {
      emit(state.copyWith(
        error: DomainError.from(error, stack: stack),
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
