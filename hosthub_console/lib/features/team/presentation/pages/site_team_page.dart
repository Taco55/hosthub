import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/team/application/site_members_cubit.dart';
import 'package:hosthub_console/features/team/domain/site_invitation.dart';
import 'package:hosthub_console/features/team/domain/site_member.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';
import 'package:hosthub_console/features/team/presentation/dialogs/invite_member_dialog.dart';
import 'package:styled_widgets/styled_widgets.dart';

class SiteTeamPage extends StatelessWidget {
  const SiteTeamPage({super.key, required this.siteId, required this.siteName});

  final String siteId;
  final String siteName;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SiteMembersCubit, SiteMembersState>(
      listenWhen: (prev, curr) => prev.error != curr.error,
      listener: (context, state) async {
        if (state.error != null) {
          final appError = AppError.fromDomain(context, state.error!);
          await showAppError(context, appError);
          if (context.mounted) {
            context.read<SiteMembersCubit>().clearError();
          }
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.members.isEmpty) {
          return StyledWebPageScaffold(
            overline: siteName,
            title: context.s.teamTitle,
            onBack: () async {
              context.pop();
              return false;
            },
            leftChild: const Center(child: CircularProgressIndicator()),
          );
        }

        return StyledWebPageScaffold(
          // Design `.top`: the site this team belongs to as the crumb, the
          // page'context.s own subject as the title — not a name as a subtitle.
          overline: siteName,
          title: context.s.teamTitle,
          onBack: () async {
            context.pop();
            return false;
          },
          actions: [
            StyledButton(
              title: context.s.teamInviteMemberButton,
              leftIconData: Icons.person_add_outlined,
              showLeftIcon: true,
              onPressed: () => _handleInvite(context),
              minHeight: 40,
            ),
          ],
          isLoading: state.isInviting,
          leftChild: ListView(
            padding: EdgeInsets.zero,
            children: [
              _MembersSection(members: state.members),
              if (state.pendingInvitations.isNotEmpty) ...[
                const SizedBox(height: 24),
                _InvitationsSection(
                  invitations: state.pendingInvitations,
                  siteName: siteName,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleInvite(BuildContext context) async {
    final result = await showInviteMemberDialog(context, siteName: siteName);
    if (result == true && context.mounted) {
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: context.s.teamInvitationSent,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Members section
// ---------------------------------------------------------------------------

class _MembersSection extends StatelessWidget {
  const _MembersSection({required this.members});

  final List<SiteMember> members;

  @override
  Widget build(BuildContext context) {
    return StyledSection(
      isFirstSection: true,
      header: context.s.teamMembersSection,
      inset: false,
      children: [
        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(context.s.teamNoMembers),
          )
        else
          StyledDataTable(
            variant: StyledTableVariant.card,
            dense: true,
            columns: [
              StyledDataColumn(
                columnHeaderLabel: context.s.teamUserColumn,
                flex: 3,
                minWidth: 180,
              ),
              StyledDataColumn(
                columnHeaderLabel: context.s.teamRoleColumn,
                flex: 2,
                minWidth: 120,
              ),
              StyledDataColumn(
                columnHeaderLabel: context.s.teamActionsColumn,
                flex: 1,
                minWidth: 80,
              ),
            ],
            itemCount: members.length,
            rowBuilder: (tableContext, index) {
              final member = members[index];
              return [
                Text(member.displayName, overflow: TextOverflow.ellipsis),
                _RoleDisplay(member: member),
                _MemberActions(member: member),
              ];
            },
          ),
      ],
    );
  }
}

class _RoleDisplay extends StatelessWidget {
  const _RoleDisplay({required this.member});

  final SiteMember member;

  @override
  Widget build(BuildContext context) {
    final role = member.memberRole;

    // Owner role cannot be changed
    if (role == SiteMemberRole.owner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          role.label,
          style: context.theme.textTheme.labelSmall?.copyWith(
            color: context.colors.onPrimaryContainer,
          ),
        ),
      );
    }

    return DropdownButton<SiteMemberRole>(
      value: role,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: SiteMemberRole.assignableRoles
          .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
          .toList(),
      onChanged: (newRole) {
        if (newRole == null || newRole == role) return;
        context.read<SiteMembersCubit>().updateRole(member, newRole);
      },
    );
  }
}

class _MemberActions extends StatelessWidget {
  const _MemberActions({required this.member});

  final SiteMember member;

  @override
  Widget build(BuildContext context) {
    // Don't allow removing owners
    if (member.memberRole == SiteMemberRole.owner) {
      return const SizedBox.shrink();
    }

    return StyledToolbarButton(
      iconData: Icons.remove_circle_outline,
      destructive: true,
      tooltip: context.s.teamRemoveMember,
      onPressed: () => _confirmRemove(context),
    );
  }

  void _confirmRemove(BuildContext context) {
    showStyledAlertDialog(
      context,
      title: context.s.teamRemoveMemberTitle,
      message: context.s.teamRemoveMemberConfirm(member.displayName),
      dismissText: context.s.cancelButton,
      actionText: context.s.teamRemoveMember,
      isDestructiveAction: true,
      onAction: () {
        context.read<SiteMembersCubit>().removeMember(member);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Invitations section
// ---------------------------------------------------------------------------

class _InvitationsSection extends StatelessWidget {
  const _InvitationsSection({
    required this.invitations,
    required this.siteName,
  });

  final List<SiteInvitation> invitations;
  final String siteName;

  @override
  Widget build(BuildContext context) {
    return StyledSection(
      header: context.s.teamPendingInvitations,
      inset: false,
      children: [
        StyledDataTable(
          variant: StyledTableVariant.card,
          dense: true,
          columns: [
            StyledDataColumn(
              columnHeaderLabel: context.s.teamEmailColumn,
              flex: 3,
              minWidth: 180,
            ),
            StyledDataColumn(
              columnHeaderLabel: context.s.teamRoleColumn,
              flex: 2,
              minWidth: 100,
            ),
            StyledDataColumn(
              columnHeaderLabel: context.s.teamActionsColumn,
              flex: 2,
              minWidth: 140,
            ),
          ],
          itemCount: invitations.length,
          rowBuilder: (tableContext, index) {
            final inv = invitations[index];
            return [
              Text(inv.email, overflow: TextOverflow.ellipsis),
              Text(inv.memberRole.label),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StyledToolbarButton(
                    iconData: Icons.send_outlined,
                    tooltip: context.s.teamResendInvitation,
                    onPressed: () {
                      context.read<SiteMembersCubit>().resendInvitation(
                        invitation: inv,
                        siteName: siteName,
                      );
                      showStyledToast(
                        context,
                        type: ToastificationType.success,
                        description: context.s.teamInvitationResent,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  StyledToolbarButton(
                    iconData: Icons.cancel_outlined,
                    destructive: true,
                    tooltip: context.s.teamCancelInvitation,
                    onPressed: () {
                      context.read<SiteMembersCubit>().cancelInvitation(inv);
                    },
                  ),
                ],
              ),
            ];
          },
          emptyLabel: context.s.teamNoPendingInvitations,
        ),
      ],
    );
  }
}
