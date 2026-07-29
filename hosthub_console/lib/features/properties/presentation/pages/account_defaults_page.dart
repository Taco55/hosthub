import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/application/account_channel_defaults_cubit.dart';
import 'package:hosthub_console/features/properties/application/property_context_cubit.dart';
import 'package:hosthub_console/features/properties/data/property_repository.dart';
import 'package:hosthub_console/features/properties/domain/booking_channel.dart';
import 'package:hosthub_console/features/properties/domain/channel_field.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings.dart';
import 'package:hosthub_console/features/properties/domain/channel_settings_resolver.dart';
import 'package:hosthub_console/features/properties/domain/property_abbreviation.dart';
import 'package:hosthub_console/features/properties/presentation/widgets/account_languages_section.dart';

/// Standaardwaarden: the account tier of everything that cascades.
///
/// The whole screen rests on one rule — **a property inherits because its own
/// value is absent**. Changing a default therefore writes exactly one row and
/// reaches every property that has not spoken for itself; nothing is copied
/// into properties, so no change can strand halfway through a backfill.
///
/// There is deliberately no property list here. The rail has one and
/// *Properties* is one; repeating it was the structural mistake of the version
/// this replaces. What the screen *does* say is who deviates — a coverage
/// figure without names is a riddle.
class AccountDefaultsPage extends StatelessWidget {
  const AccountDefaultsPage({super.key});

  @override
  Widget build(BuildContext context) => const _AccountDefaultsView();
}

class _AccountDefaultsView extends StatefulWidget {
  const _AccountDefaultsView();

  @override
  State<_AccountDefaultsView> createState() => _AccountDefaultsViewState();
}

class _AccountDefaultsViewState extends State<_AccountDefaultsView> {
  /// The draft: only the fields the owner actually touched.
  ///
  /// Sparse on purpose. It is what the impact line counts, what turns a field
  /// primary, and what `Annuleren` throws away — a full copy of the defaults
  /// could not tell "changed to the same value" from "not touched".
  final Map<({BookingChannel channel, ChannelField field}), double> _draft = {};

  BookingChannel _openChannel = BookingChannel.airbnb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AccountChannelDefaultsCubit>();
      if (cubit.state.status == AccountChannelDefaultsStatus.initial) {
        cubit.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      AccountChannelDefaultsCubit,
      AccountChannelDefaultsState
    >(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) async {
        final error = state.error;
        if (error == null) return;
        await showAppError(context, AppError.fromDomain(context, error));
        if (!context.mounted) return;
        context.read<AccountChannelDefaultsCubit>().clearError();
      },
      builder: (context, state) {
        final properties = context
            .watch<PropertyContextCubit>()
            .state
            .properties;
        final resolver = ChannelSettingsResolver.forProperties(
          accountDefaults: state.defaults,
          properties: channelOverridesOf(properties),
        );
        final propertyIds = [for (final property in properties) property.id];
        final abbreviations = uniquePropertyAbbreviations([
          for (final property in properties)
            (id: property.id, name: property.name),
        ]);

        return StyledWebPageScaffold(
          decorateLeftPane: false,
          overline: context.s.navGroupAccount,
          title: context.s.accountDefaultsTitle,
          isLoading: state.isBusy,
          leftChild: state.status == AccountChannelDefaultsStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: context.styledSpacing.lg,
                          bottom: context.styledSpacing.xl,
                        ),
                        children: [
                          if (!state.canEdit)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: context.styledSpacing.lg,
                              ),
                              child: StyledNotice(
                                message:
                                    context.s.accountDefaultsReadOnlyNotice,
                              ),
                            ),
                          StyledSection(
                            isFirstSection: true,
                            header: context.s.accountDefaultsChannelsHeader,
                            // The one rule the whole screen rests on, said
                            // where it applies rather than as a sentence under
                            // the page title.
                            footer: context.s.accountDefaultsSubtitle,
                            horizontalPadding: 0,
                            children: [
                              for (final channel in BookingChannel.values)
                                _ChannelBlock(
                                  channel: channel,
                                  isOpen: _openChannel == channel,
                                  config: _draftedConfig(state, channel),
                                  resolver: resolver,
                                  propertyIds: propertyIds,
                                  abbreviations: abbreviations,
                                  propertyNames: {
                                    for (final property in properties)
                                      property.id: property.name,
                                  },
                                  draft: _draft,
                                  enabled: state.canEdit,
                                  onToggle: () =>
                                      setState(() => _openChannel = channel),
                                  onFieldChanged: (field, value) => setState(
                                    () =>
                                        _setDraft(state, channel, field, value),
                                  ),
                                ),
                            ],
                          ),
                          const AccountLanguagesSection(),
                        ],
                      ),
                    ),
                    if (_draft.isNotEmpty)
                      _ImpactBar(
                        affected: resolver.propertiesAffectedBy(
                          propertyIds,
                          _draft.keys,
                        ),
                        propertyCount: propertyIds.length,
                        isSaving:
                            state.status == AccountChannelDefaultsStatus.saving,
                        onCancel: () => setState(_draft.clear),
                        onApply: () => _apply(state),
                      ),
                  ],
                ),
        );
      },
    );
  }

  /// The stored config with the draft laid over it — what the fields show.
  ChannelConfig _draftedConfig(
    AccountChannelDefaultsState state,
    BookingChannel channel,
  ) {
    var config = state.defaults.forChannel(channel);
    for (final entry in _draft.entries) {
      if (entry.key.channel != channel) continue;
      config = entry.key.field.withAmount(config, entry.value);
    }
    return config;
  }

  void _setDraft(
    AccountChannelDefaultsState state,
    BookingChannel channel,
    ChannelField field,
    double value,
  ) {
    final key = (channel: channel, field: field);
    final stored = field.amountIn(state.defaults.forChannel(channel));
    // Typing a value back to what it was is not a change — the field stops
    // being primary and the impact line stops counting it.
    if (channelDoublesClose(stored, value)) {
      _draft.remove(key);
    } else {
      _draft[key] = value;
    }
  }

  Future<void> _apply(AccountChannelDefaultsState state) async {
    var defaults = state.defaults;
    for (final channel in BookingChannel.values) {
      final config = _draftedConfig(state, channel);
      defaults = defaults.copyWithChannel(channel, config);
    }
    final saved = await context.read<AccountChannelDefaultsCubit>().save(
      defaults,
    );
    if (!mounted || !saved) return;
    setState(_draft.clear);
    showStyledToast(
      context,
      type: ToastificationType.success,
      description: context.s.accountDefaultsApplied,
    );
  }
}

