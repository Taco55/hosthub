import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/users/presentation/dialogs/create_user_dialog.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  bool _maintenanceMode = false;
  bool _emailUserOnCreate = true;

  ServerSettingsStatus _lastStatus = ServerSettingsStatus.initial;
  AdminSettings? _loadedSettings;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ServerSettingsCubit>();
    if (cubit.state.settings == null &&
        cubit.state.status != ServerSettingsStatus.loading &&
        cubit.state.status != ServerSettingsStatus.mutating) {
      cubit.load();
    }
  }

  void _syncLoadedSettings(AdminSettings settings) {
    _loadedSettings = settings;
    _maintenanceMode = settings.maintenanceModeEnabled;
    _emailUserOnCreate = settings.emailUserOnCreate;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServerSettingsCubit, ServerSettingsState>(
      listenWhen: (previous, current) =>
          previous.settings != current.settings ||
          previous.status != current.status ||
          previous.error != current.error,
      listener: (context, state) async {
        final settings = state.settings;
        if (settings != null && !identical(settings, _loadedSettings)) {
          setState(() => _syncLoadedSettings(settings));
        }

        if (state.status == ServerSettingsStatus.error && state.error != null) {
          final appError = AppError.fromDomain(context, state.error!);
          await showAppError(context, appError);
        } else if (_lastStatus == ServerSettingsStatus.mutating &&
            state.status == ServerSettingsStatus.ready) {
          showStyledToast(
            context,
            type: ToastificationType.success,
            description: context.s.settingsSaved,
          );
        }
        _lastStatus = state.status;
      },
      builder: (context, state) {
        final isInitialLoadInFlight =
            state.status == ServerSettingsStatus.loading &&
            state.settings == null;
        final settings = state.settings ?? AdminSettings.defaults();
        final isMutating = state.status == ServerSettingsStatus.mutating;
        final canSave = _canSave(state) && !isMutating;

        return StyledWebPageScaffold(
          // Design `.top`: the section crumb over the page's own subject.
          overline: context.s.adminSettingsTitle,
          title: context.s.serverSettingsTitle,
          intrinsicPaneHeight: true,
          primaryAction: StyledWebPageAction(
            label: context.s.saveButton,
            icon: Icons.save_outlined,
            enabled: canSave,
            inProgress: isMutating,
            onPressed: () => _save(context, settings),
          ),
          leftChild: isInitialLoadInFlight
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StyledSection(
                      isFirstSection: true,
                      header: 'Algemeen',
                      inset: false,
                      children: [
                        StyledTile(
                          title: context.s.maintenanceModeTitle,
                          subtitle: context.s.maintenanceModeDescription,
                          trailing: Switch(
                            value: _maintenanceMode,
                            onChanged:
                                state.status == ServerSettingsStatus.mutating
                                ? null
                                : (value) =>
                                      setState(() => _maintenanceMode = value),
                          ),
                        ),
                        StyledTile(
                          title: context.s.emailUserOnCreateTitle,
                          subtitle: context.s.emailUserOnCreateDescription,
                          trailing: Switch(
                            value: _emailUserOnCreate,
                            onChanged:
                                state.status == ServerSettingsStatus.mutating
                                ? null
                                : (value) => setState(
                                    () => _emailUserOnCreate = value,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Directly below the two switches it resets — it only
                    // touches the Algemeen section, nothing further down.
                    Align(
                      alignment: Alignment.centerLeft,
                      child: StyledButton(
                        title: context.s.restoreDefaults,
                        onPressed: state.status == ServerSettingsStatus.mutating
                            ? null
                            : _applyDefaults,
                        enabled: state.status != ServerSettingsStatus.mutating,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        labelColor: Theme.of(context).colorScheme.onError,
                        minHeight: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _UsersAdminSection(),
                  ],
                ),
        );
      },
    );
  }

  void _save(BuildContext context, AdminSettings current) {
    final updated = current.copyWith(
      maintenanceModeEnabled: _maintenanceMode,
      emailUserOnCreate: _emailUserOnCreate,
    );
    context.read<ServerSettingsCubit>().save(updated);
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

  void _applyDefaults() {
    final defaults = AdminSettings.defaults();
    setState(() {
      _maintenanceMode = defaults.maintenanceModeEnabled;
      _emailUserOnCreate = defaults.emailUserOnCreate;
    });
  }
}

class _UsersAdminSection extends StatefulWidget {
  const _UsersAdminSection();

  @override
  State<_UsersAdminSection> createState() => _UsersAdminSectionState();
}

class _UsersAdminSectionState extends State<_UsersAdminSection> {
  bool _isCreatingUser = false;

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
    final theme = Theme.of(context);

    return StyledSection(
      header: context.s.usersTitle,
      inset: false,
      children: [
        Text(
          '${context.s.createUserDescription} ${context.s.adminRightsDisabled}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: StyledButton(
            title: context.s.createUserButton,
            onPressed: _isCreatingUser ? null : _handleCreateUser,
            enabled: !_isCreatingUser,
            minHeight: 40,
            showLeftIcon: true,
            leftIconData: Icons.person_add_outlined,
          ),
        ),
      ],
    );
  }
}
