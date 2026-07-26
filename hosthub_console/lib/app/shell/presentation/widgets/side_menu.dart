import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';

import '../../application/sidebar_mode_cubit.dart';
import '../../navigation/navigation_guard_controller.dart';
import '../dialogs/own_profile_dialog.dart';
import 'console_nav_tree.dart';
import 'menu_item.dart';

/// The console navigation rail, composed from the shared [StyledSideMenu]: logo
/// header with pin/collapse toggle, then the navigation **tree** — Portfolio
/// (Boekingen, Omzet), the account's properties each holding their four
/// sections, and Account — then the profile tile, logout and a version footer.
///
/// The tree replaces the old flat nav plus property switcher: the sidebar is the
/// scope selector now, so there is nowhere else to say which property you mean.
/// Which property renders expanded is derived from the route
/// ([ConsoleRoute.propertyId]), never stored, so a deep link arrives correct.
///
/// Everything responsive comes from the enclosing [StyledSideMenuScaffold]
/// through its [StyledSideMenuPlacement] — which width this copy renders at,
/// whether a pin toggle has anywhere to go, how the rail reaches its labels,
/// and closing the overlay or drawer once a destination is chosen. This widget
/// only says what is in the menu and what tapping it does; the rail geometry
/// lives in `HosthubThemePreset`.
class SideMenu extends StatelessWidget {
  const SideMenu({super.key, required this.selectedItem, required this.route});

  final MenuItem selectedItem;

  /// Where the console is. The tree's expansion and selection come from here.
  final ConsoleRoute route;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final authState = context.watch<AuthBloc>().state;
    final profile = context.watch<ProfileCubit>().state.profile;
    final isAdmin = profile?.isAdmin ?? false;
    // Account-wide channel defaults, for the Prijzen override badges. Absent
    // while the settings are still loading, which reads as "no overrides" —
    // the badge appearing a moment later is better than a wrong count.
    final adminSettings =
        context.watch<ServerSettingsCubit>().state.settings ??
        AdminSettings.defaults();

    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, propertyState) {
        final properties = propertyState.properties;
        final isSingleProperty = properties.length == 1;
        final channelSettings = ChannelSettingsResolver.forProperties(
          accountDefaults: AccountChannelDefaults.fromCommissionPercentages(
            booking: adminSettings.bookingChannelFeePercentage,
            airbnb: adminSettings.airbnbChannelFeePercentage,
            other: adminSettings.otherChannelFeePercentage,
          ),
          properties: channelOverridesOf(properties),
        );

        return StyledSideMenu(
          // §7's rail geometry. The icon box is fixed and the side inset is the
          // nav's own padding, which together put every icon centre at
          // `kSidebarSideInset + kSidebarIconBox / 2` = 34px from the rail's
          // left edge — in both states, because neither value changes with the
          // width.
          iconBox: kSidebarIconBox,
          sideInset: kSidebarSideInset,
          tileHeight: kSidebarTopLevelRowHeight,
          branchTileHeight: kSidebarPropertyRowHeight,
          // A one-property account renders its property's sections flat at the
          // top level (§5), so they take the top-level icon box and no indent —
          // still the child row's own height and radius.
          childTileHeight: isSingleProperty
              ? kSidebarFlatSubItemRowHeight
              : kSidebarSubItemRowHeight,
          childIconBox: isSingleProperty
              ? kSidebarIconBox
              : kSidebarSubItemIconBox,
          childIndent: isSingleProperty ? 0 : kSidebarSubItemIndent,
          headerHeight: kSidebarHeaderHeight,
          onModeChanged: (mode) =>
              context.read<SidebarModeCubit>().setMode(mode),
          pinTooltip: s.sidebarPinTooltip,
          collapseTooltip: s.sidebarCollapseTooltip,
          expandTooltip: s.sidebarExpandTooltip,
          showSwitchersWhenCompact: true,
          showProfileWhenCompact: true,
          showFooterWhenCompact: true,
          header: const _MenuLogo(),
          groups: buildConsoleNavGroups(
            s: s,
            route: route,
            properties: consoleNavProperties(
              properties: properties,
              channelSettings: channelSettings,
            ),
            onNavigate: (path) => _go(context, path),
          ),
          profile: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileTile(
                profile: profile,
                onTap: profile == null
                    ? null
                    : () => showOwnProfileDialog(context, profile: profile),
              ),
              if (isAdmin)
                StyledSideMenuTile(
                  icon: Icons.admin_panel_settings_outlined,
                  label: s.serverSettingsTitle,
                  selected: selectedItem == MenuItem.adminOptions,
                  onTap: () => _select(context, MenuItem.adminOptions),
                ),
              StyledSideMenuTile(
                icon: Icons.logout,
                label: s.logoutLabel,
                onTap: authState.status == AuthStatus.authenticated
                    ? () =>
                          context.read<AuthBloc>().add(const AuthEvent.logout())
                    : null,
              ),
            ],
          ),
          footer: const _VersionFooter(),
        );
      },
    );
  }

  /// Navigation always passes the guard first, so a page with unsaved work can
  /// stop it. The row itself has already closed the rail overlay or the drawer.
  Future<void> _go(BuildContext context, String path) async {
    final router = GoRouter.of(context);
    if (router.state.uri.path == path) return;
    if (!await context.read<NavigationGuardController>().canNavigateAway()) {
      return;
    }
    router.go(path);
  }

  Future<void> _select(BuildContext context, MenuItem item) =>
      _go(context, _pathOf(item));

  String _pathOf(MenuItem item) => switch (item) {
    MenuItem.sites => '/sites',
    MenuItem.reservations => ConsoleRoute.bookingsPath,
    MenuItem.revenue => ConsoleRoute.revenuePath,
    MenuItem.settings => ConsoleRoute.accountPath,
    MenuItem.adminOptions => '/admin-options',
    MenuItem.pricing => ConsoleRoute.propertiesPath,
    MenuItem.propertyDetails => ConsoleRoute.propertiesPath,
  };
}

