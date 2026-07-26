import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
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
          return StyledWebPageScaffold(
            // Design: this wide page has no outer card — the channel
            // sections are the surfaces.
            decorateLeftPane: false,
            overline: context.s.menuPricing,
            title: context.s.pricingPageHeading,
            leftChild: const Center(child: CircularProgressIndicator()),
          );
        }
        if (current == null) {
          return StyledWebPageScaffold(
            // Design: this wide page has no outer card — the channel
            // sections are the surfaces.
            decorateLeftPane: false,
            overline: context.s.menuPricing,
            title: context.s.pricingPageHeading,
            leftChild: Text(context.s.propertyDetailsEmpty),
          );
        }

        final propertyRepository = context.read<PropertyRepository>();
        final adminSettingsRepository = context.read<AdminSettingsRepository>();

        return FutureBuilder<_PricingData>(
          future: _loadPricingData(
            propertyRepository,
            adminSettingsRepository,
            current.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return StyledWebPageScaffold(
                // Design: this wide page has no outer card — the channel
                // sections are the surfaces.
                decorateLeftPane: false,
                overline: context.s.menuPricing,
                title: context.s.pricingPageHeading,
                leftChild: const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return StyledWebPageScaffold(
                // Design: this wide page has no outer card — the channel
                // sections are the surfaces.
                decorateLeftPane: false,
                overline: context.s.menuPricing,
                title: context.s.pricingPageHeading,
                leftChild: Text('Failed to load pricing: ${snapshot.error}'),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return StyledWebPageScaffold(
                // Design: this wide page has no outer card — the channel
                // sections are the surfaces.
                decorateLeftPane: false,
                overline: context.s.menuPricing,
                title: context.s.pricingPageHeading,
                leftChild: Text(context.s.propertyDetailsEmpty),
              );
            }

            return StyledWebPageScaffold(
              // Design: this wide page has no outer card — the channel
              // sections are the surfaces.
              decorateLeftPane: false,
              // Design `.top`: crumb over the page's own title.
              overline: context.s.menuPricing,
              title: context.s.pricingPageHeading,
              // A Builder so the list reads the scaffold's scope: this closure
              // runs while the scaffold is still being constructed, so the
              // outer context sits above it.
              leftChild: Builder(
                builder: (context) => ListView(
                  // Bottom: the page padding, spent at the end of the list, so
                  // the last card no longer sits against the window edge.
                  padding: EdgeInsets.only(
                    top: context.styledSpacing.lg,
                    bottom: StyledWebPageScaffoldScope.of(
                      context,
                    ).contentBottomInset,
                  ),
                  children: [
                    _BookingSettingsSection(
                      details: data.details,
                      adminDefaults: data.adminSettings,
                      repository: propertyRepository,
                      onSaved: () {
                        context.read<PropertyContextCubit>().loadProperties();
                      },
                    ),
                  ],
                ),
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

/// Design `.price-grid`: single column, two columns from 1180px.
const double _pricingTwoColumnBreakpoint = 1180;
const double _pricingPreviewWidth = 340;

class _PricingData {
  const _PricingData({required this.details, required this.adminSettings});

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

  late ChannelOverrides _initial;
  bool _isSaving = false;

  /// Which channel the payout preview illustrates. Follows the channel the user
  /// last opened, per the design's "open a channel to preview that one".
  int _previewChannel = 0;

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

  /// The account tier this property's fields fall back to.
  AccountChannelDefaults get _accountDefaults =>
      AccountChannelDefaults.fromCommissionPercentages(
        booking: widget.adminDefaults.bookingChannelFeePercentage,
        airbnb: widget.adminDefaults.airbnbChannelFeePercentage,
        other: widget.adminDefaults.otherChannelFeePercentage,
      );

  void _applyDetails(PropertyDetails details) {
    final overrides = details.channelOverrides;
    _airbnb = _ChannelDraft.from(overrides.airbnb, _onChanged);
    _booking = _ChannelDraft.from(overrides.booking, _onChanged);
    _other = _ChannelDraft.from(overrides.other, _onChanged);
    _initial = overrides;
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  ChannelOverrides _currentOverrides() {
    return ChannelOverrides(
      airbnb: _airbnb.toOverride(),
      booking: _booking.toOverride(),
      other: _other.toOverride(),
    );
  }

  bool get _hasChanges => !_initial.equals(_currentOverrides());

  Future<void> _save() async {
    final overrides = _currentOverrides();
    setState(() => _isSaving = true);

    try {
      final saved = await widget.repository.updateChannelOverrides(
        propertyId: widget.details.id,
        channelOverrides: overrides,
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

    // Design `.price-grid`: one column, two from 1180px.
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= _pricingTwoColumnBreakpoint;
        final channels = _buildChannelSettings(context, currencyCode, canSave);
        final preview = _PayoutPreview(
          channelName: _previewChannelName,
          draft: _previewDraft,
          accountDefault: _previewAccountDefault,
          currencyCode: currencyCode,
        );

        if (!sideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              channels,
              SizedBox(height: context.styledSpacing.xl),
              preview,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: channels),
            SizedBox(width: context.styledSpacing.xl),
            SizedBox(width: _pricingPreviewWidth, child: preview),
          ],
        );
      },
    );
  }

  String get _previewChannelName =>
      const ['Airbnb', 'Booking.com', 'Overig / Direct'][_previewChannel];

  _ChannelDraft get _previewDraft =>
      [_airbnb, _booking, _other][_previewChannel];

  ChannelConfig get _previewAccountDefault => [
    _accountDefaults.airbnb,
    _accountDefaults.booking,
    _accountDefaults.other,
  ][_previewChannel];

  Widget _buildChannelSettings(
    BuildContext context,
    String currencyCode,
    bool canSave,
  ) {
    return StyledSection(
      isFirstSection: true,
      header: context.s.pricingChannelSettingsHeader,
      inset: false,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: context.styledSpacing.md),
          child: Text(
            '${context.s.pricingCurrencyNote} $currencyCode. '
            '${context.s.pricingCommissionNote}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        _ChannelExpansionTile(
          channelName: 'Airbnb',
          onExpanded: () => setState(() => _previewChannel = 0),
          leading: const BookingSourceIcon(source: 'airbnb', size: 20),
          draft: _airbnb,
          defaultCommission: _accountDefaults.airbnb.commissionPercentage,
          currencyCode: currencyCode,
          enabled: !_isSaving,
          initiallyExpanded: true,
        ),
        SizedBox(height: context.styledSpacing.xs),
        _ChannelExpansionTile(
          channelName: 'Booking.com',
          onExpanded: () => setState(() => _previewChannel = 1),
          leading: const BookingSourceIcon(source: 'booking', size: 20),
          draft: _booking,
          defaultCommission: _accountDefaults.booking.commissionPercentage,
          currencyCode: currencyCode,
          enabled: !_isSaving,
        ),
        SizedBox(height: context.styledSpacing.xs),
        _ChannelExpansionTile(
          channelName: 'Overig / Direct',
          onExpanded: () => setState(() => _previewChannel = 2),
          leading: const BookingSourceIcon(source: 'direct', size: 20),
          draft: _other,
          defaultCommission: _accountDefaults.other.commissionPercentage,
          currencyCode: currencyCode,
          enabled: !_isSaving,
        ),
        SizedBox(height: context.styledSpacing.md),
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
    required this.onExpanded,
    this.initiallyExpanded = false,
  });

  final String channelName;
  final Widget leading;
  final _ChannelDraft draft;
  final double defaultCommission;
  final String currencyCode;
  final bool enabled;

  /// Fired when this channel is opened, so the payout preview can follow it.
  final VoidCallback onExpanded;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final spacing = context.styledSpacing;

    // Design `.chan`: header row, hairline, body. `StyledExpansionTile` is that
    // row — header geometry, chevron and inset all come from the tile theme, so
    // the only thing stated here is the design's `.chan-body{padding-bottom}`.
    return StyledExpansionTile(
      initiallyExpanded: initiallyExpanded,
      onExpansionChanged: (expanded) {
        if (expanded) onExpanded();
      },
      leading: leading,
      title: channelName,
      emphasizeTitle: true,
      childrenPadding: EdgeInsets.only(bottom: spacing.lg),
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
// Payout preview
// ---------------------------------------------------------------------------

/// The stay the preview illustrates. A fixed, readable scenario — the point is
/// to show how the fields on the left combine, not to model a real booking.
const int _previewNights = 7;
const int _previewGuests = 4;
const double _previewBaseRate = 3200;

/// Design `.payout`: what the host keeps for one example stay, recalculated
/// live from the fields beside it.
///
/// Every number comes from [ChannelConfig.settle] — the same domain function the
/// Revenue table settles with — so the preview cannot drift from the reported
/// figures.
class _PayoutPreview extends StatelessWidget {
  const _PayoutPreview({
    required this.channelName,
    required this.draft,
    required this.accountDefault,
    required this.currencyCode,
  });

  final String channelName;
  final _ChannelDraft draft;

  /// The account values this channel's unfilled fields fall back to, so the
  /// preview shows what the property actually charges rather than what it types.
  final ChannelConfig accountDefault;

  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = context.styledSpacing;
    final s = context.s;

    final config = draft.toOverride().applyTo(accountDefault);
    final settlement = config.settle(
      baseRate: _previewBaseRate,
      nights: _previewNights,
      guests: _previewGuests,
    );

    // Cleaning + linen are shown together, service and other on their own
    // lines, matching the design's row breakdown.
    final cleaningAndLinen =
        config.cleaningCost.resolve(
          guests: _previewGuests,
          nights: _previewNights,
        ) +
        config.linenCost.resolve(
          guests: _previewGuests,
          nights: _previewNights,
        );
    final service = config.serviceCost.resolve(
      guests: _previewGuests,
      nights: _previewNights,
    );
    final other = config.otherCost.resolve(
      guests: _previewGuests,
      nights: _previewNights,
    );

    String money(double value) => '$currencyCode ${_formatMoney(value)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StyledContainer(
          // Padding and radius are the card defaults (`sections.contentPadding`
          // and `sharedLayout.cardRadius`); only the ice fill and its border are
          // particular to this panel.
          backgroundColor: colors.primaryContainer,
          border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.pricingPayoutHeader,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimaryContainer,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                s.pricingPayoutSubtitle(
                  _previewNights,
                  _previewGuests,
                  money(_previewBaseRate),
                  channelName,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: spacing.md),
              _PayoutRow(
                label: s.pricingPayoutGross(
                  _previewNights,
                  money(_previewBaseRate),
                ),
                value: money(settlement.gross),
              ),
              if (settlement.markup != 0)
                _PayoutRow(
                  label: s.pricingPayoutMarkup(
                    _formatDecimal(config.rateMarkupPercentage),
                  ),
                  value: money(settlement.markup),
                ),
              _PayoutDivider(),
              if (settlement.commission != 0)
                _PayoutRow(
                  label: s.pricingPayoutCommission(
                    _formatDecimal(config.commissionPercentage),
                  ),
                  value: money(settlement.commission),
                  negative: true,
                ),
              if (cleaningAndLinen != 0)
                _PayoutRow(
                  label: s.pricingPayoutFixedCosts,
                  value: money(cleaningAndLinen),
                  negative: true,
                ),
              if (service != 0)
                _PayoutRow(
                  label: s.pricingPayoutService(_previewGuests),
                  value: money(service),
                  negative: true,
                ),
              if (other != 0)
                _PayoutRow(
                  label: s.pricingPayoutOther,
                  value: money(other),
                  negative: true,
                ),
              _PayoutRow(
                label: s.pricingPayoutNet,
                value: money(settlement.net),
                total: true,
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
          child: Text(
            s.pricingPayoutNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Design `.prow2`: label left, tabular amount right. `.neg` prefixes a minus
/// and turns red; `.tot` gets a rule above it and the emphasised primary total.
class _PayoutRow extends StatelessWidget {
  const _PayoutRow({
    required this.label,
    required this.value,
    this.negative = false,
    this.total = false,
  });

  final String label;
  final String value;
  final bool negative;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = context.styledSpacing;

    final valueColor = total
        ? colors.primary
        : negative
        ? colors.error
        : colors.onPrimaryContainer;

    // Design `.prow2{padding:7px 0}` — 7 is off the 4px scale, so it takes the
    // neighbouring step.
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onPrimaryContainer.withValues(alpha: 0.85),
                fontWeight: total ? FontWeight.w700 : null,
              ),
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(
            negative ? '\u2212$value' : value,
            style:
                (total
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodySmall)
                    ?.copyWith(
                      color: valueColor,
                      fontWeight: total ? FontWeight.w700 : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
          ),
        ],
      ),
    );

    if (!total) return row;

    // `.prow2.tot{margin-top:6px}`, likewise rounded to the scale.
    return Container(
      margin: EdgeInsets.only(top: spacing.xs),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.onPrimaryContainer.withValues(alpha: 0.16),
          ),
        ),
      ),
      child: row,
    );
  }
}

class _PayoutDivider extends StatelessWidget {
  const _PayoutDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(
        context,
      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
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
        child: StyledTextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      padding: StyledWidgetsTheme.of(context).tiles.defaultPadding,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: theme.textTheme.bodyMedium),
          ),
          SizedBox(
            width: 100,
            child: StyledTextFormField(
              controller: controller,
              enabled: enabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              placeholder: '0',
            ),
          ),
          SizedBox(width: context.styledSpacing.sm),
          Text(
            currencyCode,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: context.styledSpacing.md),
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
                      child: Text(_costTypeLabel(context.s, t)),
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

  /// A draft over one channel's overrides.
  ///
  /// An empty field is not zero: it means the property follows the account for
  /// that field, which is why every controller starts empty when the override
  /// is absent.
  factory _ChannelDraft.from(ChannelOverride override, VoidCallback onChanged) {
    return _ChannelDraft(
      commissionController: TextEditingController(
        text: _formatOptionalDecimal(override.commissionPercentage),
      ),
      markupController: TextEditingController(
        text: _formatOptionalDecimal(override.rateMarkupPercentage),
      ),
      cleaningController: TextEditingController(
        text: _formatOptionalDecimal(override.cleaningCost?.amount),
      ),
      linenController: TextEditingController(
        text: _formatOptionalDecimal(override.linenCost?.amount),
      ),
      serviceController: TextEditingController(
        text: _formatOptionalDecimal(override.serviceCost?.amount),
      ),
      otherController: TextEditingController(
        text: _formatOptionalDecimal(override.otherCost?.amount),
      ),
      cleaningType: override.cleaningCost?.type ?? CostType.perBooking,
      linenType: override.linenCost?.type ?? CostType.perBooking,
      serviceType: override.serviceCost?.type ?? CostType.perBooking,
      otherType: override.otherCost?.type ?? CostType.perBooking,
      onChanged: onChanged,
    );
  }

  ChannelOverride toOverride() {
    CostEntry? cost(TextEditingController controller, CostType type) {
      final amount = _parseNullable(controller.text);
      if (amount == null) return null;
      return CostEntry(amount: amount, type: type);
    }

    return ChannelOverride(
      commissionPercentage: _parseNullable(commissionController.text),
      rateMarkupPercentage: _parseNullable(markupController.text),
      cleaningCost: cost(cleaningController, cleaningType),
      linenCost: cost(linenController, linenType),
      serviceCost: cost(serviceController, serviceType),
      otherCost: cost(otherController, otherType),
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

/// Thousands-separated, no decimals — the preview deals in whole currency
/// units, and the design shows `kr 3.200`.
String _formatMoney(double value) {
  final rounded = value.round().abs();
  final digits = rounded.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
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

/// How a cost multiplies, in the interface language.
String _costTypeLabel(S s, CostType type) {
  switch (type) {
    case CostType.perBooking:
      return s.pricingCostTypePerBooking;
    case CostType.perPerson:
      return s.pricingCostTypePerPerson;
    case CostType.perNight:
      return s.pricingCostTypePerNight;
  }
}