/// One channel, collapsible, with its fields and who deviates from them.
class _ChannelBlock extends StatelessWidget {
  const _ChannelBlock({
    required this.channel,
    required this.isOpen,
    required this.config,
    required this.resolver,
    required this.propertyIds,
    required this.abbreviations,
    required this.propertyNames,
    required this.draft,
    required this.enabled,
    required this.onToggle,
    required this.onFieldChanged,
  });

  final BookingChannel channel;
  final bool isOpen;
  final ChannelConfig config;
  final ChannelSettingsResolver resolver;
  final List<int> propertyIds;
  final Map<int, String> abbreviations;
  final Map<int, String> propertyNames;
  final Map<({BookingChannel channel, ChannelField field}), double> draft;
  final bool enabled;
  final VoidCallback onToggle;
  final void Function(ChannelField field, double value) onFieldChanged;

  @override
  Widget build(BuildContext context) {
    final overriding = resolver.propertiesOverriding(propertyIds, channel);

    return StyledExpansionTile(
      initiallyExpanded: isOpen,
      onExpansionChanged: (expanded) {
        if (expanded) onToggle();
      },
      leading: BookingSourceIcon(source: channel.key, size: 22),
      title: BookingSourceIcon.label(channel.key),
      subtitle: context.s.channelSummaryCommission(
        _formatAmount(config.commissionPercentage),
      ),
      children: [
        for (final field in ChannelField.values)
          _FieldRow(
            channel: channel,
            field: field,
            config: config,
            enabled: enabled,
            isChanged: draft.containsKey((channel: channel, field: field)),
            followingCount: resolver
                .propertiesFollowing(propertyIds, channel, field)
                .length,
            propertyCount: propertyIds.length,
            onChanged: (value) => onFieldChanged(field, value),
          ),
        // The counterpart of the coverage numbers above: who deviates, and one
        // click to their Prijzen. Absent when nobody does.
        if (overriding.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: context.styledSpacing.sm),
            child: Wrap(
              spacing: context.styledSpacing.sm,
              runSpacing: context.styledSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  context.s.coverageOwnValuesAt,
                  style: context.theme.textTheme.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                for (final propertyId in overriding)
                  Tooltip(
                    message: context.s.coverageOpenPricingTooltip(
                      propertyNames[propertyId] ?? '',
                    ),
                    child: InkWell(
                      onTap: () => context.go(
                        ConsoleRoute.propertyPath(
                          propertyId,
                          PropertySection.pricing,
                        ),
                      ),
                      child: PropertyChip(
                        abbreviation: abbreviations[propertyId] ?? '??',
                        size: 24,
                        borderRadius: 7,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FieldRow extends StatefulWidget {
  const _FieldRow({
    required this.channel,
    required this.field,
    required this.config,
    required this.enabled,
    required this.isChanged,
    required this.followingCount,
    required this.propertyCount,
    required this.onChanged,
  });

  final BookingChannel channel;
  final ChannelField field;
  final ChannelConfig config;
  final bool enabled;
  final bool isChanged;
  final int followingCount;
  final int propertyCount;
  final ValueChanged<double> onChanged;

  @override
  State<_FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<_FieldRow> {
  late final TextEditingController _controller = TextEditingController(
    text: _formatAmount(widget.field.amountIn(widget.config)),
  );

  @override
  void didUpdateWidget(covariant _FieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only write back when the stored value moved under us — e.g. after
    // Annuleren — so typing never fights the controller.
    final incoming = _formatAmount(widget.field.amountIn(widget.config));
    if (!widget.isChanged && incoming != _controller.text) {
      _controller.text = incoming;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final costType = widget.field.costTypeIn(widget.config);

    return StyledTile(
      title: _fieldLabel(context, widget.field),
      subtitle: _fieldHint(context, widget.field),
      titleColor: widget.isChanged ? colors.primary : null,
      value: SizedBox(
        width: 120,
        child: StyledTextField(
          controller: _controller,
          enabled: widget.enabled,
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onChanged: (text) => widget.onChanged(parseChannelDouble(text) ?? 0),
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.field.isPercentage ? '%' : _costTypeLabel(context, costType),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Coverage per field, because a default that nobody follows is worth
          // knowing before you change it.
          Text(
            _coverageLabel(context),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _coverageLabel(BuildContext context) {
    if (widget.propertyCount == 1) {
      return widget.followingCount == 1
          ? context.s.coverageSingleFollows
          : context.s.coverageSingleOwn;
    }
    return context.s.coverageFollowing(
      widget.followingCount,
      widget.propertyCount,
    );
  }
}

/// The sticky bar that says what applying would do, before it does it.
class _ImpactBar extends StatelessWidget {
  const _ImpactBar({
    required this.affected,
    required this.propertyCount,
    required this.isSaving,
    required this.onCancel,
    required this.onApply,
  });

  /// Properties that follow at least one changed field.
  final List<int> affected;
  final int propertyCount;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final spacing = context.styledSpacing;
    final unchanged = propertyCount - affected.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _headline(context),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _detail(context, unchanged),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.md),
          StyledTextButton(
            title: context.s.cancelButton,
            enabled: !isSaving,
            onPressed: onCancel,
          ),
          SizedBox(width: spacing.sm),
          StyledButton(
            title: context.s.accountDefaultsApply,
            size: StyledButtonSize.compact,
            // Still enabled when nobody follows: the default itself moves, and
            // the next property will start from it.
            enabled: !isSaving,
            showProgressIndicatorWhenDisabled: isSaving,
            onPressed: onApply,
          ),
        ],
      ),
    );
  }

  String _headline(BuildContext context) {
    if (propertyCount == 1) {
      return affected.isEmpty
          ? context.s.accountDefaultsImpactNone
          : context.s.accountDefaultsImpactSingleProperty;
    }
    if (affected.isEmpty) return context.s.accountDefaultsImpactNone;
    return context.s.accountDefaultsImpactSome(affected.length);
  }

  String _detail(BuildContext context, int unchanged) {
    if (unchanged > 0 && affected.isNotEmpty) {
      return context.s.accountDefaultsImpactUnchanged(unchanged);
    }
    return context.s.accountDefaultsImpactNotYetApplied;
  }
}

String _fieldLabel(BuildContext context, ChannelField field) {
  return switch (field) {
    ChannelField.commission => context.s.channelFieldCommission,
    ChannelField.markup => context.s.channelFieldMarkup,
    ChannelField.cleaning => context.s.channelFieldCleaning,
    ChannelField.linen => context.s.channelFieldLinen,
    ChannelField.service => context.s.channelFieldService,
    ChannelField.other => context.s.channelFieldOther,
  };
}

String? _fieldHint(BuildContext context, ChannelField field) {
  return switch (field) {
    ChannelField.commission => context.s.channelFieldCommissionHint,
    ChannelField.markup => context.s.channelFieldMarkupHint,
    _ => null,
  };
}

String _costTypeLabel(BuildContext context, CostType? type) {
  return switch (type) {
    CostType.perPerson => context.s.costTypePerPerson,
    CostType.perNight => context.s.costTypePerNight,
    _ => context.s.costTypePerBooking,
  };
}

/// A trailing `.00` on a percentage reads as precision the owner did not ask
/// for; the value keeps whatever decimals it actually has.
String _formatAmount(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
