import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

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
        final horizontalPadding = MediaQuery.sizeOf(context).width >= 1400
            ? 48.0
            : 24.0;
        final isMutating = state.status == ServerSettingsStatus.mutating;
        final canSave = _canSave(state) && !isMutating;

        return ConsolePageScaffold(
          title: context.s.serverSettingsTitle,
          description: context.s.serverSettingsSubtitle,
          leftChild: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: isInitialLoadInFlight
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.s.serverSettingsTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.s.serverSettingsSubtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            StyledButton(
                              title: context.s.saveButton,
                              onPressed: canSave
                                  ? () => _save(context, settings)
                                  : null,
                              enabled: canSave,
                              showProgressIndicatorWhenDisabled: isMutating,
                              leftIconData: isMutating
                                  ? null
                                  : Icons.save_outlined,
                              showLeftIcon: !isMutating,
                              minHeight: 44,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        StyledSection(
                          isFirstSection: true,
                          header: 'Algemeen',
                          grouped: false,
                          children: [
                            StyledTile(
                              title: context.s.maintenanceModeTitle,
                              subtitle: context.s.maintenanceModeDescription,
                              trailing: Switch(
                                value: _maintenanceMode,
                                onChanged:
                                    state.status ==
                                        ServerSettingsStatus.mutating
                                    ? null
                                    : (value) => setState(
                                        () => _maintenanceMode = value,
                                      ),
                              ),
                            ),
                            StyledTile(
                              title: context.s.emailUserOnCreateTitle,
                              subtitle:
                                  context.s.emailUserOnCreateDescription,
                              trailing: Switch(
                                value: _emailUserOnCreate,
                                onChanged:
                                    state.status ==
                                        ServerSettingsStatus.mutating
                                    ? null
                                    : (value) => setState(
                                        () => _emailUserOnCreate = value,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: StyledButton(
                            title: context.s.restoreDefaults,
                            onPressed:
                                state.status == ServerSettingsStatus.mutating
                                ? null
                                : _applyDefaults,
                            enabled:
                                state.status != ServerSettingsStatus.mutating,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            labelColor: Theme.of(context).colorScheme.onError,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
            ),
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
