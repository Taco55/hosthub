import 'dart:convert';

import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/reservations/application/nightly_rates_cubit.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

enum _RevenuePeriod { month, quarter, year }

class RevenuePage extends StatelessWidget {
  const RevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RevenuePageBody();
  }
}

class _RevenuePageBody extends StatefulWidget {
  const _RevenuePageBody();

  @override
  State<_RevenuePageBody> createState() => _RevenuePageBodyState();
}

class _RevenuePageBodyState extends State<_RevenuePageBody> {
  _RevenuePeriod _period = _RevenuePeriod.year;
  DateTime _periodAnchor = _startOfPeriod(_RevenuePeriod.year, DateTime.now());
  String? _lastRequestKey;
  AdminSettings _adminSettings = AdminSettings.defaults();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdminSettings();
      _loadForProperty(
        context.read<PropertyContextCubit>().state.currentProperty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PropertyContextCubit, PropertyContextState>(
          listenWhen: (previous, current) =>
              previous.currentProperty?.lodgifyId !=
              current.currentProperty?.lodgifyId,
          listener: (context, state) {
            _lastRequestKey = null;
            _loadForProperty(state.currentProperty);
          },
        ),
        BlocListener<NightlyRatesCubit, NightlyRatesState>(
          listenWhen: (previous, current) =>
              previous.rateCurrency != current.rateCurrency &&
              current.rateCurrency != null,
          listener: (context, state) {
            final property = context
                .read<PropertyContextCubit>()
                .state
                .currentProperty;
            if (property == null) return;
            final currency = state.rateCurrency;
            if (currency == null || currency.trim().isEmpty) return;
            context
                .read<PropertyRepository>()
                .updatePropertyCurrency(property.id, currency)
                .catchError((_) {
                  /* best-effort */
                });
          },
        ),
        BlocListener<ReservationsCubit, ReservationsState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == ReservationsStatus.loaded,
          listener: (context, state) {
            final propertyId = state.propertyId;
            if (propertyId == null || propertyId.isEmpty) return;
            final range = _rangeForPeriod(_period, _periodAnchor);
            final midpoint =
                range.start.add(range.end.difference(range.start) ~/ 2);
            context.read<NightlyRatesCubit>().loadRates(
              propertyId: propertyId,
              focusedMonth: DateTime(midpoint.year, midpoint.month),
            );
          },
        ),
        BlocListener<ReservationsCubit, ReservationsState>(
          listenWhen: (previous, current) =>
              previous.error != current.error && current.error != null,
          listener: (context, state) async {
            final error = state.error;
            if (error == null) return;
            final appError = AppError.fromDomain(context, error);
            await showAppError(context, appError);
            if (!context.mounted) return;
            context.read<ReservationsCubit>().clearError();
          },
        ),
      ],
      child: BlocBuilder<ReservationsCubit, ReservationsState>(
        builder: (context, state) {
          final property = context
              .watch<PropertyContextCubit>()
              .state
              .currentProperty;
          final now = DateTime.now();
          final periodRange = _rangeForPeriod(_period, _periodAnchor);
          final canNavigateForward = _canNavigateToNextPeriod(
            _period,
            _periodAnchor,
            now,
          );
          final propertyName =
              property?.name ?? context.s.revenueUnknownProperty;
          final propertyId = property?.lodgifyId?.trim() ?? '';
          final canRefresh =
              propertyId.isNotEmpty && state.status != ReservationsStatus.loading;
          final locale = Localizations.localeOf(context).toString();
          final dateFormatter = DateFormat('d MMM yyyy', locale);
          final dateTimeFormatter = DateFormat('d MMM yyyy HH:mm', locale);
          final s = context.s;
          final periodLabel = _periodDisplayLabel(
            _period,
            periodRange.start,
            locale,
            s,
          );
          final periodRangeLabel =
              '${dateFormatter.format(periodRange.start)} - ${dateFormatter.format(periodRange.end)}';

          final bookedEntries = _entriesForRevenue(state.entries);
          final periodEntries = _entriesWithinRange(
            bookedEntries,
            start: periodRange.start,
            end: periodRange.end,
          );
          final revenueRows = periodEntries
              .map(
                (entry) => _RevenueRow.fromEntry(
                  entry,
                  settings: _adminSettings,
                  property: property,
                  unknownBookerLabel: s.revenueUnknownBooker,
                ),
              )
              .toList(growable: false);
          final totals = _RevenueTotals.fromRows(revenueRows);

          return ConsolePageScaffold(
            title: context.s.menuRevenue,
            description: context.s.revenueDescription(propertyName),
            actions: [
              Tooltip(
                message: context.s.revenueRefreshTooltip,
                child: StyledIconButton(
                  iconData: Icons.refresh,
                  onPressed: canRefresh
                      ? () => _loadForProperty(property, force: true)
                      : null,
                  isDisabled: !canRefresh,
                ),
              ),
            ],
            showLoadingIndicator: state.status == ReservationsStatus.loading,
            leftChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RevenueHeader(
                  period: _period,
                  onPeriodChanged: (value) {
                    setState(() {
                      _period = value;
                      _periodAnchor = _startOfPeriod(value, DateTime.now());
                    });
                    _loadForProperty(property, force: true);
                  },
                  onPreviousPeriod: () {
                    setState(() {
                      final currentStart = _startOfPeriod(
                        _period,
                        _periodAnchor,
                      );
                      _periodAnchor = _shiftPeriodStart(
                        _period,
                        currentStart,
                        -1,
                      );
                    });
                    _loadForProperty(property, force: true);
                  },
                  onNextPeriod: canNavigateForward
                      ? () {
                          setState(() {
                            final currentStart = _startOfPeriod(
                              _period,
                              _periodAnchor,
                            );
                            final candidate = _shiftPeriodStart(
                              _period,
                              currentStart,
                              1,
                            );
                            final latestStart = _startOfPeriod(
                              _period,
                              DateTime.now(),
                            );
                            _periodAnchor = candidate.isAfter(latestStart)
                                ? latestStart
                                : candidate;
                          });
                          _loadForProperty(property, force: true);
                        }
                      : null,
                  periodLabel: periodLabel,
                  periodRangeLabel: periodRangeLabel,
                ),
                const SizedBox(height: 12),
                _RevenuePeriodOverviewSection(
                  periodLabel: periodRangeLabel,
                  totals: totals,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildContent(
                    context,
                    state: state,
                    property: property,
                    propertyId: propertyId.isEmpty ? null : propertyId,
                    dateFormatter: dateFormatter,
                    dateTimeFormatter: dateTimeFormatter,
                    rows: revenueRows,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required ReservationsState state,
    required PropertySummary? property,
    required String? propertyId,
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
    required List<_RevenueRow> rows,
  }) {
    if (propertyId == null || propertyId.isEmpty) {
      return Center(
        child: Text(
          S.of(context).revenueNoLodgifyId,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state.status == ReservationsStatus.error) {
      return Center(
        child: Text(
          S.of(context).revenueLoadFailed,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state.status == ReservationsStatus.loading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final noBookedStaysLabel = S.of(context).revenueNoBookedStaysInPeriod;

    Widget textCell(
      BuildContext context,
      String? value, {
      FontWeight? fontWeight,
      TextAlign textAlign = TextAlign.left,
    }) {
      final safeValue = _valueOrDash(value);
      return Text(
        safeValue,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: fontWeight),
      );
    }

    Widget sourceCell(BuildContext context, String? source) {
      final resolvedSource = _valueOrDash(source);
      return Align(
        alignment: Alignment.center,
        child: Tooltip(
          message: resolvedSource,
          child: BookingSourceIcon(source: source, size: 18),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        StyledDataTable(
          variant: StyledTableVariant.card,
          dense: true,
          uppercaseHeaderLabels: false,
          layout: const StyledTableLayout(headerHeight: 58),
          columns: [
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnBooker,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              flex: 3,
              minWidth: 180,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnCheckIn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              flex: 2,
              minWidth: 120,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnCheckOut,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              flex: 2,
              minWidth: 120,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnNights,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              flex: 1,
              minWidth: 80,
              alignment: Alignment.centerRight,
              headerAlignment: Alignment.centerRight,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnNightlyRate,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              flex: 2,
              minWidth: 128,
              alignment: Alignment.centerRight,
              headerAlignment: Alignment.centerRight,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnTotal,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              flex: 2,
              minWidth: 128,
              alignment: Alignment.centerRight,
              headerAlignment: Alignment.centerRight,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnFixedCosts,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              flex: 2,
              minWidth: 128,
              alignment: Alignment.centerRight,
              headerAlignment: Alignment.centerRight,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnChannelFee,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              flex: 2,
              minWidth: 128,
              alignment: Alignment.centerRight,
              headerAlignment: Alignment.centerRight,
            ),
            StyledDataColumn(
              columnHeader: Text(
                S.of(context).revenueColumnNet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              flex: 2,
              minWidth: 128,
              alignment: Alignment.centerRight,
              headerAlignment: Alignment.centerRight,
            ),
            const StyledDataColumn(
              columnHeader: Icon(Icons.hub_outlined, size: 16),
              flex: 1,
              width: 56,
              alignment: Alignment.center,
              headerAlignment: Alignment.center,
            ),
          ],
          itemCount: rows.length,
          rowBuilder: (tableContext, index) {
            final row = rows[index];
            return [
              textCell(tableContext, row.booker, fontWeight: FontWeight.w600),
              textCell(tableContext, _formatDate(row.checkIn, dateFormatter)),
              textCell(tableContext, _formatDate(row.checkOut, dateFormatter)),
              textCell(
                tableContext,
                row.nights.toString(),
                textAlign: TextAlign.right,
              ),
              textCell(
                tableContext,
                _formatAmount(row.nightlyRate, row.currency),
                textAlign: TextAlign.right,
              ),
              textCell(
                tableContext,
                _formatAmount(row.totalRevenue, row.currency),
                textAlign: TextAlign.right,
              ),
              textCell(
                tableContext,
                _formatAmount(row.serviceCosts, row.currency),
                textAlign: TextAlign.right,
              ),
              textCell(
                tableContext,
                _formatAmount(row.fees, row.currency),
                textAlign: TextAlign.right,
              ),
              textCell(
                tableContext,
                _formatAmount(row.netRevenue, row.currency),
                textAlign: TextAlign.right,
                fontWeight: FontWeight.w600,
              ),
              sourceCell(tableContext, row.source),
            ];
          },
          onRowTap: (_, index) {
            _showReservationDetails(
              context,
              rows[index].entry,
              dateFormatter: dateFormatter,
              dateTimeFormatter: dateTimeFormatter,
              settings: _adminSettings,
              property: property,
            );
          },
          showTableWhenEmpty: true,
          emptyLabel: noBookedStaysLabel,
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              noBookedStaysLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  Future<void> _showReservationDetails(
    BuildContext context,
    Reservation entry, {
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
    required AdminSettings settings,
    required PropertySummary? property,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _ReservationDetailsDialog(
          entry: entry,
          dateFormatter: dateFormatter,
          dateTimeFormatter: dateTimeFormatter,
          settings: settings,
          property: property,
        );
      },
    );
  }

  Future<void> _loadAdminSettings() async {
    try {
      final settings = await context.read<AdminSettingsRepository>().load();
      if (!mounted) return;
      setState(() => _adminSettings = settings);
    } catch (_) {
      // Keep defaults when admin settings are unavailable.
    }
  }

  void _loadForProperty(PropertySummary? property, {bool force = false}) {
    final lodgifyId = property?.lodgifyId?.trim();
    if (lodgifyId == null || lodgifyId.isEmpty) {
      _lastRequestKey = null;
      return;
    }

    final range = _rangeForPeriod(_period, _periodAnchor);
    final requestKey =
        '$lodgifyId:${range.start.toIso8601String()}:${range.end.toIso8601String()}';

    final calendarState = context.read<ReservationsCubit>().state;
    final hasSameCalendarRequest =
        calendarState.propertyId == lodgifyId &&
        calendarState.rangeStart == range.start &&
        calendarState.rangeEnd == range.end &&
        (calendarState.status == ReservationsStatus.loading ||
            calendarState.status == ReservationsStatus.loaded);

    if (!force && (_lastRequestKey == requestKey || hasSameCalendarRequest)) {
      _lastRequestKey = requestKey;
      return;
    }
    _lastRequestKey = requestKey;

    context.read<ReservationsCubit>().loadReservations(
      propertyId: lodgifyId,
      start: range.start,
      end: range.end,
    );
    // Rates worden geladen via BlocListener zodra reserveringen klaar zijn.
  }
}

class _RevenueHeader extends StatelessWidget {
  const _RevenueHeader({
    required this.period,
    required this.onPeriodChanged,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.periodLabel,
    required this.periodRangeLabel,
  });

  final _RevenuePeriod period;
  final ValueChanged<_RevenuePeriod> onPeriodChanged;
  final VoidCallback? onPreviousPeriod;
  final VoidCallback? onNextPeriod;
  final String periodLabel;
  final String periodRangeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StyledSegmentedControl(
          labels: [
            s.revenuePeriodMonth,
            s.revenuePeriodQuarter,
            s.revenuePeriodYear,
          ],
          selectedIndex: period.index,
          onChanged: (index) {
            onPeriodChanged(_RevenuePeriod.values[index]);
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildPeriodArrowButton(
              context,
              iconData: Icons.chevron_left_rounded,
              onPressed: onPreviousPeriod,
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(periodRangeLabel, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(width: 12),
            _buildPeriodArrowButton(
              context,
              iconData: Icons.chevron_right_rounded,
              onPressed: onNextPeriod,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodArrowButton(
    BuildContext context, {
    required IconData iconData,
    required VoidCallback? onPressed,
  }) {
    final enabled = onPressed != null;
    final colors = Theme.of(context).colorScheme;
    final iconColor = enabled
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant.withValues(alpha: 0.95);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.4,
      child: StyledButton(
        titleWidget: Icon(iconData, size: 24, color: iconColor),
        onPressed: onPressed,
        enabled: enabled,
        minWidth: 56,
        minHeight: 44,
        horizontalSpacing: 0,
        padding: EdgeInsets.zero,
        cornerRadius: 10,
        borderWidth: 1.2,
        backgroundColor: colors.primaryContainer,
        backgroundColorDisabled: colors.surfaceContainerHighest,
        borderColor: colors.primary.withValues(alpha: 0.45),
        borderColorDisabled: colors.outline.withValues(alpha: 0.85),
        enableShadow: false,
        enableShrinking: enabled,
      ),
    );
  }
}

class _RevenuePeriodOverviewSection extends StatelessWidget {
  const _RevenuePeriodOverviewSection({
    required this.periodLabel,
    required this.totals,
  });

  final String periodLabel;
  final _RevenueTotals totals;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return StyledSection(
      isFirstSection: true,
      headerInsideGroup: true,
      header: s.revenueOverviewHeader,
      headerStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      childMinHeight: 24,
      subheader: periodLabel,
      children: [
        StyledTile(
          title: s.revenueTotalBookings,
          value: totals.bookingCount.toString(),
        ),
        StyledTile(
          title: s.revenueTotalRevenue,
          value: _formatAmount(totals.totalRevenue, totals.currency),
        ),
        StyledTile(
          title: s.revenueFees,
          value: _formatAmount(totals.totalFees, totals.currency),
        ),
        StyledTile(
          title: s.revenueServiceCosts,
          value: _formatAmount(totals.totalServiceCosts, totals.currency),
        ),
        StyledTile(
          title: s.revenueNetRevenue,
          value: _formatAmount(totals.totalNetRevenue, totals.currency),
          titleStyle: const TextStyle(fontWeight: FontWeight.w600),
          valueStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _RevenueRow {
  const _RevenueRow({
    required this.entry,
    required this.booker,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.nightlyRate,
    required this.totalRevenue,
    required this.serviceCosts,
    required this.fees,
    required this.netRevenue,
    required this.currency,
    required this.source,
  });

  final Reservation entry;
  final String booker;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int nights;
  final num? nightlyRate;
  final num? totalRevenue;
  final num? serviceCosts;
  final num? fees;
  final num? netRevenue;
  final String? currency;
  final String? source;

  factory _RevenueRow.fromEntry(
    Reservation entry, {
    required AdminSettings settings,
    required PropertySummary? property,
    required String unknownBookerLabel,
  }) {
    final revenue = _extractRevenue(entry);
    final nights = _stayNights(entry.startDate, entry.endDate) ?? 1;
    final totalRevenue = _normalizeMoney(revenue.total ?? entry.totalAmount);
    final serviceCosts = _normalizeMoney(
      revenue.fixedCosts ??
          _fallbackFixedCostsFromProperty(
            property,
            entry.source,
            guests: entry.guestCount ?? 1,
            nights: nights,
          ),
    );
    final fees = _normalizeMoney(
      revenue.channelFees ??
          revenue.fees ??
          _fallbackChannelFeeFromRules(entry, totalRevenue, settings, property),
    );

    final netRevenue = _normalizeMoney(
      revenue.net ??
          (totalRevenue == null
              ? null
              : totalRevenue - (serviceCosts ?? 0) - (fees ?? 0)),
    );

    final nightlyRate = _normalizeMoney(
      revenue.nightlyRate ??
          (totalRevenue == null || nights <= 0 ? null : totalRevenue / nights),
    );

    return _RevenueRow(
      entry: entry,
      booker: _guestDisplayName(entry, fallback: unknownBookerLabel),
      checkIn: entry.startDate,
      checkOut: entry.endDate,
      nights: nights,
      nightlyRate: nightlyRate,
      totalRevenue: totalRevenue,
      serviceCosts: serviceCosts,
      fees: fees,
      netRevenue: netRevenue,
      currency: revenue.currency ?? entry.currency,
      source: entry.source,
    );
  }
}

class _RevenueTotals {
  const _RevenueTotals({
    required this.bookingCount,
    required this.totalNights,
    required this.totalRevenue,
    required this.totalServiceCosts,
    required this.totalFees,
    required this.totalNetRevenue,
    required this.averageNightlyRate,
    required this.currency,
  });

  final int bookingCount;
  final int totalNights;
  final num? totalRevenue;
  final num? totalServiceCosts;
  final num? totalFees;
  final num? totalNetRevenue;
  final num? averageNightlyRate;
  final String? currency;

  factory _RevenueTotals.fromRows(List<_RevenueRow> rows) {
    num? sumField(num? Function(_RevenueRow row) selector) {
      num total = 0;
      var hasValue = false;
      for (final row in rows) {
        final value = selector(row);
        if (value == null) continue;
        total += value;
        hasValue = true;
      }
      return hasValue ? _normalizeMoney(total) : null;
    }

    var nights = 0;
    for (final row in rows) {
      nights += row.nights;
    }

    final totalRevenue = sumField((row) => row.totalRevenue);
    final totalServiceCosts = sumField((row) => row.serviceCosts);
    final totalFees = sumField((row) => row.fees);
    final totalNetRevenue = sumField((row) => row.netRevenue);

    final averageNightlyRate = totalRevenue != null && nights > 0
        ? _normalizeMoney(totalRevenue / nights)
        : null;

    String? currency;
    for (final row in rows) {
      final c = row.currency?.trim();
      if (c != null && c.isNotEmpty) {
        currency = c;
        break;
      }
    }

    return _RevenueTotals(
      bookingCount: rows.length,
      totalNights: nights,
      totalRevenue: totalRevenue,
      totalServiceCosts: totalServiceCosts,
      totalFees: totalFees,
      totalNetRevenue: totalNetRevenue,
      averageNightlyRate: averageNightlyRate,
      currency: currency,
    );
  }
}

class _ExtractedRevenue {
  const _ExtractedRevenue({
    required this.currency,
    required this.total,
    required this.nightlyRate,
    required this.fixedCosts,
    required this.channelFees,
    required this.fees,
    required this.net,
  });

  final String? currency;
  final num? total;
  final num? nightlyRate;
  final num? fixedCosts;
  final num? channelFees;
  final num? fees;
  final num? net;
}

enum _RevenueLineItemKind { unknown, nightly, fee, tax }

class _RevenueLineItem {
  const _RevenueLineItem({
    required this.label,
    required this.amount,
    required this.kind,
  });

  final String label;
  final num amount;
  final _RevenueLineItemKind kind;
}

class _DateRange {
  const _DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _startOfPeriod(_RevenuePeriod period, DateTime anchor) {
  final date = _dateOnly(anchor);
  switch (period) {
    case _RevenuePeriod.month:
      return DateTime(date.year, date.month, 1);
    case _RevenuePeriod.quarter:
      final quarterStartMonth = ((date.month - 1) ~/ 3) * 3 + 1;
      return DateTime(date.year, quarterStartMonth, 1);
    case _RevenuePeriod.year:
      return DateTime(date.year, 1, 1);
  }
}

DateTime _endOfPeriod(_RevenuePeriod period, DateTime start) {
  switch (period) {
    case _RevenuePeriod.month:
      return DateTime(start.year, start.month + 1, 0);
    case _RevenuePeriod.quarter:
      return DateTime(start.year, start.month + 3, 0);
    case _RevenuePeriod.year:
      return DateTime(start.year + 1, 1, 0);
  }
}

DateTime _shiftPeriodStart(_RevenuePeriod period, DateTime start, int steps) {
  switch (period) {
    case _RevenuePeriod.month:
      return DateTime(start.year, start.month + steps, 1);
    case _RevenuePeriod.quarter:
      return DateTime(start.year, start.month + (steps * 3), 1);
    case _RevenuePeriod.year:
      return DateTime(start.year + steps, 1, 1);
  }
}

bool _canNavigateToNextPeriod(
  _RevenuePeriod period,
  DateTime selectedAnchor,
  DateTime now,
) {
  final selectedStart = _startOfPeriod(period, selectedAnchor);
  final currentStart = _startOfPeriod(period, now);
  return selectedStart.isBefore(currentStart);
}

_DateRange _rangeForPeriod(_RevenuePeriod period, DateTime anchor) {
  final periodStart = _startOfPeriod(period, anchor);
  final periodEnd = _endOfPeriod(period, periodStart);
  return _DateRange(start: periodStart, end: periodEnd);
}

String _periodDisplayLabel(
  _RevenuePeriod period,
  DateTime periodStart,
  String locale,
  S s,
) {
  switch (period) {
    case _RevenuePeriod.month:
      return DateFormat('MMMM yyyy', locale).format(periodStart);
    case _RevenuePeriod.quarter:
      final quarter = ((periodStart.month - 1) ~/ 3) + 1;
      return s.revenueQuarterLabel(
        quarter.toString(),
        periodStart.year.toString(),
      );
    case _RevenuePeriod.year:
      return periodStart.year.toString();
  }
}

List<Reservation> _sortedBookings(List<Reservation> entries) {
  final bookings = entries.where(_isBooking).toList();
  _sortEntriesByStart(bookings);
  return bookings;
}

List<Reservation> _entriesForRevenue(List<Reservation> entries) {
  final strict = _sortedBookings(entries);
  final relaxed = entries.where(_isLikelyRevenueEntry).toList();
  _sortEntriesByStart(relaxed);

  final merged = <Reservation>{...strict, ...relaxed}.toList();
  _sortEntriesByStart(merged);
  if (merged.isNotEmpty) return merged;

  // Fallback: keep non-availability entries so the table does not go empty
  // when payload field mapping changes in Lodgify responses.
  final broad = entries.where((entry) {
    final status = entry.status?.trim().toLowerCase();
    if (status == null || status.isEmpty) return true;
    return !status.contains('available') && !status.contains('inquiry');
  }).toList();
  _sortEntriesByStart(broad);
  if (broad.isNotEmpty) return broad;

  final all = [...entries];
  _sortEntriesByStart(all);
  return all;
}

void _sortEntriesByStart(List<Reservation> entries) {
  entries.sort((a, b) {
    final aStart = a.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bStart = b.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aStart.compareTo(bStart);
  });
}

List<Reservation> _entriesWithinRange(
  List<Reservation> entries, {
  required DateTime start,
  required DateTime end,
}) {
  final startDate = DateTime(start.year, start.month, start.day);
  final endDate = DateTime(end.year, end.month, end.day);
  return entries
      .where((entry) => _entryOverlapsRange(entry, startDate, endDate))
      .toList(growable: false);
}

bool _entryOverlapsRange(
  Reservation entry,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final referenceStart = entry.startDate ?? entry.createdAt ?? entry.updatedAt;
  final referenceEnd =
      entry.endDate ?? entry.startDate ?? entry.createdAt ?? entry.updatedAt;
  if (referenceStart == null && referenceEnd == null) {
    return true;
  }
  if (referenceStart == null || referenceEnd == null) {
    return true;
  }
  final start = referenceStart.isBefore(referenceEnd)
      ? referenceStart
      : referenceEnd;
  final end = referenceEnd.isAfter(referenceStart)
      ? referenceEnd
      : referenceStart;
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);
  return !endDay.isBefore(rangeStart) && !startDay.isAfter(rangeEnd);
}

bool _isBooking(Reservation entry) {
  final hasReservationId = entry.reservationId?.trim().isNotEmpty ?? false;
  final hasGuestIdentity =
      entry.guestName?.trim().isNotEmpty == true ||
      entry.guestEmail?.trim().isNotEmpty == true;
  final hasAmount = entry.totalAmount != null && entry.totalAmount! > 0;
  final hasBookingSignal = hasReservationId || hasGuestIdentity || hasAmount;

  final status = entry.status?.trim().toLowerCase();
  if (status != null && status.isNotEmpty) {
    const nonBookingKeywords = <String>[
      'available',
      'inquiry',
      'quote',
      'declined',
    ];
    if (nonBookingKeywords.any(status.contains)) {
      return false;
    }

    const maybeNonBookingKeywords = <String>[
      'blocked',
      'maintenance',
      'cancelled',
      'canceled',
    ];
    if (maybeNonBookingKeywords.any(status.contains)) {
      return hasBookingSignal;
    }

    const bookingKeywords = <String>[
      'booked',
      'reserved',
      'confirmed',
      'checked in',
      'checked-in',
      'arrived',
      'stayed',
    ];
    if (bookingKeywords.any(status.contains)) {
      return true;
    }

    if (status.contains('unavailable')) {
      return true;
    }

    return hasBookingSignal;
  }

  return hasBookingSignal;
}

bool _isLikelyRevenueEntry(Reservation entry) {
  final hasReservationId = entry.reservationId?.trim().isNotEmpty == true;
  final hasGuestIdentity =
      entry.guestName?.trim().isNotEmpty == true ||
      entry.guestEmail?.trim().isNotEmpty == true;
  final hasAmount = entry.totalAmount != null && entry.totalAmount! > 0;
  final hasSource = entry.source?.trim().isNotEmpty == true;

  final status = entry.status?.trim().toLowerCase();
  if (status != null && status.isNotEmpty) {
    const definitelyNonBookingKeywords = <String>[
      'available',
      'blocked',
      'maintenance',
      'inquiry',
      'quote',
      'declined',
    ];
    if (definitelyNonBookingKeywords.any(status.contains)) {
      return hasReservationId || hasGuestIdentity || hasAmount;
    }
  }

  return hasReservationId || hasGuestIdentity || hasAmount || hasSource;
}

int? _stayNights(DateTime? start, DateTime? end) {
  if (start == null || end == null) return null;
  final nights = DateTime(
    end.year,
    end.month,
    end.day,
  ).difference(DateTime(start.year, start.month, start.day)).inDays;
  return nights <= 0 ? 1 : nights;
}

String _guestDisplayName(Reservation entry, {required String fallback}) {
  final name = entry.guestName?.trim();
  if (name == null || name.isEmpty) return fallback;
  return name;
}

String _guestBreakdown(Reservation entry, {String unknownLabel = '-'}) {
  final adults = entry.adultCount;
  final children = entry.childCount;
  final hasBreakdown = adults != null || children != null;
  final totalGuests = _resolvedGuestTotal(entry);

  if (totalGuests == null && !hasBreakdown) {
    return unknownLabel;
  }

  if (!hasBreakdown) {
    return totalGuests?.toString() ?? unknownLabel;
  }

  final adultsText = adults?.toString() ?? '?';
  final childrenText = children?.toString() ?? '?';
  final adultsAndChildren = (adults ?? 0) + (children ?? 0);
  final resolvedTotal = adults != null && children != null
      ? adultsAndChildren
      : (totalGuests ?? adultsAndChildren);
  return '$resolvedTotal ($adultsText + $childrenText)';
}

int? _resolvedGuestTotal(Reservation entry) {
  if (entry.guestCount != null) return entry.guestCount;

  final adults = entry.adultCount;
  final children = entry.childCount;
  final infants = entry.infantCount;
  if (adults == null && children == null && infants == null) return null;
  return (adults ?? 0) + (children ?? 0) + (infants ?? 0);
}

_ExtractedRevenue _extractRevenue(Reservation entry) {
  final raw = entry.raw;
  final currency =
      _readFirstStringFromMap(raw, const [
        ['currency'],
        ['currencyCode'],
        ['currency_code'],
        ['pricing', 'currency'],
        ['financials', 'currency'],
        ['money', 'currency'],
      ]) ??
      entry.currency;

  final total = _normalizeMoney(
    entry.totalAmount ??
        _readFirstNumFromMap(raw, const [
          ['totalAmount'],
          ['total_amount'],
          ['total'],
          ['amount'],
          ['price'],
          ['pricing', 'total'],
          ['quote', 'total'],
          ['financials', 'total'],
        ]),
  );

  final nightlyRate = _normalizeMoney(
    _readFirstNumFromMap(raw, const [
      ['nightlyRate'],
      ['nightly_rate'],
      ['pricing', 'nightlyRate'],
      ['pricing', 'nightly_rate'],
      ['financials', 'nightlyRate'],
      ['financials', 'nightly_rate'],
    ]),
  );

  final lines = _extractRevenueLineItems(raw);

  final directFixedCosts = _sumMoney([
    _readFirstNumFromMap(raw, const [
      ['serviceFee'],
      ['service_fee'],
      ['fees', 'service'],
      ['pricing', 'serviceFee'],
      ['pricing', 'service_fee'],
      ['financials', 'service'],
      ['financials', 'serviceFee'],
    ]),
    _readFirstNumFromMap(raw, const [
      ['cleaningFee'],
      ['cleaning_fee'],
      ['cleaning'],
      ['cleaningCost'],
      ['cleaning_cost'],
      ['cleaningCosts'],
      ['cleaning_costs'],
      ['fees', 'cleaning'],
      ['pricing', 'cleaningFee'],
      ['pricing', 'cleaning_fee'],
      ['pricing', 'cleaning'],
      ['financials', 'cleaning'],
    ]),
    _readFirstNumFromMap(raw, const [
      ['linenFee'],
      ['linen_fee'],
      ['linensFee'],
      ['linens_fee'],
      ['linen'],
      ['linens'],
      ['bedlinen'],
      ['bed_linen'],
      ['bedLinen'],
      ['bedLinenCost'],
      ['bed_linen_cost'],
      ['linenRental'],
      ['linen_rental'],
      ['bedLinenFee'],
      ['bed_linen_fee'],
      ['fees', 'linen'],
      ['fees', 'linens'],
      ['pricing', 'linenFee'],
      ['pricing', 'linensFee'],
      ['pricing', 'linen'],
      ['pricing', 'linens'],
      ['financials', 'linen'],
      ['financials', 'linens'],
    ]),
  ]);

  final directChannelFees = _extractDirectChannelFee(raw);

  final derivedFixedCosts = _sumLineItemsWhere(
    lines,
    (line) =>
        _isFixedCostLabel(line.label) ||
        (line.kind == _RevenueLineItemKind.fee &&
            !_isChannelFeeLabel(line.label)),
  );

  final derivedChannelFees = _sumLineItemsWhere(
    lines,
    (line) => _isChannelFeeLabel(line.label),
  );

  num? fixedCosts = _normalizeMoney(directFixedCosts ?? derivedFixedCosts);
  num? channelFees = _normalizeMoney(directChannelFees ?? derivedChannelFees);
  channelFees = _sanitizeChannelFee(channelFees, total);
  num? fees = _normalizeMoney(channelFees);

  final net = _normalizeMoney(
    _readFirstNumFromMap(raw, const [
      ['net'],
      ['netAmount'],
      ['net_amount'],
      ['financials', 'net'],
      ['revenue', 'net'],
    ]),
  );

  return _ExtractedRevenue(
    currency: currency,
    total: total,
    nightlyRate: nightlyRate,
    fixedCosts: fixedCosts,
    channelFees: channelFees,
    fees: fees,
    net: net,
  );
}

List<_RevenueLineItem> _extractRevenueLineItems(Map<String, dynamic> raw) {
  final items = <_RevenueLineItem>[];
  final seen = <String>{};

  void addLineItem(
    String? label,
    num? amount, {
    _RevenueLineItemKind kind = _RevenueLineItemKind.unknown,
  }) {
    final resolvedLabel = label?.trim();
    final normalizedAmount = _normalizeMoney(amount);
    if (resolvedLabel == null ||
        resolvedLabel.isEmpty ||
        normalizedAmount == null) {
      return;
    }
    final key =
        '${resolvedLabel.toLowerCase()}|${normalizedAmount.toStringAsFixed(6)}|$kind';
    if (!seen.add(key)) return;
    items.add(
      _RevenueLineItem(
        label: resolvedLabel,
        amount: normalizedAmount,
        kind: kind,
      ),
    );
  }

  void readLabelValueItems(
    Object? source, {
    _RevenueLineItemKind kind = _RevenueLineItemKind.unknown,
  }) {
    if (source is! List) return;
    for (final entry in source) {
      final map = _asStringDynamicMap(entry);
      if (map == null) continue;
      final label = _readFirstStringFromMap(map, const [
        ['label'],
        ['name'],
        ['description'],
        ['title'],
        ['type'],
        ['itemType'],
        ['item_type'],
        ['feeType'],
        ['fee_type'],
        ['code'],
      ]);
      final amount = _readFirstNumFromMap(map, const [
        ['amount'],
        ['price'],
        ['total'],
        ['subtotal'],
        ['value'],
        ['fee'],
        ['cost'],
        ['gross'],
        ['net'],
      ]);
      final resolvedKind = kind == _RevenueLineItemKind.unknown
          ? _kindFromLabel(label)
          : kind;
      addLineItem(label, amount, kind: resolvedKind);
    }
  }

  final roomTypes =
      _readByPathFromMap(raw, const ['room_types']) ??
      _readByPathFromMap(raw, const ['roomTypes']);
  if (roomTypes is List) {
    for (final roomType in roomTypes) {
      final roomMap = _asStringDynamicMap(roomType);
      if (roomMap == null) continue;
      final priceTypes =
          _readByPathFromMap(roomMap, const ['price_types']) ??
          _readByPathFromMap(roomMap, const ['priceTypes']);
      if (priceTypes is! List) continue;

      for (final priceType in priceTypes) {
        final typeMap = _asStringDynamicMap(priceType);
        if (typeMap == null) continue;

        final rawType = _readByPathFromMap(typeMap, const ['type']);
        final typeValue = _coerceInt(rawType);
        final kind = switch (typeValue) {
          0 => _RevenueLineItemKind.nightly,
          2 => _RevenueLineItemKind.fee,
          4 => _RevenueLineItemKind.tax,
          _ => _RevenueLineItemKind.unknown,
        };

        final subtotal = _readFirstNumFromMap(typeMap, const [
          ['subtotal'],
          ['amount'],
          ['total'],
        ]);
        final typeLabel = _readFirstStringFromMap(typeMap, const [
          ['description'],
          ['name'],
          ['title'],
        ]);
        addLineItem(typeLabel, subtotal, kind: kind);

        final nestedPrices =
            _readByPathFromMap(typeMap, const ['prices']) ??
            _readByPathFromMap(typeMap, const ['items']);
        readLabelValueItems(nestedPrices, kind: kind);
      }
    }
  }

  const genericSources = [
    ['add_ons'],
    ['addOns'],
    ['other_items'],
    ['otherItems'],
    ['lines'],
    ['items'],
    ['priceLines'],
    ['breakdown'],
    ['fees'],
    ['pricing', 'fees'],
    ['pricing', 'breakdown'],
    ['financials', 'fees'],
    ['financials', 'breakdown'],
  ];
  for (final path in genericSources) {
    readLabelValueItems(_readByPathFromMap(raw, path));
  }

  void walkDynamic(Object? node) {
    if (node is List) {
      for (final item in node) {
        walkDynamic(item);
      }
      return;
    }

    final map = _asStringDynamicMap(node);
    if (map == null) return;

    final label = _readFirstStringFromMap(map, const [
      ['label'],
      ['name'],
      ['description'],
      ['title'],
      ['type'],
      ['itemType'],
      ['item_type'],
      ['feeType'],
      ['fee_type'],
      ['code'],
    ]);
    final amount = _readFirstNumFromMap(map, const [
      ['amount'],
      ['price'],
      ['total'],
      ['subtotal'],
      ['value'],
      ['fee'],
      ['cost'],
      ['gross'],
      ['net'],
    ]);
    if (label != null && amount != null) {
      addLineItem(label, amount, kind: _kindFromLabel(label));
    }

    for (final entry in map.entries) {
      final key = entry.key.trim();
      final amountFromValue = _parseAmount(entry.value);
      if (amountFromValue != null && _looksLikeCostOrFeeKey(key)) {
        addLineItem(key, amountFromValue, kind: _kindFromLabel(key));
      }
      walkDynamic(entry.value);
    }
  }

  walkDynamic(raw);

  return items;
}

_RevenueLineItemKind _kindFromLabel(String? label) {
  final normalized = label?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return _RevenueLineItemKind.unknown;
  if (normalized.contains('tax') || normalized.contains('vat')) {
    return _RevenueLineItemKind.tax;
  }
  if (normalized.contains('nightly') ||
      normalized.contains('rent') ||
      normalized.contains('base rate') ||
      normalized.contains('nachttarief') ||
      normalized.contains('huur')) {
    return _RevenueLineItemKind.nightly;
  }
  if (normalized.contains('fee') ||
      normalized.contains('clean') ||
      normalized.contains('schoon') ||
      normalized.contains('linen') ||
      normalized.contains('linnen') ||
      normalized.contains('towel') ||
      normalized.contains('service') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota') ||
      _hasBookingChannelSignal(normalized) ||
      normalized.contains('airbnb')) {
    return _RevenueLineItemKind.fee;
  }
  return _RevenueLineItemKind.unknown;
}

bool _looksLikeCostOrFeeKey(String key) {
  final normalized = key.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return normalized.contains('fee') ||
      normalized.contains('cost') ||
      normalized.contains('clean') ||
      normalized.contains('schoon') ||
      normalized.contains('linen') ||
      normalized.contains('linnen') ||
      normalized.contains('service') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota') ||
      _hasBookingChannelSignal(normalized) ||
      normalized.contains('airbnb');
}

bool _isFixedCostLabel(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return normalized.contains('clean') ||
      normalized.contains('schoon') ||
      normalized.contains('linen') ||
      normalized.contains('linnen') ||
      normalized.contains('towel') ||
      normalized.contains('service');
}

bool _isChannelFeeLabel(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return _hasBookingChannelSignal(normalized) ||
      normalized.contains('airbnb') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota') ||
      normalized.contains('platform');
}

bool _hasBookingChannelSignal(String normalized) {
  if (!normalized.contains('booking')) return false;
  if (normalized.contains('booking.com') ||
      normalized.contains('booking com')) {
    return true;
  }
  return normalized.contains('fee') ||
      normalized.contains('cost') ||
      normalized.contains('commission') ||
      normalized.contains('commiss') ||
      normalized.contains('channel') ||
      normalized.contains('ota');
}

num? _sumLineItemsWhere(
  List<_RevenueLineItem> lines,
  bool Function(_RevenueLineItem line) predicate,
) {
  num total = 0;
  var hasValue = false;
  for (final line in lines) {
    if (!predicate(line)) continue;
    total += line.amount;
    hasValue = true;
  }
  return hasValue ? _normalizeMoney(total) : null;
}

num? _sumMoney(List<num?> values) {
  num total = 0;
  var hasValue = false;
  for (final value in values) {
    final normalized = _normalizeMoney(value);
    if (normalized == null) continue;
    total += normalized;
    hasValue = true;
  }
  return hasValue ? _normalizeMoney(total) : null;
}

num? _extractDirectChannelFee(Map<String, dynamic> raw) {
  final explicitChannelFee = _readFirstNumFromMap(raw, const [
    ['commission'],
    ['commissionFee'],
    ['commission_fee'],
    ['bookingComission'],
    ['bookingComissionFee'],
    ['bookingCommission'],
    ['booking_commission'],
    ['channelFee'],
    ['channel_fee'],
    ['otaFee'],
    ['ota_fee'],
    ['platformFee'],
    ['platform_fee'],
    ['airbnbFee'],
    ['airbnb_fee'],
    ['airbnbCommission'],
    ['airbnb_commission'],
    ['fees', 'commission'],
    ['fees', 'channel'],
    ['fees', 'ota'],
    ['fees', 'airbnb'],
    ['pricing', 'commission'],
    ['pricing', 'channelFee'],
    ['pricing', 'otaFee'],
    ['pricing', 'airbnbFee'],
    ['financials', 'commission'],
    ['financials', 'channelFee'],
    ['financials', 'otaFee'],
    ['financials', 'airbnbFee'],
  ]);

  final bookingSpecificFee = _readFirstNumFromMap(raw, const [
    ['bookingFee'],
    ['booking_fee'],
    ['fees', 'booking'],
    ['pricing', 'bookingFee'],
    ['financials', 'bookingFee'],
  ]);

  return _normalizeMoney(explicitChannelFee ?? bookingSpecificFee);
}

num? _sanitizeChannelFee(num? channelFee, num? total) {
  final normalizedFee = _normalizeMoney(channelFee);
  if (normalizedFee == null) return null;

  final normalizedTotal = _normalizeMoney(total);
  if (normalizedTotal == null) return normalizedFee;

  final totalAbsolute = normalizedTotal.abs();
  if (totalAbsolute < 0.01) return normalizedFee;

  final ratio = normalizedFee.abs() / totalAbsolute;
  if (ratio >= 0.95) {
    return null;
  }

  return normalizedFee;
}

num? _fallbackFixedCostsFromProperty(
  PropertySummary? property,
  String? source, {
  int guests = 1,
  int nights = 1,
}) {
  if (property == null) return null;
  final config = property.channelSettings.configForSource(source);
  final total = config.totalCosts(guests: guests, nights: nights);
  return total > 0 ? _normalizeMoney(total) : null;
}

/// Resolve a single cost entry from channel settings for display in the
/// reservation details breakdown.
num? _feeFromPriceTypes(
  Map<String, dynamic> raw,
  bool Function(String label) labelMatcher,
) {
  final roomTypes =
      _readByPathFromMap(raw, const ['room_types']) ??
      _readByPathFromMap(raw, const ['roomTypes']);
  if (roomTypes is! List) return null;
  for (final roomType in roomTypes) {
    final roomMap = _asStringDynamicMap(roomType);
    if (roomMap == null) continue;
    final priceTypes =
        _readByPathFromMap(roomMap, const ['price_types']) ??
        _readByPathFromMap(roomMap, const ['priceTypes']);
    if (priceTypes is! List) continue;
    for (final priceType in priceTypes) {
      final typeMap = _asStringDynamicMap(priceType);
      if (typeMap == null) continue;
      final rawType = _readByPathFromMap(typeMap, const ['type']);
      final typeValue = _coerceInt(rawType);
      if (typeValue != 2) continue; // only fee-type items
      final description = _readFirstStringFromMap(typeMap, const [
        ['description'],
        ['name'],
        ['title'],
      ]);
      if (description != null && labelMatcher(description)) {
        final subtotal = _readFirstNumFromMap(typeMap, const [
          ['subtotal'],
          ['amount'],
          ['total'],
        ]);
        final normalized = _normalizeMoney(subtotal);
        if (normalized != null) return normalized;
      }
    }
  }
  return null;
}

num? _channelCostFallback(
  PropertySummary? property,
  Reservation entry,
  CostEntry Function(ChannelConfig) selector,
) {
  if (property == null) return null;
  final config = property.channelSettings.configForSource(entry.source);
  final cost = selector(config);
  if (cost.amount <= 0) return null;
  final nights = _stayNights(entry.startDate, entry.endDate) ?? 1;
  final resolved = cost.resolve(guests: entry.guestCount ?? 1, nights: nights);
  return resolved > 0 ? _normalizeMoney(resolved) : null;
}

num? _fallbackChannelFeeFromRules(
  Reservation entry,
  num? totalRevenue,
  AdminSettings settings,
  PropertySummary? property,
) {
  final total = _normalizeMoney(totalRevenue);
  if (total == null || total <= 0) return null;

  final percentage = _channelFeePercentageForSource(
    entry.source,
    settings,
    property,
  );
  if (percentage <= 0) return null;
  return _normalizeMoney(total * (percentage / 100));
}

double _channelFeePercentageForSource(
  String? source,
  AdminSettings settings,
  PropertySummary? property,
) {
  // Use per-channel commission override from channel settings if available.
  final override = property?.channelSettings
      .configForSource(source)
      .commissionPercentage;
  if (override != null) return override;

  // Fall back to admin defaults.
  final normalized = source?.trim().toLowerCase() ?? '';
  if (normalized.contains('booking')) {
    return settings.bookingChannelFeePercentage;
  }
  if (normalized.contains('airbnb')) {
    return settings.airbnbChannelFeePercentage;
  }
  return settings.otherChannelFeePercentage;
}

num? _readFirstNumFromMap(Map<String, dynamic> map, List<List<String>> paths) {
  for (final path in paths) {
    final value = _readByPathFromMap(map, path);
    final amount = _parseAmount(value);
    if (amount != null) return amount;
  }
  return null;
}

String? _readFirstStringFromMap(
  Map<String, dynamic> map,
  List<List<String>> paths,
) {
  for (final path in paths) {
    final value = _readByPathFromMap(map, path);
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}

Object? _readByPathFromMap(Map<String, dynamic> map, List<String> path) {
  Object? current = map;

  for (final segment in path) {
    if (current is! Map) return null;

    Object? next;
    if (current is Map<String, dynamic>) {
      next = current[segment];
      if (next == null) {
        final lower = segment.toLowerCase();
        for (final entry in current.entries) {
          if (entry.key.toLowerCase() == lower) {
            next = entry.value;
            break;
          }
        }
      }
    } else {
      for (final entry in current.entries) {
        final key = entry.key.toString();
        if (key == segment || key.toLowerCase() == segment.toLowerCase()) {
          next = entry.value;
          break;
        }
      }
    }

    if (next == null) return null;
    current = next;
  }

  return current;
}

Map<String, dynamic>? _asStringDynamicMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    final converted = <String, dynamic>{};
    for (final entry in value.entries) {
      converted[entry.key.toString()] = entry.value;
    }
    return converted;
  }
  return null;
}

int? _coerceInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed) ??
        num.tryParse(trimmed.replaceAll(',', '.'))?.toInt();
  }
  return null;
}

num? _parseAmount(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final cleaned = trimmed.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (cleaned.isEmpty || cleaned == '-' || cleaned == '.' || cleaned == ',') {
      return null;
    }

    var normalized = cleaned;
    if (cleaned.contains(',') && cleaned.contains('.')) {
      if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
        normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        normalized = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      normalized = cleaned.replaceAll(',', '.');
    }

    return num.tryParse(normalized);
  }
  return null;
}

num? _normalizeMoney(num? value) {
  if (value == null) return null;
  final asDouble = value.toDouble();
  if (asDouble.isNaN || asDouble.isInfinite) return null;
  if (asDouble.abs() < 0.005) return 0;
  return value;
}

String _formatAmount(num? amount, String? currency) {
  if (amount == null) return '-';
  final value = amount % 1 == 0
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);
  if (currency == null || currency.trim().isEmpty) return value;
  return '$value ${currency.trim().toUpperCase()}';
}

String _valueOrDash(String? value) {
  if (value == null) return '-';
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '-';
  return trimmed;
}

String? _formatDate(DateTime? date, DateFormat formatter) {
  if (date == null) return null;
  return formatter.format(date.toLocal());
}

String? _formatDateTime(DateTime? date, DateFormat formatter) {
  if (date == null) return null;
  return formatter.format(date.toLocal());
}

class _ReservationDetailsDialog extends StatelessWidget {
  const _ReservationDetailsDialog({
    required this.entry,
    required this.dateFormatter,
    required this.dateTimeFormatter,
    required this.settings,
    required this.property,
  });

  final Reservation entry;
  final DateFormat dateFormatter;
  final DateFormat dateTimeFormatter;
  final AdminSettings settings;
  final PropertySummary? property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final revenue = _extractReservationRevenueData(
      entry,
      settings: settings,
      property: property,
      l10n: s,
    );
    final prettyRaw = const JsonEncoder.withIndent('  ').convert(entry.raw);
    final nights = _stayNights(entry.startDate, entry.endDate);
    final guestName = _guestDisplayName(
      entry,
      fallback: s.revenueUnknownBooker,
    );

    final dialogBg = theme.brightness == Brightness.light
        ? Colors.white
        : theme.colorScheme.surfaceContainerLow;

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  _CircularCloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      guestName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StyledSection(
                      isFirstSection: true,
                      header: s.reservationSectionBooker,
                      children: [
                        StyledTile(title: s.reservationName, value: guestName),
                        StyledTile(
                          title: s.reservationEmail,
                          value: _valueOrDash(entry.guestEmail),
                        ),
                        StyledTile(
                          title: s.reservationPhone,
                          value: _valueOrDash(entry.guestPhone),
                        ),
                      ],
                    ),
                    StyledSection(
                      header: s.reservationSectionStay,
                      children: [
                        StyledTile(
                          title: s.reservationCheckIn,
                          value:
                              _formatDate(entry.startDate, dateFormatter) ??
                              '-',
                        ),
                        StyledTile(
                          title: s.reservationCheckOut,
                          value:
                              _formatDate(entry.endDate, dateFormatter) ?? '-',
                        ),
                        StyledTile(
                          title: s.reservationNights,
                          value: nights != null ? '$nights' : '-',
                        ),
                        StyledTile(
                          title: s.reservationStatus,
                          value: _valueOrDash(entry.status),
                        ),
                        StyledTile(
                          title: s.reservationSource,
                          value: _valueOrDash(entry.source),
                        ),
                        if (entry.reservationId != null &&
                            entry.reservationId!.isNotEmpty)
                          StyledTile(
                            title: s.reservationId,
                            value: entry.reservationId!,
                          ),
                      ],
                    ),
                    StyledSection(
                      header: s.reservationSectionGuests,
                      children: [
                        StyledTile(
                          title: s.reservationGuestTotal,
                          value: _guestBreakdown(entry),
                        ),
                        StyledTile(
                          title: s.reservationAdults,
                          value: entry.adultCount?.toString() ?? '-',
                        ),
                        StyledTile(
                          title: s.reservationChildren,
                          value: entry.childCount?.toString() ?? '-',
                        ),
                        StyledTile(
                          title: s.reservationInfants,
                          value: entry.infantCount?.toString() ?? '-',
                        ),
                      ],
                    ),
                    if (revenue.hasAnyData)
                      StyledSection(
                        header: s.reservationSectionRevenue,
                        children: [
                          if (revenue.total != null)
                            StyledTile(
                              title: s.reservationGross,
                              value: _formatAmount(
                                revenue.total,
                                revenue.currency,
                              ),
                            ),
                          for (final item in revenue.breakdown)
                            StyledTile(
                              title: item.label,
                              value: _formatAmount(
                                item.amount,
                                revenue.currency,
                              ),
                            ),
                          if (revenue.net != null)
                            StyledTile(
                              title: s.reservationNet,
                              value: _formatAmount(
                                revenue.net,
                                revenue.currency,
                              ),
                            ),
                          if (revenue.outstanding != null)
                            StyledTile(
                              title: s.reservationOutstanding,
                              value: _formatAmount(
                                revenue.outstanding,
                                revenue.currency,
                              ),
                            ),
                        ],
                      ),
                    StyledSection(
                      header: s.reservationSectionOther,
                      children: [
                        if (entry.notes != null &&
                            entry.notes!.trim().isNotEmpty)
                          StyledTile(
                            title: s.reservationNotes,
                            value: entry.notes!.trim(),
                          ),
                        StyledTile(
                          title: s.reservationCreatedAt,
                          value:
                              _formatDateTime(
                                entry.createdAt,
                                dateTimeFormatter,
                              ) ??
                              '-',
                        ),
                        StyledTile(
                          title: s.reservationUpdatedAt,
                          value:
                              _formatDateTime(
                                entry.updatedAt,
                                dateTimeFormatter,
                              ) ??
                              '-',
                        ),
                      ],
                    ),
                    StyledSection(
                      header: s.reservationSectionPayload,
                      grouped: false,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SelectableText(
                              prettyRaw,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationRevenueData {
  const _ReservationRevenueData({
    required this.currency,
    required this.total,
    required this.paid,
    required this.outstanding,
    required this.net,
    required this.payout,
    required this.breakdown,
  });

  final String? currency;
  final num? total;
  final num? paid;
  final num? outstanding;
  final num? net;
  final num? payout;
  final List<_ReservationRevenueBreakdownItem> breakdown;

  bool get hasAnyData {
    return total != null ||
        paid != null ||
        outstanding != null ||
        net != null ||
        payout != null ||
        breakdown.isNotEmpty;
  }
}

class _ReservationRevenueBreakdownItem {
  const _ReservationRevenueBreakdownItem({
    required this.label,
    required this.amount,
  });

  final String label;
  final num amount;
}

class _CircularCloseButton extends StatelessWidget {
  const _CircularCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: S.of(context).reservationCloseTooltip,
      child: Material(
        color: const Color(0xFFE1F5FE),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.close, size: 20, color: Color(0xFF37474F)),
          ),
        ),
      ),
    );
  }
}

_ReservationRevenueData _extractReservationRevenueData(
  Reservation entry, {
  required AdminSettings settings,
  required PropertySummary? property,
  required S l10n,
}) {
  final raw = entry.raw;
  final currency =
      _readFirstStringFromMap(raw, const [
        ['currency'],
        ['currencyCode'],
        ['currency_code'],
        ['pricing', 'currency'],
        ['financials', 'currency'],
        ['money', 'currency'],
      ]) ??
      entry.currency;

  var total = _normalizeMoney(
    entry.totalAmount ??
        _readFirstNumFromMap(raw, const [
          ['totalAmount'],
          ['total_amount'],
          ['total'],
          ['amount'],
          ['price'],
          ['pricing', 'total'],
          ['quote', 'total'],
          ['financials', 'total'],
          ['revenue', 'total'],
        ]),
  );
  var paid = _normalizeMoney(
    _readFirstNumFromMap(raw, const [
      ['paid'],
      ['paidAmount'],
      ['paid_amount'],
      ['amountPaid'],
      ['amount_paid'],
      ['collectedAmount'],
      ['collected_amount'],
      ['payments', 'paid'],
      ['payment', 'paid'],
      ['financials', 'paid'],
    ]),
  );
  var outstanding = _normalizeMoney(
    _readFirstNumFromMap(raw, const [
      ['outstanding'],
      ['amountDue'],
      ['amount_due'],
      ['balanceDue'],
      ['balance_due'],
      ['remainingAmount'],
      ['remaining_amount'],
      ['payments', 'due'],
      ['payment', 'due'],
      ['financials', 'due'],
      ['financials', 'outstanding'],
    ]),
  );
  final net = _normalizeMoney(
    _readFirstNumFromMap(raw, const [
      ['net'],
      ['netAmount'],
      ['net_amount'],
      ['financials', 'net'],
      ['revenue', 'net'],
    ]),
  );
  final payout = _normalizeMoney(
    _readFirstNumFromMap(raw, const [
      ['payout'],
      ['ownerPayout'],
      ['owner_payout'],
      ['financials', 'payout'],
      ['revenue', 'payout'],
    ]),
  );

  if (total != null) {
    if (paid == null && outstanding != null) {
      paid = _normalizeMoney(total - outstanding);
    }
    if (outstanding == null && paid != null) {
      outstanding = _normalizeMoney(total - paid);
    }
  } else if (paid != null && outstanding != null) {
    total = _normalizeMoney(paid + outstanding);
  }

  final breakdown = <_ReservationRevenueBreakdownItem>[];
  _addReservationBreakdownItem(
    breakdown,
    l10n.revenueBreakdownRent,
    _readFirstNumFromMap(raw, const [
      ['rent'],
      ['rentAmount'],
      ['rent_amount'],
      ['baseRate'],
      ['base_rate'],
      ['baseAmount'],
      ['base_amount'],
      ['pricing', 'rent'],
      ['pricing', 'base'],
      ['financials', 'rent'],
    ]),
  );
  _addReservationBreakdownItem(
    breakdown,
    l10n.revenueBreakdownCleaning,
    _readFirstNumFromMap(raw, const [
          ['cleaningFee'],
          ['cleaning_fee'],
          ['cleaning'],
          ['cleaningCost'],
          ['cleaning_cost'],
          ['cleaningCosts'],
          ['cleaning_costs'],
          ['fees', 'cleaning'],
          ['pricing', 'cleaningFee'],
          ['pricing', 'cleaning_fee'],
          ['pricing', 'cleaning'],
          ['financials', 'cleaning'],
        ]) ??
        _feeFromPriceTypes(raw, (label) {
          final l = label.toLowerCase();
          return l.contains('clean') || l.contains('schoon');
        }) ??
        _channelCostFallback(property, entry, (c) => c.cleaningCost),
  );
  _addReservationBreakdownItem(
    breakdown,
    l10n.revenueBreakdownLinen,
    _readFirstNumFromMap(raw, const [
          ['linenFee'],
          ['linen_fee'],
          ['linensFee'],
          ['linens_fee'],
          ['linen'],
          ['linens'],
          ['bedlinen'],
          ['bed_linen'],
          ['bedLinen'],
          ['bedLinenCost'],
          ['bed_linen_cost'],
          ['linenRental'],
          ['linen_rental'],
          ['fees', 'linen'],
          ['fees', 'linens'],
          ['pricing', 'linenFee'],
          ['pricing', 'linensFee'],
          ['pricing', 'linen'],
          ['pricing', 'linens'],
          ['financials', 'linen'],
          ['financials', 'linens'],
        ]) ??
        _feeFromPriceTypes(raw, (label) {
          final l = label.toLowerCase();
          return l.contains('linen') ||
              l.contains('linnen') ||
              l.contains('bedlinen') ||
              l.contains('bed linen');
        }) ??
        _channelCostFallback(property, entry, (c) => c.linenCost),
  );
  _addReservationBreakdownItem(
    breakdown,
    l10n.revenueBreakdownServiceCosts,
    _readFirstNumFromMap(raw, const [
          ['serviceFee'],
          ['service_fee'],
          ['fees', 'service'],
          ['pricing', 'serviceFee'],
          ['pricing', 'service_fee'],
          ['financials', 'service'],
        ]) ??
        _channelCostFallback(property, entry, (c) => c.serviceCost),
  );
  _addReservationBreakdownItem(
    breakdown,
    l10n.revenueBreakdownOtherCosts,
    _channelCostFallback(property, entry, (c) => c.otherCost),
  );
  _addReservationBreakdownItem(
    breakdown,
    l10n.revenueBreakdownChannelFee,
    _sanitizeChannelFee(
      _extractDirectChannelFee(raw) ??
          _fallbackChannelFeeFromRules(entry, total, settings, property),
      total,
    ),
  );
  _addReservationBreakdownItem(
    breakdown,
    l10n.revenueBreakdownTax,
    _readFirstNumFromMap(raw, const [
      ['tax'],
      ['taxes'],
      ['vat'],
      ['taxAmount'],
      ['tax_amount'],
      ['pricing', 'tax'],
      ['financials', 'tax'],
      ['financials', 'taxes'],
    ]),
  );

  return _ReservationRevenueData(
    currency: currency,
    total: total,
    paid: paid,
    outstanding: outstanding,
    net: net,
    payout: payout,
    breakdown: breakdown,
  );
}

void _addReservationBreakdownItem(
  List<_ReservationRevenueBreakdownItem> items,
  String label,
  num? amount,
) {
  final normalized = _normalizeMoney(amount);
  if (normalized == null) return;
  items.add(_ReservationRevenueBreakdownItem(label: label, amount: normalized));
}
