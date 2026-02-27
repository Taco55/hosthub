import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/properties/properties.dart';
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
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.s.serverSettingsSubtitle,
                                    style: Theme.of(context).textTheme.bodyLarge
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
                              subtitle: context.s.emailUserOnCreateDescription,
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
                        const _UsersAdminSection(),
                        const SizedBox(height: 16),
                        const _ListingsAdminSection(),
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
      grouped: false,
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

class _ListingsAdminSection extends StatefulWidget {
  const _ListingsAdminSection();

  @override
  State<_ListingsAdminSection> createState() => _ListingsAdminSectionState();
}

class _ListingsAdminSectionState extends State<_ListingsAdminSection> {
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;
  int? _deletingPropertyId;

  bool get _isMutating => _isCreating || _deletingPropertyId != null;

  bool get _canCreate => !_isMutating && _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);

    final cubit = context.read<PropertyContextCubit>();
    if (cubit.state.status == PropertyContextStatus.initial) {
      cubit.loadProperties();
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _createProperty() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isMutating) return;

    setState(() => _isCreating = true);
    try {
      await context.read<PropertyRepository>().createProperty(name: name);
      if (!mounted) return;
      _nameController.clear();
      await context.read<PropertyContextCubit>().loadProperties();
      if (!mounted) return;
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: 'Listing "$name" toegevoegd.',
      );
    } catch (error, stack) {
      if (!mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _deleteProperty(PropertySummary property) async {
    if (_isMutating) return;
    final shouldDelete = await _confirmDelete(property);
    if (!mounted || !shouldDelete) return;

    setState(() => _deletingPropertyId = property.id);
    try {
      await context.read<PropertyRepository>().deleteProperty(property.id);
      if (!mounted) return;
      await context.read<PropertyContextCubit>().loadProperties();
      if (!mounted) return;
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: 'Listing "${property.name}" verwijderd.',
      );
    } catch (error, stack) {
      if (!mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    } finally {
      if (mounted) {
        setState(() => _deletingPropertyId = null);
      }
    }
  }

  Future<bool> _confirmDelete(PropertySummary property) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Listing verwijderen'),
          content: Text(
            'Weet je zeker dat je "${property.name}" wilt verwijderen?',
          ),
          actions: [
            StyledButton(
              title: context.s.cancelButton,
              onPressed: () => Navigator.of(context).pop(false),
              minHeight: 40,
            ),
            StyledButton(
              title: context.s.deleteButton,
              onPressed: () => Navigator.of(context).pop(true),
              minHeight: 40,
              backgroundColor: Theme.of(context).colorScheme.error,
              labelColor: Theme.of(context).colorScheme.onError,
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StyledSection(
      header: 'Listings',
      grouped: false,
      children: [
        Text(
          'Voeg handmatig een listing toe of verwijder listings om een nieuwe website-opzet te testen zonder Lodgify-sync.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final field = StyledFormField(
              controller: _nameController,
              label: context.s.propertySetupManualNameLabel,
              placeholder: context.s.propertySetupManualNameLabel,
              enabled: !_isMutating,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (_canCreate) _createProperty();
              },
            );
            final button = StyledButton(
              title: context.s.propertySetupManualButton,
              onPressed: _canCreate ? _createProperty : null,
              enabled: _canCreate,
              minHeight: 44,
              leftIconData: _isCreating ? null : Icons.add,
              showLeftIcon: !_isCreating,
              showProgressIndicatorWhenDisabled: _isCreating,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [field, const SizedBox(height: 8), button],
              );
            }

            return Row(
              children: [
                Expanded(child: field),
                const SizedBox(width: 12),
                button,
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<PropertyContextCubit, PropertyContextState>(
          builder: (context, state) {
            final properties = state.properties;
            final isLoading =
                state.status == PropertyContextStatus.loading &&
                properties.isEmpty;

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.status == PropertyContextStatus.error &&
                properties.isEmpty) {
              return Text(
                'Kon listings niet laden.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              );
            }

            return StyledDataTable(
              variant: StyledTableVariant.card,
              dense: true,
              uppercaseHeaderLabels: false,
              columns: const [
                StyledDataColumn(
                  columnHeaderLabel: 'ID',
                  flex: 1,
                  minWidth: 64,
                ),
                StyledDataColumn(
                  columnHeaderLabel: 'Naam',
                  flex: 3,
                  minWidth: 220,
                ),
                StyledDataColumn(
                  columnHeaderLabel: 'Lodgify ID',
                  flex: 2,
                  minWidth: 180,
                ),
                StyledDataColumn(
                  columnHeaderLabel: 'Acties',
                  flex: 2,
                  minWidth: 140,
                ),
              ],
              itemCount: properties.length,
              rowBuilder: (tableContext, index) {
                final property = properties[index];
                final lodgifyId = property.lodgifyId?.trim();
                final isDeleting = _deletingPropertyId == property.id;
                final canDelete = !_isMutating || isDeleting;

                return [
                  Text(
                    property.id.toString(),
                    style: Theme.of(tableContext).textTheme.bodyMedium,
                  ),
                  Text(
                    property.name,
                    style: Theme.of(tableContext).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lodgifyId == null || lodgifyId.isEmpty ? '-' : lodgifyId,
                    style: Theme.of(tableContext).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StyledButton(
                      title: context.s.deleteButton,
                      onPressed: canDelete && !isDeleting
                          ? () => _deleteProperty(property)
                          : null,
                      enabled: canDelete && !isDeleting,
                      showProgressIndicatorWhenDisabled: isDeleting,
                      minHeight: 36,
                      minWidth: 104,
                      backgroundColor: theme.colorScheme.error,
                      labelColor: theme.colorScheme.onError,
                    ),
                  ),
                ];
              },
              emptyLabel: 'Nog geen listings gevonden.',
            );
          },
        ),
      ],
    );
  }
}
