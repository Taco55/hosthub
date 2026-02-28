import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/app/shell/presentation/dialogs/own_profile_dialog.dart';
import 'package:hosthub_console/app/shell/navigation/navigation_guard_controller.dart';
import 'menu_item.dart';
import 'side_menu.dart';

class SectionScaffold extends StatelessWidget {
  const SectionScaffold({
    super.key,
    required this.selectedItem,
    required this.builder,
  });

  final MenuItem selectedItem;
  final Widget Function(BuildContext context, bool isPinned) builder;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileCubit>().state;
    const menuWidth = 320.0;

    final scaffold = ResponsiveSideMenuScaffold(
      breakpoint: 1100,
      menuWidth: menuWidth,
      menuSafeArea: false,
      menuBuilder: (context, isPinned, closeDrawer) {
        final guard = context.read<NavigationGuardController>();
        return SideMenu(
          width: menuWidth,
          profile: profileState.profile,
          selectedItem: selectedItem,
          onItemSelected: (item) {
            if (item == selectedItem) return;
            _confirmAndNavigate(
              context,
              guard,
              item,
              isPinned: isPinned,
              closeDrawer: closeDrawer,
            );
          },
          onPropertyDetailsTap: () async {
            if (!await guard.canNavigateAway()) return;
            if (!isPinned) closeDrawer();
            GoRouter.of(context).go('/properties/details');
          },
          onLogout: authState.status == AuthStatus.authenticated
              ? () {
                  if (!isPinned) closeDrawer();
                  context.read<AuthBloc>().add(const AuthEvent.logout());
                }
              : null,
          onAccountTap: profileState.profile == null
              ? null
              : () {
                  if (!isPinned) closeDrawer();
                  _handleAccountTap(context, profileState.profile!);
                },
        );
      },
      appBarBuilder: (context, isPinned, openDrawer) {
        if (isPinned) return null;
        return AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: context.s.menuTooltip,
            icon: const Icon(Icons.menu),
            onPressed: openDrawer,
          ),
        );
      },
      bodyBuilder: (context, isPinned) {
        final propertyState = context.watch<PropertyContextCubit>().state;
        final shouldForcePropertySetup =
            propertyState.status == PropertyContextStatus.loaded &&
            propertyState.properties.isEmpty &&
            selectedItem != MenuItem.settings &&
            selectedItem != MenuItem.adminOptions;
        if (shouldForcePropertySetup) {
          return const PropertySetupPage();
        }
        return builder(context, isPinned);
      },
    );

    if (kIsWeb) return scaffold;

    return SelectionArea(child: scaffold);
  }

  void _navigate(GoRouter router, MenuItem item) {
    switch (item) {
      case MenuItem.sites:
        router.go('/sites');
        break;
      case MenuItem.reservations:
        router.go('/reservations');
        break;
      case MenuItem.revenue:
        router.go('/revenue');
        break;
      case MenuItem.settings:
        router.go('/settings');
        break;
      case MenuItem.adminOptions:
        router.go('/admin-options');
        break;
      case MenuItem.pricing:
        router.go('/properties/pricing');
        break;
      case MenuItem.propertyDetails:
        router.go('/properties/details');
        break;
    }
  }

  Future<void> _confirmAndNavigate(
    BuildContext context,
    NavigationGuardController guard,
    MenuItem item, {
    required bool isPinned,
    VoidCallback? closeDrawer,
  }) async {
    final router = GoRouter.of(context);
    if (!await guard.canNavigateAway()) return;
    if (!isPinned) closeDrawer?.call();
    _navigate(router, item);
  }

  Future<void> _handleAccountTap(BuildContext context, Profile profile) async {
    await showOwnProfileDialog(context, profile: profile);
  }

}