/// Leading icon-box width shared by every row (§7: a fixed 44px box).
///
/// Fixed is the point: the box does not change with the rail's width, so an icon
/// lands on the same x whether the rail is 72 or 284 wide.
const double kSidebarIconBox = 44;

/// The nav's own horizontal padding (§7: `6px 12px`).
///
/// With [kSidebarIconBox] this is what puts every icon centre at 34px from the
/// rail's left edge. Derived from the rail width instead, it would drift the
/// moment either width changed.
const double kSidebarSideInset = 12;

/// How long the pointer rests on the collapsed rail before it expands (§7).
const Duration kSidebarHoverIntentDelay = Duration(milliseconds: 350);

/// Row heights (§7): a top-level destination, a property, a sub-item.
const double kSidebarTopLevelRowHeight = 48;
const double kSidebarPropertyRowHeight = 42;
const double kSidebarSubItemRowHeight = 36;

/// A sub-item rendered flat at the top level, in a one-property account.
const double kSidebarFlatSubItemRowHeight = 44;

/// Sub-item indent and icon box (§7: 16 + 32).
///
/// The two are chosen together: `12 + 16 + 32 = 60` stays inside the 72px
/// collapsed rail, so an active sub-item's background cannot spill onto the page.
const double kSidebarSubItemIndent = 16;
const double kSidebarSubItemIconBox = 32;

/// Header block height, identical in both states (design: 72px).
const double kSidebarHeaderHeight = 72;

// ---------------------------------------------------------------------------
// Profile / logo / footer slots
// ---------------------------------------------------------------------------

/// Profile row with the same geometry as the nav tiles: avatar in the icon
/// box, display name as the label.
class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile, this.onTap});

  final Profile? profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scope = StyledSideMenuScope.maybeOf(context);
    final fg =
        scope?.foregroundColor ??
        Theme.of(context).colorScheme.onPrimaryContainer;
    final profile = this.profile;

    if (profile == null) {
      return StyledSideMenuTile(
        icon: Icons.person_outline,
        label: context.s.profileLoadingLabel,
        onTap: null,
      );
    }

    final displayName = (profile.username?.isNotEmpty ?? false)
        ? profile.username!
        : profile.email;

    return StyledSideMenuTile(
      leading: CircleAvatar(
        radius: (scope?.iconSize ?? 22) * 0.75,
        backgroundColor: fg.withValues(alpha: 0.2),
        foregroundColor: fg,
        child: Text(
          _resolveInitial(profile),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      label: displayName,
      onTap: onTap,
    );
  }
}

String _resolveInitial(Profile profile) {
  final source = (profile.username?.isNotEmpty ?? false)
      ? profile.username!
      : profile.email;
  return source.isEmpty ? '?' : source.characters.first.toUpperCase();
}

/// Brand header: the mark plus the wordmark when expanded, the mark alone —
/// centred — on the compact rail, where it doubles as the tap-to-expand target
/// (the shell wires `onExpandRequested`).
class _MenuLogo extends StatelessWidget {
  const _MenuLogo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = StyledSideMenuScope.maybeOf(context);
    final expanded = scope?.expanded ?? true;

    final mark = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        Icons.holiday_village_outlined,
        size: 20,
        color: theme.colorScheme.onPrimary,
      ),
    );

    // The same icon column the nav rows use, so the mark sits on the one
    // vertical axis the design asks for — and, because the column and the inset
    // are the same in both states, it does not move when the rail collapses.
    //
    // It used to centre itself across the compact rail instead. That happened to
    // land on the same centre while the inset was half the leftover width; §7's
    // 12px inset made it 2px off, which the rail geometry test caught.
    final iconColumn = SizedBox(
      width: scope?.iconBox ?? kSidebarIconBox,
      child: Center(child: mark),
    );

    if (!expanded) {
      // The compact header is full-bleed, so the row supplies the inset the
      // expanded header would have given it.
      return Padding(
        padding: EdgeInsets.only(left: scope?.sideInset ?? kSidebarSideInset),
        child: Align(alignment: Alignment.centerLeft, child: iconColumn),
      );
    }

    return Row(
      children: [
        iconColumn,
        Expanded(
          child: Text(
            context.s.appTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Version footer: right-aligned when expanded, centered on the compact rail
/// (per the design; the compact rail drops the alignment luxury, not the info).
class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    final scope = StyledSideMenuScope.maybeOf(context);
    final expanded = scope?.expanded ?? true;
    final fg =
        (scope?.foregroundColor ??
                Theme.of(context).colorScheme.onPrimaryContainer)
            .withValues(alpha: 0.6);

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        if (version == null || version.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: expanded ? Alignment.centerRight : Alignment.center,
            child: Text(
              context.s.versionFooter(version),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: fg),
            ),
          ),
        );
      },
    );
  }
}
