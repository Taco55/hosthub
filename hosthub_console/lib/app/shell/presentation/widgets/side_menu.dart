import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/features/properties/properties.dart';

import 'menu_item.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isAdmin = profile?.isAdmin ?? false;

    return Drawer(
      width: width,
      backgroundColor: colors.primaryContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MenuLogo(),
              _MenuHeader(profile: profile, onAccountTap: onAccountTap),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: BlocBuilder<PropertyContextCubit,
                            PropertyContextState>(
                          builder: (context, propertyState) {
                            final hasProperties = propertyState.status ==
                                    PropertyContextStatus.loaded &&
                                propertyState.properties.isNotEmpty;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _PropertySelector(),
                                if (hasProperties) ...[
                                  const SizedBox(height: 4),
                                  _DrawerListTile(
                                    label: context.s.detailsLabel,
                                    icon: Icons.home_work_outlined,
                                    selected: selectedItem ==
                                        MenuItem.propertyDetails,
                                    onTap: onPropertyDetailsTap,
                                  ),
                                  _DrawerListTile(
                                    label: context.s.sitesTitle,
                                    icon: Icons.web,
                                    selected: selectedItem == MenuItem.sites,
                                    onTap: () =>
                                        onItemSelected(MenuItem.sites),
                                  ),
                                  _DrawerListTile(
                                    label: context.s.reservations,
                                    icon: Icons.calendar_month_outlined,
                                    selected:
                                        selectedItem == MenuItem.reservations,
                                    onTap: () =>
                                        onItemSelected(MenuItem.reservations),
                                  ),
                                  _DrawerListTile(
                                    label: context.s.menuRevenue,
                                    icon: Icons.payments_outlined,
                                    selected:
                                        selectedItem == MenuItem.revenue,
                                    onTap: () =>
                                        onItemSelected(MenuItem.revenue),
                                  ),
                                  _DrawerListTile(
                                    label: context.s.menuPricing,
                                    icon: Icons.tune_outlined,
                                    selected:
                                        selectedItem == MenuItem.pricing,
                                    onTap: () =>
                                        onItemSelected(MenuItem.pricing),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 4),
                    _DrawerListTile(
                      label: context.s.adminSettingsTitle,
                      icon: Icons.settings_outlined,
                      selected: selectedItem == MenuItem.settings,
                      onTap: () => onItemSelected(MenuItem.settings),
                    ),
                    if (isAdmin)
                      _DrawerListTile(
                        label: context.s.serverSettingsTitle,
                        icon: Icons.admin_panel_settings_outlined,
                        selected: selectedItem == MenuItem.adminOptions,
                        onTap: () => onItemSelected(MenuItem.adminOptions),
                      ),
                    _DrawerListTile(
                      label: context.s.logoutLabel,
                      icon: Icons.logout,
                      selected: false,
                      onTap: onLogout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.profile, this.onAccountTap});

  final Profile? profile;
  final VoidCallback? onAccountTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final profile = this.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (profile != null)
          _ProfileSummary(profile: profile, onTap: onAccountTap)
        else
          Text(
            context.s.profileLoadingLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }
}

class _DrawerListTile extends StatelessWidget {
  const _DrawerListTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDisabled = onTap == null;
    final baseColor = colors.onPrimaryContainer;
    final backgroundColor = selected && !isDisabled
        ? baseColor.withValues(alpha: 0.12)
        : Colors.transparent;
    final foregroundColor = isDisabled
        ? baseColor.withValues(alpha: 0.5)
        : selected
        ? baseColor
        : baseColor.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: backgroundColor,
        dense: true,
        leading: Icon(icon, color: foregroundColor),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: foregroundColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.profile, this.onTap});

  final Profile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final displayName = (profile.username?.isNotEmpty ?? false)
        ? profile.username!
        : profile.email;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.onPrimaryContainer.withValues(alpha: 0.2),
            foregroundColor: colors.onPrimaryContainer,
            child: Text(
              _resolveInitial(profile),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MenuLogo extends StatelessWidget {
  const _MenuLogo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Hosthub',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _PropertySelector extends StatelessWidget {
  const _PropertySelector();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final isReady = state.status == PropertyContextStatus.loaded;
        final isDisabled = !isReady || state.properties.isEmpty;
        final label = () {
          if (state.status == PropertyContextStatus.loading) {
            return 'Loading properties...';
          }
          if (state.status == PropertyContextStatus.error) {
            return 'Properties unavailable';
          }
          return state.currentProperty?.name ?? 'Select property';
        }();
        final baseColor = colors.onPrimaryContainer;
        final foregroundColor = isDisabled
            ? baseColor.withValues(alpha: 0.5)
            : baseColor.withValues(alpha: 0.85);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            dense: true,
            hoverColor: colors.onPrimaryContainer.withValues(alpha: 0.12),
            title: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(
              Icons.swap_horiz_rounded,
              size: 20,
              color: foregroundColor,
            ),
            onTap: isDisabled
                ? null
                : () async {
                    final selected = await showSwitchPropertyDialog(
                      context,
                      properties: state.properties,
                      current: state.currentProperty,
                    );
                    if (selected == null || !context.mounted) return;
                    context.read<PropertyContextCubit>().selectProperty(
                      selected,
                    );
                  },
          ),
        );
      },
    );
  }
}

String _resolveInitial(Profile profile) {
  if (profile.email.isNotEmpty) {
    return profile.email.characters.first.toUpperCase();
  }
  if (profile.username?.isNotEmpty ?? false) {
    return profile.username!.characters.first.toUpperCase();
  }
  return '?';
}
