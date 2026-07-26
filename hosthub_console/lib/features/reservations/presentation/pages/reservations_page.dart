import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:web/web.dart' as web;

import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/lodgify_error_utils.dart';
import 'package:hosthub_console/features/reservations/application/nightly_rates_cubit.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/reservations/presentation/dialogs/reservation_details_dialog.dart';
import 'package:hosthub_console/features/reservations/presentation/reservation_display.dart';
import 'package:hosthub_console/features/revenue/domain/booking_revenue.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

enum _ReservationsViewMode { list, timeline }

enum _TimelineDensity { compact, comfortable }

class _ExportColumn {
  _ExportColumn._();

  static const String isNew = 'new';
  static const String arrival = 'arrival';
  static const String departure = 'departure';
  static const String guestName = 'guestName';
  static const String guests = 'guests';
  static const String babyBed = 'babyBed';
  static const String nights = 'nights';
  static const String status = 'status';
  static const String source = 'source';
  static const String notes = 'notes';

  static const List<String> all = [
    isNew,
    arrival,
    departure,
    guestName,
    guests,
    babyBed,
    nights,
    status,
    source,
    notes,
  ];

  static const List<String> defaults = [
    isNew,
    arrival,
    departure,
    guestName,
    guests,
    babyBed,
    nights,
    notes,
  ];

  static String label(String key, {required S l10n}) {
    return switch (key) {
      isNew => l10n.reservationListColumnNew,
      arrival => l10n.reservationArrival,
      departure => l10n.reservationDeparture,
      guestName => l10n.reservationSectionBooker,
      guests => l10n.reservationSectionGuests,
      babyBed => l10n.reservationBabyBed,
      nights => l10n.reservationNights,
      status => l10n.reservationStatus,
      source => l10n.reservationSource,
      notes => l10n.reservationNotes,
      _ => key,
    };
  }
}

class _ReservationListColumn {
  _ReservationListColumn._();

  static const String source = 'source';
  static const String guestName = 'guestName';
  static const String checkIn = 'checkIn';
  static const String checkOut = 'checkOut';
  static const String nights = 'nights';
  static const String guests = 'guests';
  static const String babyBed = 'babyBed';
  static const String status = 'status';
  static const String booked = 'booked';
  static const String isNew = 'new';

  static const List<String> all = [
    source,
    guestName,
    checkIn,
    checkOut,
    nights,
    guests,
    babyBed,
    status,
    booked,
    isNew,
  ];

  static String label(String key, {required S l10n}) {
    return switch (key) {
      source => l10n.reservationSource,
      guestName => l10n.reservationSectionBooker,
      checkIn => l10n.reservationCheckIn,
      checkOut => l10n.reservationCheckOut,
      nights => l10n.reservationNights,
      guests => l10n.reservationSectionGuests,
      babyBed => l10n.reservationInfants,
      status => l10n.reservationStatus,
      booked => l10n.reservationListColumnBooked,
      isNew => l10n.reservationListColumnNew,
      _ => key,
    };
  }
}

class _ExportPdfOrientation {
  _ExportPdfOrientation._();

  static const String portrait = 'portrait';
  static const String landscape = 'landscape';
}

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReservationsPageBody();
  }
}

class _ReservationsPageBody extends StatefulWidget {
  const _ReservationsPageBody();

  @override
  State<_ReservationsPageBody> createState() => _ReservationsPageBodyState();
}

class _ReservationsPageBodyState extends State<_ReservationsPageBody> {
  _ReservationsViewMode _viewMode = _ReservationsViewMode.list;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String? _lastChannelPropertyId;
  bool _showHistorical = false;
  _TimelineDensity _timelineDensity = _TimelineDensity.comfortable;
  OutOfMonthDisplay _outOfMonthDisplay = OutOfMonthDisplay.hide;
  bool _continuousMonths = false;
  final ScrollController _continuousScrollController = ScrollController();
  final Map<String, GlobalKey> _monthKeys = {};
  final GlobalKey _scrollViewKey = GlobalKey();
  bool _isScrollingToMonth = false;

  /// Active month in continuous scroll mode. Updated without setState so only
  /// listeners (ValueListenableBuilder) rebuild — avoids rebuilding all month
  /// grids on every scroll tick.
  final ValueNotifier<DateTime> _continuousActiveMonth = ValueNotifier(
    DateTime(DateTime.now().year, DateTime.now().month),
  );
  final Set<String> _hiddenStatuses = {};
  final Set<String> _markedAsNew = {};
  final Set<String> _hiddenListColumns = {};
  bool _statusFilterInitialized = false;
  bool _timelineFocusInitialized = false;

