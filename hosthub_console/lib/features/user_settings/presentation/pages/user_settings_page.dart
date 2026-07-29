import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/presentation/widgets/admin_options_section.dart';
import 'package:hosthub_console/features/team/application/site_members_cubit.dart';
import 'package:hosthub_console/features/team/domain/site_invitation.dart';
import 'package:hosthub_console/features/team/domain/site_member.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';
import 'package:hosthub_console/features/team/presentation/dialogs/invite_member_dialog.dart';
import 'package:hosthub_console/features/user_settings/presentation/widgets/listings_section.dart';
import 'package:hosthub_console/features/user_settings/presentation/widgets/site_settings_sections.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

const _lodgifyServerStoredMarker = '__lodgify_server_stored__';
const _legacyLodgifyServerStoredMarker = '__server_stored__';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserSettingsView();
  }
}

class _UserSettingsView extends StatelessWidget {
  const _UserSettingsView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.toast != current.toast && current.toast != null,
          listener: (context, state) async {
            final toast = state.toast;
            if (toast == null) return;
            final message = _toastMessage(context, toast.message);
            if (toast.type == UserSettingsToastType.error) {
              await showAppError(
                context,
                AppError.custom(title: context.s.error, alert: message),
              );
              if (!context.mounted) return;
              context.read<UserSettingsCubit>().clearToast();
              return;
            }
            showStyledToast(
              context,
              type: _toastType(toast.type),
              description: message,
            );
            context.read<UserSettingsCubit>().clearToast();
          },
        ),
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.domainError != current.domainError &&
              current.domainError != null,
          listener: (context, state) async {
            final domainError = state.domainError;
            if (domainError == null) return;
            final appError = _mapDomainError(context, domainError);
            await showAppError(context, appError);
            if (!context.mounted) return;
            context.read<UserSettingsCubit>().clearError();
          },
        ),
        // Save feedback for every ServerSettingsCubit save on this page — the
        // channel-fee defaults and the admin section share one cubit, so the
        // page owns the toast and the error instead of each section claiming
        // transitions the other caused.
        BlocListener<ServerSettingsCubit, ServerSettingsState>(
          listenWhen: (previous, current) =>
              previous.status == ServerSettingsStatus.mutating &&
              current.status == ServerSettingsStatus.ready,
          listener: (context, state) {
            showStyledToast(
              context,
              type: ToastificationType.success,
              description: context.s.settingsSaved,
            );
          },
        ),
        BlocListener<ServerSettingsCubit, ServerSettingsState>(
          listenWhen: (previous, current) =>
              previous.error != current.error && current.error != null,
          listener: (context, state) async {
            final error = state.error;
            if (error == null) return;
            await showAppError(context, AppError.fromDomain(context, error));
          },
        ),
        BlocListener<SiteContextCubit, SiteContextState>(
          listenWhen: (previous, current) =>
              previous.error != current.error && current.error != null,
          listener: (context, state) async {
            final error = state.error;
            if (error == null) return;
            await showAppError(context, AppError.fromDomain(context, error));
            if (!context.mounted) return;
            context.read<SiteContextCubit>().clearError();
          },
        ),
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.channelPropertiesToReview !=
                  current.channelPropertiesToReview &&
              current.channelPropertiesToReview != null,
          listener: (context, state) async {
            final lodgifyProperties = state.channelPropertiesToReview;
            if (lodgifyProperties == null) return;
            final missing = state.missingPropertiesToConfirm ?? const [];
            final shouldAdd = await _showMissingPropertiesDialog(
              context,
              lodgifyProperties: lodgifyProperties,
              missing: missing,
            );
            if (!context.mounted) return;
            if (missing.isEmpty) {
              if (shouldAdd) {
                await context.read<UserSettingsCubit>().confirmLodgifySync();
              } else {
                context.read<UserSettingsCubit>().skipMissingProperties();
              }
              return;
            }
            if (shouldAdd) {
              await context.read<UserSettingsCubit>().addMissingProperties(
                missing,
              );
              if (!context.mounted) return;
              context.read<PropertyContextCubit>().loadProperties();
            } else {
              await context.read<UserSettingsCubit>().skipMissingProperties();
            }
            context.read<UserSettingsCubit>().clearMissingProperties();
          },
        ),
      ],
      child: BlocBuilder<UserSettingsCubit, UserSettingsState>(
        builder: (context, state) {
          final settings = state.settings;
          final isLoading =
              state.status == UserSettingsStatus.loading && settings == null;

          // Intrinsic height: the pane card grows with its content and the
          // page itself scrolls, with the page padding as a scroll inset —
          // content runs to the screen edge and the gap below the card is
          // only visible at maximum scroll.
          return StyledWebPageScaffold(
            overline: context.s.navGroupAccount,
            title: context.s.accountTitle,
            intrinsicPaneHeight: true,
            leftChild: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _UserSettingsSection(
                    theme: context.theme,
                    settings: settings,
                  ),
          );
        },
      ),
    );
  }
}

