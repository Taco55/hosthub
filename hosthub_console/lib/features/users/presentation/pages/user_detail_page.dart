import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hosthub_console/core/models/models.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/users/application/admin_user_detail_cubit.dart';
import 'package:hosthub_console/features/users/domain/models/admin_user_detail.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/change_user_password_dialog.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/delete_user_confirmation_dialog.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/edit_user_profile_dialog.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/user_management_actions_dialog.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/user_settings_dialog.dart';
import 'package:hosthub_console/features/users/presentation/widgets/profile_info_row.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, required this.userId});

  final String userId;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  AppError? _lastShownError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.s;
    return BlocBuilder<AdminUserDetailCubit, AdminUserDetailState>(
      builder: (context, state) {
        return _buildBody(context, theme, l10n, state);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    S l10n,
    AdminUserDetailState state,
  ) {
    final detail = state.detail;
    final isLoading = state.isLoading;
    final error = state.appError;
    if (error == null) {
      _lastShownError = null;
    } else if (detail == null) {
      _maybeShowError(error);
    }
    final profile = detail?.profile;
    final title = profile?.email ?? context.s.usersTitle;
    final description = (profile?.username?.isNotEmpty ?? false)
        ? profile!.username!
        : context.s.usersSubtitle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 1400 ? 48.0 : 24.0;

        Widget content;
        if (isLoading && detail == null) {
          content = const Center(child: CircularProgressIndicator());
        } else if (detail == null) {
          content = Center(
            child: Text(error?.alert ?? context.s.loadUserFailedMessage),
          );
        } else {
          content = SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StyledButton(
                      title: context.s.manageUserAction,
                      onPressed: state.isMutating
                          ? null
                          : () => _openManagementActions(detail),
                      enabled: !state.isMutating,
                      leftIconData: Icons.manage_accounts_outlined,
                      showLeftIcon: true,
                      minHeight: 40,
                    ),
                    StyledButton(
                      title: context.s.userSettingsAction,
                      onPressed: () => _showUserSettings(detail),
                      leftIconData: Icons.tune_outlined,
                      showLeftIcon: true,
                      minHeight: 40,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      labelColor: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileCard(context, theme, detail, l10n, state),
                const SizedBox(height: 16),
                _buildAppsCard(theme, detail, l10n),
                const SizedBox(height: 16),
              ],
            ),
          );
        }

        return ConsolePageScaffold(
          title: title,
          description: description,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          onBack: () async {
            context.go('/users');
            return true;
          },
          leftChild: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(padding: const EdgeInsets.all(24), child: content),
          ),
        );
      },
    );
  }

  void _maybeShowError(AppError appError) {
    if (_lastShownError == appError) return;
    _lastShownError = appError;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showAppError(context, appError);
    });
  }

  Widget _buildProfileCard(
    BuildContext context,
    ThemeData theme,
    AdminUserDetail detail,
    S l10n,
    AdminUserDetailState state,
  ) {
    final colors = theme.colorScheme;
    final profile = detail.profile;
    final profileError = state.appError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              child: Text(
                _profileInitial(profile),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.email, style: theme.textTheme.headlineSmall),
                  if (profile.username?.isNotEmpty ?? false)
                    Text(
                      profile.username!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.s.refreshTooltip,
              onPressed: state.isLoading
                  ? null
                  : () => context.read<AdminUserDetailCubit>().refresh(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: profile.isAdmin,
          title: Text(context.s.adminRightsTitle),
          subtitle: Text(context.s.adminRightsDescription),
          onChanged: state.isToggling ? null : (value) => _toggleAdmin(value),
          secondary: state.isToggling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        if (profileError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              profileError.alert,
              style: TextStyle(color: colors.error),
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        ProfileInfoRow(label: context.s.userIdLabel, value: profile.id),
        ProfileInfoRow(label: context.s.emailLabel, value: profile.email),
        if (profile.username?.isNotEmpty ?? false)
          ProfileInfoRow(
            label: context.s.usernameLabel,
            value: profile.username!,
          ),
      ],
    );
  }

  Widget _buildAppsCard(ThemeData theme, AdminUserDetail detail, S l10n) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apps_outlined),
                const SizedBox(width: 8),
                Text(context.s.appsTitle, style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAdmin(bool value) async {
    final cubit = context.read<AdminUserDetailCubit>();
    final success = await cubit.toggleAdmin(value);
    if (!mounted) return;
    if (success) {
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: value
            ? context.s.adminRightsEnabled
            : context.s.adminRightsDisabled,
        dismissAllBeforeShowing: true,
      );
      return;
    }
    await _showErrorDialog(
      context,
      appError: cubit.state.appError,
      fallbackMessage: context.s.updateAdminRightsFailed,
    );
  }

  Future<void> _showUserSettings(AdminUserDetail detail) {
    return showUserSettingsDialog(context, profile: detail.profile);
  }

  Future<void> _openManagementActions(AdminUserDetail detail) async {
    final action = await showUserManagementActionsDialog(context);
    if (action == null) return;
    switch (action) {
      case UserManagementAction.editProfile:
        await _handleEditProfile(detail);
        break;
      case UserManagementAction.changePassword:
        await _handleChangePassword(detail);
        break;
      case UserManagementAction.deleteUser:
        await _handleDeleteUser(detail);
        break;
    }
  }

  String _profileInitial(Profile profile) {
    if (profile.email.isNotEmpty) return profile.email[0].toUpperCase();
    if (profile.username?.isNotEmpty ?? false) {
      return profile.username![0].toUpperCase();
    }
    return '?';
  }

  Future<void> _handleEditProfile(AdminUserDetail detail) async {
    final cubit = context.read<AdminUserDetailCubit>();
    final result = await showEditUserProfileDialog(
      context,
      currentEmail: detail.profile.email,
      currentUsername: detail.profile.username,
    );
    if (result == null) return;
    final success = await cubit.updateProfile(
      email: result.email,
      username: result.username,
    );
    if (!mounted) return;
    if (success) {
      _showToast(context, context.s.userUpdated, ToastificationType.success);
    } else {
      await _showErrorDialog(
        context,
        appError: cubit.state.appError,
        fallbackMessage: context.s.userUpdateFailed,
      );
    }
  }

  Future<void> _handleChangePassword(AdminUserDetail detail) async {
    final cubit = context.read<AdminUserDetailCubit>();
    final password = await showChangeUserPasswordDialog(context);
    if (password == null || password.isEmpty) return;
    final success = await cubit.changePassword(password);
    if (!mounted) return;
    if (success) {
      _showToast(
        context,
        context.s.passwordChanged,
        ToastificationType.success,
      );
    } else {
      await _showErrorDialog(
        context,
        appError: cubit.state.appError,
        fallbackMessage: context.s.passwordChangeFailed,
      );
    }
  }

  Future<void> _handleDeleteUser(AdminUserDetail detail) async {
    final cubit = context.read<AdminUserDetailCubit>();
    final confirmed = await showDeleteUserConfirmationDialog(
      context,
      email: detail.profile.email,
    );
    if (!confirmed) return;
    final success = await cubit.deleteUser();
    if (!mounted) return;
    if (success) {
      _showToast(context, context.s.userDeleted, ToastificationType.success);
      context.go('/users');
    } else {
      await _showErrorDialog(
        context,
        appError: cubit.state.appError,
        fallbackMessage: context.s.userDeleteFailed,
      );
    }
  }

  void _showToast(
    BuildContext context,
    String message,
    ToastificationType type,
  ) {
    showStyledToast(
      context,
      description: message,
      type: type,
      dismissAllBeforeShowing: true,
    );
  }

  Future<void> _showErrorDialog(
    BuildContext context, {
    AppError? appError,
    String? fallbackMessage,
  }) async {
    final effectiveError =
        appError ??
        AppError.custom(
          title: context.s.error,
          alert: fallbackMessage ?? context.s.anUnknownErrorOccurred,
        );
    await showAppError(context, effectiveError);
  }
}
