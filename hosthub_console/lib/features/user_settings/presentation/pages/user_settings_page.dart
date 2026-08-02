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
import 'package:hosthub_console/features/team/presentation/site_member_role_copy.dart';
import 'package:hosthub_console/features/user_settings/presentation/dialogs/lodgify_api_key_modal.dart';
import 'package:hosthub_console/features/user_settings/presentation/widgets/site_settings_sections.dart'
    show notSetPlaceholder;
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
            leftChild: isLoading || settings == null
                ? const Center(child: CircularProgressIndicator())
                : _AccountSections(settings: settings),
          );
        },
      ),
    );
  }
}

/// §8.3, in order: who has access, what we are connected to, what you pay.
///
/// Nothing else. Listings moved to Properties (§8.5) — an owner does not look
/// for "add a home" under their invoices — and site details, website languages
/// and the source language moved to Site-instellingen, because they are about
/// one property.
class _AccountSections extends StatelessWidget {
  const _AccountSections({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TeamSection(),
        _ConnectionsSection(settings: settings),
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
          // A role is account-wide and says what it may do — both before the
          // reader grants one, and once for the whole list instead of on every
          // row.
          footer: context.s.accountUsersFooter,
          horizontalPadding: 0,
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
              for (final member in members) _MemberRow(member: member),
              for (final invitation in invitations)
                _InvitationRow(invitation: invitation),
            ],
            // The add affordance as the list's last row (design `.stile.tap`
            // with the primary `+`), the same as `Taal toevoegen` — not a
            // filled button in the section header competing with the page.
            // A StyledIconBadge rather than a bare Icon: an outlined glyph's
            // ink doesn't fill its own box the way a solid badge does, so a
            // bare icon reads as less indented next to the avatar above it
            // even though both start at the exact same x.
            StyledTile(
              leading: StyledIconBadge(
                icon: Icons.person_add_outlined,
                iconColor: context.colors.primary,
              ),
              title: context.s.accountInviteMember,
              titleColor: context.colors.primary,
              onTap: () => _handleInvite(context),
            ),
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

/// Design `.stile` + `.avm` + `.rochip`: who, their address, and their role as
/// one quiet tag.
///
/// One chip style for members and invitations. Three container colours in one
/// list (a teal pill for a role, an azure one for an invitation, primary blue on
/// the buttons) made a role read as something to click.
class _MemberRow extends StatelessWidget with StyledTileLike {
  const _MemberRow({required this.member});

  final SiteMember member;

  @override
  Widget build(BuildContext context) {
    final email = member.email?.trim() ?? '';
    final name = member.displayName;

    return StyledTile(
      leading: _Avatar(seed: name),
      title: name,
      // Only when it adds something: `displayName` falls back to the email.
      subtitle: email.isEmpty || email == name ? null : email,
      value: StatusPill(label: member.memberRole.roleLabel(context)),
      trailing: member.memberRole != SiteMemberRole.owner
          ? StyledToolbarButton(
              iconData: Icons.remove_circle_outline,
              destructive: true,
              tooltip: context.s.teamRemoveMember,
              onPressed: () => _confirmRemove(context, member),
            )
          : null,
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

class _InvitationRow extends StatelessWidget with StyledTileLike {
  const _InvitationRow({required this.invitation});

  final SiteInvitation invitation;

  @override
  Widget build(BuildContext context) {
    return StyledTile(
      leading: _Avatar(seed: invitation.email),
      title: invitation.email,
      // The role, then what is still missing: the link has not been used yet.
      // One row per person either way.
      value: StatusPill(
        label:
            '${invitation.memberRole.roleLabel(context)} '
            '${context.s.accountMemberInvited}',
      ),
      trailing: StyledToolbarButton(
        iconData: Icons.cancel_outlined,
        destructive: true,
        tooltip: context.s.teamCancelInvitation,
        onPressed: () {
          context.read<SiteMembersCubit>().cancelPartnerInvitation(invitation);
        },
      ),
    );
  }
}

/// Design `.stile .lead.avm`: a round monogram in the ice/primary pairing,
/// sized like every other tile leading (`tiles.iconBadgeSize`).
class _Avatar extends StatelessWidget {
  const _Avatar({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final trimmed = seed.trim();
    return StyledIconBadge.monogram(
      trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
      backgroundColor: context.colors.primaryContainer,
      iconColor: context.colors.primary,
    );
  }
}

// ---------------------------------------------------------------------------
// Koppelingen
// ---------------------------------------------------------------------------

/// What the account is connected to: the credential, and the connection itself.
///
/// Two rows, because that is what there is to say. The version this replaces
/// spent four — a bare `Lodgify` text between the tiles, a row whose title was
/// the connection status, a full-height primary `Sync` button and the last-sync
/// time on a row of its own.
class _ConnectionsSection extends StatelessWidget {
  const _ConnectionsSection({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (UserSettingsCubit cubit) => cubit.state.status,
    );
    final apiKey = settings.lodgifyApiKey?.trim();
    final hasApiKey = apiKey?.isNotEmpty ?? false;
    final isServerStored =
        apiKey == _lodgifyServerStoredMarker ||
        apiKey == _legacyLodgifyServerStoredMarker;
    final isBusy =
        status == UserSettingsStatus.saving ||
        status == UserSettingsStatus.connecting ||
        status == UserSettingsStatus.syncing;

    return StyledSection(
      header: context.s.accountConnectionsHeader,
      footer: context.s.accountConnectionsFooter,
      horizontalPadding: 0,
      children: [
        StyledSecretTile(
          // Design `.stile .lead`: both rows in this card carry a leading
          // glyph, so their titles start on the same edge — both as a
          // StyledIconBadge, so they share the same leading width too.
          leading: const StyledIconBadge(icon: Icons.vpn_key_outlined),
          title: context.s.lodgifyApiKeyLabel,
          subtitle: context.s.lodgifyApiKeyDescription,
          isSet: hasApiKey,
          // The raw key only reaches the client on an explicit reveal, so the
          // row itself has nothing but the last-4 hint to show. A key the user
          // typed and has not saved yet is already in `value`.
          value: isServerStored ? null : apiKey,
          hint: settings.lodgifyApiKeyLast4,
          onReveal: isServerStored
              ? () => context.read<UserSettingsCubit>().revealChannelApiKey()
              : null,
          copyable: true,
          onCopied: () => showStyledToast(
            context,
            type: ToastificationType.success,
            description: context.s.copied,
          ),
          revealTooltip: context.s.show,
          hideTooltip: context.s.hide,
          copyTooltip: context.s.copy,
          // Same icon-button family as the reveal/copy actions beside it.
          trailing: StyledToolbarButton(
            iconData: hasApiKey ? Icons.edit_outlined : Icons.add,
            tooltip: hasApiKey ? context.s.edit : context.s.add,
            onPressed: isBusy ? null : () => _editApiKey(context, settings),
          ),
        ),
        _LodgifyConnectionTile(settings: settings, isBusy: isBusy),
      ],
    );
  }

  Future<void> _editApiKey(BuildContext context, UserSettings settings) async {
    final cubit = context.read<UserSettingsCubit>();
    final apiKey = settings.lodgifyApiKey?.trim();
    final hasApiKey = apiKey?.isNotEmpty ?? false;
    final isServerStored =
        apiKey == _lodgifyServerStoredMarker ||
        apiKey == _legacyLodgifyServerStoredMarker;

    final result = await showLodgifyApiKeyModal(
      context,
      hasApiKey: hasApiKey,
      currentApiKey: isServerStored ? null : apiKey,
      resolveApiKey: isServerStored ? cubit.revealChannelApiKey : null,
    );
    if (result == null) return;
    cubit.updateLodgifyApiKey(result.apiKey, remove: result.remove);
  }
}

/// One row for the connection: what it does, when it last worked, and the one
/// button that makes it work again.
///
/// Stateful for the clock only — `timeago` renders a relative time, so the row
/// re-reads it every minute instead of aging silently while the page is open.
class _LodgifyConnectionTile extends StatefulWidget with StyledTileLike {
  const _LodgifyConnectionTile({required this.settings, required this.isBusy});

  final UserSettings settings;
  final bool isBusy;

  @override
  State<_LodgifyConnectionTile> createState() => _LodgifyConnectionTileState();
}

class _LodgifyConnectionTileState extends State<_LodgifyConnectionTile> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant _LodgifyConnectionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.lodgifyLastSyncedAt !=
        widget.settings.lodgifyLastSyncedAt) {
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
    if (widget.settings.lodgifyLastSyncedAt == null) return;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final isConnected = settings.lodgifyConnected;
    final hasApiKey = settings.lodgifyApiKey?.trim().isNotEmpty ?? false;
    final canAct = isConnected ? !widget.isBusy : hasApiKey && !widget.isBusy;

    return StyledTile(
      leading: StyledIconBadge.monogram(
        'LG',
        borderRadius: 10,
        backgroundColor: context.colors.secondary,
        iconColor: context.colors.onSecondary,
      ),
      title: context.s.lodgifyTitle,
      // What it brings across, and when it last did — the design's
      // `Boekingen, prijzen en beschikbaarheid · 6 dagen geleden`.
      subtitle:
          '${context.s.accountConnectionScope} · ${_syncLine(context, settings)}',
      value: isConnected
          ? StatusPill(
              label: context.s.connectionStatusConnected,
              tone: StatusPillTone.positive,
              icon: Icons.check,
            )
          : StatusPill(label: context.s.connectionStatusDisconnected),
      trailing: StyledButton.secondary(
        title: isConnected
            ? context.s.lodgifySyncLabel
            : context.s.connectLabel,
        size: StyledButtonSize.compact,
        enabled: canAct,
        showProgressIndicatorWhenDisabled: widget.isBusy,
        onPressed: canAct
            ? () {
                final cubit = context.read<UserSettingsCubit>();
                if (isConnected) {
                  cubit.syncLodgify();
                } else {
                  cubit.connectLodgify();
                }
              }
            : null,
      ),
    );
  }

  String _syncLine(BuildContext context, UserSettings settings) {
    final timestamp = settings.lodgifyLastSyncedAt;
    if (timestamp == null) return context.s.accountConnectionNeverSynced;
    return context.s.lodgifyLastSyncLabel(
      timeago.format(
        timestamp.toLocal(),
        locale: Localizations.localeOf(context).languageCode,
      ),
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
          leading: const StyledIconBadge(icon: Icons.workspace_premium_outlined),
          title: context.s.accountBillingPlan,
          subtitle: context.s.accountBillingPlanSubtitle(propertyCount),
          value: context.s.accountBillingPlanPro,
        ),
        StyledTile(
          leading: const StyledIconBadge(icon: Icons.credit_card_outlined),
          title: context.s.accountBillingPaymentMethod,
          value: notSetPlaceholder(context),
        ),
        StyledTile(
          leading: const StyledIconBadge(icon: Icons.receipt_long_outlined),
          title: context.s.accountBillingInvoices,
          value: context.s.accountBillingInvoicesValue,
        ),
        // StyledTextTile owns the text-editing state (controller, dirty
        // sync) itself and is already `StyledTileLike` — no bespoke
        // StatefulWidget wrapper, and no `with StyledTileLike` to remember.
        StyledTextTile(
          leading: const StyledIconBadge(icon: Icons.badge_outlined),
          title: context.s.accountBillingVatNumber,
          subtitle: context.s.accountBillingVatHint,
          value: state.settings.vatNumber,
          hintText: context.s.optionalPlaceholder,
          width: 170,
          enabled: state.canEdit,
          // Committed on submit rather than per keystroke: an account-level
          // write per character is a write per character.
          onSubmitted: (raw) => _saveVatNumber(context, state, raw),
        ),
      ],
    );
  }
}

void _saveVatNumber(
  BuildContext context,
  AccountChannelDefaultsState state,
  String raw,
) {
  final value = raw.trim();
  final stored = state.settings.vatNumber ?? '';
  if (value == stored) return;
  context.read<AccountChannelDefaultsCubit>().saveSettings(
    state.settings.copyWith(
      vatNumber: value.isEmpty ? null : value,
      clearVatNumber: value.isEmpty,
    ),
  );
}

class _AppInfoTile extends StatefulWidget with StyledTileLike {
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
    // A diagnostic row: it states the environment when there is one rather than
    // taking the page down with it when there is not.
    final environment =
        AppConfig.currentOrNull?.environment.name.toUpperCase() ?? '-';

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
    UserSettingsToastMessage.lodgifyConnectSuccess =>
      context.s.lodgifyConnectSuccess,
  };
}
