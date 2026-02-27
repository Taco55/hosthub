import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class PropertyPricingPage extends StatelessWidget {
  const PropertyPricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final current = state.currentProperty;
        if (state.status == PropertyContextStatus.loading ||
            state.status == PropertyContextStatus.initial) {
          return ConsolePageScaffold(
            title: context.s.menuPricing,
            description: context.s.pricingDescription,
            leftChild: const Center(child: CircularProgressIndicator()),
          );
        }
        if (current == null) {
          return ConsolePageScaffold(
            title: context.s.menuPricing,
            description: context.s.pricingDescription,
            leftChild: Text(context.s.propertyDetailsEmpty),
          );
        }

        final propertyRepository = context.read<PropertyRepository>();
        final adminSettingsRepository =
            context.read<AdminSettingsRepository>();

        return FutureBuilder<_PricingData>(
          future: _loadPricingData(
            propertyRepository,
            adminSettingsRepository,
            current.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ConsolePageScaffold(
                title: context.s.menuPricing,
                description: context.s.pricingDescription,
                leftChild:
                    const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return ConsolePageScaffold(
                title: context.s.menuPricing,
                description: context.s.pricingDescription,
                leftChild:
                    Text('Failed to load pricing: ${snapshot.error}'),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return ConsolePageScaffold(
                title: context.s.menuPricing,
                description: context.s.pricingDescription,
                leftChild: Text(context.s.propertyDetailsEmpty),
              );
            }

            return ConsolePageScaffold(
              title: context.s.menuPricing,
              description: context.s.pricingDescription,
              leftChild: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  _BookingSettingsSection(
                    details: data.details,
                    adminDefaults: data.adminSettings,
                    repository: propertyRepository,
                    onSaved: () {
                      context
                          .read<PropertyContextCubit>()
                          .loadProperties();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Future<_PricingData> _loadPricingData(
  PropertyRepository propertyRepository,
  AdminSettingsRepository adminSettingsRepository,
  int propertyId,
) async {
  final results = await Future.wait<Object>([
    propertyRepository.fetchPropertyDetails(propertyId),
    adminSettingsRepository.load(),
  ]);

  return _PricingData(
    details: results[0] as PropertyDetails,
    adminSettings: results[1] as AdminSettings,
  );
}

class _PricingData {
  const _PricingData({
    required this.details,
    required this.adminSettings,
  });

  final PropertyDetails details;
  final AdminSettings adminSettings;
}

// ---------------------------------------------------------------------------
// Booking Settings Section
// ---------------------------------------------------------------------------

class _BookingSettingsSection extends StatefulWidget {
  const _BookingSettingsSection({
    required this.details,
    required this.adminDefaults,
    required this.repository,
    required this.onSaved,
  });

  final PropertyDetails details;
  final AdminSettings adminDefaults;
  final PropertyRepository repository;
  final VoidCallback onSaved;

  @override
  State<_BookingSettingsSection> createState() =>
      _BookingSettingsSectionState();
}

class _BookingSettingsSectionState extends State<_BookingSettingsSection> {
  late _ChannelDraft _airbnb;
  late _ChannelDraft _booking;
  late _ChannelDraft _other;

  late ChannelSettings _initial;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _applyDetails(widget.details);
  }

  @override
  void didUpdateWidget(covariant _BookingSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.details.id != widget.details.id) {
      _disposeDrafts();
      _applyDetails(widget.details);
    }
  }

  @override
  void dispose() {
    _disposeDrafts();
    super.dispose();
  }

  void _disposeDrafts() {
    _airbnb.dispose();
    _booking.dispose();
    _other.dispose();
  }

  void _applyDetails(PropertyDetails details) {
    final cs = details.channelSettings;
    _airbnb = _ChannelDraft.from(cs.airbnb, _onChanged);
    _booking = _ChannelDraft.from(cs.booking, _onChanged);
    _other = _ChannelDraft.from(cs.other, _onChanged);
    _initial = cs;
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  ChannelSettings _currentSettings() {
    return ChannelSettings(
      airbnb: _airbnb.toConfig(),
      booking: _booking.toConfig(),
      other: _other.toConfig(),
    );
  }

  bool get _hasChanges => !_initial.equals(_currentSettings());

  Future<void> _save() async {
    final settings = _currentSettings();
    setState(() => _isSaving = true);

    try {
      final saved = await widget.repository.updateChannelSettings(
        propertyId: widget.details.id,
        channelSettings: settings,
      );

      if (!mounted) return;
      _disposeDrafts();
      setState(() {
        _isSaving = false;
        _applyDetails(saved);
      });

      widget.onSaved();
      showStyledToast(
        context,
        type: ToastificationType.success,
        description: context.s.pricingSaved,
      );
    } catch (error, stack) {
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);

      if (!mounted) return;
      setState(() => _isSaving = false);
      await showAppError(context, AppError.fromDomain(context, domainError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = widget.details.currencyCode;
    final canSave = !_isSaving && _hasChanges;

    return StyledSection(
      isFirstSection: true,
      header: context.s.pricingChannelSettingsHeader,
      grouped: false,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${context.s.pricingCurrencyNote} $currencyCode. '
            '${context.s.pricingCommissionNote}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        _ChannelExpansionTile(
          channelName: 'Airbnb',
          leading: const BookingSourceIcon(source: 'airbnb', size: 20),
          draft: _airbnb,
          defaultCommission: widget.adminDefaults.airbnbChannelFeePercentage,
          currencyCode: currencyCode,
          enabled: !_isSaving,
          initiallyExpanded: true,
        ),
        const SizedBox(height: 4),
        _ChannelExpansionTile(
          channelName: 'Booking.com',
          leading: const BookingSourceIcon(source: 'booking', size: 20),
          draft: _booking,
          defaultCommission:
              widget.adminDefaults.bookingChannelFeePercentage,
          currencyCode: currencyCode,
          enabled: !_isSaving,
        ),
        const SizedBox(height: 4),
        _ChannelExpansionTile(
          channelName: 'Overig / Direct',
          leading: const BookingSourceIcon(source: 'direct', size: 20),
          draft: _other,
          defaultCommission: widget.adminDefaults.otherChannelFeePercentage,
          currencyCode: currencyCode,
          enabled: !_isSaving,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: StyledButton(
            title: context.s.saveButton,
            onPressed: canSave ? _save : null,
            enabled: canSave,
            showProgressIndicatorWhenDisabled: _isSaving,
            leftIconData: _isSaving ? null : Icons.save_outlined,
            showLeftIcon: !_isSaving,
            minHeight: 40,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Channel Expansion Tile
// ---------------------------------------------------------------------------

class _ChannelExpansionTile extends StatelessWidget {
  const _ChannelExpansionTile({
    required this.channelName,
    required this.leading,
    required this.draft,
    required this.defaultCommission,
    required this.currencyCode,
    required this.enabled,
    this.initiallyExpanded = false,
  });

  final String channelName;
  final Widget leading;
  final _ChannelDraft draft;
  final double defaultCommission;
  final String currencyCode;
  final bool enabled;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      leading: leading,
      title: Text(
        channelName,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PercentageInputTile(
          title: context.s.pricingCommissionOverride,
          description:
              '${context.s.pricingCommissionDefault} (${_formatDecimal(defaultCommission)}%).',
          controller: draft.commissionController,
          placeholder: _formatDecimal(defaultCommission),
          enabled: enabled,
        ),
        _PercentageInputTile(
          title: context.s.pricingRateMarkup,
          description: context.s.pricingRateMarkupDescription,
          controller: draft.markupController,
          placeholder: '0',
          enabled: enabled,
        ),
        const Divider(height: 24),
        _CostInputRow(
          title: context.s.pricingCleaningCost,
          controller: draft.cleaningController,
          costType: draft.cleaningType,
          onCostTypeChanged: draft.setCleaningType,
          currencyCode: currencyCode,
          enabled: enabled,
        ),
        _CostInputRow(
          title: context.s.pricingLinenCost,
          controller: draft.linenController,
          costType: draft.linenType,
          onCostTypeChanged: draft.setLinenType,
          currencyCode: currencyCode,
          enabled: enabled,
        ),
        _CostInputRow(
          title: context.s.pricingServiceCost,
          controller: draft.serviceController,
          costType: draft.serviceType,
          onCostTypeChanged: draft.setServiceType,
          currencyCode: currencyCode,
          enabled: enabled,
        ),
        _CostInputRow(
          title: context.s.pricingOtherCost,
          controller: draft.otherController,
          costType: draft.otherType,
          onCostTypeChanged: draft.setOtherType,
          currencyCode: currencyCode,
          enabled: enabled,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Input Widgets
// ---------------------------------------------------------------------------

class _PercentageInputTile extends StatelessWidget {
  const _PercentageInputTile({
    required this.title,
    required this.description,
    required this.controller,
    required this.placeholder,
    required this.enabled,
  });

  final String title;
  final String description;
  final TextEditingController controller;
  final String placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StyledTile(
      title: title,
      subtitle: description,
      value: SizedBox(
        width: 120,
        child: StyledFormField(
          controller: controller,
          enabled: enabled,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          placeholder: placeholder,
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

class _CostInputRow extends StatelessWidget {
  const _CostInputRow({
    required this.title,
    required this.controller,
    required this.costType,
    required this.onCostTypeChanged,
    required this.currencyCode,
    required this.enabled,
  });

  final String title;
  final TextEditingController controller;
  final CostType costType;
  final ValueChanged<CostType> onCostTypeChanged;
  final String currencyCode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 100,
            child: StyledFormField(
              controller: controller,
              enabled: enabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              placeholder: '0',
            ),
          ),
          const SizedBox(width: 6),
          Text(
            currencyCode,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: DropdownButton<CostType>(
              value: costType,
              isExpanded: true,
              isDense: true,
              underline: const SizedBox.shrink(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              items: CostType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(costTypeLabel(t)),
                    ),
                  )
                  .toList(),
              onChanged: enabled
                  ? (value) {
                      if (value != null) onCostTypeChanged(value);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Channel Draft (state holder for one channel's editable fields)
// ---------------------------------------------------------------------------

class _ChannelDraft {
  _ChannelDraft({
    required this.commissionController,
    required this.markupController,
    required this.cleaningController,
    required this.linenController,
    required this.serviceController,
    required this.otherController,
    required this.cleaningType,
    required this.linenType,
    required this.serviceType,
    required this.otherType,
    required this.onChanged,
  }) {
    commissionController.addListener(onChanged);
    markupController.addListener(onChanged);
    cleaningController.addListener(onChanged);
    linenController.addListener(onChanged);
    serviceController.addListener(onChanged);
    otherController.addListener(onChanged);
  }

  final TextEditingController commissionController;
  final TextEditingController markupController;
  final TextEditingController cleaningController;
  final TextEditingController linenController;
  final TextEditingController serviceController;
  final TextEditingController otherController;

  CostType cleaningType;
  CostType linenType;
  CostType serviceType;
  CostType otherType;

  final VoidCallback onChanged;

  void setCleaningType(CostType t) {
    cleaningType = t;
    onChanged();
  }

  void setLinenType(CostType t) {
    linenType = t;
    onChanged();
  }

  void setServiceType(CostType t) {
    serviceType = t;
    onChanged();
  }

  void setOtherType(CostType t) {
    otherType = t;
    onChanged();
  }

  factory _ChannelDraft.from(ChannelConfig config, VoidCallback onChanged) {
    return _ChannelDraft(
      commissionController: TextEditingController(
        text: _formatOptionalDecimal(config.commissionPercentage),
      ),
      markupController: TextEditingController(
        text: _formatOptionalDecimal(config.rateMarkupPercentage),
      ),
      cleaningController: TextEditingController(
        text: _formatDecimal(config.cleaningCost.amount),
      ),
      linenController: TextEditingController(
        text: _formatDecimal(config.linenCost.amount),
      ),
      serviceController: TextEditingController(
        text: _formatDecimal(config.serviceCost.amount),
      ),
      otherController: TextEditingController(
        text: _formatDecimal(config.otherCost.amount),
      ),
      cleaningType: config.cleaningCost.type,
      linenType: config.linenCost.type,
      serviceType: config.serviceCost.type,
      otherType: config.otherCost.type,
      onChanged: onChanged,
    );
  }

  ChannelConfig toConfig() {
    return ChannelConfig(
      commissionPercentage: _parseNullable(commissionController.text),
      rateMarkupPercentage: _parseNullable(markupController.text),
      cleaningCost: CostEntry(
        amount: _parseAmount(cleaningController.text),
        type: cleaningType,
      ),
      linenCost: CostEntry(
        amount: _parseAmount(linenController.text),
        type: linenType,
      ),
      serviceCost: CostEntry(
        amount: _parseAmount(serviceController.text),
        type: serviceType,
      ),
      otherCost: CostEntry(
        amount: _parseAmount(otherController.text),
        type: otherType,
      ),
    );
  }

  void dispose() {
    commissionController.removeListener(onChanged);
    markupController.removeListener(onChanged);
    cleaningController.removeListener(onChanged);
    linenController.removeListener(onChanged);
    serviceController.removeListener(onChanged);
    otherController.removeListener(onChanged);

    commissionController.dispose();
    markupController.dispose();
    cleaningController.dispose();
    linenController.dispose();
    serviceController.dispose();
    otherController.dispose();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatOptionalDecimal(double? value) {
  if (value == null) return '';
  return _formatDecimal(value);
}

String _formatDecimal(double value) {
  if (value == 0) return '0';
  final fixed = value.toStringAsFixed(2);
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

double? _parseNullable(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed.replaceAll(',', '.'));
}

double _parseAmount(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 0;
  return double.tryParse(trimmed.replaceAll(',', '.')) ?? 0;
}
