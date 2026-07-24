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
/// lives on the Settings page. In the compact 96px rail only the icons remain;
/// the desktop shell overlays the expanded menu while hovering.
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
    this.onMenuOpenChanged,
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

  /// Forces the expanded visual state (used by the hover flyout).
  final bool? expandedOverride;

  /// Extra callback after any nav selection (the flyout closes itself).
  final VoidCallback? onAnyItemSelected;

  /// Reports switcher dropdowns opening/closing (keeps the flyout open).
  final ValueChanged<bool>? onMenuOpenChanged;

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
          expandedMinWidth: width ?? kSidebarExpandedMinWidth,
          compactWidth: kSidebarCompactWidth,
          expandOnHoverWhenCompact: false,
          onModeChanged: showModeToggle
              ? (mode) => context.read<SidebarModeCubit>().setMode(mode)
              : null,
          pinTooltip: s.sidebarPinTooltip,
          collapseTooltip: s.sidebarCollapseTooltip,
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
          ],
          switchers: [_PropertySwitcher(onMenuOpenChanged: onMenuOpenChanged)],
          profile: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileTile(profile: profile, onTap: onAccountTap),
              StyledSideMenuTile(
                icon: Icons.settings_outlined,
                label: s.adminSettingsTitle,
                selected: selectedItem == MenuItem.settings,
                onTap: () => select(MenuItem.settings),
              ),
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

/// Shared rail geometry, matching the design (96px compact rail; expanded
/// menu is at least this wide and grows with the viewport in the shell).
const double kSidebarCompactWidth = 96;
const double kSidebarExpandedMinWidth = 320;

/// Leading icon-box width shared by every row (StyledSideMenu's default).
const double kSidebarIconBox = 44;

/// Horizontal inset that centres the icon box in the compact rail. Applied to
/// the switcher too so the Property tile lines up with the nav icons.
const double kSidebarSideInset = (kSidebarCompactWidth - kSidebarIconBox) / 2;

// ---------------------------------------------------------------------------
// Property switcher — a rail-aligned context tile backed by StyledMenuOverlay.
// It borrows StyledSideMenuTile's geometry (icon box + label + chevron) so it
// reads as part of the menu rather than a form field dropped into it; the
// compact rail keeps just the icon.
// ---------------------------------------------------------------------------

class _PropertySwitcher extends StatelessWidget {
  const _PropertySwitcher({this.onMenuOpenChanged});

  final ValueChanged<bool>? onMenuOpenChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final isReady = state.status == PropertyContextStatus.loaded;
        final enabled = isReady && state.properties.isNotEmpty;
        final label = () {
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

        final scope = StyledSideMenuScope.of(context);
        final collapsed = !scope.expanded;

        final overlay = StyledMenuOverlay<PropertySummary>(
          entries: [
            for (final property in state.properties)
              StyledMenuOverlayEntry(value: property, label: property.name),
          ],
          selectedValue: state.currentProperty,
          showSelectionIndicator: true,
          enabled: enabled,
          onSelected: (property) =>
              context.read<PropertyContextCubit>().selectProperty(property),
          onOpenChanged: onMenuOpenChanged,
          tooltip: collapsed ? context.s.propertySelectorSelect : null,
          child: _PropertySwitcherTile(
            icon: Icons.apartment_outlined,
            label: label,
            enabled: enabled,
            collapsed: collapsed,
          ),
        );

        return collapsed
            ? Align(alignment: Alignment.centerLeft, child: overlay)
            : overlay;
      },
    );
  }
}

/// The switcher's visual anchor. Mirrors [StyledSideMenuTile] — a rounded,
/// foreground-tinted row with the icon in the shared icon box — but without an
/// own tap handler, so the enclosing [StyledMenuOverlay] owns the gesture. The
/// compact rail collapses it to just the icon box.
class _PropertySwitcherTile extends StatefulWidget {
  const _PropertySwitcherTile({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.collapsed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool collapsed;

  @override
  State<_PropertySwitcherTile> createState() => _PropertySwitcherTileState();
}

class _PropertySwitcherTileState extends State<_PropertySwitcherTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scope = StyledSideMenuScope.of(context);
    final baseFg = scope.foregroundColor;
    final fg = baseFg.withValues(alpha: widget.enabled ? 1.0 : 0.5);

    final iconBox = SizedBox(
      width: scope.iconBox,
      height: scope.tileHeight,
      child: Center(
        child: Icon(widget.icon, size: scope.iconSize, color: fg),
      ),
    );

    if (widget.collapsed) {
      return iconBox;
    }

    final bgAlpha = widget.enabled && _hovering ? 0.16 : 0.08;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: scope.tileHeight,
        decoration: BoxDecoration(
          color: baseFg.withValues(alpha: bgAlpha),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            iconBox,
            Expanded(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 12),
              child: Icon(Icons.unfold_more, size: 18, color: fg),
            ),
          ],
        ),
      ),
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

class _MenuLogo extends StatelessWidget {
  const _MenuLogo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = StyledSideMenuScope.maybeOf(context);
    final expanded = scope?.expanded ?? true;
    if (!expanded) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        context.s.appTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
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
