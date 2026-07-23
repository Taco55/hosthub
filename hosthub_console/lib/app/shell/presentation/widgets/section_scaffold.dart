import 'dart:math' as math;

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

class SectionScaffold extends StatefulWidget {
  const SectionScaffold({
    super.key,
    required this.selectedItem,
    required this.builder,
  });

  final MenuItem selectedItem;
  final Widget Function(BuildContext context, bool isPinned) builder;

  @override
  State<SectionScaffold> createState() => _SectionScaffoldState();
}

class _SectionScaffoldState extends State<SectionScaffold> {
  static const double _breakpoint = 1100;

  // Desktop hover flyout over the compact rail (mirrors the dashboard shell):
  // the expanded menu overlays the content, so nothing reflows.
  bool _hovering = false;
  // A switcher dropdown is open in the flyout; keep it from collapsing while
  // the pointer is over the (elevated) menu.
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isPinned =
        ResponsiveSideMenuScaffold.isPinned(context, _breakpoint);
    if (!isPinned) return _buildNarrow(context);
    return _buildDesktop(context);
  }

  // -- desktop: pinned rail + hover flyout ---------------------------------

  Widget _buildDesktop(BuildContext context) {
    final mode = context.watch<SidebarModeCubit>().state;
    final isCompact = mode == StyledSideMenuMode.compact;

    final expandedWidth = math.max(
      kSidebarExpandedMinWidth,
      MediaQuery.sizeOf(context).width * 0.2,
    );
    final railWidth = isCompact ? kSidebarCompactWidth : expandedWidth;

    if (!isCompact && _hovering) {
      // Keep state consistent if the mode flips while hovering.
      _hovering = false;
    }

    final scaffold = Scaffold(
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                onEnter: isCompact
                    ? (_) => setState(() => _hovering = true)
                    : null,
                child: SizedBox(
                  width: railWidth,
                  height: double.infinity,
                  child: _buildMenu(
                    context,
                    isPinned: true,
                    width: railWidth,
                    collapsed: isCompact,
                    // Pinned-expanded rail exposes the collapse toggle.
                    showModeToggle: !isCompact,
                  ),
                ),
              ),
              Expanded(child: _buildBody(context, isPinned: true)),
            ],
          ),
          if (isCompact && _hovering)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                onExit: (_) {
                  // Keep the flyout open while a switcher menu is open.
                  if (!_menuOpen) setState(() => _hovering = false);
                },
                child: Material(
                  elevation: 8,
                  child: SizedBox(
                    width: expandedWidth,
                    child: _buildMenu(
                      context,
                      isPinned: true,
                      width: expandedWidth,
                      collapsed: true,
                      expandedOverride: true,
                      showModeToggle: true,
                      onAnyItemSelected: () =>
                          setState(() => _hovering = false),
                      onMenuOpenChanged: (open) =>
                          setState(() => _menuOpen = open),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (kIsWeb) return scaffold;
    return SelectionArea(child: scaffold);
  }

  // -- narrow: drawer + hamburger (existing responsive behaviour) ----------

  Widget _buildNarrow(BuildContext context) {
    final scaffold = ResponsiveSideMenuScaffold(
      breakpoint: _breakpoint,
      menuWidth: kSidebarExpandedMinWidth,
      menuSafeArea: false,
      menuBuilder: (context, isPinned, closeDrawer) => _buildMenu(
        context,
        isPinned: isPinned,
        width: kSidebarExpandedMinWidth,
        closeDrawer: closeDrawer,
      ),
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
      bodyBuilder: (context, isPinned) => _buildBody(context, isPinned: isPinned),
    );

    if (kIsWeb) return scaffold;
    return SelectionArea(child: scaffold);
  }

  // -- shared menu/body construction ---------------------------------------

  Widget _buildMenu(
    BuildContext context, {
    required bool isPinned,
    required double width,
    bool collapsed = false,
    bool showModeToggle = false,
    bool? expandedOverride,
    VoidCallback? onAnyItemSelected,
    ValueChanged<bool>? onMenuOpenChanged,
    VoidCallback? closeDrawer,
  }) {
    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileCubit>().state;
    final guard = context.read<NavigationGuardController>();

    return SideMenu(
      width: width,
      collapsed: collapsed,
      showModeToggle: showModeToggle,
      expandedOverride: expandedOverride,
      onAnyItemSelected: onAnyItemSelected,
      onMenuOpenChanged: onMenuOpenChanged,
      profile: profileState.profile,
      selectedItem: widget.selectedItem,
      onItemSelected: (item) {
        if (item == widget.selectedItem) return;
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
        if (!isPinned) closeDrawer?.call();
        if (!context.mounted) return;
        GoRouter.of(context).go('/properties/details');
      },
      onLogout: authState.status == AuthStatus.authenticated
          ? () {
              if (!isPinned) closeDrawer?.call();
              context.read<AuthBloc>().add(const AuthEvent.logout());
            }
          : null,
      onAccountTap: profileState.profile == null
          ? null
          : () {
              if (!isPinned) closeDrawer?.call();
              _handleAccountTap(context, profileState.profile!);
            },
    );
  }

  Widget _buildBody(BuildContext context, {required bool isPinned}) {
    final propertyState = context.watch<PropertyContextCubit>().state;
    final shouldForcePropertySetup =
        propertyState.status == PropertyContextStatus.loaded &&
            propertyState.properties.isEmpty &&
            widget.selectedItem != MenuItem.settings &&
            widget.selectedItem != MenuItem.adminOptions;
    if (shouldForcePropertySetup) {
      return const PropertySetupPage();
    }
    return widget.builder(context, isPinned);
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