  GlobalKey _keyForMonth(DateTime month) {
    final key = '${month.year}-${month.month}';
    return _monthKeys.putIfAbsent(key, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final property = context
          .read<PropertyContextCubit>()
          .state
          .currentProperty;
      _loadReservationsForProperty(property);
    });
  }

  @override
  void dispose() {
    _continuousScrollController.dispose();
    _continuousActiveMonth.dispose();
    super.dispose();
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
            final now = DateTime(DateTime.now().year, DateTime.now().month);
            setState(() {
              _focusedMonth = now;
              // Another property has another first booking.
              _timelineFocusInitialized = false;
            });
            _continuousActiveMonth.value = now;
            _loadReservationsForProperty(state.currentProperty);
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
            // Na het laden van reserveringen: laad tarieven.
            final channelPropertyId = _lastChannelPropertyId;
            if (channelPropertyId == null || channelPropertyId.isEmpty) return;
            context.read<NightlyRatesCubit>().loadRates(
              propertyId: channelPropertyId,
              focusedMonth: _focusedMonth,
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
          final propertyName =
              property?.name ?? context.s.revenueUnknownProperty;
          final propertyId = property?.lodgifyId?.trim() ?? '';
          final locale = Localizations.localeOf(context).toString();
          final dateFormatter = DateFormat('d MMM yyyy', locale);
          final dateTimeFormatter = DateFormat('d MMM yyyy HH:mm', locale);
          final allBookings = _sortedBookings(state.entries);
          final today = _dateOnly(DateTime.now());
          final afterHistorical = _showHistorical
              ? allBookings
              : allBookings.where((e) => !_bookingEnded(e, today)).toList();
          final allStatuses =
              allBookings
                  .map((e) => e.status?.trim().toLowerCase() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

          // On first load, default to showing only "booked" status.
          if (!_statusFilterInitialized && allStatuses.isNotEmpty) {
            _statusFilterInitialized = true;
            final hasBooked = allStatuses.contains('booked');
            if (hasBooked) {
              _hiddenStatuses.addAll(allStatuses.where((s) => s != 'booked'));
            }
          }

          final bookings = _hiddenStatuses.isEmpty
              ? afterHistorical
              : afterHistorical.where((e) {
                  final s = e.status?.trim().toLowerCase() ?? '';
                  return s.isEmpty || !_hiddenStatuses.contains(s);
                }).toList();

          return StyledWebPageScaffold(
            // Design: these wide pages have no outer card. `.set-body`
            // holds the KPI tiles and the table, and those are the white
            // surfaces — a pane card around everything adds a second
            // border the design does not have.
            decorateLeftPane: false,
            // Design `.top`: crumb over a title that names the property.
            overline: context.s.reservationsPageTitle,
            title: context.s.reservationsPageHeading(propertyName),
            isLoading: state.status == ReservationsStatus.loading,
            leftChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Design order inside `.set-wide`: `.kpis`, then `.ptools`,
                // then the table/calendar. The KPIs summarise the month the
                // toolbar is filtering, so they read as page context above the
                // controls, not as a caption under them. Nothing to summarise
                // when the page is showing a message instead of data.
                if (_hasReservationData(state, propertyId)) ...[
                  _buildMetrics(context, state: state, entries: bookings),
                  SizedBox(height: context.styledSpacing.lg),
                ],
                _ReservationsHeader(
                  viewMode: _viewMode,
                  showHistorical: _showHistorical,
                  allStatuses: allStatuses,
                  hiddenStatuses: _hiddenStatuses,
                  hiddenListColumns: _hiddenListColumns,
                  timelineDensity: _viewMode == _ReservationsViewMode.timeline
                      ? _timelineDensity
                      : null,
                  onViewChanged: (value) {
                    _changeViewMode(value, listBookings: bookings);
                  },
                  onShowHistoricalChanged: (value) {
                    setState(() => _showHistorical = value);
                  },
                  onStatusToggled: (status) {
                    setState(() {
                      if (_hiddenStatuses.contains(status)) {
                        _hiddenStatuses.remove(status);
                      } else {
                        _hiddenStatuses.add(status);
                      }
                    });
                  },
                  onListColumnToggled: (column) {
                    setState(() {
                      if (_hiddenListColumns.contains(column)) {
                        _hiddenListColumns.remove(column);
                        return;
                      }
                      if (_hiddenListColumns.length >=
                          _ReservationListColumn.all.length - 1) {
                        return;
                      }
                      _hiddenListColumns.add(column);
                    });
                  },
                  onTimelineDensityChanged: (value) {
                    setState(() => _timelineDensity = value);
                  },
                  continuousMonths: _viewMode == _ReservationsViewMode.timeline
                      ? _continuousMonths
                      : null,
                  onContinuousMonthsChanged: (value) {
                    setState(() => _continuousMonths = value);
                    if (value) {
                      _continuousActiveMonth.value = _focusedMonth;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToMonth(_focusedMonth);
                      });
                    }
                  },
                  outOfMonthDisplay:
                      _viewMode == _ReservationsViewMode.timeline &&
                          !_continuousMonths
                      ? _outOfMonthDisplay
                      : null,
                  onOutOfMonthDisplayChanged: (value) {
                    setState(() => _outOfMonthDisplay = value);
                  },
                  exportMenu:
                      _viewMode == _ReservationsViewMode.list &&
                          bookings.isNotEmpty
                      ? _buildExportMenu(
                          context,
                          entries: bookings,
                          dateFormatter: dateFormatter,
                        )
                      : null,
                ),
                SizedBox(height: context.styledSpacing.lg),
                Expanded(
                  child: _buildContent(
                    context,
                    state: state,
                    propertyId: propertyId.isEmpty ? null : propertyId,
                    entries: bookings,
                    dateFormatter: dateFormatter,
                    dateTimeFormatter: dateTimeFormatter,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Whether the body is showing reservations rather than one of the three
  /// message states `_buildContent` short-circuits to.
  bool _hasReservationData(ReservationsState state, String propertyId) {
    if (propertyId.isEmpty) return false;
    if (state.status == ReservationsStatus.error) return false;
    return !(state.status == ReservationsStatus.loading &&
        state.entries.isEmpty);
  }

  /// The four KPIs, above the toolbar for both views.
  ///
  /// [entries] is the list view's filtered set; the timeline scopes its own
  /// because it always includes historical bookings. Either way the numbers
  /// describe the month the user is looking at, so switching view or month
  /// moves them.
  Widget _buildMetrics(
    BuildContext context, {
    required ReservationsState state,
    required List<Reservation> entries,
  }) {
    final l10n = context.s;

    if (_viewMode == _ReservationsViewMode.list) {
      return MetricsGrid(
        metrics: _monthMetrics(
          _monthSummary(_focusedMonth, entries),
          l10n: l10n,
        ),
      );
    }

    final timelineBookings = _timelineBookings(state);
    if (!_continuousMonths) {
      return MetricsGrid(
        metrics: _monthMetrics(
          _monthSummary(_focusedMonth, timelineBookings),
          l10n: l10n,
        ),
      );
    }

    // Continuous scroll: only the tiles rebuild as the active month changes,
    // not the 24+ calendar grids below them.
    return ValueListenableBuilder<DateTime>(
      valueListenable: _continuousActiveMonth,
      builder: (context, activeMonth, _) => MetricsGrid(
        metrics: _monthMetrics(
          _monthSummary(activeMonth, timelineBookings),
          l10n: l10n,
        ),
      ),
    );
  }

  /// Timeline bookings: always including historical, status filter applied.
  List<Reservation> _timelineBookings(ReservationsState state) {
    final all = _sortedBookings(state.entries);
    if (_hiddenStatuses.isEmpty) return all;
    return all.where((e) {
      final s = e.status?.trim().toLowerCase() ?? '';
      return s.isEmpty || !_hiddenStatuses.contains(s);
    }).toList();
  }

  /// Switches list/timeline, and on the first switch to the timeline focuses
  /// the month of the first booking in the list instead of today's month — a
  /// property whose next stay is months out would otherwise open on an empty
  /// calendar and have to be scrolled to.
  void _changeViewMode(
    _ReservationsViewMode value, {
    required List<Reservation> listBookings,
  }) {
    final isFirstTimelineOpen =
        value == _ReservationsViewMode.timeline && !_timelineFocusInitialized;
    final firstStart = isFirstTimelineOpen
        ? listBookings.map((e) => e.startDate).whereType<DateTime>().firstOrNull
        : null;

    setState(() {
      _viewMode = value;
      if (isFirstTimelineOpen) _timelineFocusInitialized = true;
      if (firstStart != null) {
        _focusedMonth = DateTime(firstStart.year, firstStart.month);
      }
    });

    if (firstStart == null) return;

    final month = DateTime(firstStart.year, firstStart.month);
    _continuousActiveMonth.value = month;
    final channelPropertyId = _lastChannelPropertyId;
    if (channelPropertyId != null && channelPropertyId.isNotEmpty) {
      context.read<NightlyRatesCubit>().loadRates(
        propertyId: channelPropertyId,
        focusedMonth: month,
      );
    }
    if (_continuousMonths) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToMonth(month),
      );
    }
  }

  Widget _buildContent(
    BuildContext context, {
    required ReservationsState state,
    required String? propertyId,
    required List<Reservation> entries,
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
  }) {
    final l10n = context.s;

    if (propertyId == null || propertyId.isEmpty) {
      return Center(
        child: Text(
          l10n.reservationsNoLodgifyId,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state.status == ReservationsStatus.error) {
      return Center(
        child: Text(
          context.s.reservationsLoadFailed,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state.status == ReservationsStatus.loading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Timeline always includes historical; handle before empty check.
    if (_viewMode == _ReservationsViewMode.timeline) {
      // Timeline always shows historical bookings; only apply status filter.
      final timelineBookings = _timelineBookings(state);
      final today = _dateOnly(DateTime.now());

      // Build nightly-rate labels per day from ALL entries (including
      // "available" entries which carry pricing info).
      final dayLabels = <DateTime, String>{};
      for (final e in state.entries) {
        if (e.startDate == null || e.endDate == null) continue;
        final rev = readBookingPayloadRevenue(e);
        num? rate = rev.nightlyRate;
        if (rate == null && rev.total != null) {
          final nights = _dateOnly(
            e.endDate!,
          ).difference(_dateOnly(e.startDate!)).inDays;
          if (nights > 0) rate = rev.total! / nights;
        }
        if (rate == null) continue;
        final rateStr = formatAmount(rate, rev.currency);
        var d = _dateOnly(e.startDate!);
        final end = _dateOnly(e.endDate!);
        while (d.isBefore(end)) {
          dayLabels.putIfAbsent(d, () => rateStr);
          d = d.add(const Duration(days: 1));
        }
      }

      // Fill in nightly rates from the availability API for days that
      // don't already have a label from reservation data.
      final ratesState = context.watch<NightlyRatesCubit>().state;
      for (final entry in ratesState.rates.entries) {
        dayLabels.putIfAbsent(
          entry.key,
          () => formatAmount(entry.value, ratesState.rateCurrency),
        );
      }

      final isCompact = _timelineDensity == _TimelineDensity.compact;
      // Density geometry and the past-booking treatment live in the theme, not
      // here — see TimelineCalendarTheme.
      final timelineTheme = Theme.of(context).timelineCalendar;
      final density = isCompact
          ? timelineTheme.compact
          : timelineTheme.comfortable;
      final locale = Localizations.localeOf(context).toString();

      final timelineEntries = timelineBookings
          .where((e) => e.startDate != null && e.endDate != null)
          .map((e) {
            final isPast =
                _dateOnly(e.endDate!).isBefore(today) ||
                _dateOnly(e.endDate!).isAtSameMomentAs(today);
            final baseColor = BookingSourceIcon.barColor(e.source);
            final guestInfo = guestBreakdown(e, unknownLabel: '');
            final name = e.guestName ?? l10n.revenueUnknownBooker;
            final label = guestInfo.isNotEmpty ? '$name ($guestInfo)' : name;
            final nights = stayNights(e.startDate, e.endDate);
            final tooltipParts = <String>[
              name,
              '${dateFormatter.format(e.startDate!.toLocal())} → ${dateFormatter.format(e.endDate!.toLocal())}',
              if (nights != null) l10n.reservationsBarNights(nights),
              if (guestInfo.isNotEmpty) l10n.reservationsBarGuests(guestInfo),
              if (e.source != null && e.source!.isNotEmpty)
                l10n.reservationsBarSource(e.source!),
              if (e.status != null && e.status!.isNotEmpty)
                l10n.reservationsBarStatus(e.status!),
            ];
            return TimelineCalendarEntry(
              start: e.startDate!,
              end: e.endDate!,
              label: label,
              tooltip: tooltipParts.join('\n'),
              color: isPast
                  ? Color.lerp(
                      baseColor,
                      timelineTheme.pastEntryBlendColor,
                      timelineTheme.pastEntryBlend,
                    )!
                  : baseColor,
              textColor: isPast ? timelineTheme.pastEntryTextColor : null,
              outlined: isPast,
              leading: isPast
                  ? Opacity(
                      opacity: timelineTheme.pastEntryLeadingOpacity,
                      child: BookingSourceIcon(
                        source: e.source,
                        size: density.leadingIconSize,
                      ),
                    )
                  : BookingSourceIcon(
                      source: e.source,
                      size: density.leadingIconSize,
                    ),
              data: e,
            );
          })
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_continuousMonths) ...[
            // The month navigation listens to the ValueNotifier — only it (and
            // the KPI tiles above the toolbar) rebuilds when the active month
            // changes during scroll, NOT the 24+ TimelineCalendar grids below.
            ValueListenableBuilder<DateTime>(
              valueListenable: _continuousActiveMonth,
              builder: (context, activeMonth, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ContinuousMonthNavigation(
                      focusedMonth: activeMonth,
                      locale: locale,
                      onPrevious: () {
                        final prev = DateTime(
                          activeMonth.year,
                          activeMonth.month - 1,
                        );
                        _continuousActiveMonth.value = prev;
                        if (propertyId.isNotEmpty) {
                          context.read<NightlyRatesCubit>().loadRates(
                            propertyId: propertyId,
                            focusedMonth: prev,
                          );
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToMonth(prev);
                        });
                      },
                      onNext: () {
                        final next = DateTime(
                          activeMonth.year,
                          activeMonth.month + 1,
                        );
                        _continuousActiveMonth.value = next;
                        if (propertyId.isNotEmpty) {
                          context.read<NightlyRatesCubit>().loadRates(
                            propertyId: propertyId,
                            focusedMonth: next,
                          );
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToMonth(next);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: context.styledSpacing.sm),
            Expanded(
              child: Builder(
                builder: (context) {
                  final months = _continuousMonthRange(state);
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      _onContinuousScroll(months);
                      return false;
                    },
                    child: SingleChildScrollView(
                      key: _scrollViewKey,
                      controller: _continuousScrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < months.length; i++)
                            RepaintBoundary(
                              key: _keyForMonth(months[i]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (i > 0)
                                    SizedBox(height: context.styledSpacing.xl),
                                  Padding(
                                    // Design `.calmonth-hd`.
                                    padding: Theme.of(
                                      context,
                                    ).timelineCalendar.monthHeadingPadding,
                                    child: Text(
                                      DateFormat(
                                        'MMMM yyyy',
                                        locale,
                                      ).format(months[i]),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  TimelineCalendar(
                                    focusedMonth: months[i],
                                    entries: timelineEntries,
                                    showNavigation: false,
                                    showWeekdayHeader: i == 0,
                                    shrinkWrap: true,
                                    outOfMonthDisplay: OutOfMonthDisplay.hide,
                                    barHeight: density.barHeight,
                                    dayNumberHeight: density.dayNumberHeight,
                                    barTopPadding: density.barTopPadding,
                                    rowBottomPadding: density.rowBottomPadding,
                                    dayLabels: density.showDayLabels
                                        ? dayLabels
                                        : null,
                                    onEntryTap: (entry) {
                                      final lodgifyEntry =
                                          entry.data as Reservation;
                                      _showReservationDetails(
                                        context,
                                        lodgifyEntry,
                                        dateFormatter: dateFormatter,
                                        dateTimeFormatter: dateTimeFormatter,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: TimelineCalendar(
                focusedMonth: _focusedMonth,
                outOfMonthDisplay: _outOfMonthDisplay,
                barHeight: density.barHeight,
                dayNumberHeight: density.dayNumberHeight,
                barTopPadding: density.barTopPadding,
                rowBottomPadding: density.rowBottomPadding,
                entries: timelineEntries,
                dayLabels: density.showDayLabels ? dayLabels : null,
                rangeStart: state.rangeStart,
                rangeEnd: state.rangeEnd,
                onMonthChanged: (month) {
                  setState(() => _focusedMonth = month);
                  if (propertyId.isNotEmpty) {
                    context.read<NightlyRatesCubit>().loadRates(
                      propertyId: propertyId,
                      focusedMonth: month,
                    );
                  }
                },
                onEntryTap: (entry) {
                  final lodgifyEntry = entry.data as Reservation;
                  _showReservationDetails(
                    context,
                    lodgifyEntry,
                    dateFormatter: dateFormatter,
                    dateTimeFormatter: dateTimeFormatter,
                  );
                },
              ),
            ),
          ],
        ],
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Text(
          context.s.reservationsEmptyPeriod,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (_viewMode == _ReservationsViewMode.list) {
      return _buildListView(
        entries: entries,
        dateFormatter: dateFormatter,
        dateTimeFormatter: dateTimeFormatter,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildListView({
    required List<Reservation> entries,
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
  }) {
    return _ReservationListView(
      entries: entries,
      dateFormatter: dateFormatter,
      dateTimeFormatter: dateTimeFormatter,
      markedAsNew: _markedAsNew,
      hiddenColumns: _hiddenListColumns,
      onToggleNew: (id) {
        setState(() {
          if (_markedAsNew.contains(id)) {
            _markedAsNew.remove(id);
          } else {
            _markedAsNew.add(id);
          }
        });
      },
      onEntryTap: (entry) => _showReservationDetails(
        context,
        entry,
        dateFormatter: dateFormatter,
        dateTimeFormatter: dateTimeFormatter,
      ),
    );
  }

  Future<void> _showReservationDetails(
    BuildContext context,
    Reservation entry, {
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
  }) {
    final rateCurrency = context.read<NightlyRatesCubit>().state.rateCurrency;
    final revenue = readBookingPayloadRevenue(entry);
    final cubit = context.read<ReservationsCubit>();

    return showReservationDetailsDialog(
      context,
      entry: entry,
      dateFormatter: dateFormatter,
      dateTimeFormatter: dateTimeFormatter,
      revenue: ReservationRevenueSummary(
        // The booking's own currency, falling back to the one the nightly-rate
        // settings report for this property.
        currency: revenue.currency ?? rateCurrency,
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
      // Only this screen can write a note back: it owns the reservations cubit.
      onSaveNotes: (reservationId, notes) =>
          cubit.updateNotes(reservationId, notes),
    );
  }

  void _loadReservationsForProperty(PropertySummary? property) {
    if (property == null) {
      _lastChannelPropertyId = null;
      return;
    }
    final lodgifyId = property.lodgifyId?.trim();
    if (lodgifyId == null || lodgifyId.isEmpty) {
      _lastChannelPropertyId = null;
      return;
    }
    if (_lastChannelPropertyId == lodgifyId) return;
    _lastChannelPropertyId = lodgifyId;
    context.read<ReservationsCubit>().loadReservations(
      propertyId: property.id,
      channelPropertyId: lodgifyId,
    );
    // Rates worden geladen via BlocListener zodra reserveringen klaar zijn.
  }

  List<DateTime> _continuousMonthRange(ReservationsState state) {
    final start =
        state.rangeStart ??
        DateTime(DateTime.now().year, DateTime.now().month - 12);
    final end =
        state.rangeEnd ??
        DateTime(DateTime.now().year, DateTime.now().month + 12);
    final months = <DateTime>[];
    var m = DateTime(start.year, start.month);
    final endMonth = DateTime(end.year, end.month);
    while (!m.isAfter(endMonth)) {
      months.add(m);
      m = DateTime(m.year, m.month + 1);
    }
    return months;
  }

  void _scrollToMonth(DateTime month) {
    final key = _keyForMonth(month);
    if (key.currentContext == null) return;
    _isScrollingToMonth = true;
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      _isScrollingToMonth = false;
    });
  }

  void _onContinuousScroll(List<DateTime> months) {
    if (_isScrollingToMonth) return;

    // Use the scroll view's screen position as reference for "top of visible area".
    final scrollBox =
        _scrollViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollBox == null) return;
    final scrollViewTop = scrollBox.localToGlobal(Offset.zero).dy;

    DateTime? activeMonth;
    for (int i = 0; i < months.length; i++) {
      final key = _keyForMonth(months[i]);
      if (key.currentContext == null) continue;
      final box = key.currentContext!.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      // Month whose top has scrolled to or past the scroll view top.
      if (top <= scrollViewTop + 50) {
        activeMonth = months[i];
      } else {
        break;
      }
    }

    if (activeMonth != null) {
      final current = _continuousActiveMonth.value;
      if (activeMonth.year != current.year ||
          activeMonth.month != current.month) {
        _continuousActiveMonth.value = activeMonth;
      }
    }
  }

  Widget _buildExportMenu(
    BuildContext context, {
    required List<Reservation> entries,
    required DateFormat dateFormatter,
  }) {
    final newCount = _markedAsNew.length;
    final l10n = context.s;
    String labeledWithNew(String label) {
      return switch (newCount) {
        0 => label,
        _ => '$label (${l10n.reservationNewCount(newCount)})',
      };
    }

    // Design `.ptools > .btn.btn-line.btn-sm`: the one labelled control in the
    // toolbar. "Exporteren" is the whole point of the button, and an icon-only
    // control next to three other icon-only controls does not say that.
    return StyledMenuOverlay<String>(
      tooltip: context.s.reservationsExportTooltip,
      verticalOffset: 8,
      showDividers: true,
      anchorBuilder: (anchorContext, isOpen, toggle) => StyledButton(
        variant: StyledButtonVariant.secondary,
        title: l10n.reservationsExportLabel,
        showLeftIcon: true,
        leftIconData: Icons.file_upload_outlined,
        iconSize: 16,
        fontSize: 12.5,
        // Matches `.tbtn` next to it: 36 high, radius 10.
        minHeight: 36,
        cornerRadius: 10,
        onPressed: toggle,
      ),
      entries: [
        StyledMenuOverlayEntry(
          value: 'pdf',
          label: labeledWithNew(context.s.reservationsExportPdfDownload),
          leading: const Icon(Icons.picture_as_pdf_outlined),
        ),
        StyledMenuOverlayEntry(
          value: 'pdf_share',
          label: labeledWithNew(context.s.reservationsExportPdfShare),
          leading: const Icon(Icons.mail_outlined),
        ),
        StyledMenuOverlayEntry(
          value: 'excel',
          // 'Excel' and 'CSV' below are file-format names, not prose: they
          // read the same in every language this console speaks.
          label: labeledWithNew('Excel'),
          leading: const Icon(Icons.table_chart_outlined),
        ),
        const StyledMenuOverlayEntry(
          value: 'csv',
          label: 'CSV',
          leading: Icon(Icons.download_outlined),
        ),
        StyledMenuOverlayEntry(
          value: 'settings',
          label: context.s.reservationsExportSettings,
          leading: const Icon(Icons.settings_outlined),
        ),
      ],
      onSelected: (value) async {
        final settings = context.read<SettingsCubit>().state.settings;
        final exportPdfOrientation = _normalizePdfOrientation(
          settings?.exportPdfOrientation,
        );
        switch (value) {
          case 'pdf':
            await _exportPdf(
              context,
              entries,
              dateFormatter,
              exportPdfOrientation: exportPdfOrientation,
              columns: settings?.exportColumns ?? _ExportColumn.defaults,
            );
          case 'pdf_share':
            await _sharePdf(
              context,
              entries,
              dateFormatter,
              exportPdfOrientation: exportPdfOrientation,
              columns: settings?.exportColumns ?? _ExportColumn.defaults,
            );
          case 'excel':
            _exportExcel(
              context,
              entries,
              dateFormatter,
              columns: settings?.exportColumns ?? _ExportColumn.defaults,
            );
          case 'csv':
            _exportCsv(context, entries, dateFormatter);
          case 'settings':
            () async {
              final settings = context.read<SettingsCubit>().state.settings;
              final currentColumns =
                  settings?.exportColumns ?? _ExportColumn.defaults;
              final currentPdfOrientation = _normalizePdfOrientation(
                settings?.exportPdfOrientation,
              );
              final result = await _showExportSettingsDialog(
                context,
                currentColumns: currentColumns,
                currentPdfOrientation: currentPdfOrientation,
              );
              if (result == null || !context.mounted) return;
              context.read<UserSettingsCubit>().changeExportSettings(
                exportLanguageCode: Localizations.localeOf(
                  context,
                ).languageCode,
                exportColumns: result.enabledColumns,
                exportPdfOrientation: result.exportPdfOrientation,
              );
            }();
        }
      },
    );
  }

  void _exportExcel(
    BuildContext context,
    List<Reservation> entries,
    DateFormat dateFormatter, {
    List<String>? columns,
  }) {
    final l10n = S.of(context);
    final enabledColumns = columns ?? _ExportColumn.defaults;
    final yesLabel = l10n.yes;
    final exportedLabel = l10n.reservationExportedLabel;

    final now = DateTime.now();
    final exportDate = DateFormat('yyyy-MM-dd').format(now);
    final exportDateDisplay = DateFormat('d MMM yyyy, HH:mm').format(now);
    final buf = StringBuffer();
    buf.writeln(
      '<html xmlns:o="urn:schemas-microsoft-com:office:office" '
      'xmlns:x="urn:schemas-microsoft-com:office:spreadsheet" '
      'xmlns="http://www.w3.org/TR/REC-html40">',
    );
    buf.writeln('<head><meta charset="utf-8">');
    buf.writeln('<style>');
    buf.writeln(
      'table { border-collapse: collapse; font-family: Calibri, sans-serif; font-size: 11pt; }',
    );
    buf.writeln(
      'th { background-color: #4472C4; color: #FFFFFF; font-weight: bold; '
      'padding: 6px 10px; border: 1px solid #2F5496; text-align: left; }',
    );
    buf.writeln('td { padding: 4px 10px; border: 1px solid #D6DCE4; }');
    buf.writeln('.new-row td { background-color: #FFFF00; }');
    buf.writeln(
      '.export-date { font-family: Calibri, sans-serif; font-size: 10pt; '
      'color: #666666; margin-bottom: 8px; }',
    );
    buf.writeln('</style>');
    buf.writeln('</head><body>');
    buf.writeln(
      '<p class="export-date">$exportedLabel: $exportDateDisplay</p>',
    );
    buf.writeln('<table>');

    // Header row
    buf.write('<tr>');
    for (final key in enabledColumns) {
      buf.write('<th>${_ExportColumn.label(key, l10n: l10n)}</th>');
    }
    buf.writeln('</tr>');

    // Data rows
    for (final e in entries) {
      final id = _reservationKey(e);
      final isNew = _markedAsNew.contains(id);
      final cellValues = <String, String>{
        _ExportColumn.isNew: isNew ? yesLabel : '',
        _ExportColumn.arrival: e.startDate != null
            ? dateFormatter.format(e.startDate!.toLocal())
            : '',
        _ExportColumn.departure: e.endDate != null
            ? dateFormatter.format(e.endDate!.toLocal())
            : '',
        _ExportColumn.guestName: _escapeHtml(
          guestDisplayName(e, fallback: l10n.revenueUnknownBooker),
        ),
        _ExportColumn.guests: _escapeHtml(guestBreakdown(e, unknownLabel: '')),
        _ExportColumn.babyBed: _formatBabyExportValue(
          e.infantCount,
          l10n: l10n,
        ),
        _ExportColumn.nights:
            stayNights(e.startDate, e.endDate)?.toString() ?? '',
        _ExportColumn.status: _escapeHtml(e.status ?? ''),
        _ExportColumn.source: _escapeHtml(e.source ?? ''),
        _ExportColumn.notes: _escapeHtml(
          (e.notes ?? '').replaceAll(RegExp(r'[\t\r\n]+'), ' '),
        ),
      };
      final rowClass = isNew ? ' class="new-row"' : '';
      buf.write('<tr$rowClass>');
      for (final key in enabledColumns) {
        buf.write('<td>${cellValues[key] ?? ''}</td>');
      }
      buf.writeln('</tr>');
    }
    buf.writeln('</table>');
    buf.writeln('</body></html>');

    final html = buf.toString();
    final bytes = utf8.encode(html);
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/vnd.ms-excel;charset=utf-8'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = 'reservations_$exportDate.xls';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  void _exportCsv(
    BuildContext context,
    List<Reservation> entries,
    DateFormat dateFormatter,
  ) {
    final l10n = S.of(context);
    final buf = StringBuffer();
    buf.writeln(
      '${l10n.reservationListColumnNew}\t${l10n.reservationArrival}\t${l10n.reservationDeparture}\t${l10n.reservationSectionBooker}\t${l10n.reservationSectionGuests}\t${l10n.reservationBabyBed}\t${l10n.reservationCheckIn}\t${l10n.reservationCheckOut}\t${l10n.reservationNotes}',
    );
    for (final e in entries) {
      final id = _reservationKey(e);
      final isNew = _markedAsNew.contains(id) ? l10n.yes : '';
      final arrival = e.startDate != null
          ? dateFormatter.format(e.startDate!.toLocal())
          : '';
      final departure = e.endDate != null
          ? dateFormatter.format(e.endDate!.toLocal())
          : '';
      final guestName = guestDisplayName(
        e,
        fallback: l10n.revenueUnknownBooker,
      );
      final guests = guestBreakdown(e, unknownLabel: '');
      final babyBed = _formatBabyExportValue(e.infantCount, l10n: l10n);
      final notes = (e.notes ?? '').replaceAll(RegExp(r'[\t\r\n]+'), ' ');
      buf.writeln(
        '$isNew\t$arrival\t$departure\t$guestName\t$guests\t$babyBed\t$arrival\t$departure\t$notes',
      );
    }

    final csv = buf.toString();
    final bytes = utf8.encode('\uFEFF$csv');
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = 'reserveringen.csv';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  Future<(Uint8List bytes, String filename)> _buildPdfBytes(
    BuildContext context,
    List<Reservation> entries,
    DateFormat dateFormatter, {
    String? exportPdfOrientation,
    List<String>? columns,
  }) async {
    final l10n = S.of(context);
    final pdfOrientation = _normalizePdfOrientation(exportPdfOrientation);
    final enabledColumns = columns ?? _ExportColumn.defaults;
    final yesLabel = l10n.yes;
    final exportedLabel = l10n.reservationExportedLabel;
    final titleLabel = l10n.reservations;

    final now = DateTime.now();
    final exportDate = DateFormat('yyyy-MM-dd').format(now);
    final exportDateDisplay = DateFormat('d MMM yyyy, HH:mm').format(now);
    final headers = enabledColumns
        .map((key) => _ExportColumn.label(key, l10n: l10n))
        .toList();
    final rowData = entries.map((entry) {
      final reservationId = _reservationKey(entry);
      final isNew = _markedAsNew.contains(reservationId);
      final cellValues = <String, String>{
        _ExportColumn.isNew: isNew ? yesLabel : '',
        _ExportColumn.arrival: entry.startDate != null
            ? dateFormatter.format(entry.startDate!.toLocal())
            : '',
        _ExportColumn.departure: entry.endDate != null
            ? dateFormatter.format(entry.endDate!.toLocal())
            : '',
        _ExportColumn.guestName: guestDisplayName(
          entry,
          fallback: l10n.revenueUnknownBooker,
        ),
        _ExportColumn.guests: guestBreakdown(entry, unknownLabel: ''),
        _ExportColumn.babyBed: _formatBabyExportValue(
          entry.infantCount,
          l10n: l10n,
        ),
        _ExportColumn.nights:
            stayNights(entry.startDate, entry.endDate)?.toString() ?? '',
        _ExportColumn.status: entry.status ?? '',
        _ExportColumn.source: entry.source ?? '',
        _ExportColumn.notes: (entry.notes ?? '').replaceAll(
          RegExp(r'[\t\r\n]+'),
          ' ',
        ),
      };
      return (
        isNew: isNew,
        values: [for (final key in enabledColumns) cellValues[key] ?? ''],
      );
    }).toList();

    pw.TableColumnWidth columnWidthFor(String key) {
      return switch (key) {
        _ExportColumn.isNew => const pw.FlexColumnWidth(0.8),
        _ExportColumn.arrival => const pw.FlexColumnWidth(1.55),
        _ExportColumn.departure => const pw.FlexColumnWidth(1.55),
        _ExportColumn.guestName => const pw.FlexColumnWidth(2.1),
        _ExportColumn.guests => const pw.FlexColumnWidth(1.1),
        _ExportColumn.babyBed => const pw.FlexColumnWidth(0.9),
        _ExportColumn.nights => const pw.FlexColumnWidth(1.25),
        _ExportColumn.status => const pw.FlexColumnWidth(1.1),
        _ExportColumn.source => const pw.FlexColumnWidth(1.1),
        _ExportColumn.notes => const pw.FlexColumnWidth(1.7),
        _ => const pw.FlexColumnWidth(1.0),
      };
    }

    final regular = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();

    final doc = pw.Document();
    final headerColor = PdfColor.fromInt(0xFF4472C4);
    final borderColor = PdfColor.fromInt(0xFFD6DCE4);
    final newRowColor = PdfColor.fromInt(0xFFFFFF00);

    doc.addPage(
      pw.MultiPage(
        pageFormat: switch (pdfOrientation) {
          _ExportPdfOrientation.landscape => PdfPageFormat.a4.landscape,
          _ => PdfPageFormat.a4,
        },
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          final tableRows = <pw.TableRow>[
            pw.TableRow(
              decoration: pw.BoxDecoration(color: headerColor),
              children: [
                for (final header in headers)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(
                        font: bold,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ];

          for (final row in rowData) {
            tableRows.add(
              pw.TableRow(
                decoration: row.isNew
                    ? pw.BoxDecoration(color: newRowColor)
                    : null,
                children: [
                  for (final value in row.values)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: pw.Text(
                        value,
                        style: pw.TextStyle(font: regular, fontSize: 9),
                      ),
                    ),
                ],
              ),
            );
          }

          return [
            pw.Text(
              titleLabel,
              style: pw.TextStyle(
                font: bold,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              '$exportedLabel: $exportDateDisplay',
              style: pw.TextStyle(
                font: regular,
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.7),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: {
                for (var index = 0; index < enabledColumns.length; index++)
                  index: columnWidthFor(enabledColumns[index]),
              },
              children: tableRows,
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    final filename = 'reservations_$exportDate.pdf';
    return (bytes, filename);
  }

  Future<void> _exportPdf(
    BuildContext context,
    List<Reservation> entries,
    DateFormat dateFormatter, {
    String? exportPdfOrientation,
    List<String>? columns,
  }) async {
    final (bytes, filename) = await _buildPdfBytes(
      context,
      entries,
      dateFormatter,
      exportPdfOrientation: exportPdfOrientation,
      columns: columns,
    );
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  Future<void> _sharePdf(
    BuildContext context,
    List<Reservation> entries,
    DateFormat dateFormatter, {
    String? exportPdfOrientation,
    List<String>? columns,
  }) async {
    final (bytes, filename) = await _buildPdfBytes(
      context,
      entries,
      dateFormatter,
      exportPdfOrientation: exportPdfOrientation,
      columns: columns,
    );
    final file = web.File(
      [bytes.toJS].toJS,
      filename,
      web.FilePropertyBag(type: 'application/pdf'),
    );
    final shareData = web.ShareData(files: [file].toJS);
    if (web.window.navigator.canShare(shareData)) {
      await web.window.navigator.share(shareData).toDart;
    }
  }
}

class _ReservationsHeader extends StatelessWidget {
  const _ReservationsHeader({
    required this.viewMode,
    required this.showHistorical,
    required this.allStatuses,
    required this.hiddenStatuses,
    required this.hiddenListColumns,
    required this.onViewChanged,
    required this.onShowHistoricalChanged,
    required this.onStatusToggled,
    required this.onListColumnToggled,
    this.timelineDensity,
    this.onTimelineDensityChanged,
    this.continuousMonths,
    this.onContinuousMonthsChanged,
    this.outOfMonthDisplay,
    this.onOutOfMonthDisplayChanged,
    this.exportMenu,
  });

  final _ReservationsViewMode viewMode;
  final bool showHistorical;
  final List<String> allStatuses;
  final Set<String> hiddenStatuses;
  final Set<String> hiddenListColumns;
  final ValueChanged<_ReservationsViewMode> onViewChanged;
  final ValueChanged<bool> onShowHistoricalChanged;
  final ValueChanged<String> onStatusToggled;
  final ValueChanged<String> onListColumnToggled;
  final _TimelineDensity? timelineDensity;
  final ValueChanged<_TimelineDensity>? onTimelineDensityChanged;
  final bool? continuousMonths;
  final ValueChanged<bool>? onContinuousMonthsChanged;
  final OutOfMonthDisplay? outOfMonthDisplay;
  final ValueChanged<OutOfMonthDisplay>? onOutOfMonthDisplayChanged;
  final Widget? exportMenu;

  @override
  Widget build(BuildContext context) {
    final isTimeline = viewMode == _ReservationsViewMode.timeline;
    final hasActiveFilter = hiddenStatuses.isNotEmpty || showHistorical;

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: context.styledSpacing.sm,
            runSpacing: context.styledSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StyledSegmentedControl(
                labels: [
                  context.s.reservationsViewList,
                  context.s.reservationsViewTimeline,
                ],
                selectedIndex: switch (viewMode) {
                  _ReservationsViewMode.list => 0,
                  _ReservationsViewMode.timeline => 1,
                },
                onChanged: (index) {
                  onViewChanged(switch (index) {
                    0 => _ReservationsViewMode.list,
                    _ => _ReservationsViewMode.timeline,
                  });
                },
              ),
              _buildFilterButton(context, hasActiveFilter),
              if (viewMode == _ReservationsViewMode.list)
                _buildListColumnsButton(context),
              if (isTimeline) _buildViewButton(context),
            ],
          ),
        ),
        if (exportMenu != null) ...[
          SizedBox(width: context.styledSpacing.sm),
          exportMenu!,
        ],
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context, bool hasActiveFilter) {
    return StyledToolbarButton.menu<String>(
      iconData: Icons.filter_list_rounded,
      isSelected: hasActiveFilter,
      tooltip: context.s.reservationsFilterTooltip,
      verticalOffset: 8,
      showDividers: allStatuses.isNotEmpty,
      entries: [
        _checkEntry(
          '_historical',
          context.s.reservationsFilterHistorical,
          showHistorical,
        ),
        ...allStatuses.map(
          (status) =>
              _checkEntry(status, status, !hiddenStatuses.contains(status)),
        ),
      ],
      onSelected: (value) {
        if (value == '_historical') {
          onShowHistoricalChanged(!showHistorical);
        } else {
          onStatusToggled(value);
        }
      },
    );
  }

  Widget _buildListColumnsButton(BuildContext context) {
    final hasActiveColumnToggles = hiddenListColumns.isNotEmpty;
    final l10n = context.s;

    return StyledToolbarButton.menu<String>(
      iconData: Icons.view_column_outlined,
      isSelected: hasActiveColumnToggles,
      tooltip: context.s.reservationsColumnsTooltip,
      verticalOffset: 8,
      entries: [
        for (final key in _ReservationListColumn.all)
          _checkEntry(
            key,
            _ReservationListColumn.label(key, l10n: l10n),
            !hiddenListColumns.contains(key),
            enabled:
                !hiddenListColumns.contains(key) ||
                hiddenListColumns.length <
                    _ReservationListColumn.all.length - 1,
          ),
      ],
      onSelected: (value) {
        onListColumnToggled(value);
      },
    );
  }

  Widget _buildViewButton(BuildContext context) {
    final density = timelineDensity;
    final continuous = continuousMonths;
    final outOfMonth = outOfMonthDisplay;

    final entries = <StyledMenuOverlayEntry<String>>[];
    if (density != null) {
      entries.add(
        _checkEntry(
          'compact',
          context.s.reservationsDensityCompact,
          density == _TimelineDensity.compact,
        ),
      );
      entries.add(
        _checkEntry(
          'comfortable',
          context.s.reservationsDensityDetailed,
          density == _TimelineDensity.comfortable,
        ),
      );
    }
    if (continuous != null) {
      entries.add(_checkEntry('single', '1 maand', !continuous));
      entries.add(
        _checkEntry(
          'continuous',
          context.s.reservationsMonthsContinuous,
          continuous,
        ),
      );
    }
    if (outOfMonth != null && continuous == false) {
      entries.add(
        _checkEntry(
          'outOfMonth_hide',
          context.s.reservationsOutOfMonthHide,
          outOfMonth == OutOfMonthDisplay.hide,
        ),
      );
      entries.add(
        _checkEntry(
          'outOfMonth_bookedOnly',
          context.s.reservationsOutOfMonthBookedOnly,
          outOfMonth == OutOfMonthDisplay.bookedOnly,
        ),
      );
    }

    return StyledToolbarButton.menu<String>(
      iconData: Icons.tune,
      tooltip: context.s.reservationsViewTooltip,
      verticalOffset: 8,
      showDividers: true,
      entries: entries,
      onSelected: (value) {
        switch (value) {
          case 'compact':
            onTimelineDensityChanged?.call(_TimelineDensity.compact);
          case 'comfortable':
            onTimelineDensityChanged?.call(_TimelineDensity.comfortable);
          case 'single':
            onContinuousMonthsChanged?.call(false);
          case 'continuous':
            onContinuousMonthsChanged?.call(true);
          case 'outOfMonth_hide':
            onOutOfMonthDisplayChanged?.call(OutOfMonthDisplay.hide);
          case 'outOfMonth_bookedOnly':
            onOutOfMonthDisplayChanged?.call(OutOfMonthDisplay.bookedOnly);
        }
      },
    );
  }

  static StyledMenuOverlayEntry<String> _checkEntry(
    String value,
    String label,
    bool checked, {
    bool enabled = true,
  }) {
    // The check mark, its size and its three state colours all come from the
    // menu theme — the call site only says whether the entry is on.
    return StyledMenuOverlayEntry<String>(
      value: value,
      enabled: enabled,
      label: label,
      checked: checked,
    );
  }
}

class _ContinuousMonthNavigation extends StatelessWidget {
  const _ContinuousMonthNavigation({
    required this.focusedMonth,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final String locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy', locale).format(focusedMonth);
    final dateFormatter = DateFormat('d MMM yyyy', locale);
    final monthStart = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final monthEnd = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final rangeLabel =
        '${dateFormatter.format(monthStart)} - ${dateFormatter.format(monthEnd)}';

    return Row(
      children: [
        _buildArrowButton(Icons.chevron_left_rounded, onPrevious),
        SizedBox(width: context.styledSpacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.styledSpacing.xs),
            Text(rangeLabel, style: theme.textTheme.bodySmall),
          ],
        ),
        SizedBox(width: context.styledSpacing.md),
        _buildArrowButton(Icons.chevron_right_rounded, onNext),
      ],
    );
  }

  // Design `.pnav .arw`: a white, hairline-bordered, radius-10 square — the
  // same control family as `.tbtn`, so it reads from the toolbar-button group
  // instead of being styled here.
  Widget _buildArrowButton(IconData iconData, VoidCallback onPressed) {
    return StyledToolbarButton(iconData: iconData, onPressed: onPressed);
  }
}

class _ReservationListView extends StatelessWidget {
  const _ReservationListView({
    required this.entries,
    required this.dateFormatter,
    required this.dateTimeFormatter,
    required this.markedAsNew,
    required this.hiddenColumns,
    required this.onToggleNew,
    required this.onEntryTap,
  });

  final List<Reservation> entries;
  final DateFormat dateFormatter;
  final DateFormat dateTimeFormatter;
  final Set<String> markedAsNew;
  final Set<String> hiddenColumns;
  final ValueChanged<String> onToggleNew;
  final ValueChanged<Reservation> onEntryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final visibleColumns = _ReservationListColumn.all
        .where((column) => !hiddenColumns.contains(column))
        .toList();
    final safeVisibleColumns = visibleColumns.isEmpty
        ? [_ReservationListColumn.guestName]
        : visibleColumns;

    StyledDataColumn _columnFor(String key) {
      return switch (key) {
        _ReservationListColumn.source => const StyledDataColumn(
          columnHeaderLabel: '',
          flex: 0,
          width: 28,
        ),
        _ReservationListColumn.guestName => StyledDataColumn(
          columnHeaderLabel: l10n.reservationSectionBooker,
          flex: 2,
          minWidth: 128,
        ),
        _ReservationListColumn.checkIn => StyledDataColumn(
          columnHeaderLabel: l10n.reservationCheckIn,
          flex: 1,
          minWidth: 96,
        ),
        _ReservationListColumn.checkOut => StyledDataColumn(
          columnHeaderLabel: l10n.reservationCheckOut,
          flex: 1,
          minWidth: 96,
        ),
        _ReservationListColumn.nights => StyledDataColumn(
          columnHeaderLabel: l10n.reservationNights,
          flex: 0,
          width: 66,
          alignment: Alignment.centerLeft,
        ),
        _ReservationListColumn.guests => StyledDataColumn(
          columnHeaderLabel: l10n.reservationsColumnGuests,
          flex: 0,
          width: 66,
          alignment: Alignment.centerLeft,
        ),
        _ReservationListColumn.babyBed => StyledDataColumn(
          columnHeaderLabel: l10n.reservationInfants,
          flex: 0,
          width: 52,
          alignment: Alignment.centerLeft,
        ),
        _ReservationListColumn.status => StyledDataColumn(
          columnHeaderLabel: l10n.reservationStatus,
          flex: 1,
          // The chip carries 9px of padding either side of the label.
          minWidth: 98,
        ),
        _ReservationListColumn.booked => StyledDataColumn(
          columnHeaderLabel: l10n.reservationListColumnBooked,
          flex: 2,
          minWidth: 132,
        ),
        _ReservationListColumn.isNew => StyledDataColumn(
          columnHeaderLabel: l10n.reservationListColumnNew,
          flex: 0,
          width: 44,
          alignment: Alignment.center,
        ),
        _ => const StyledDataColumn(
          columnHeaderLabel: '',
          flex: 1,
          minWidth: 64,
        ),
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            // Page bottom padding at the end of the list — see
            // `bottomPaddingInsideContent`.
            padding: EdgeInsets.only(
              bottom: StyledWebPageScaffoldScope.of(context).contentBottomInset,
            ),
            children: [
              StyledDataTable(
                // Design `.tbl-wrap` + `.dt td{border-bottom}`: one surface with
                // hairline separators, not gapped rounded row cards.
                variant: StyledTableVariant.plain,
                dense: true,
                uppercaseHeaderLabels: false,
                itemCount: entries.length,
                columns: safeVisibleColumns
                    .map((column) => _columnFor(column))
                    .toList(),
                rowBuilder: (tableContext, index) {
                  final entry = entries[index];
                  final nights = stayNights(entry.startDate, entry.endDate);
                  final key = _reservationKey(entry);
                  final isNew = markedAsNew.contains(key);

                  Widget textCell(
                    String? value, {
                    FontWeight? fontWeight,
                    TextAlign textAlign = TextAlign.left,
                  }) {
                    final safeValue = valueOrDash(value);
                    return Text(
                      safeValue,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      textAlign: textAlign,
                      style: Theme.of(
                        tableContext,
                      ).textTheme.bodySmall?.copyWith(fontWeight: fontWeight),
                    );
                  }

                  Widget cellFor(String columnKey) {
                    return switch (columnKey) {
                      _ReservationListColumn.source => Align(
                        alignment: Alignment.centerLeft,
                        child: BookingSourceIcon(
                          source: entry.source,
                          size: 18,
                        ),
                      ),
                      _ReservationListColumn.guestName => textCell(
                        guestDisplayName(
                          entry,
                          fallback: l10n.revenueUnknownBooker,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                      _ReservationListColumn.checkIn => textCell(
                        formatDateTime(entry.startDate, dateFormatter),
                      ),
                      _ReservationListColumn.checkOut => textCell(
                        formatDateTime(entry.endDate, dateFormatter),
                      ),
                      _ReservationListColumn.nights => textCell(
                        nights?.toString(),
                        textAlign: TextAlign.right,
                      ),
                      _ReservationListColumn.guests => textCell(
                        guestBreakdown(entry, unknownLabel: ''),
                        textAlign: TextAlign.left,
                      ),
                      _ReservationListColumn.babyBed => textCell(
                        entry.infantCount == null
                            ? null
                            : entry.infantCount! > 0
                            ? l10n.yes
                            : l10n.no,
                        textAlign: TextAlign.left,
                      ),
                      _ReservationListColumn.status => Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusChip(status: entry.status),
                      ),
                      _ReservationListColumn.booked => textCell(
                        formatDateTime(entry.createdAt, dateTimeFormatter),
                      ),
                      _ReservationListColumn.isNew => Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: isNew,
                            onChanged: (_) => onToggleNew(key),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      _ => const SizedBox.shrink(),
                    };
                  }

                  return safeVisibleColumns
                      .map((column) => cellFor(column))
                      .toList();
                },
                onRowTap: (tableContext, index) => onEntryTap(entries[index]),
                emptyLabel: context.s.reservationsEmptyList,
                showTableWhenEmpty: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Design `.stat`: the booking status as a tinted pill, not a word in the row.
///
/// The label is Lodgify's own status string — the console does not own that
/// vocabulary, and the filter menu lists the same raw values — but the tone is
/// ours, so a cancellation is visible without reading the column.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final label = status?.trim();
    if (label == null || label.isEmpty) return const SizedBox.shrink();

    // Lodgify's vocabulary, mapped onto the console's four tones. The pill
    // itself is shared with every other state pill in the app.
    final tone = switch (label.toLowerCase()) {
      final s when s.contains('cancel') || s.contains('declin') =>
        StatusPillTone.negative,
      final s
          when s.contains('tentative') ||
              s.contains('pending') ||
              s.contains('option') ||
              s.contains('hold') =>
        StatusPillTone.caution,
      final s when s.contains('book') || s.contains('confirm') =>
        StatusPillTone.positive,
      _ => StatusPillTone.neutral,
    };

    return StatusPill(label: label, tone: tone);
  }
}

/// The four KPIs from the design, scoped to one month: Boekingen, Aankomsten,
/// Vertrekken, Bezetting.
///
/// One definition, used by both the list and the timeline, so the two can never
/// show a different set — and all four recompute when a status filter changes,
/// because they are derived from the same filtered bookings.
List<MetricTileData> _monthMetrics(_MonthSummary summary, {required S l10n}) {
  return [
    MetricTileData(
      label: l10n.reservationsKpiBookings,
      value: '${summary.bookingCount}',
      // Design `.kpi .kl svg`: a calendar, a check-in arrow, a check-out arrow
      // and a suitcase — the four glyphs read as one set, which a ticket icon
      // and a bed do not.
      icon: Icons.calendar_month_outlined,
      caption: l10n.reservationsKpiBookingsCaption,
    ),
    MetricTileData(
      label: l10n.reservationsKpiArrivals,
      value: '${summary.arrivals}',
      icon: Icons.login_outlined,
      caption: l10n.reservationsKpiArrivalsCaption,
    ),
    MetricTileData(
      label: l10n.reservationsKpiDepartures,
      value: '${summary.departures}',
      icon: Icons.logout_outlined,
      caption: l10n.reservationsKpiDeparturesCaption,
    ),
    MetricTileData(
      label: l10n.reservationsKpiOccupancy,
      value: '${summary.occupancyPercentage}%',
      icon: Icons.work_outline,
      caption: l10n.reservationsBarNights(summary.occupiedNights),
    ),
  ];
}

class _MonthSummary {
  const _MonthSummary({
    required this.bookingCount,
    required this.arrivals,
    required this.departures,
    required this.occupiedNights,
    required this.daysInMonth,
  });

  final int bookingCount;
  final int arrivals;
  final int departures;

  /// Nights occupied within this month, clipped to the month — a stay that
  /// straddles the boundary counts only its nights inside it.
  final int occupiedNights;
  final int daysInMonth;

  /// Occupancy as a whole percentage, `0` for a month with no nights.
  int get occupancyPercentage {
    if (daysInMonth <= 0) return 0;
    return ((occupiedNights / daysInMonth) * 100).round();
  }
}

List<Reservation> _sortedBookings(List<Reservation> entries) {
  final bookings = entries.where(_isBooking).toList();
  bookings.sort((a, b) {
    final aStart = a.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bStart = b.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aStart.compareTo(bStart);
  });
  return bookings;
}

bool _isBooking(Reservation entry) {
  final status = entry.status?.trim().toLowerCase();
  if (status == null || status.isEmpty) return true;
  return !status.contains('available');
}

bool _bookingEnded(Reservation entry, DateTime today) {
  final end = entry.endDate ?? entry.startDate;
  if (end == null) return false;
  return _dateOnly(end).isBefore(today);
}

_MonthSummary _monthSummary(DateTime month, List<Reservation> entries) {
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 1);

  var bookingCount = 0;
  var arrivals = 0;
  var departures = 0;
  var occupiedNights = 0;

  for (final entry in entries) {
    final start = entry.startDate;
    final end = entry.endDate ?? start;
    if (start == null || end == null) continue;

    final startDay = _dateOnly(start);
    final endDay = _dateOnly(end);

    final overlapsMonth =
        !endDay.isBefore(monthStart) && !startDay.isAfter(monthEnd);

    if (overlapsMonth) {
      bookingCount += 1;
      occupiedNights += _overlapDays(
        startDay,
        endDay,
        monthStart,
        monthEnd.subtract(const Duration(days: 1)),
      );
    }

    if (!startDay.isBefore(monthStart) && startDay.isBefore(monthEnd)) {
      arrivals += 1;
    }

    if (!endDay.isBefore(monthStart) && endDay.isBefore(monthEnd)) {
      departures += 1;
    }
  }

  return _MonthSummary(
    bookingCount: bookingCount,
    arrivals: arrivals,
    departures: departures,
    occupiedNights: occupiedNights,
    daysInMonth: monthEnd.difference(monthStart).inDays,
  );
}

int _overlapDays(
  DateTime start,
  DateTime end,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final overlapStart = start.isAfter(rangeStart) ? start : rangeStart;
  final overlapEnd = end.isBefore(rangeEnd) ? end : rangeEnd;
  if (overlapEnd.isBefore(overlapStart)) return 0;
  return overlapEnd.difference(overlapStart).inDays + 1;
}

String _reservationKey(Reservation entry) {
  if (entry.reservationId != null && entry.reservationId!.isNotEmpty) {
    return entry.reservationId!;
  }
  return '${entry.guestName ?? ''}_${entry.startDate?.toIso8601String() ?? ''}';
}

String _normalizePdfOrientation(String? orientation) {
  final normalized = orientation?.trim().toLowerCase() ?? '';
  if (normalized == _ExportPdfOrientation.landscape) {
    return _ExportPdfOrientation.landscape;
  }
  return _ExportPdfOrientation.portrait;
}

String _formatBabyExportValue(int? infantCount, {required S l10n}) {
  if (infantCount == null) return '-';
  if (infantCount > 0) return infantCount.toString();
  return l10n.no;
}

// ---------------------------------------------------------------------------
// Export Settings Dialog
// ---------------------------------------------------------------------------

class _ExportSettingsResult {
  const _ExportSettingsResult({
    required this.enabledColumns,
    required this.exportPdfOrientation,
  });

  final List<String> enabledColumns;
  final String exportPdfOrientation;
}

Future<_ExportSettingsResult?> _showExportSettingsDialog(
  BuildContext context, {
  required List<String> currentColumns,
  required String currentPdfOrientation,
}) async {
  return showStyledModal<_ExportSettingsResult>(
    context,
    title: context.s.exportSettingsTitle,
    isDismissible: true,
    showCloseButton: true,
    leadingClose: true,
    leadingPlacement: StyledModalSlotPlacement.header,
    dialogMinWidth: 440,
    dialogMaxWidth: 480,
    actionPlacement: StyledModalSlotPlacement.footer,
    actionLabel: context.s.saveButton,
    closeOnAction: true,
    stateBuilder: (data) => StyledModalControlState(
      actionEnabled: data != null && data.enabledColumns.isNotEmpty,
    ),
    initialValue: _ExportSettingsResult(
      enabledColumns: currentColumns,
      exportPdfOrientation: currentPdfOrientation,
    ),
    dataBuilder: (dialogContext, onDataChanged) {
      return _ExportSettingsDialogContent(
        initialColumns: currentColumns,
        initialPdfOrientation: currentPdfOrientation,
        onDataChanged: onDataChanged,
      );
    },
  );
}

class _ExportSettingsDialogContent extends StatefulWidget {
  const _ExportSettingsDialogContent({
    required this.initialColumns,
    required this.initialPdfOrientation,
    required this.onDataChanged,
  });

  final List<String> initialColumns;
  final String initialPdfOrientation;
  final void Function(_ExportSettingsResult?) onDataChanged;

  @override
  State<_ExportSettingsDialogContent> createState() =>
      _ExportSettingsDialogContentState();
}

class _ExportSettingsDialogContentState
    extends State<_ExportSettingsDialogContent> {
  late String _pdfOrientation;
  late List<String> _orderedColumns;
  late Set<String> _toggledColumns;

  @override
  void initState() {
    super.initState();
    _pdfOrientation = _normalizePdfOrientation(widget.initialPdfOrientation);
    final enabled = List<String>.from(widget.initialColumns);
    final disabled = _ExportColumn.all
        .where((key) => !enabled.contains(key))
        .toList();
    _orderedColumns = [...enabled, ...disabled];
    _toggledColumns = Set<String>.from(widget.initialColumns);
  }

  void _notifyDataChanged() {
    widget.onDataChanged(
      _ExportSettingsResult(
        enabledColumns: _orderedColumns
            .where(_toggledColumns.contains)
            .toList(),
        exportPdfOrientation: _pdfOrientation,
      ),
    );
  }

  void _toggle(String key) {
    setState(() {
      if (_toggledColumns.contains(key)) {
        _toggledColumns.remove(key);
      } else {
        _toggledColumns.add(key);
      }
    });
    _notifyDataChanged();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = _orderedColumns.removeAt(oldIndex);
      _orderedColumns.insert(newIndex, item);
    });
    _notifyDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StyledSection(
          inset: false,
          children: [
            StyledSelectionTile<String>.dropdown(
              title: context.s.exportPdfOrientationTitle,
              currentValue: _pdfOrientation,
              options: const [
                _ExportPdfOrientation.portrait,
                _ExportPdfOrientation.landscape,
              ],
              optionLabelBuilder: (value) => switch (value) {
                _ExportPdfOrientation.landscape =>
                  context.s.exportPdfOrientationLandscape,
                _ => context.s.exportPdfOrientationPortrait,
              },
              fieldAutoSize: true,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _pdfOrientation = value);
                _notifyDataChanged();
              },
            ),
          ],
        ),
        SizedBox(height: context.styledSpacing.sm),
        StyledReorderableSection(
          header: context.s.exportColumnsTitle,
          inset: false,
          itemCount: _orderedColumns.length,
          onReorder: _onReorder,
          itemBuilder: (context, index, isReorderMode) {
            final key = _orderedColumns[index];
            final enabled = _toggledColumns.contains(key);
            return StyledReorderableTile(
              key: ValueKey(key),
              index: index,
              canDrag: true,
              showChevron: false,
              leading: SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: enabled,
                  onChanged: (_) => _toggle(key),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              title: Text(
                _ExportColumn.label(key, l10n: S.of(context)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: enabled ? null : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

String _escapeHtml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
