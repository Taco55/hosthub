import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/team/application/site_members_cubit.dart';
import 'package:hosthub_console/features/team/domain/site_invitation.dart';
import 'package:hosthub_console/features/team/domain/site_member.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';
import 'package:hosthub_console/features/team/presentation/dialogs/invite_member_dialog.dart';
import 'package:styled_widgets/styled_widgets.dart';

class SiteTeamPage extends StatelessWidget {
  const SiteTeamPage({
    super.key,
    required this.siteId,
    required this.siteName,
  });

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
          return ConsolePageScaffold(
            title: 'Team',
            description: siteName,
            onBack: () async {
              context.pop();
              return false;
            },
            leftChild: const Center(child: CircularProgressIndicator()),
          );
        }

        return ConsolePageScaffold(
          title: 'Team',
          description: siteName,
          onBack: () async {
            context.pop();
            return false;
          },
          actions: [
            StyledButton(
              title: 'Lid uitnodigen',
              leftIconData: Icons.person_add_outlined,
              showLeftIcon: true,
              onPressed: () => _handleInvite(context),
              minHeight: 40,
            ),
          ],
          showLoadingIndicator: state.isInviting,
          leftChild: ListView(
            padding: const EdgeInsets.only(top: 8),
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
    final result = await showInviteMemberDialog(
      context,
      siteName: siteName,
    );
    if (result == true && context.mounted) {
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: 'Uitnodiging verstuurd',
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
      header: 'Leden',
      grouped: false,
      children: [
        if (members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Geen leden gevonden.'),
          )
        else
          StyledDataTable(
            variant: StyledTableVariant.card,
            dense: true,
            columns: const [
              StyledDataColumn(
                columnHeaderLabel: 'Gebruiker',
                flex: 3,
                minWidth: 180,
              ),
              StyledDataColumn(
                columnHeaderLabel: 'Rol',
                flex: 2,
                minWidth: 120,
              ),
              StyledDataColumn(
                columnHeaderLabel: 'Acties',
                flex: 1,
                minWidth: 80,
              ),
            ],
            itemCount: members.length,
            rowBuilder: (tableContext, index) {
              final member = members[index];
              return [
                Text(
                  member.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
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
    final theme = Theme.of(context);
    final role = member.memberRole;

    // Owner role cannot be changed
    if (role == SiteMemberRole.owner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          role.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return DropdownButton<SiteMemberRole>(
      value: role,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: SiteMemberRole.assignableRoles
          .map(
            (r) => DropdownMenuItem(
              value: r,
              child: Text(r.label),
            ),
          )
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

    return IconButton(
      icon: const Icon(Icons.remove_circle_outline, size: 20),
      tooltip: 'Verwijderen',
      onPressed: () => _confirmRemove(context),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lid verwijderen'),
        content: Text(
          'Weet je zeker dat je ${member.displayName} wilt verwijderen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.s.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<SiteMembersCubit>().removeMember(member);
      }
    });
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
      header: 'Openstaande uitnodigingen',
      grouped: false,
      children: [
        StyledDataTable(
          variant: StyledTableVariant.card,
          dense: true,
          columns: const [
            StyledDataColumn(
              columnHeaderLabel: 'E-mail',
              flex: 3,
              minWidth: 180,
            ),
            StyledDataColumn(
              columnHeaderLabel: 'Rol',
              flex: 2,
              minWidth: 100,
            ),
            StyledDataColumn(
              columnHeaderLabel: 'Acties',
              flex: 2,
              minWidth: 140,
            ),
          ],
          itemCount: invitations.length,
          rowBuilder: (tableContext, index) {
            final inv = invitations[index];
            return [
              Text(
                inv.email,
                overflow: TextOverflow.ellipsis,
              ),
              Text(inv.memberRole.label),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.send_outlined, size: 18),
                    tooltip: 'Opnieuw versturen',
                    onPressed: () {
                      context.read<SiteMembersCubit>().resendInvitation(
                            invitation: inv,
                            siteName: siteName,
                          );
                      showStyledToast(
                        context,
                        type: ToastificationType.success,
                        description: 'Uitnodiging opnieuw verstuurd',
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    tooltip: 'Annuleren',
                    onPressed: () {
                      context
                          .read<SiteMembersCubit>()
                          .cancelInvitation(inv);
                    },
                  ),
                ],
              ),
            ];
          },
          emptyLabel: 'Geen openstaande uitnodigingen.',
        ),
      ],
    );
  }
}
