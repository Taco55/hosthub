import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/shared/l10n/l10n.dart';
import 'package:hosthub_console/shared/models/models.dart';
import 'package:hosthub_console/shared/domain/channel_manager/models/models.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';
import 'package:hosthub_console/shared/l10n/application/language_cubit.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserSettingsView();
  }
}

class _UserSettingsView extends StatelessWidget {
  const _UserSettingsView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
            final appError = _mapDomainError(context, domainError);
            await showAppError(context, appError);
            if (!context.mounted) return;
            context.read<UserSettingsCubit>().clearError();
          },
        ),
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.settings?.languageCode != current.settings?.languageCode,
          listener: (context, state) {
            final languageCode = state.settings?.languageCode?.trim();
            if (languageCode == null || languageCode.isEmpty) return;
            final current = context.read<LanguageCubit>().state.languageCode;
            if (current == languageCode) return;
            context.read<LanguageCubit>().changeLang(context, languageCode);
          },
        ),
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
              await context.read<UserSettingsCubit>().addMissingProperties(
                missing,
              );
              if (!context.mounted) return;
              context.read<PropertyContextCubit>().loadProperties();
            } else {
              await context.read<UserSettingsCubit>().skipMissingProperties();
            }
            context.read<UserSettingsCubit>().clearMissingProperties();
          },
        ),
      ],
      child: BlocBuilder<UserSettingsCubit, UserSettingsState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final locale = context.watch<LanguageCubit>().state;
          final supportedLocales = S.delegate.supportedLocales;
          final localeNames = LocaleNames.of(context);
          final settings = state.settings;
          final isLoading =
              state.status == UserSettingsStatus.loading && settings == null;

          return ConsolePageScaffold(
            title: context.s.settingsLabel,
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),

            leftChild: SafeArea(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: _UserSettingsSection(
                        theme: theme,
                        currentLocale: locale,
                        supportedLocales: supportedLocales,
                        localeNames: localeNames,
                        settings: settings,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _UserSettingsSection extends StatelessWidget {
  const _UserSettingsSection({
    required this.theme,
    required this.currentLocale,
    required this.supportedLocales,
    required this.localeNames,
    required this.settings,
  });

  final ThemeData theme;
  final Locale currentLocale;
  final List<Locale> supportedLocales;
  final LocaleNames? localeNames;
  final UserSettings? settings;

  @override
  Widget build(BuildContext context) {
    final styledTheme = StyledWidgetsTheme.of(context);
    final selectedLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == currentLocale.languageCode,
      orElse: () => supportedLocales.first,
    );

    final status = context.select(
      (UserSettingsCubit cubit) => cubit.state.status,
    );
    final hasApiKey = settings?.lodgifyApiKey?.trim().isNotEmpty ?? false;
    final isConnected = settings?.lodgifyConnected ?? false;
    final isBusy =
        status == UserSettingsStatus.saving ||
        status == UserSettingsStatus.connecting ||
        status == UserSettingsStatus.syncing;
    final canConnect = hasApiKey && !isBusy;
    final canSync = isConnected && !isBusy;
    final lastSyncedAt = settings?.lodgifyLastSyncedAt;

    if (settings == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StyledSection(
          isFirstSection: true,
          header: context.s.generalSectionTitle,
          grouped: false,
          children: [
            StyledSelectionTile<String>.dropdown(
              title: context.s.languagePreferenceTitle,
              subtitle: context.s.languagePreferenceDescription,
              currentValue: selectedLocale.languageCode,
              options: supportedLocales
                  .map((locale) => locale.languageCode)
                  .toList(),
              modalTitle: context.s.languagePreferenceTitle,
              optionLabelBuilder: (value) {
                final locale = supportedLocales.firstWhere(
                  (locale) => locale.languageCode == value,
                  orElse: () => supportedLocales.first,
                );
                return _localizedLocaleName(locale, localeNames);
              },
              dropdownFieldAutoSize: true,
              onChanged: (value) {
                if (value == null || value == currentLocale.languageCode)
                  return;
                context.read<UserSettingsCubit>().changeLanguage(value);
              },
            ),
          ],
        ),
        StyledSection(
          header: context.s.connectionsSectionTitle,
          grouped: false,
          children: [
            Text(context.s.lodgifyTitle),
            StyledTile(
              title: context.s.lodgifyApiKeyLabel,
              subtitle: context.s.lodgifyApiKeyDescription,
              value: hasApiKey
                  ? Text(
                      _maskApiKey(settings?.lodgifyApiKey ?? ''),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.1,
                      ),
                    )
                  : null,
              trailing: _LodgifyApiKeyControl(
                hasApiKey: hasApiKey,
                isBusy: isBusy,
                onEdit: () async {
                  final result = await _showLodgifyApiKeyDialog(
                    context,
                    currentApiKey: settings?.lodgifyApiKey,
                  );
                  if (result == null || !context.mounted) return;
                  context.read<UserSettingsCubit>().updateLodgifyApiKey(
                    result.apiKey,
                    remove: result.remove,
                  );
                },
              ),
            ),
            StyledTile(
              title: Text(
                isConnected
                    ? context.s.connectionStatusConnected
                    : context.s.connectionStatusDisconnected,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: StyledButton(
                title: isConnected
                    ? context.s.lodgifySyncLabel
                    : context.s.connectLabel,
                onPressed: isConnected
                    ? (canSync
                          ? () =>
                                context.read<UserSettingsCubit>().syncLodgify()
                          : null)
                    : (canConnect
                          ? () => context
                                .read<UserSettingsCubit>()
                                .connectLodgify()
                          : null),
                enabled: isConnected ? canSync : canConnect,
                showProgressIndicatorWhenDisabled: isBusy,
                backgroundColorDisabled:
                    styledTheme.buttons.disabledBackgroundColor,
                labelColorDisabled:
                    styledTheme.buttons.disabledLabelColor,
                enableShrinking: false,
                width: 120,
                minWidth: 120,
                minHeight: 40,
              ),
            ),
            _LastSyncTile(lastSyncedAt: lastSyncedAt),
          ],
        ),
        const _ChannelFeeDefaultsSection(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Channel Fee Defaults Section
// ---------------------------------------------------------------------------

class _ChannelFeeDefaultsSection extends StatefulWidget {
  const _ChannelFeeDefaultsSection();

  @override
  State<_ChannelFeeDefaultsSection> createState() =>
      _ChannelFeeDefaultsSectionState();
}

class _ChannelFeeDefaultsSectionState
    extends State<_ChannelFeeDefaultsSection> {
  final _bookingController = TextEditingController();
  final _airbnbController = TextEditingController();
  final _otherController = TextEditingController();

  bool _isApplyingDraft = false;
  AdminSettings? _loadedSettings;

  List<TextEditingController> get _controllers => [
    _bookingController,
    _airbnbController,
    _otherController,
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_onDraftChanged);
    }
    final cubit = context.read<ServerSettingsCubit>();
    if (cubit.state.settings == null &&
        cubit.state.status != ServerSettingsStatus.loading &&
        cubit.state.status != ServerSettingsStatus.mutating) {
      cubit.load();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_onDraftChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onDraftChanged() {
    if (_isApplyingDraft || !mounted) return;
    setState(() {});
  }

  void _applyDraft(AdminSettings settings) {
    _loadedSettings = settings;
    _isApplyingDraft = true;
    _bookingController.text = _fmtDec(settings.bookingChannelFeePercentage);
    _airbnbController.text = _fmtDec(settings.airbnbChannelFeePercentage);
    _otherController.text = _fmtDec(settings.otherChannelFeePercentage);
    _isApplyingDraft = false;
  }

  bool _hasChanges(AdminSettings base) {
    return _dblChanged(
          _parseCtrl(_bookingController, base.bookingChannelFeePercentage),
          base.bookingChannelFeePercentage,
        ) ||
        _dblChanged(
          _parseCtrl(_airbnbController, base.airbnbChannelFeePercentage),
          base.airbnbChannelFeePercentage,
        ) ||
        _dblChanged(
          _parseCtrl(_otherController, base.otherChannelFeePercentage),
          base.otherChannelFeePercentage,
        );
  }

  void _save(AdminSettings current) {
    final updated = current.copyWith(
      bookingChannelFeePercentage:
          _parseCtrl(_bookingController, current.bookingChannelFeePercentage),
      airbnbChannelFeePercentage:
          _parseCtrl(_airbnbController, current.airbnbChannelFeePercentage),
      otherChannelFeePercentage:
          _parseCtrl(_otherController, current.otherChannelFeePercentage),
    );
    context.read<ServerSettingsCubit>().save(updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServerSettingsCubit, ServerSettingsState>(
      listenWhen: (previous, current) =>
          previous.settings != current.settings ||
          previous.status != current.status,
      listener: (context, state) {
        final settings = state.settings;
        if (settings != null && !identical(settings, _loadedSettings)) {
          setState(() => _applyDraft(settings));
        }
        if (state.status == ServerSettingsStatus.ready &&
            _loadedSettings != null &&
            state.settings == _loadedSettings) {
          // just saved
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ServerSettingsStatus.loading &&
            state.settings == null;
        if (isLoading) {
          return StyledSection(
            header: context.s.channelFeeDefaultsHeader,
            grouped: false,
            children: const [
              Center(child: CircularProgressIndicator()),
            ],
          );
        }

        final settings = state.settings ?? AdminSettings.defaults();
        final isMutating = state.status == ServerSettingsStatus.mutating;
        final canSave = _loadedSettings != null &&
            _hasChanges(_loadedSettings!) &&
            !isMutating;

        return StyledSection(
          header: context.s.channelFeeDefaultsHeader,
          grouped: false,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                context.s.channelFeeDefaultsDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _ChannelFeeInputTile(
              title: 'Booking.com',
              leading: const BookingSourceIcon(source: 'booking', size: 20),
              controller: _bookingController,
              enabled: !isMutating,
            ),
            _ChannelFeeInputTile(
              title: 'Airbnb',
              leading: const BookingSourceIcon(source: 'airbnb', size: 20),
              controller: _airbnbController,
              enabled: !isMutating,
            ),
            _ChannelFeeInputTile(
              title: 'Overig / Direct',
              leading: const BookingSourceIcon(source: 'direct', size: 20),
              controller: _otherController,
              enabled: !isMutating,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: StyledButton(
                title: context.s.saveButton,
                onPressed: canSave ? () => _save(settings) : null,
                enabled: canSave,
                showProgressIndicatorWhenDisabled: isMutating,
                leftIconData: isMutating ? null : Icons.save_outlined,
                showLeftIcon: !isMutating,
                minHeight: 40,
              ),
            ),
          ],
        );
      },
    );
  }

  static String _fmtDec(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static double _parseCtrl(TextEditingController c, double fallback) {
    final text = c.text.trim();
    if (text.isEmpty) return 0;
    return double.tryParse(text.replaceAll(',', '.')) ?? fallback;
  }

  static bool _dblChanged(double a, double b) => (a - b).abs() >= 0.001;
}

class _ChannelFeeInputTile extends StatelessWidget {
  const _ChannelFeeInputTile({
    required this.title,
    required this.controller,
    required this.enabled,
    this.leading,
  });

  final String title;
  final TextEditingController controller;
  final bool enabled;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StyledTile(
      title: title,
      leading: leading,
      value: SizedBox(
        width: 120,
        child: StyledFormField(
          controller: controller,
          enabled: enabled,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          placeholder: '0',
        ),
      ),
      trailing: Text(
        '%',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LastSyncTile extends StatefulWidget {
  const _LastSyncTile({required this.lastSyncedAt});

  final DateTime? lastSyncedAt;

  @override
  State<_LastSyncTile> createState() => _LastSyncTileState();
}

class _LastSyncTileState extends State<_LastSyncTile> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant _LastSyncTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lastSyncedAt != widget.lastSyncedAt) {
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.lastSyncedAt == null) return;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.lastSyncedAt;
    if (timestamp == null) {
      return const SizedBox.shrink();
    }

    final formattedSyncTime = _formatSyncTimestamp(context, timestamp);
    final theme = Theme.of(context);
    return StyledTile(
      title: Text(
        context.s.lodgifyLastSyncLabel(formattedSyncTime),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LodgifyApiKeyControl extends StatelessWidget {
  const _LodgifyApiKeyControl({
    required this.hasApiKey,
    required this.isBusy,
    required this.onEdit,
  });

  final bool hasApiKey;
  final bool isBusy;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (!hasApiKey) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: StyledButton(
          title: context.s.add,
          onPressed: isBusy ? null : onEdit,
          enabled: !isBusy,
          leftIconData: Icons.add,
          showLeftIcon: !isBusy,
          minHeight: 40,
        ),
      );
    }

    return IconButton(
      onPressed: isBusy ? null : onEdit,
      icon: const Icon(Icons.edit_outlined),
      tooltip: context.s.edit,
    );
  }
}

class _LodgifyApiKeyDialogResult {
  const _LodgifyApiKeyDialogResult.save(this.apiKey) : remove = false;
  const _LodgifyApiKeyDialogResult.remove() : apiKey = null, remove = true;

  final String? apiKey;
  final bool remove;
}

Future<_LodgifyApiKeyDialogResult?> _showLodgifyApiKeyDialog(
  BuildContext context, {
  required String? currentApiKey,
}) async {
  final hasApiKey = currentApiKey?.trim().isNotEmpty ?? false;
  final contentKey = GlobalKey<_LodgifyApiKeyDialogContentState>();

  final result = await showStyledModal<_LodgifyApiKeyDialogResult>(
    context,
    title: context.s.lodgifyApiKeyLabel,
    isDismissible: false,
    actionText: hasApiKey ? context.s.saveButton : context.s.add,
    leadingText: context.s.cancelButton,
    showAction: true,
    showLeading: true,
    closeOnAction: false,
    builder: (context) {
      return _LodgifyApiKeyDialogContent(
        key: contentKey,
        currentApiKey: currentApiKey,
        hasApiKey: hasApiKey,
      );
    },
    onAction: (_) {
      contentKey.currentState?.submit();
    },
  );

  return result;
}

class _LodgifyApiKeyDialogContent extends StatefulWidget {
  const _LodgifyApiKeyDialogContent({
    super.key,
    required this.currentApiKey,
    required this.hasApiKey,
  });

  final String? currentApiKey;
  final bool hasApiKey;

  @override
  State<_LodgifyApiKeyDialogContent> createState() =>
      _LodgifyApiKeyDialogContentState();
}

class _LodgifyApiKeyDialogContentState
    extends State<_LodgifyApiKeyDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentApiKey ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop(_LodgifyApiKeyDialogResult.save(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: StyledFormField(
              controller: _controller,
              autofocus: true,
              placeholder: context.s.lodgifyApiKeyLabel,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.s.lodgifyApiKeyRequired;
                }
                return null;
              },
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          if (widget.hasApiKey) ...[
            const SizedBox(height: 12),
            StyledButton(
              title: context.s.deleteButton,
              onPressed: () => Navigator.of(
                context,
              ).pop(const _LodgifyApiKeyDialogResult.remove()),
              backgroundColor: theme.colorScheme.error,
              labelColor: theme.colorScheme.onError,
              minHeight: 40,
            ),
          ],
        ],
      ),
    );
  }
}

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
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          styledTheme.buttons.labelColor,
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

AppError _mapDomainError(BuildContext context, DomainError domainError) {
  final lodgifyAction = domainError.context?['lodgify_action']?.toString();
  if (lodgifyAction == 'connect') {
    return AppError.custom(
      title: context.s.lodgifyConnectErrorTitle,
      alert: context.s.lodgifyConnectErrorDescription,
      domainError: domainError,
    );
  }
  return AppError.fromDomain(context, domainError);
}

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

String _maskApiKey(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.length <= 4) {
    return List.filled(trimmed.length, '*').join();
  }
  return '********${trimmed.substring(trimmed.length - 4)}';
}

String _formatSyncTimestamp(BuildContext context, DateTime timestamp) {
  final local = timestamp.toLocal();
  final localeCode = Localizations.localeOf(context).languageCode;
  return timeago.format(local, locale: localeCode);
}

String _localizedLocaleName(Locale locale, LocaleNames? localeNames) {
  return localeNames?.nameOf(locale.languageCode) ??
      locale.languageCode.toUpperCase();
}
