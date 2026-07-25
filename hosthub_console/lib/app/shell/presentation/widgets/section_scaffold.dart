
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/app/shell/presentation/dialogs/own_profile_dialog.dart';
import 'package:hosthub_console/app/shell/navigation/navigation_guard_controller.dart';
import '../../application/sidebar_mode_cubit.dart';
import 'menu_item.dart';
import 'side_menu.dart';

/// The console section shell: the shared [StyledSideMenuScaffold] wired to the
/// console's [SideMenu] and the guarded navigation it triggers.
class SectionScaffold extends StatelessWidget {
  const SectionScaffold({
    super.key,
    required this.selectedItem,
    required this.builder,
  });

  final MenuItem selectedItem;
  final Widget Function(BuildContext context, bool isPinned) builder;

  /// Three-band responsive strategy (design §"Responsieve strategie"): the full
  /// menu from 1100px, the pinned 72px icon rail down to 600px — no hamburger,
  /// navigation stays visible — and only below that the hamburger drawer. The
  /// shared [StyledSideMenuScaffold] owns the layout, the rail overlay and the
  /// drawer; this widget only supplies the console's menu and body.
  static const StyledSideMenuBreakpoints _breakpoints =
      StyledSideMenuBreakpoints(expandedMin: 1100, railMin: 600);

  @override
  Widget build(BuildContext context) {
    final scaffold = StyledSideMenuScaffold(
      breakpoints: _breakpoints,
      // The pin preference only applies where both widths fit.
      compact:
          context.watch<SidebarModeCubit>().state ==
          StyledSideMenuMode.compact,
      expandedWidth: kSidebarExpandedWidth,
      railWidth: kSidebarCompactWidth,
      appBarBuilder: (context, openDrawer) => AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        leading: Center(
          child: StyledToolbarButton(
            iconData: Icons.menu,
            tooltip: context.s.menuTooltip,
            onPressed: openDrawer,
          ),
        ),
      ),
      menuBuilder: _buildMenu,
      bodyBuilder: (context, form) =>
          _buildBody(context, isPinned: form.isPinned),
    );

    if (kIsWeb) return scaffold;
    return SelectionArea(child: scaffold);
  }

  // -- shared menu/body construction ---------------------------------------

  Widget _buildMenu(BuildContext context, StyledSideMenuPlacement placement) {
    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileCubit>().state;
    final guard = context.read<NavigationGuardController>();

    final dismiss = placement.dismiss;

    return SideMenu(
      width: placement.width,
      collapsed: placement.collapsed,
      // The pinned expanded menu and the rail overlay offer the pin toggle;
      // in the forced rail band there is no other width to switch to.
      showModeToggle: placement.canChangeMode && !placement.isDrawer,
      expandedOverride: placement.expandedOverride,
      onAnyItemSelected: dismiss,
      onExpandRequested: placement.requestExpand,
      profile: profileState.profile,
      selectedItem: selectedItem,
      onItemSelected: (item) {
        if (item == selectedItem) return;
        _confirmAndNavigate(context, guard, item, dismiss: dismiss);
      },
      onPropertyDetailsTap: () async {
        if (!await guard.canNavigateAway()) return;
        dismiss?.call();
        if (!context.mounted) return;
        GoRouter.of(context).go('/properties/details');
      },
      onLogout: authState.status == AuthStatus.authenticated
          ? () {
              dismiss?.call();
              context.read<AuthBloc>().add(const AuthEvent.logout());
            }
          : null,
      onAccountTap: profileState.profile == null
          ? null
          : () {
              dismiss?.call();
              _handleAccountTap(context, profileState.profile!);
            },
    );
  }

  Widget _buildBody(BuildContext context, {required bool isPinned}) {
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
    VoidCallback? dismiss,
  }) async {
    final router = GoRouter.of(context);
    if (!await guard.canNavigateAway()) return;
    dismiss?.call();
    _navigate(router, item);
  }

  Future<void> _handleAccountTap(BuildContext context, Profile profile) async {
    await showOwnProfileDialog(context, profile: profile);
  }
}
