import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import 'menu_item.dart';

/// The console navigation rail, composed from the shared [StyledSideMenu]:
/// logo header, primary nav items, the property switcher, and a bottom block
/// (profile, settings, admin, logout) built from [StyledSideMenuTile]s so all
/// rows share the same geometry. The shell renders it pinned (wide screens)
/// or inside a drawer; it always shows the expanded state.
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
  });

  final double? width;
  final Profile? profile;
  final MenuItem selectedItem;
  final ValueChanged<MenuItem> onItemSelected;
  final VoidCallback? onLogout;
  final VoidCallback? onPropertyDetailsTap;
  final VoidCallback? onAccountTap;

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile?.isAdmin ?? false;
    final s = context.s;

    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, propertyState) {
        final hasProperties =
            propertyState.status == PropertyContextStatus.loaded &&
                propertyState.properties.isNotEmpty;

        return StyledSideMenu(
          mode: StyledSideMenuMode.expanded,
          expandedMinWidth: width ?? 320,
          expandOnHoverWhenCompact: false,
          header: const _MenuLogo(),
          items: [
            if (hasProperties) ...[
              StyledNavItem(
                icon: Icons.home_work_outlined,
                label: s.detailsLabel,
                selected: selectedItem == MenuItem.propertyDetails,
                onTap: onPropertyDetailsTap,
              ),
              StyledNavItem(
                icon: Icons.web,
                label: s.sitesTitle,
                selected: selectedItem == MenuItem.sites,
                onTap: () => onItemSelected(MenuItem.sites),
              ),
              StyledNavItem(
                icon: Icons.calendar_month_outlined,
                label: s.reservations,
                selected: selectedItem == MenuItem.reservations,
                onTap: () => onItemSelected(MenuItem.reservations),
              ),
              StyledNavItem(
                icon: Icons.payments_outlined,
                label: s.menuRevenue,
                selected: selectedItem == MenuItem.revenue,
                onTap: () => onItemSelected(MenuItem.revenue),
              ),
              StyledNavItem(
                icon: Icons.tune_outlined,
                label: s.menuPricing,
                selected: selectedItem == MenuItem.pricing,
                onTap: () => onItemSelected(MenuItem.pricing),
              ),
            ],
          ],
          switchers: const [_PropertySelector()],
          profile: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileTile(profile: profile, onTap: onAccountTap),
              StyledSideMenuTile(
                icon: Icons.settings_outlined,
                label: s.adminSettingsTitle,
                selected: selectedItem == MenuItem.settings,
                onTap: () => onItemSelected(MenuItem.settings),
              ),
              if (isAdmin)
                StyledSideMenuTile(
                  icon: Icons.admin_panel_settings_outlined,
                  label: s.serverSettingsTitle,
                  selected: selectedItem == MenuItem.adminOptions,
                  onTap: () => onItemSelected(MenuItem.adminOptions),
                ),
              StyledSideMenuTile(
                icon: Icons.logout,
                label: s.logoutLabel,
                onTap: onLogout,
              ),
            ],
          ),
        );
      },
    );
  }
}

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

/// Property context switcher, rendered as a styled dropdown field in the
/// switcher slot.
class _PropertySelector extends StatelessWidget {
  const _PropertySelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final isReady = state.status == PropertyContextStatus.loaded;
        final isDisabled = !isReady || state.properties.isEmpty;
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

        return StyledSideMenuTile(
          icon: Icons.apartment_outlined,
          label: label,
          onTap: isDisabled
              ? null
              : () async {
                  final selected = await showSwitchPropertyDialog(
                    context,
                    properties: state.properties,
                    current: state.currentProperty,
                  );
                  if (selected == null || !context.mounted) return;
                  context
                      .read<PropertyContextCubit>()
                      .selectProperty(selected);
                },
        );
      },
    );
  }
}
