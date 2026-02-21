import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';
import 'package:hosthub_console/shared/domain/channel_manager/models/models.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';
import 'package:app_errors/app_errors.dart';

class PropertySetupPage extends StatelessWidget {
  const PropertySetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.channelPropertiesToReview !=
                  current.channelPropertiesToReview &&
              current.channelPropertiesToReview != null,
          listener: (context, state) async {
            final lodgifyProperties = state.channelPropertiesToReview;
            if (lodgifyProperties == null) return;
            final missing = state.missingPropertiesToConfirm ?? const [];
            final shouldAdd = await _showMissingPropertiesDialog(
              context,
              lodgifyProperties: lodgifyProperties,
              missing: missing,
            );
            if (!context.mounted) return;
            if (missing.isEmpty) {
              if (shouldAdd) {
                await context.read<UserSettingsCubit>().confirmLodgifySync();
              } else {
                context.read<UserSettingsCubit>().skipMissingProperties();
              }
              return;
            }
            if (shouldAdd) {
              await context
                  .read<UserSettingsCubit>()
                  .addMissingProperties(missing);
              if (!context.mounted) return;
              context.read<PropertyContextCubit>().loadProperties();
            } else {
              await context.read<UserSettingsCubit>().skipMissingProperties();
            }
            context.read<UserSettingsCubit>().clearMissingProperties();
          },
        ),
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.toast != current.toast && current.toast != null,
          listener: (context, state) {
            final toast = state.toast;
            if (toast == null) return;
            showStyledToast(
              context,
              type: _toastType(toast.type),
              description: _toastMessage(context, toast.message),
            );
            context.read<UserSettingsCubit>().clearToast();
          },
        ),
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.domainError != current.domainError &&
              current.domainError != null,
          listener: (context, state) async {
            final domainError = state.domainError;
            if (domainError == null) return;
            await showAppError(
              context,
              AppError.fromDomain(context, domainError),
            );
            if (!context.mounted) return;
            context.read<UserSettingsCubit>().clearError();
          },
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          if (settingsState.status == SettingsStatus.initial ||
              settingsState.status == SettingsStatus.loading) {
            return ConsolePageScaffold(
              title: 'Properties',
              description: '',
              leftChild: const Center(child: CircularProgressIndicator()),
            );
          }

          final isLodgifyConnected =
              settingsState.settings?.lodgifyConnected ?? false;

          return ConsolePageScaffold(
            title: 'Properties',
            description: '',
            leftChild: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLodgifyConnected)
                    const _SyncFromLodgifyContent()
                  else
                    const _ConnectLodgifyContent(),
                  const _OrDivider(),
                  const _ManualCreateContent(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Connect Lodgify Content
// ---------------------------------------------------------------------------

class _ConnectLodgifyContent extends StatelessWidget {
  const _ConnectLodgifyContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.link_off,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          context.s.propertySetupConnectTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          context.s.propertySetupConnectBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        StyledButton(
          title: context.s.propertySetupGoToSettings,
          onPressed: () => GoRouter.of(context).go('/settings'),
          leftIconData: Icons.settings_outlined,
          showLeftIcon: true,
          minHeight: 44,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sync from Lodgify Content
// ---------------------------------------------------------------------------

class _SyncFromLodgifyContent extends StatelessWidget {
  const _SyncFromLodgifyContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserSettingsCubit, UserSettingsState>(
      builder: (context, userSettingsState) {
        final isSyncing =
            userSettingsState.status == UserSettingsStatus.syncing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.sync,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.s.propertySetupSyncTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.s.propertySetupSyncBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            StyledButton(
              title: context.s.lodgifySyncLabel,
              onPressed: isSyncing
                  ? null
                  : () => context.read<UserSettingsCubit>().syncLodgify(),
              enabled: !isSyncing,
              showProgressIndicatorWhenDisabled: isSyncing,
              leftIconData: Icons.sync,
              showLeftIcon: !isSyncing,
              minHeight: 44,
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// "or" Divider
// ---------------------------------------------------------------------------

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.s.propertySetupOrDivider,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Manual Create Content
// ---------------------------------------------------------------------------

class _ManualCreateContent extends StatefulWidget {
  const _ManualCreateContent();

  @override
  State<_ManualCreateContent> createState() => _ManualCreateContentState();
}

class _ManualCreateContentState extends State<_ManualCreateContent> {
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);

    try {
      final repository = context.read<PropertyRepository>();
      await repository.createProperty(name: name);
      if (!mounted) return;
      context.read<PropertyContextCubit>().loadProperties();
    } catch (error, stack) {
      if (!mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCreate =
        _nameController.text.trim().isNotEmpty && !_isCreating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.add_home_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          context.s.propertySetupManualTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          context.s.propertySetupManualBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: StyledFormField(
            controller: _nameController,
            label: context.s.propertySetupManualNameLabel,
            placeholder: context.s.propertySetupManualNameLabel,
            enabled: !_isCreating,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (canCreate) _create();
            },
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        StyledButton(
          title: context.s.propertySetupManualButton,
          onPressed: canCreate ? _create : null,
          enabled: canCreate,
          showProgressIndicatorWhenDisabled: _isCreating,
          leftIconData: _isCreating ? null : Icons.add,
          showLeftIcon: !_isCreating,
          minHeight: 44,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Missing Properties Dialog
// ---------------------------------------------------------------------------

Future<bool> _showMissingPropertiesDialog(
  BuildContext context, {
  required List<ChannelProperty> lodgifyProperties,
  required List<ChannelProperty> missing,
}) async {
  final missingIds = missing
      .map((property) => property.id?.trim())
      .whereType<String>()
      .where((value) => value.isNotEmpty)
      .toSet();
  final missingNames = missing
      .map((property) => property.name?.trim().toLowerCase())
      .whereType<String>()
      .where((value) => value.isNotEmpty)
      .toSet();
  final hasMissing = missing.isNotEmpty;
  final theme = Theme.of(context);
  final styledTheme = StyledWidgetsTheme.of(context);
  final subtitle = hasMissing ? null : context.s.lodgifyNoNewPropertiesFound;

  final shouldAdd =
      await showStyledModal<bool>(
        context,
        hideDefaultHeader: true,
        isDismissible: false,
        builder: (context) {
          return SizedBox(
            width: 420,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      children: [
                        Text(
                          context.s.lodgifyMissingPropertiesTitle,
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: lodgifyProperties.length,
                      itemBuilder: (context, index) {
                        final property = lodgifyProperties[index];
                        final title =
                            property.name ?? property.id ?? 'Unknown property';
                        final lodgifyId = property.id?.trim();
                        final isMissing =
                            (lodgifyId != null &&
                                lodgifyId.isNotEmpty &&
                                missingIds.contains(lodgifyId)) ||
                            missingNames.contains(
                              (property.name ?? '').trim().toLowerCase(),
                            );
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: StyledTile(
                            title: title,
                            leading: isMissing
                                ? null
                                : Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                  ),
                            centerContent: false,
                            minHeight: 44,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: StyledButton(
                            title: context.s.cancelButton,
                            onPressed: () => Navigator.of(context).pop(false),
                            minHeight: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StyledButton(
                            titleWidget: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    hasMissing
                                        ? context
                                              .s
                                              .lodgifyMissingPropertiesAddAction
                                        : context.s.lodgifySyncLabel,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: styledTheme.buttons.labelColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            minHeight: 40,
                            backgroundColor:
                                styledTheme.buttons.backgroundColor,
                            labelColor: styledTheme.buttons.labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
  return shouldAdd;
}

// ---------------------------------------------------------------------------
// Toast Helpers
// ---------------------------------------------------------------------------

ToastificationType _toastType(UserSettingsToastType type) {
  return switch (type) {
    UserSettingsToastType.success => ToastificationType.success,
    UserSettingsToastType.error => ToastificationType.error,
    UserSettingsToastType.info => ToastificationType.info,
  };
}

String _toastMessage(BuildContext context, UserSettingsToastMessage message) {
  return switch (message) {
    UserSettingsToastMessage.settingsSaved => context.s.settingsSaved,
    UserSettingsToastMessage.lodgifyApiKeyRequired =>
      context.s.lodgifyApiKeyRequired,
    UserSettingsToastMessage.lodgifyApiKeySaveFailed =>
      context.s.lodgifyApiKeySaveFailed,
    UserSettingsToastMessage.lodgifyConnectSuccess =>
      context.s.lodgifyConnectSuccess,
    UserSettingsToastMessage.lodgifyConnectFailed =>
      context.s.lodgifyConnectFailed,
    UserSettingsToastMessage.lodgifySyncCompleted =>
      context.s.lodgifySyncCompleted,
    UserSettingsToastMessage.lodgifySyncFailed => context.s.lodgifySyncFailed,
    UserSettingsToastMessage.lodgifyNoNewProperties =>
      context.s.lodgifyNoNewPropertiesFound,
    UserSettingsToastMessage.userSettingsLoadFailed =>
      context.s.userSettingsLoadFailed,
  };
}
