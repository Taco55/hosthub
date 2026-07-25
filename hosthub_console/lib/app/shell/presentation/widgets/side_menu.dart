import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import '../../application/sidebar_mode_cubit.dart';
import 'menu_item.dart';

/// The console navigation rail, composed from the shared [StyledSideMenu],
/// mirroring the dashboard rail design: logo header with pin/collapse toggle,
/// primary nav items (Website, Reservations, Revenue, Pricing), the Property
/// switcher pinned at the bottom as a rail-aligned context tile, then the
/// profile tile, logout and a version footer. The source-language selector
/// lives on the Settings page. In the compact 72px rail only the icons remain;
/// hovering a row shows its label beside it, and tapping the rail header asks
/// the shell to overlay the expanded menu — the route that also works on touch,
/// where hover does not exist.
class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    this.width,
    required this.profile,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onLogout,
    this.onPropertyDetailsTap,
    this.onAccountTap,
    this.collapsed = false,
    this.showModeToggle = false,
    this.expandedOverride,
    this.onAnyItemSelected,
    this.onExpandRequested,
  });

  final double? width;
  final Profile? profile;
  final MenuItem selectedItem;
  final ValueChanged<MenuItem> onItemSelected;
  final VoidCallback? onLogout;
  final VoidCallback? onPropertyDetailsTap;
  final VoidCallback? onAccountTap;

  /// Renders the compact icon rail.
  final bool collapsed;

  /// Shows the pin/collapse toggle in the header.
  final bool showModeToggle;

  /// Forces the expanded visual state (used by the shell's rail overlay).
  final bool? expandedOverride;

  /// Extra callback after any nav selection (closes the rail overlay).
  final VoidCallback? onAnyItemSelected;

  /// Tap on the compact rail's header: asks the shell to expand the rail over
  /// the content. The only route to the labels on touch, where hover — and so
  /// the per-row label flyout — does not exist.
  final VoidCallback? onExpandRequested;

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile?.isAdmin ?? false;
    final s = context.s;

    void select(MenuItem item) {
      onAnyItemSelected?.call();
      onItemSelected(item);
    }

    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, propertyState) {
        final hasProperties =
            propertyState.status == PropertyContextStatus.loaded &&
            propertyState.properties.isNotEmpty;

        return StyledSideMenu(
          mode: collapsed
              ? StyledSideMenuMode.compact
              : StyledSideMenuMode.expanded,
          expandedOverride: expandedOverride,
          expandedMinWidth: width ?? kSidebarExpandedWidth,
          compactWidth: kSidebarCompactWidth,
          iconBox: kSidebarIconBox,
          headerHeight: kSidebarHeaderHeight,
          expandOnHoverWhenCompact: false,
          // Labels sit beside the icon on the rail (design §"Label-toegang"),
          // not below it where they would collide with the next row.
          compactLabels: StyledSideMenuCompactLabels.flyout,
          onCompactHeaderTap: onExpandRequested,
          onModeChanged: showModeToggle
              ? (mode) => context.read<SidebarModeCubit>().setMode(mode)
              : null,
          pinTooltip: s.sidebarPinTooltip,
          collapseTooltip: s.sidebarCollapseTooltip,
          expandTooltip: s.sidebarExpandTooltip,
          showSwitchersWhenCompact: true,
          showProfileWhenCompact: true,
          showFooterWhenCompact: true,
          switcherPadding: const EdgeInsets.symmetric(
            horizontal: kSidebarSideInset,
            vertical: 4,
          ),
          header: const _MenuLogo(),
          items: [
            if (hasProperties) ...[
              StyledNavItem(
                icon: Icons.home_work_outlined,
                label: s.detailsLabel,
                selected: selectedItem == MenuItem.propertyDetails,
                onTap: onPropertyDetailsTap == null
                    ? null
                    : () {
                        onAnyItemSelected?.call();
                        onPropertyDetailsTap!.call();
                      },
              ),
              StyledNavItem(
                icon: Icons.language,
                label: s.sitesTitle,
                selected: selectedItem == MenuItem.sites,
                onTap: () => select(MenuItem.sites),
              ),
              StyledNavItem(
                icon: Icons.calendar_today,
                label: s.reservations,
                selected: selectedItem == MenuItem.reservations,
                onTap: () => select(MenuItem.reservations),
              ),
              StyledNavItem(
                icon: Icons.show_chart,
                label: s.menuRevenue,
                selected: selectedItem == MenuItem.revenue,
                onTap: () => select(MenuItem.revenue),
              ),
              StyledNavItem(
                icon: Icons.sell_outlined,
                label: s.menuPricing,
                selected: selectedItem == MenuItem.pricing,
                onTap: () => select(MenuItem.pricing),
              ),
            ],
            // Settings is a primary destination (design §5); personal
            // preferences live in the profile modal, not here.
            StyledNavItem(
              icon: Icons.settings_outlined,
              label: s.adminSettingsTitle,
              selected: selectedItem == MenuItem.settings,
              onTap: () => select(MenuItem.settings),
            ),
          ],
          switchers: const [_PropertySwitcher()],
          profile: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileTile(profile: profile, onTap: onAccountTap),
              if (isAdmin)
                StyledSideMenuTile(
                  icon: Icons.admin_panel_settings_outlined,
                  label: s.serverSettingsTitle,
                  selected: selectedItem == MenuItem.adminOptions,
                  onTap: () => select(MenuItem.adminOptions),
                ),
              StyledSideMenuTile(
                icon: Icons.logout,
                label: s.logoutLabel,
                onTap: onLogout,
              ),
            ],
          ),
          footer: const _VersionFooter(),
        );
      },
    );
  }
}

/// Shared rail geometry: a 72px compact rail and a 284px expanded menu. The
/// design draws the rail at 96px (`.sb2.compact`), but 96 costs the page
/// content ~24px between 600 and 1100px and only buys empty space around the
/// 48px rows — a deliberate deviation, reviewed against the design on
/// 2026-07-24.
const double kSidebarCompactWidth = 72;
const double kSidebarExpandedWidth = 284;

/// Leading icon-box width shared by every row.
const double kSidebarIconBox = 48;

/// Header block height, identical in both states (design: 72px).
const double kSidebarHeaderHeight = 72;

/// Horizontal row inset, 12px in both modes (design `.sb2-nav{padding:6px 12px}`,
/// which `.sb2.compact` does not override, and `(72 - 48) / 2` in the rail), so
/// the icons keep their x position when the menu expands and sit centred in the
/// rail. Applied to the switcher too so the Property tile lines up with the nav
/// icons.
const double kSidebarSideInset = (kSidebarCompactWidth - kSidebarIconBox) / 2;

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
