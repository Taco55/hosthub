import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/lodgify_error_utils.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_aggregation.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_chrome.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_page.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_refs.dart';
import 'package:hosthub_console/features/portfolio/presentation/widgets/property_filter_button.dart';
import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';
import 'package:hosthub_console/features/reservations/application/nightly_rates_cubit.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/application/user_settings_cubit.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/reservations/presentation/dialogs/reservation_details_dialog.dart';
import 'package:hosthub_console/features/reservations/presentation/reservation_display.dart';
import 'package:hosthub_console/features/revenue/domain/booking_revenue.dart';
import 'package:hosthub_console/features/revenue/domain/revenue_breakdown.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPortfolio(context.read<PropertyContextCubit>().state.properties);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PropertyContextCubit, PropertyContextState>(
          // The whole account, not the selected property: the filter narrows a
          // set that is already loaded, so toggling it costs no request and
          // cannot run into the channel's rate limit.
          listenWhen: (previous, current) =>
              !_sameProperties(previous.properties, current.properties),
          listener: (context, state) {
            _lastRequestKey = null;
            _loadPortfolio(state.properties);
          },
        ),
        BlocListener<NightlyRatesCubit, NightlyRatesState>(
          listenWhen: (previous, current) =>
              previous.rateCurrency != current.rateCurrency &&
              current.rateCurrency != null,
          listener: (context, state) {
            // The currency belongs to the property the rates were loaded for, not
            // to whichever property happens to be selected — writing it to the
            // wrong row would relabel another cabin's money.
            final propertyId = context
                .read<ReservationsCubit>()
                .state
                .singleProperty
                ?.propertyId;
            if (propertyId == null) return;
            final currency = state.rateCurrency;
            if (currency == null || currency.trim().isEmpty) return;
            context
                .read<PropertyRepository>()
                .updatePropertyCurrency(propertyId, currency)
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
            // Rates are per property: a mixed portfolio has no single rate
            // calendar and no single currency, so this only runs for one.
            final channelPropertyId = state.singleProperty?.channelPropertyId;
            if (channelPropertyId == null || channelPropertyId.isEmpty) return;
            final range = _rangeForPeriod(_period, _periodAnchor);
            final midpoint = range.start.add(
              range.end.difference(range.start) ~/ 2,
            );
            context.read<NightlyRatesCubit>().loadRates(
              propertyId: channelPropertyId,
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
            if (isLodgifyCredentialError(error)) {
              return;
            }
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
          // A portfolio screen has something to show as soon as *any* property
          // is connected to the channel, not just the selected one.
          final hasChannelProperties = state.properties.isNotEmpty;
          final canRefresh =
              hasChannelProperties &&
              state.status != ReservationsStatus.loading;
          final locale = Localizations.localeOf(context).toString();
          final dateFormatter = DateFormat('d MMM yyyy', locale);
          final dateTimeFormatter = DateFormat('d MMM yyyy HH:mm', locale);
          final periodLabel = _periodDisplayLabel(
            _period,
            periodRange.start,
            locale,
            context.s,
          );
          final periodRangeLabel =
              '${dateFormatter.format(periodRange.start)} - ${dateFormatter.format(periodRange.end)}';

          // One filtered set feeds the KPIs, the chart, the table, the totals
          // row, the export and the detail modal — §3's "one filter, one source
          // of truth". The selection covers the properties actually loaded, so
          // the occupancy divisor and the booking set can never disagree.
          // What the user last chose for *this* page, clamped to the properties
          // that are actually loaded. Boekingen keeps its own.
          final selection = propertySelectionFor(
            page: PortfolioPage.revenue,
            availablePropertyIds: state.properties.map((ref) => ref.propertyId),
            storedScope: context
                .watch<UserSettingsCubit>()
                .state
                .settings
                ?.portfolioScope,
          );
          final accountProperties = context
              .watch<PropertyContextCubit>()
              .state
              .properties;
          final filterOptions = portfolioFilterOptions(accountProperties);
          // §5: a one-property account does not pay for the portfolio chrome.
          final chrome = PortfolioChrome(
            propertyCount: accountProperties.length,
          );
          final bookedEntries = _entriesForRevenue(
            bookingsForSelection(state.entries, selection),
          );
          final periodEntries = _entriesWithinRange(
            bookedEntries,
            start: periodRange.start,
            end: periodRange.end,
          );
          final channelSettings = _channelSettingsResolver(accountProperties);
          final revenueRows = periodEntries
              .map(
                (entry) => _RevenueRow.fromEntry(
                  entry,
                  // Per booking, for the booking's own property — the resolver
                  // answers for any property, not for "the current one".
                  channelSettings: channelSettingsForBooking(
                    channelSettings,
                    entry,
                  ),
                  unknownBookerLabel: context.s.revenueUnknownBooker,
                ),
              )
              .toList(growable: false);
          final totals = _RevenueTotals.fromRows(revenueRows);

          return StyledWebPageScaffold(
            // Design: these wide pages have no outer card. `.set-body`
            // holds the KPI tiles and the table, and those are the white
            // surfaces — a pane card around everything adds a second
            // border the design does not have.
            decorateLeftPane: false,
            // Design `.top`: the crumb says which part of the console this is;
            // the title is the screen. A portfolio screen does not name one
            // property — the filter beside it says what the scope is.
            overline: chrome.isSingleProperty
                ? context.s.navGroupSingleProperty
                : context.s.navGroupPortfolio,
            title: context.s.menuRevenue,
            actions: [
              // §3: one control in the page header — which properties count.
              // Absent for one property: nothing to choose between.
              if (chrome.showsPropertyFilter) ...[
                PropertyFilterButton(
                  selection: selection,
                  options: filterOptions,
                  onChanged: (updated) => _persistSelection(context, updated),
                ),
                SizedBox(width: context.styledSpacing.sm),
              ],
              // Design `.top`: the period `.seg` sits in the header band beside
              // the title, not on top of the body.
              StyledSegmentedControl(
                labels: [
                  context.s.revenuePeriodMonth,
                  context.s.revenuePeriodQuarter,
                  context.s.revenuePeriodYear,
                ],
                selectedIndex: _period.index,
                onChanged: (index) {
                  final value = _RevenuePeriod.values[index];
                  setState(() {
                    _period = value;
                    _periodAnchor = _startOfPeriod(value, DateTime.now());
                  });
                  _reload();
                },
              ),
              const SizedBox(width: 8),
              // Not in the mock, which has no way to reload: the page reads a
              // live Lodgify feed, so it keeps a refresh affordance.
              StyledToolbarButton(
                iconData: Icons.refresh,
                tooltip: context.s.revenueRefreshTooltip,
                onPressed: canRefresh ? () => _reload() : null,
              ),
            ],
            isLoading: state.status == ReservationsStatus.loading,
            leftChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RevenuePeriodNav(
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
                    _reload();
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
                          _reload();
                        }
                      : null,
                  periodLabel: periodLabel,
                  periodRangeLabel: periodRangeLabel,
                ),
                // Design `.pnav`/`.kpis{margin-bottom:18px}` — 18 is off the
                // 4px scale, so both gaps round to `lg`.
                SizedBox(height: context.styledSpacing.lg),
                _RevenueKpis(
                  totals: totals,
                  occupancy: occupancyPercentage(
                    occupiedNights: occupiedNightsInPeriod(
                      periodEntries,
                      periodStart: periodRange.start,
                      periodEnd: periodRange.end,
                    ),
                    daysInPeriod: daysInPeriod(
                      start: periodRange.start,
                      end: periodRange.end,
                    ),
                    selectedPropertyCount: selection.selectedCount,
                  ),
                ),
                SizedBox(height: context.styledSpacing.lg),
                Expanded(
                  child: _buildContent(
                    context,
                    state: state,
                    property: property,
                    properties: filterOptions,
                    selection: selection,
                    channelSettings: channelSettings,
                    hasChannelProperties: hasChannelProperties,
                    dateFormatter: dateFormatter,
                    dateTimeFormatter: dateTimeFormatter,
                    rows: revenueRows,
                    totals: totals,
                    periodRange: periodRange,
                    periodLabel: periodLabel,
                    locale: locale,
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
    required ChannelSettingsResolver channelSettings,
    required bool hasChannelProperties,
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
    required List<_RevenueRow> rows,
    required List<PropertyFilterOption> properties,
    required PropertySelection selection,
    required _RevenueTotals totals,
    required _DateRange periodRange,
    required String periodLabel,
    required String locale,
  }) {
    final showPropertyColumn = !selection.isSingle && !selection.isEmpty;
    final propertyById = {for (final option in properties) option.id: option};

    if (!hasChannelProperties) {
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
      final safeValue = valueOrDash(value);
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
      final resolvedSource = valueOrDash(source);
      return Align(
        alignment: Alignment.center,
        child: Tooltip(
          message: resolvedSource,
          child: BookingSourceIcon(source: source, size: 18),
        ),
      );
    }

    // Design §8c: the chart answers "when did this property earn?", which a
    // single month cannot. Below two months it would be one bar, so it is left
    // out rather than drawn misleadingly.
    final breakdown = _breakdownEntries(rows);
    final chartMonths = monthsInRange(periodRange.start, periodRange.end);
    final channels = channelTotals(breakdown, labelOf: BookingSourceIcon.label);

    // A Builder so the list reads the scaffold's scope: this method runs while
    // the scaffold is still being constructed, so `context` here is above it.
    return Builder(
      builder: (context) => ListView(
        // The page's bottom padding lives here, at the end of the list, so the
        // table scrolls all the way to the window edge instead of stopping
        // above a dead band (`bottomPaddingInsideContent`).
        padding: EdgeInsets.only(
          bottom: StyledWebPageScaffoldScope.of(context).contentBottomInset,
        ),
        children: [
          if (chartMonths.length >= 2) ...[
            _RevenueMonthChart(
              months: chartMonths,
              entries: breakdown,
              currency: totals.currency,
              periodLabel: periodLabel,
              locale: locale,
            ),
            SizedBox(height: context.styledSpacing.lg),
          ],
          if (channels.isNotEmpty) ...[
            _RevenueChannelSplit(channels: channels, currency: totals.currency),
            SizedBox(height: context.styledSpacing.lg),
          ],
          StyledDataTable(
            // Design `.tbl-wrap` + `.dt td{border-bottom}`: one surface with
            // hairline separators, not gapped rounded row cards.
            variant: StyledTableVariant.plain,
            dense: true,
            uppercaseHeaderLabels: false,
            columns: [
              // §3.4: a leading property column while the selection covers more
              // than one. This table is the dense one, so it shows the chip
              // alone — the name is in the filter above it.
              if (showPropertyColumn)
                StyledDataColumn(
                  columnHeader: Text(
                    S.of(context).portfolioColumnProperty,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  flex: 0,
                  width: 40,
                ),
              StyledDataColumn(
                columnHeader: Text(
                  S.of(context).revenueColumnBooker,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                flex: 3,
                minWidth: 168,
              ),
              StyledDataColumn(
                columnHeader: Text(
                  S.of(context).revenueColumnCheckIn,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                flex: 2,
                minWidth: 112,
              ),
              StyledDataColumn(
                columnHeader: Text(
                  S.of(context).revenueColumnNights,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                flex: 1,
                minWidth: 72,
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
                minWidth: 112,
                alignment: Alignment.centerRight,
                headerAlignment: Alignment.centerRight,
              ),
              StyledDataColumn(
                columnHeader: Text(
                  S.of(context).revenueColumnGross,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                flex: 2,
                minWidth: 112,
                alignment: Alignment.centerRight,
                headerAlignment: Alignment.centerRight,
              ),
              StyledDataColumn(
                columnHeader: Text(
                  S.of(context).revenueColumnCosts,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                flex: 2,
                minWidth: 112,
                alignment: Alignment.centerRight,
                headerAlignment: Alignment.centerRight,
              ),
              StyledDataColumn(
                columnHeader: Text(
                  S.of(context).revenueColumnCommission,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                flex: 2,
                minWidth: 112,
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
                minWidth: 112,
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
                if (showPropertyColumn)
                  _RevenuePropertyCell(
                    abbreviation:
                        propertyById[row.entry.propertyId]?.abbreviation,
                  ),
                textCell(tableContext, row.booker, fontWeight: FontWeight.w600),
                textCell(
                  tableContext,
                  formatDateTime(row.checkIn, dateFormatter),
                ),
                textCell(
                  tableContext,
                  row.nights.toString(),
                  textAlign: TextAlign.right,
                ),
                textCell(
                  tableContext,
                  formatAmount(row.nightlyRate, row.currency),
                  textAlign: TextAlign.right,
                ),
                textCell(
                  tableContext,
                  formatAmount(row.totalRevenue, row.currency),
                  textAlign: TextAlign.right,
                ),
                textCell(
                  tableContext,
                  formatAmount(row.serviceCosts, row.currency),
                  textAlign: TextAlign.right,
                ),
                textCell(
                  tableContext,
                  formatAmount(row.fees, row.currency),
                  textAlign: TextAlign.right,
                ),
                textCell(
                  tableContext,
                  formatAmount(row.netRevenue, row.currency),
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.w600,
                ),
                sourceCell(tableContext, row.source),
              ];
            },
            onRowTap: (_, index) {
              final entry = rows[index].entry;
              _showReservationDetails(
                context,
                entry,
                dateFormatter: dateFormatter,
                dateTimeFormatter: dateTimeFormatter,
                channelSettings: channelSettings.effectiveChannelSettings(
                  entry.propertyId,
                ),
              );
            },
            showTableWhenEmpty: true,
            emptyLabel: noBookedStaysLabel,
            // Design `.dt tfoot`: nights, gross, costs, commission and net summed
            // under the columns they belong to. Only drawn when there is
            // something to sum.
            footerCells: rows.isEmpty
                ? null
                : [
                    Text(
                      S.of(context).revenueTotalsRowLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    null,
                    _totalCell(totals.totalNights.toString()),
                    null,
                    _totalCell(
                      formatAmount(totals.totalRevenue, totals.currency),
                    ),
                    _totalCell(
                      formatAmount(totals.totalServiceCosts, totals.currency),
                    ),
                    _totalCell(formatAmount(totals.totalFees, totals.currency)),
                    _totalCell(
                      formatAmount(totals.totalNetRevenue, totals.currency),
                    ),
                    null,
                  ],
          ),
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: context.styledSpacing.md),
              child: Text(
                noBookedStaysLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showReservationDetails(
    BuildContext context,
    Reservation entry, {
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
    required EffectiveChannelSettings channelSettings,
  }) {
    final revenue = readBookingPayloadRevenue(
      entry,
      channelSettings: channelSettings,
    );

    return showReservationDetailsDialog(
      context,
      entry: entry,
      dateFormatter: dateFormatter,
      dateTimeFormatter: dateTimeFormatter,
      revenue: ReservationRevenueSummary(
        currency: revenue.currency,
        total: revenue.total,
        net: revenue.net,
        outstanding: revenue.outstanding,
        lines: [
          for (final line in revenue.lines)
            ReservationRevenueLine(
              label: revenueLineLabel(line.kind, context.s),
              amount: line.amount,
            ),
        ],
      ),
    );
  }

  /// The two settings tiers, ready to answer for any property.
  ///
  /// `account_channel_defaults` holds what the account charges per channel; the
  /// property row holds only its own deviations. Only
  /// [ChannelSettingsResolver] puts the two together.
  /// Over the **whole account**, not the property on screen: the per-booking
  /// lookup can only find what the resolver was given, so a resolver built from
  /// one property would cost every other booking at the account's defaults.
  ChannelSettingsResolver _channelSettingsResolver(
    List<PropertySummary> properties,
  ) {
    return ChannelSettingsResolver.forProperties(
      accountDefaults: context
          .watch<AccountChannelDefaultsCubit>()
          .state
          .defaults,
      properties: channelOverridesOf(properties),
    );
  }

  static bool _sameProperties(
    List<PropertySummary> a,
    List<PropertySummary> b,
  ) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index].id != b[index].id ||
          a[index].lodgifyId != b[index].lodgifyId) {
        return false;
      }
    }
    return true;
  }

  /// Remember this page's filter for this user.
  ///
  /// Nothing is refetched: the selection narrows a booking set that is already
  /// loaded, so the screen updates in the same frame the checkbox does.
  void _persistSelection(BuildContext context, PropertySelection selection) {
    final settings = context.read<UserSettingsCubit>();
    settings.changePortfolioScope(
      storedScopeWith(
        page: PortfolioPage.revenue,
        selection: selection,
        storedScope: settings.state.settings?.portfolioScope,
      ),
    );
  }

  void _reload() => _loadPortfolio(
    context.read<PropertyContextCubit>().state.properties,
    force: true,
  );

  /// Load every property in the account, so the filter is a narrowing of what is
  /// already here rather than a reason to fetch again.
  void _loadPortfolio(List<PropertySummary> properties, {bool force = false}) {
    final refs = portfolioPropertyRefs(properties);
    if (refs.isEmpty) {
      _lastRequestKey = null;
      return;
    }

    final range = _rangeForPeriod(_period, _periodAnchor);
    final requestKey =
        '${refs.map((ref) => ref.channelPropertyId).join(',')}:'
        '${range.start.toIso8601String()}:${range.end.toIso8601String()}';

    if (!force && _lastRequestKey == requestKey) return;
    _lastRequestKey = requestKey;

    context.read<ReservationsCubit>().loadReservations(
      properties: refs,
      start: range.start,
      end: range.end,
    );
    // Rates worden geladen via BlocListener zodra reserveringen klaar zijn.
  }
}

/// Design `.pnav`: previous/next arrows around the selected period and its
/// date range. The period *choice* itself lives in the header band (`.top`).
class _RevenuePeriodNav extends StatelessWidget {
  const _RevenuePeriodNav({
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.periodLabel,
    required this.periodRangeLabel,
  });

  final VoidCallback? onPreviousPeriod;
  final VoidCallback? onNextPeriod;
  final String periodLabel;
  final String periodRangeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPeriodArrowButton(
          context,
          iconData: Icons.chevron_left_rounded,
          onPressed: onPreviousPeriod,
        ),
        SizedBox(width: context.styledSpacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              periodLabel,
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.styledSpacing.xs),
            Text(periodRangeLabel, style: context.theme.textTheme.bodySmall),
          ],
        ),
        SizedBox(width: context.styledSpacing.md),
        _buildPeriodArrowButton(
          context,
          iconData: Icons.chevron_right_rounded,
          onPressed: onNextPeriod,
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

    // Design `.pnav .arw` — same control family as `.tbtn`, so the styling
    // comes from the toolbar-button group. `[data-off]{opacity:.4}` is the
    // design's disabled treatment.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.4,
      child: StyledToolbarButton(iconData: iconData, onPressed: onPressed),
    );
  }
}

/// Design: four KPI tiles above the revenue table — Bruto, Netto, gemiddelde
/// nachtprijs (ADR) and Bezetting for the selected period.
class _RevenueKpis extends StatelessWidget {
  const _RevenueKpis({required this.totals, required this.occupancy});

  final _RevenueTotals totals;

  /// Occupancy over the whole selection as a whole percentage, computed by
  /// [occupancyPercentage] in the portfolio domain — the screen only labels it.
  final int occupancy;

  @override
  Widget build(BuildContext context) {
    // Design: the revenue `.kpi .kl` is a plain label — no icon, unlike the
    // reservations tiles.
    return MetricsGrid(
      metrics: [
        MetricTileData(
          label: context.s.revenueKpiGross,
          value: formatAmount(totals.totalRevenue, totals.currency),
          caption: context.s.revenueKpiGrossCaption(totals.bookingCount),
        ),
        MetricTileData(
          label: context.s.revenueKpiNet,
          value: formatAmount(totals.totalNetRevenue, totals.currency),
          caption: context.s.revenueKpiNetCaption,
        ),
        MetricTileData(
          label: context.s.revenueKpiAdr,
          value: formatAmount(totals.averageNightlyRate, totals.currency),
          caption: context.s.revenueKpiAdrCaption(totals.totalNights),
        ),
        MetricTileData(
          label: context.s.revenueKpiOccupancy,
          value: '$occupancy%',
          caption: context.s.revenueKpiOccupancyCaption,
        ),
      ],
    );
  }
}

/// One right-aligned totals cell, in the emphasised footer style the table
/// theme supplies (`tables.footerTextStyle`).
Widget _totalCell(String value) {
  return Text(
    value,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.right,
  );
}

/// The rows as the breakdown functions see them: check-in, gross, net, channel.
List<RevenueBreakdownEntry> _breakdownEntries(List<_RevenueRow> rows) {
  return [
    for (final row in rows)
      RevenueBreakdownEntry(
        checkIn: row.checkIn,
        gross: row.totalRevenue?.toDouble(),
        net: row.netRevenue?.toDouble(),
        source: row.source,
      ),
  ];
}

/// Design `.chartcard` — "Omzet per maand": gross bars with the net share
/// inset at the base, one column per month of the period.
class _RevenueMonthChart extends StatelessWidget {
  const _RevenueMonthChart({
    required this.months,
    required this.entries,
    required this.currency,
    required this.periodLabel,
    required this.locale,
  });

  final List<DateTime> months;
  final List<RevenueBreakdownEntry> entries;
  final String? currency;
  final String periodLabel;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final byMonth = monthlyRevenue(entries);
    final shortMonth = DateFormat('MMM', locale);
    final longMonth = DateFormat('MMMM', locale);

    return StyledSection(
      isFirstSection: true,
      headerInsideGroup: true,
      // The page pane already pads its content; the section's own 24 would
      // indent the chart card past the period control, the KPI tiles and the
      // table, which all sit flush against the pane.
      horizontalPadding: 0,
      header: context.s.revenueChartTitle,
      headerAction: Text(
        periodLabel,
        style: context.theme.textTheme.bodySmall?.copyWith(
          color: context.colors.outline,
        ),
      ),
      children: [
        StyledBarChart(
          data: [
            for (final month in months)
              StyledBarDatum(
                label: shortMonth.format(month),
                value: byMonth[month]?.gross ?? 0,
                secondaryValue: byMonth[month]?.net ?? 0,
              ),
          ],
          tooltipBuilder: (datum) {
            final month = months.firstWhere(
              (candidate) => shortMonth.format(candidate) == datum.label,
              orElse: () => months.first,
            );
            final revenue = byMonth[month] ?? MonthRevenue.zero;
            return context.s.revenueChartTooltip(
              longMonth.format(month),
              formatAmount(revenue.gross, currency),
              formatAmount(revenue.net, currency),
            );
          },
          primaryLegendLabel: context.s.revenueChartLegendGross,
          secondaryLegendLabel: context.s.revenueChartLegendNet,
        ),
      ],
    );
  }
}

/// Design `.chartcard` + `.split` — "Omzet per kanaal": one meter per channel,
/// scaled to the largest, in that channel's own brand colour.
class _RevenueChannelSplit extends StatelessWidget {
  const _RevenueChannelSplit({required this.channels, required this.currency});

  final List<ChannelRevenue> channels;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.styledSpacing;
    final largest = channels.fold<double>(
      0,
      (previous, channel) =>
          channel.gross > previous ? channel.gross : previous,
    );

    return StyledSection(
      isFirstSection: true,
      headerInsideGroup: true,
      // Design `.split`: a stack of meters, not a list of rows — no dividers.
      showDividers: false,
      // Flush with the rest of the page — see the chart card.
      horizontalPadding: 0,
      header: context.s.revenueChannelSplitTitle,
      children: [
        for (final channel in channels)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: Row(
              children: [
                BookingSourceIcon(source: channel.source, size: 18),
                SizedBox(width: spacing.md),
                SizedBox(
                  width: _channelNameWidth,
                  child: Text(
                    channel.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: StyledMeter(
                    value: largest <= 0 ? 0 : channel.gross / largest,
                    width: double.infinity,
                    // `.split .stk{height:9px}` — the bar is thicker than the
                    // library default because it carries a brand colour.
                    height: 9,
                    fillColor: BookingSourceIcon.brandColor(channel.source),
                    labelPosition: StyledMeterLabelPosition.none,
                  ),
                ),
                SizedBox(width: spacing.md),
                SizedBox(
                  width: _channelValueWidth,
                  child: Text(
                    formatAmount(channel.gross, currency),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

/// `.split .srow span{min-width:96px}` and `.split .sv{min-width:78px}` — the
/// two fixed columns that keep the meters starting and ending in line.
const double _channelNameWidth = 96;
const double _channelValueWidth = 78;

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
    required EffectiveChannelSettings channelSettings,
    required String unknownBookerLabel,
  }) {
    final revenue = readBookingRowRevenue(entry);
    final nights = stayNights(entry.startDate, entry.endDate) ?? 1;
    final totalRevenue = normalizeMoney(revenue.total ?? entry.totalAmount);
    final serviceCosts = normalizeMoney(
      revenue.fixedCosts ??
          fallbackFixedCosts(
            channelSettings,
            entry.source,
            guests: entry.guestCount ?? 1,
            nights: nights,
          ),
    );
    final fees = normalizeMoney(
      revenue.channelFees ??
          revenue.fees ??
          fallbackChannelFeeFromRules(entry, totalRevenue, channelSettings),
    );

    final netRevenue = normalizeMoney(
      revenue.net ??
          (totalRevenue == null
              ? null
              : totalRevenue - (serviceCosts ?? 0) - (fees ?? 0)),
    );

    final nightlyRate = normalizeMoney(
      revenue.nightlyRate ??
          (totalRevenue == null || nights <= 0 ? null : totalRevenue / nights),
    );

    return _RevenueRow(
      entry: entry,
      booker: guestDisplayName(entry, fallback: unknownBookerLabel),
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
      return hasValue ? normalizeMoney(total) : null;
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
        ? normalizeMoney(totalRevenue / nights)
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

/// A booking's property in the Revenue table: the chip alone.
///
/// The table is the dense one — five money columns — so the name would cost a
/// column the figures need. The filter above the table names the properties.
class _RevenuePropertyCell extends StatelessWidget {
  const _RevenuePropertyCell({required this.abbreviation});

  final String? abbreviation;

  @override
  Widget build(BuildContext context) {
    final abbreviation = this.abbreviation;
    if (abbreviation == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: PropertyChip(
        abbreviation: abbreviation,
        size: 22,
        borderRadius: 6,
      ),
    );
  }
}
