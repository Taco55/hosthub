import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import '../../application/sidebar_mode_cubit.dart';
import '../../application/site_context_cubit.dart';
import 'menu_item.dart';

/// The console navigation rail, composed from the shared [StyledSideMenu],
/// mirroring the dashboard rail design: logo header with pin/collapse toggle,
/// primary nav items (Website, Reservations, Revenue, Pricing), the Property
/// and Source-language switchers pinned at the bottom as ice dropdown fields,
/// then the profile tile, logout and a version footer. In the compact 96px
/// rail only the icons remain; the desktop shell overlays the expanded menu
/// while hovering.
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
          switchers: [
            _PropertySwitcher(onMenuOpenChanged: onMenuOpenChanged),
            _SourceLanguageSwitcher(onMenuOpenChanged: onMenuOpenChanged),
          ],
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

// ---------------------------------------------------------------------------
// Switchers — ice dropdown fields backed by StyledMenuOverlay in both states
// (the icon stays rail-aligned; expanding only reveals the field).
// ---------------------------------------------------------------------------

Widget _switcherIconBox(BuildContext context, IconData icon,
    {required bool enabled}) {
  final scope = StyledSideMenuScope.of(context);
  final fg = scope.foregroundColor.withValues(alpha: enabled ? 1.0 : 0.5);
  return SizedBox(
    width: scope.iconBox,
    height: scope.iconBox,
    child: Center(child: Icon(icon, size: scope.iconSize, color: fg)),
  );
}

Widget _switcherField(
  BuildContext context, {
  required String value,
  required bool enabled,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final fg =
      colorScheme.onPrimaryContainer.withValues(alpha: enabled ? 1.0 : 0.5);
  return Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: colorScheme.primaryContainer,
      border: Border.all(
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.24),
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
          ),
        ),
        Icon(Icons.unfold_more, size: 18, color: fg),
      ],
    ),
  );
}

Widget _switcherOverlay<T>({
  required BuildContext context,
  required IconData icon,
  required bool enabled,
  required String tooltip,
  required String value,
  required List<StyledMenuOverlayEntry<T>> entries,
  required T? selectedValue,
  required ValueChanged<T> onSelected,
  ValueChanged<bool>? onOpenChanged,
}) {
  final scope = StyledSideMenuScope.of(context);
  final collapsed = !scope.expanded;
  final iconBox = _switcherIconBox(context, icon, enabled: enabled);
  final child = collapsed
      ? iconBox
      : Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconBox,
            const SizedBox(width: 4),
            Expanded(
              child: _switcherField(context, value: value, enabled: enabled),
            ),
          ],
        );

  final overlay = StyledMenuOverlay<T>(
    entries: entries,
    selectedValue: selectedValue,
    showSelectionIndicator: true,
    enabled: enabled,
    onSelected: onSelected,
    onOpenChanged: onOpenChanged,
    tooltip: collapsed ? tooltip : null,
    child: child,
  );

  return collapsed
      ? Align(alignment: Alignment.centerLeft, child: overlay)
      : overlay;
}

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

        return _switcherOverlay<PropertySummary>(
          context: context,
          icon: Icons.apartment_outlined,
          enabled: enabled,
          tooltip: context.s.propertySelectorSelect,
          value: label,
          entries: [
            for (final property in state.properties)
              StyledMenuOverlayEntry(value: property, label: property.name),
          ],
          selectedValue: state.currentProperty,
          onSelected: (property) =>
              context.read<PropertyContextCubit>().selectProperty(property),
          onOpenChanged: onMenuOpenChanged,
        );
      },
    );
  }
}

class _SourceLanguageSwitcher extends StatelessWidget {
  const _SourceLanguageSwitcher({this.onMenuOpenChanged});

  final ValueChanged<bool>? onMenuOpenChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteContextCubit, SiteContextState>(
      builder: (context, state) {
        final site = state.site;
        final enabled = site != null && site.locales.length > 1;
        final value = site == null
            ? context.s.sourceLanguageUnavailable
            : _languageName(context, site.defaultLocale);

        return _switcherOverlay<String>(
          context: context,
          icon: Icons.translate,
          enabled: enabled,
          tooltip: context.s.sourceLanguageLabel,
          value: value,
          entries: [
            for (final locale in site?.locales ?? const <String>[])
              StyledMenuOverlayEntry(
                value: locale,
                label: _languageName(context, locale),
              ),
          ],
          selectedValue: site?.defaultLocale,
          onSelected: (locale) =>
              context.read<SiteContextCubit>().setSourceLanguage(locale),
          onOpenChanged: onMenuOpenChanged,
        );
      },
    );
  }

  static String _languageName(BuildContext context, String code) {
    final s = context.s;
    switch (code) {
      case 'nl':
        return s.weLangDutch;
      case 'en':
        return s.weLangEnglish;
      case 'no':
      case 'nb':
        return s.weLangNorwegian;
      default:
        return code.toUpperCase();
    }
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
    final fg = scope?.foregroundColor ??
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
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: fg, fontWeight: FontWeight.w700),
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
    final fg = (scope?.foregroundColor ??
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
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: fg),
            ),
          ),
        );
      },
    );
  }
}
