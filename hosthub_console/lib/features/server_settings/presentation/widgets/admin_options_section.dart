import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/create_user_dialog.dart';

/// Server-wide configuration, rendered as the admin-only section at the bottom
/// of Settings.
///
/// It used to be a page of its own behind a rail row; folded into Settings it
/// keeps admin scope visible as *scope* instead of as a destination — hence the
/// badge and the subheader, which say out loud that these rows are not account
/// data and affect the whole environment.
///
/// Renders nothing for a non-admin. Save feedback (toast, error) belongs to the
/// enclosing page, which owns it for every [ServerSettingsCubit] save on the
/// page — this section only reads state and dispatches.
class AdminOptionsSection extends StatefulWidget {
  const AdminOptionsSection({super.key});

  @override
  State<AdminOptionsSection> createState() => _AdminOptionsSectionState();
}

class _AdminOptionsSectionState extends State<AdminOptionsSection> {
  bool _maintenanceMode = false;
  bool _emailUserOnCreate = true;

  /// The last settings the drafts were seeded from — the baseline `_canSave`
  /// compares against, so an unchanged form cannot save.
  AdminSettings? _loadedSettings;

  bool _isCreatingUser = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ServerSettingsCubit>();
    final settings = cubit.state.settings;
    if (settings != null) {
      _syncLoadedSettings(settings);
    } else if (cubit.state.status != ServerSettingsStatus.loading &&
        cubit.state.status != ServerSettingsStatus.mutating) {
      cubit.load();
    }
  }

  void _syncLoadedSettings(AdminSettings settings) {
    _loadedSettings = settings;
    _maintenanceMode = settings.maintenanceModeEnabled;
    _emailUserOnCreate = settings.emailUserOnCreate;
  }

  bool _canSave(ServerSettingsState state) {
    if (state.status == ServerSettingsStatus.mutating ||
        state.status == ServerSettingsStatus.loading) {
      return false;
    }
    final base = _loadedSettings;
    if (base == null) return false;
    return _maintenanceMode != base.maintenanceModeEnabled ||
        _emailUserOnCreate != base.emailUserOnCreate;
  }

  void _save(AdminSettings current) {
    context.read<ServerSettingsCubit>().save(
      current.copyWith(
        maintenanceModeEnabled: _maintenanceMode,
        emailUserOnCreate: _emailUserOnCreate,
      ),
    );
  }

  void _applyDefaults() {
    final defaults = AdminSettings.defaults();
    setState(() {
      _maintenanceMode = defaults.maintenanceModeEnabled;
      _emailUserOnCreate = defaults.emailUserOnCreate;
    });
  }

  Future<void> _handleCreateUser() async {
    if (_isCreatingUser) return;

    setState(() => _isCreatingUser = true);
    try {
      final created = await showCreateUserDialog(context);
      if (!mounted || created != true) return;

      showStyledToast(
        context,
        type: ToastificationType.success,
        description:
            '${context.s.userCreated} ${context.s.adminRightsDisabled}',
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingUser = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServerSettingsCubit, ServerSettingsState>(
      listenWhen: (previous, current) => previous.settings != current.settings,
      listener: (context, state) {
        final settings = state.settings;
        if (settings != null && !identical(settings, _loadedSettings)) {
          setState(() => _syncLoadedSettings(settings));
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == ServerSettingsStatus.loading &&
            state.settings == null;
        final settings = state.settings ?? AdminSettings.defaults();
        final isMutating = state.status == ServerSettingsStatus.mutating;
        final canSave = _canSave(state);

        return StyledSection(
          header: context.s.serverSettingsTitle,
          headerAction: StyledChip(
            label: context.s.adminOnlyBadge,
            leading: Icon(
              Icons.admin_panel_settings_outlined,
              size: 16,
              color: context.colors.primary,
            ),
            backgroundColor: context.colors.surface,
            borderColor: context.colors.primaryContainer,
            labelColor: context.colors.primary,
          ),
          subheader: context.s.adminOptionsSectionSubtitle,
          horizontalPadding: 0,
          children: isLoading
              ? const [Center(child: CircularProgressIndicator())]
              : [
                  StyledSwitchTile(
                    title: context.s.maintenanceModeTitle,
                    subtitle: context.s.maintenanceModeDescription,
                    value: _maintenanceMode,
                    enabled: !isMutating,
                    onChanged: (value) =>
                        setState(() => _maintenanceMode = value),
                  ),
                  StyledSwitchTile(
                    title: context.s.emailUserOnCreateTitle,
                    subtitle: context.s.emailUserOnCreateDescription,
                    value: _emailUserOnCreate,
                    enabled: !isMutating,
                    onChanged: (value) =>
                        setState(() => _emailUserOnCreate = value),
                  ),
                  // Directly below the two switches, because that is all the
                  // pair of buttons touches: the create-user row underneath
                  // acts on its own.
                  Row(
                    children: [
                      StyledButton(
                        title: context.s.saveButton,
                        onPressed: canSave ? () => _save(settings) : null,
                        enabled: canSave,
                        showProgressIndicatorWhenDisabled: isMutating,
                        leftIconData: isMutating ? null : Icons.save_outlined,
                        showLeftIcon: !isMutating,
                      ),
                      const SizedBox(width: 12),
                      // Secondary, not red: this only refills the two switches
                      // with their defaults. Nothing is written until Save is
                      // pressed beside it, so there is nothing to warn about —
                      // and a red fill here made the reversible button look
                      // more dangerous than the one that actually saves.
                      StyledButton.secondary(
                        title: context.s.restoreDefaults,
                        onPressed: isMutating ? null : _applyDefaults,
                        enabled: !isMutating,
                      ),
                    ],
                  ),
                  StyledTile(
                    leading: const Icon(Icons.person_add_outlined),
                    title: context.s.createUserTitle,
                    subtitle:
                        '${context.s.createUserDescription} '
                        '${context.s.adminRightsDisabled}',
                    trailing: StyledButton(
                      title: context.s.createUserButton,
                      onPressed: _isCreatingUser ? null : _handleCreateUser,
                      enabled: !_isCreatingUser,
                      showProgressIndicatorWhenDisabled: _isCreatingUser,
                    ),
                  ),
                ],
        );
      },
    );
  }
}