class _UserSettingsSection extends StatelessWidget {
  const _UserSettingsSection({required this.theme, required this.settings});

  final ThemeData theme;
  final UserSettings? settings;

  @override
  Widget build(BuildContext context) {
    final styledTheme = StyledWidgetsTheme.of(context);

    final status = context.select(
      (UserSettingsCubit cubit) => cubit.state.status,
    );
    final lodgifyApiKey = settings?.lodgifyApiKey?.trim();
    final hasApiKey = lodgifyApiKey?.isNotEmpty ?? false;
    final isServerStoredApiKey =
        lodgifyApiKey == _lodgifyServerStoredMarker ||
        lodgifyApiKey == _legacyLodgifyServerStoredMarker;
    final isConnected = settings?.lodgifyConnected ?? false;
    final isBusy =
        status == UserSettingsStatus.saving ||
        status == UserSettingsStatus.connecting ||
        status == UserSettingsStatus.syncing;
    final canConnect = hasApiKey && !isBusy;
    final canSync = isConnected && !isBusy;
    final lastSyncedAt = settings?.lodgifyLastSyncedAt;

    if (settings == null) {
      return const SizedBox.shrink();
    }

    // §8.3, in order: who has access, what we are connected to, what you pay.
    // Site details, website languages and the source language moved to
    // Site-instellingen — they are about one property, and three screens called
    // "instellingen" with no rule about which held what was the problem this
    // split solves.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TeamSection(),
        StyledSection(
          header: context.s.accountConnectionsHeader,
          horizontalPadding: 0,
          children: [
            Text(context.s.lodgifyTitle),
            StyledTile(
              title: context.s.lodgifyApiKeyLabel,
              subtitle: context.s.lodgifyApiKeyDescription,
              value: hasApiKey
                  ? Text(
                      _maskApiKey(
                        settings?.lodgifyApiKey ?? '',
                        isServerStored: isServerStoredApiKey,
                        last4: settings?.lodgifyApiKeyLast4,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.1,
                      ),
                    )
                  : null,
              trailing: _LodgifyApiKeyControl(
                hasApiKey: hasApiKey,
                isBusy: isBusy,
                onEdit: () async {
                  final result = await _showLodgifyApiKeyDialog(
                    context,
                    currentApiKey: isServerStoredApiKey
                        ? null
                        : settings?.lodgifyApiKey,
                  );
                  if (result == null || !context.mounted) return;
                  context.read<UserSettingsCubit>().updateLodgifyApiKey(
                    result.apiKey,
                    remove: result.remove,
                  );
                },
              ),
            ),
            StyledTile(
              title: Text(
                isConnected
                    ? context.s.connectionStatusConnected
                    : context.s.connectionStatusDisconnected,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: StyledButton(
                title: isConnected
                    ? context.s.lodgifySyncLabel
                    : context.s.connectLabel,
                onPressed: isConnected
                    ? (canSync
                          ? () =>
                                context.read<UserSettingsCubit>().syncLodgify()
                          : null)
                    : (canConnect
                          ? () => context
                                .read<UserSettingsCubit>()
                                .connectLodgify()
                          : null),
                enabled: isConnected ? canSync : canConnect,
                showProgressIndicatorWhenDisabled: isBusy,
                backgroundColorDisabled:
                    styledTheme.buttons.disabledBackgroundColor,
                labelColorDisabled: styledTheme.buttons.disabledLabelColor,
                enableShrinking: false,
                width: 120,
                minWidth: 120,
                minHeight: 40,
              ),
            ),
            _LastSyncTile(lastSyncedAt: lastSyncedAt),
          ],
        ),
        // Listings sit under the connection that normally creates them — the
        // manual add/remove is the escape hatch for setting up a website
        // without a sync.
        const ListingsSection(),
        const _BillingSection(),
        StyledSection(
          header: context.s.generalSectionTitle,
          footer: context.s.accountPreferencesMovedFooter,
          horizontalPadding: 0,
          children: const [_AppInfoTile()],
        ),
        // Admin scope last: everything above is this account's own data, the
        // admin section is the whole environment's. Absent for a non-admin, so
        // the page ends at the account for everyone else.
        if (context.watch<ProfileCubit>().state.profile?.isAdmin ?? false)
          const AdminOptionsSection(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gebruikers & rollen
// ---------------------------------------------------------------------------

/// The role a member holds, as the account states it.
///
/// Three roles, and they are **account-wide**: a role is granted once and holds
/// for every property, including one added tomorrow (a trigger on `sites`
/// carries the account's members onto a new site). Per-site rows remain the
/// storage; there is deliberately no second membership model beside them.
extension _AccountRoleCopy on SiteMemberRole {
  String roleLabel(BuildContext context) => switch (this) {
    SiteMemberRole.owner => context.s.accountRoleOwner,
    SiteMemberRole.editor => context.s.accountRoleAdmin,
    SiteMemberRole.viewer => context.s.accountRoleViewer,
  };

  String roleDescription(BuildContext context) => switch (this) {
    SiteMemberRole.owner => context.s.accountRoleOwnerDescription,
    SiteMemberRole.editor => context.s.accountRoleAdminDescription,
    SiteMemberRole.viewer => context.s.accountRoleViewerDescription,
  };
}

class _TeamSection extends StatefulWidget {
  const _TeamSection();

  @override
  State<_TeamSection> createState() => _TeamSectionState();
}

class _TeamSectionState extends State<_TeamSection> {
  @override
  void initState() {
    super.initState();
    context.read<SiteMembersCubit>().loadAccountTeam();
  }

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
        final members = state.members;
        final invitations = state.pendingInvitations;
        final isLoading = state.isLoading && members.isEmpty;

        return StyledSection(
          isFirstSection: true,
          header: context.s.accountUsersHeader,
          // A role is account-wide, and the reader has to know that before
          // they grant one.
          footer: context.s.accountUsersFooter,
          horizontalPadding: 0,
          headerAction: StyledButton(
            title: context.s.accountInviteMember,
            size: StyledButtonSize.compact,
            leftIconData: Icons.person_add_outlined,
            showLeftIcon: true,
            onPressed: () => _handleInvite(context),
          ),
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              // Members and pending invitations are one list: an invitation is
              // a member whose link has not been used yet, and splitting them
              // made the same person look like two entries.
              if (members.isNotEmpty) _TeamMembersList(members: members),
              if (invitations.isNotEmpty)
                _TeamInvitationsList(invitations: invitations),
              if (members.isEmpty && invitations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.s.accountNoMembers,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _handleInvite(BuildContext context) async {
    final result = await showInvitePartnerDialog(context);
    if (result == true && context.mounted) {
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: context.s.teamInvitationSent,
      );
    }
  }
}

class _TeamMembersList extends StatelessWidget {
  const _TeamMembersList({required this.members});

  final List<SiteMember> members;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: members.map((member) {
        return StyledTile(
          title: member.displayName,
          subtitle: member.memberRole.roleDescription(context),
          value: StyledChip(
            label: member.memberRole.roleLabel(context),
            size: StyledChipSize.display,
            backgroundColor: context.colors.secondaryContainer,
            labelColor: context.colors.onSecondaryContainer,
          ),
          trailing: member.memberRole != SiteMemberRole.owner
              ? StyledToolbarButton(
                  iconData: Icons.remove_circle_outline,
                  destructive: true,
                  tooltip: context.s.teamRemoveMember,
                  onPressed: () => _confirmRemove(context, member),
                )
              : null,
        );
      }).toList(),
    );
  }

  void _confirmRemove(BuildContext context, SiteMember member) {
    showStyledAlertDialog(
      context,
      title: context.s.accountRemoveMemberTitle(member.displayName),
      message: context.s.accountRemoveMemberMessage,
      actionText: context.s.remove,
      dismissText: context.s.cancelButton,
      isDestructiveAction: true,
      onAction: () => context.read<SiteMembersCubit>().removePartner(member),
    );
  }
}

class _TeamInvitationsList extends StatelessWidget {
  const _TeamInvitationsList({required this.invitations});

  final List<SiteInvitation> invitations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: invitations.map((inv) {
        return StyledTile(
          title: inv.email,
          subtitle: inv.memberRole.roleDescription(context),
          value: StyledChip(
            // The role, then what is still missing: the link has not been used
            // yet. One row per person either way.
            label:
                '${inv.memberRole.roleLabel(context)} '
                '${context.s.accountMemberInvited}',
            size: StyledChipSize.display,
            backgroundColor: context.colors.tertiaryContainer,
            labelColor: context.colors.onTertiaryContainer,
          ),
          trailing: StyledToolbarButton(
            iconData: Icons.cancel_outlined,
            destructive: true,
            tooltip: context.s.teamCancelInvitation,
            onPressed: () {
              context.read<SiteMembersCubit>().cancelPartnerInvitation(inv);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _AppInfoTile extends StatefulWidget {
  const _AppInfoTile();

  @override
  State<_AppInfoTile> createState() => _AppInfoTileState();
}

class _AppInfoTileState extends State<_AppInfoTile> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final environment = AppConfig.current.environment.name.toUpperCase();

    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final buildNumber = packageInfo?.buildNumber.trim() ?? '';
        final version = packageInfo?.version ?? '-';
        final fullVersion = buildNumber.isEmpty
            ? version
            : '$version+$buildNumber';

        return StyledTile(
          title: context.s.appInfoTileTitle,
          value: Text(
            context.s.appInfoTileValue(fullVersion, environment),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Abonnement & facturering
// ---------------------------------------------------------------------------

/// What the account pays for, and the one field a business user needs.
///
/// Deliberately small. HostHub is for people with a few homes; the business
/// ones need a company number on the invoice, not a second account type, a
/// "bedrijfsgegevens" block or a KvK field. The payment method and the invoice
/// list belong to the payment provider, so they are stated here and linked
/// there — a row without a chevron is a value, never a dead navigation.
class _BillingSection extends StatelessWidget {
  const _BillingSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountChannelDefaultsCubit>().state;
    final propertyCount = context
        .watch<PropertyContextCubit>()
        .state
        .properties
        .length;

    return StyledSection(
      header: context.s.accountBillingHeader,
      footer: context.s.accountBillingExternalNotice,
      horizontalPadding: 0,
      children: [
        StyledTile(
          leading: const Icon(Icons.workspace_premium_outlined),
          title: context.s.accountBillingPlan,
          value: context.s.accountBillingPlanValue(
            context.s.accountBillingPlanPro,
            propertyCount,
          ),
        ),
        StyledTile(
          leading: const Icon(Icons.credit_card_outlined),
          title: context.s.accountBillingPaymentMethod,
          value: notSetPlaceholder(context),
        ),
        StyledTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: context.s.accountBillingInvoices,
          value: context.s.accountBillingInvoicesValue,
        ),
        _VatNumberTile(state: state),
      ],
    );
  }
}

class _VatNumberTile extends StatefulWidget {
  const _VatNumberTile({required this.state});

  final AccountChannelDefaultsState state;

  @override
  State<_VatNumberTile> createState() => _VatNumberTileState();
}

class _VatNumberTileState extends State<_VatNumberTile> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.state.settings.vatNumber ?? '',
  );

  @override
  void didUpdateWidget(covariant _VatNumberTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stored = widget.state.settings.vatNumber ?? '';
    if (stored != _controller.text && !_focusNode.hasFocus) {
      _controller.text = stored;
    }
  }

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit() {
    final value = _controller.text.trim();
    final stored = widget.state.settings.vatNumber ?? '';
    if (value == stored) return;
    context.read<AccountChannelDefaultsCubit>().saveSettings(
      widget.state.settings.copyWith(
        vatNumber: value.isEmpty ? null : value,
        clearVatNumber: value.isEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StyledTile(
      leading: const Icon(Icons.badge_outlined),
      title: context.s.accountBillingVatNumber,
      subtitle: context.s.accountBillingVatHint,
      value: SizedBox(
        width: 220,
        child: StyledTextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.state.canEdit,
          textAlign: TextAlign.right,
          // Committed on leaving the field rather than per keystroke: an
          // account-level write per character is a write per character.
          onEditingComplete: _commit,
          onSubmitted: (_) => _commit(),
        ),
      ),
    );
  }
}

class _LastSyncTile extends StatefulWidget {
  const _LastSyncTile({required this.lastSyncedAt});

  final DateTime? lastSyncedAt;

  @override
  State<_LastSyncTile> createState() => _LastSyncTileState();
}

class _LastSyncTileState extends State<_LastSyncTile> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant _LastSyncTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lastSyncedAt != widget.lastSyncedAt) {
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.lastSyncedAt == null) return;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.lastSyncedAt;
    if (timestamp == null) {
      return const SizedBox.shrink();
    }

    final formattedSyncTime = _formatSyncTimestamp(context, timestamp);
    return StyledTile(
      title: Text(
        context.s.lodgifyLastSyncLabel(formattedSyncTime),
        style: context.theme.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LodgifyApiKeyControl extends StatelessWidget {
  const _LodgifyApiKeyControl({
    required this.hasApiKey,
    required this.isBusy,
    required this.onEdit,
  });

  final bool hasApiKey;
  final bool isBusy;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (!hasApiKey) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: StyledButton(
          title: context.s.add,
          onPressed: isBusy ? null : onEdit,
          enabled: !isBusy,
          leftIconData: Icons.add,
          showLeftIcon: !isBusy,
          minHeight: 40,
        ),
      );
    }

    return StyledToolbarButton(
      iconData: Icons.edit_outlined,
      tooltip: context.s.edit,
      onPressed: isBusy ? null : onEdit,
    );
  }
}

class _LodgifyApiKeyDialogResult {
  const _LodgifyApiKeyDialogResult.save(this.apiKey) : remove = false;
  const _LodgifyApiKeyDialogResult.remove() : apiKey = null, remove = true;

  final String? apiKey;
  final bool remove;
}

Future<_LodgifyApiKeyDialogResult?> _showLodgifyApiKeyDialog(
  BuildContext context, {
  required String? currentApiKey,
}) async {
  final hasApiKey = currentApiKey?.trim().isNotEmpty ?? false;
  final contentKey = GlobalKey<_LodgifyApiKeyDialogContentState>();

  final result = await showStyledModal<_LodgifyApiKeyDialogResult>(
    context,
    title: context.s.lodgifyApiKeyLabel,
    isDismissible: false,
    actionLabel: hasApiKey ? context.s.saveButton : context.s.add,
    leadingLabel: context.s.cancelButton,
    showAction: true,
    showCloseButton: true,
    leadingClose: true,
    closeOnAction: false,
    builder: (context, modal) {
      return _LodgifyApiKeyDialogContent(
        key: contentKey,
        currentApiKey: currentApiKey,
        hasApiKey: hasApiKey,
      );
    },
    onAction: (_) {
      contentKey.currentState?.submit();
    },
  );

  return result;
}

class _LodgifyApiKeyDialogContent extends StatefulWidget {
  const _LodgifyApiKeyDialogContent({
    super.key,
    required this.currentApiKey,
    required this.hasApiKey,
  });

  final String? currentApiKey;
  final bool hasApiKey;

  @override
  State<_LodgifyApiKeyDialogContent> createState() =>
      _LodgifyApiKeyDialogContentState();
}

class _LodgifyApiKeyDialogContentState
    extends State<_LodgifyApiKeyDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentApiKey ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop(_LodgifyApiKeyDialogResult.save(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: StyledTextFormField(
              controller: _controller,
              autofocus: true,
              placeholder: context.s.lodgifyApiKeyLabel,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.s.lodgifyApiKeyRequired;
                }
                return null;
              },
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          if (widget.hasApiKey) ...[
            const SizedBox(height: 12),
            StyledButton(
              title: context.s.deleteButton,
              onPressed: () => Navigator.of(
                context,
              ).pop(const _LodgifyApiKeyDialogResult.remove()),
              backgroundColor: context.colors.error,
              labelColor: context.colors.onError,
              minHeight: 40,
            ),
          ],
        ],
      ),
    );
  }
}

Future<bool> _showMissingPropertiesDialog(
  BuildContext context, {
  required List<ChannelProperty> lodgifyProperties,
  required List<ChannelProperty> missing,
}) async {
  final missingIds = missing
      .map((property) => property.id?.trim())
      .whereType<String>()
      .where((value) => value.isNotEmpty)
      .toSet();
  final missingNames = missing
      .map((property) => property.name?.trim().toLowerCase())
      .whereType<String>()
      .where((value) => value.isNotEmpty)
      .toSet();
  final hasMissing = missing.isNotEmpty;
  final styledTheme = StyledWidgetsTheme.of(context);
  final subtitle = hasMissing ? null : context.s.lodgifyNoNewPropertiesFound;

  final shouldAdd =
      await showStyledModal<bool>(
        context,
        hideDefaultHeader: true,
        isDismissible: false,
        builder: (context, modal) {
          return SizedBox(
            width: 420,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      children: [
                        Text(
                          context.s.lodgifyMissingPropertiesTitle,
                          style: context.theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: context.theme.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: lodgifyProperties.length,
                      itemBuilder: (context, index) {
                        final property = lodgifyProperties[index];
                        final title =
                            property.name ?? property.id ?? 'Unknown property';
                        final lodgifyId = property.id?.trim();
                        final isMissing =
                            (lodgifyId != null &&
                                lodgifyId.isNotEmpty &&
                                missingIds.contains(lodgifyId)) ||
                            missingNames.contains(
                              (property.name ?? '').trim().toLowerCase(),
                            );
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: StyledTile(
                            title: title,
                            leading: isMissing
                                ? null
                                : Icon(
                                    Icons.check_circle,
                                    color: context.colors.primary,
                                  ),
                            centerContent: false,
                            minHeight: 44,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: StyledButton(
                            title: context.s.cancelButton,
                            onPressed: () => Navigator.of(context).pop(false),
                            minHeight: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StyledButton(
                            titleWidget: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    hasMissing
                                        ? context
                                              .s
                                              .lodgifyMissingPropertiesAddAction
                                        : context.s.lodgifySyncLabel,
                                    style: context.theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: styledTheme.buttons.labelColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            minHeight: 40,
                            backgroundColor:
                                styledTheme.buttons.backgroundColor,
                            labelColor: styledTheme.buttons.labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
  return shouldAdd;
}

AppError _mapDomainError(BuildContext context, DomainError domainError) {
  final lodgifyAction = domainError.context?['lodgify_action']?.toString();
  if (lodgifyAction == 'connect') {
    return AppError.custom(
      title: context.s.lodgifyConnectErrorTitle,
      alert: _lodgifyConnectAlert(context, domainError),
      domainError: domainError,
    );
  }
  return AppError.fromDomain(context, domainError);
}

String _lodgifyConnectAlert(BuildContext context, DomainError domainError) {
  if (domainError.isNetworkError) {
    return context.s.networkError;
  }

  final functionStatus = int.tryParse(
    domainError.context?['function_status']?.toString() ?? '',
  );
  final functionDetails =
      domainError.context?['function_details']?.toString().toLowerCase() ?? '';

  if (functionStatus == 404 ||
      functionDetails.contains('requested function was not found')) {
    return context.s.configurationInvalid;
  }

  return context.s.lodgifyConnectErrorDescription;
}

ToastificationType _toastType(UserSettingsToastType type) {
  return switch (type) {
    UserSettingsToastType.success => ToastificationType.success,
    UserSettingsToastType.error => ToastificationType.error,
    UserSettingsToastType.info => ToastificationType.info,
  };
}

String _toastMessage(BuildContext context, UserSettingsToastMessage message) {
  return switch (message) {
    UserSettingsToastMessage.settingsSaved => context.s.settingsSaved,
    UserSettingsToastMessage.lodgifyApiKeyRequired =>
      context.s.lodgifyApiKeyRequired,
    UserSettingsToastMessage.lodgifyApiKeySaveFailed =>
      context.s.lodgifyApiKeySaveFailed,
    UserSettingsToastMessage.lodgifyConnectSuccess =>
      context.s.lodgifyConnectSuccess,
    UserSettingsToastMessage.lodgifyConnectFailed =>
      context.s.lodgifyConnectFailed,
    UserSettingsToastMessage.lodgifySyncCompleted =>
      context.s.lodgifySyncCompleted,
    UserSettingsToastMessage.lodgifySyncFailed => context.s.lodgifySyncFailed,
    UserSettingsToastMessage.lodgifyNoNewProperties =>
      context.s.lodgifyNoNewPropertiesFound,
    UserSettingsToastMessage.userSettingsLoadFailed =>
      context.s.userSettingsLoadFailed,
  };
}

String _maskApiKey(String value, {bool isServerStored = false, String? last4}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  if (isServerStored) {
    // The raw key never reaches the client; show the non-secret last-4 hint
    // when available, otherwise fall back to a plain mask.
    final hint = last4?.trim() ?? '';
    return hint.isNotEmpty ? '••••••••$hint' : '********';
  }
  if (trimmed.length <= 4) {
    return List.filled(trimmed.length, '*').join();
  }
  return '********${trimmed.substring(trimmed.length - 4)}';
}

String _formatSyncTimestamp(BuildContext context, DateTime timestamp) {
  final local = timestamp.toLocal();
  final localeCode = Localizations.localeOf(context).languageCode;
  return timeago.format(local, locale: localeCode);
}
