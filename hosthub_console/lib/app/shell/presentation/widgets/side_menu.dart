import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import '../../application/sidebar_mode_cubit.dart';
import '../../navigation/navigation_guard_controller.dart';
import '../dialogs/own_profile_dialog.dart';
import 'menu_item.dart';

/// The console navigation rail, composed from the shared [StyledSideMenu]:
/// logo header with pin/collapse toggle, primary nav items (Website,
/// Reservations, Revenue, Pricing), the Property switcher pinned at the bottom
/// as a rail-aligned context tile, then the profile tile, logout and a version
/// footer. The source-language selector lives on the Settings page.
///
/// Everything responsive comes from the enclosing [StyledSideMenuScaffold]
/// through its [StyledSideMenuPlacement] — which width this copy renders at,
/// whether a pin toggle has anywhere to go, how the rail reaches its labels,
/// and closing the overlay or drawer once a destination is chosen. This widget
/// only says what is in the menu and what tapping it does; the rail geometry
/// lives in `HosthubThemePreset`.
class SideMenu extends StatelessWidget {
  const SideMenu({super.key, required this.selectedItem});

  final MenuItem selectedItem;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final authState = context.watch<AuthBloc>().state;
    final profile = context.watch<ProfileCubit>().state.profile;
    final isAdmin = profile?.isAdmin ?? false;

    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, propertyState) {
        final hasProperties =
            propertyState.status == PropertyContextStatus.loaded &&
            propertyState.properties.isNotEmpty;

        return StyledSideMenu(
          iconBox: kSidebarIconBox,
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
          items: [
            if (hasProperties) ...[
              StyledNavItem(
                icon: Icons.home_work_outlined,
                label: s.detailsLabel,
                selected: selectedItem == MenuItem.propertyDetails,
                onTap: () => _select(context, MenuItem.propertyDetails),
              ),
              StyledNavItem(
                icon: Icons.language,
                label: s.sitesTitle,
                selected: selectedItem == MenuItem.sites,
                onTap: () => _select(context, MenuItem.sites),
              ),
              StyledNavItem(
                icon: Icons.calendar_today,
                label: s.reservations,
                selected: selectedItem == MenuItem.reservations,
                onTap: () => _select(context, MenuItem.reservations),
              ),
              StyledNavItem(
                icon: Icons.show_chart,
                label: s.menuRevenue,
                selected: selectedItem == MenuItem.revenue,
                onTap: () => _select(context, MenuItem.revenue),
              ),
              StyledNavItem(
                icon: Icons.sell_outlined,
                label: s.menuPricing,
                selected: selectedItem == MenuItem.pricing,
                onTap: () => _select(context, MenuItem.pricing),
              ),
            ],
            // Settings is a primary destination (design §5); personal
            // preferences live in the profile modal, not here.
            StyledNavItem(
              icon: Icons.settings_outlined,
              label: s.adminSettingsTitle,
              selected: selectedItem == MenuItem.settings,
              onTap: () => _select(context, MenuItem.settings),
            ),
          ],
          switchers: const [_PropertySwitcher()],
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
                    ? () => context.read<AuthBloc>().add(
                        const AuthEvent.logout(),
                      )
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
  Future<void> _select(BuildContext context, MenuItem item) async {
    if (item == selectedItem) return;
    final router = GoRouter.of(context);
    if (!await context.read<NavigationGuardController>().canNavigateAway()) {
      return;
    }
    router.go(_pathOf(item));
  }

  String _pathOf(MenuItem item) => switch (item) {
    MenuItem.sites => '/sites',
    MenuItem.reservations => '/reservations',
    MenuItem.revenue => '/revenue',
    MenuItem.settings => '/settings',
    MenuItem.adminOptions => '/admin-options',
    MenuItem.pricing => '/properties/pricing',
    MenuItem.propertyDetails => '/properties/details',
  };
}

/// Leading icon-box width shared by every row.
const double kSidebarIconBox = 48;

/// Header block height, identical in both states (design: 72px).
const double kSidebarHeaderHeight = 72;

// ---------------------------------------------------------------------------
// Property switcher — the shared ice dropdown field (design `.swf`): rail
// icon + bordered field with the uppercase PROPERTY label above the current
// property name. Icon-only on the compact rail.
// ---------------------------------------------------------------------------

class _PropertySwitcher extends StatelessWidget {
  const _PropertySwitcher();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final isReady = state.status == PropertyContextStatus.loaded;
        final enabled = isReady && state.properties.isNotEmpty;
        final value = () {
          if (state.status == PropertyContextStatus.loading) {
            return context.s.propertySelectorLoading;
          }
          if (state.status == PropertyContextStatus.error) {
            return context.s.propertySelectorUnavailable;
          }
          if (state.properties.isEmpty) {
            return context.s.propertySelectorEmpty;
          }
          return state.currentProperty?.name ??
              context.s.propertySelectorSelect;
        }();

        return StyledSideMenuSwitcher<PropertySummary>(
          icon: Icons.apartment_outlined,
          label: context.s.propertySwitcherLabel,
          value: value,
          enabled: enabled,
          tooltip: context.s.propertySelectorSelect,
          entries: [
            for (final property in state.properties)
              StyledMenuOverlayEntry(value: property, label: property.name),
          ],
          selectedValue: state.currentProperty,
          onSelected: (property) =>
              context.read<PropertyContextCubit>().selectProperty(property),
        );
      },
    );
  }
}

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

    if (!expanded) return Center(child: mark);

    return Row(
      children: [
        mark,
        const SizedBox(width: 11),
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
