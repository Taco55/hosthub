import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app_errors/app_errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/users/users.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/change_user_password_dialog.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/edit_user_profile_dialog.dart';
import 'package:hosthub_console/app/shell/presentation/dialogs/admin_account_actions_dialog.dart';
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
      case MenuItem.calendar:
        router.go('/calendar');
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
    final action = await showAdminAccountActionsDialog(
      context,
      profile: profile,
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case AdminAccountAction.editDetails:
        await _editAccountDetails(context, profile);
        break;
      case AdminAccountAction.changePassword:
        await _changePassword(context, profile);
        break;
    }
  }

  Future<void> _editAccountDetails(
    BuildContext context,
    Profile profile,
  ) async {
    final result = await showEditUserProfileDialog(
      context,
      currentEmail: profile.email,
      currentUsername: profile.username,
    );
    if (result == null || !context.mounted) return;

    final repository = context.read<AdminUserRepository>();

    try {
      final updated = await repository.updateProfileDetails(
        profile.id,
        email: result.email,
        username: result.username,
      );
      if (!context.mounted) return;
      context.read<ProfileCubit>().updateProfile(updated);
      _showToast(context, context.s.userUpdated, ToastificationType.success);
    } catch (error, stack) {
      if (!context.mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    }
  }

  Future<void> _changePassword(BuildContext context, Profile profile) async {
    final password = await showChangeUserPasswordDialog(context);
    if (password == null || password.isEmpty || !context.mounted) return;

    final repository = context.read<AdminUserRepository>();

    try {
      await repository.updatePassword(profile.id, password);
      if (!context.mounted) return;
      _showToast(
        context,
        context.s.passwordChanged,
        ToastificationType.success,
      );
    } catch (error, stack) {
      if (!context.mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    }
  }

  void _showToast(
    BuildContext context,
    String message,
    ToastificationType type,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    showStyledToast(
      context,
      type: type,
      description: message,
      backgroundColor: colors.surfaceContainerHighest,
    );
  }
}
