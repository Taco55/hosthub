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

import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/features/reservations/application/nightly_rates_cubit.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/l10n/intl/messages_all.dart'
    as l10n_messages;
import 'package:hosthub_console/core/widgets/widgets.dart';
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
  String? _lastPropertyId;
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

  GlobalKey _keyForMonth(DateTime month) {
    final key = '${month.year}-${month.month}';
    return _monthKeys.putIfAbsent(key, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.wait([
        _ensureLanguageMessagesInitialized('nl'),
        _ensureLanguageMessagesInitialized('en'),
      ]),
    );
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
            setState(() => _focusedMonth = now);
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
            final propertyId = _lastPropertyId;
            if (propertyId == null || propertyId.isEmpty) return;
            context.read<NightlyRatesCubit>().loadRates(
              propertyId: propertyId,
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
          final propertyName = property?.name ?? 'Onbekende accommodatie';
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

          return ConsolePageScaffold(
            title: 'Reserveringen',
            description: 'Boekingen voor $propertyName uit Lodgify.',
            showLoadingIndicator: state.status == ReservationsStatus.loading,
            leftChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    setState(() => _viewMode = value);
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
                const SizedBox(height: 16),
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

  Widget _buildContent(
    BuildContext context, {
    required ReservationsState state,
    required String? propertyId,
    required List<Reservation> entries,
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
  }) {
    if (propertyId == null || propertyId.isEmpty) {
      return Center(
        child: Text(
          'Koppel een Lodgify ID aan deze accommodatie om boekingen te laden.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state.status == ReservationsStatus.error) {
      return Center(
        child: Text(
          'Boekingen konden niet worden geladen.',
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
      final allBookings = _sortedBookings(state.entries);
      final timelineBookings = _hiddenStatuses.isEmpty
          ? allBookings
          : allBookings.where((e) {
              final s = e.status?.trim().toLowerCase() ?? '';
              return s.isEmpty || !_hiddenStatuses.contains(s);
            }).toList();
      final today = _dateOnly(DateTime.now());

      // Build nightly-rate labels per day from ALL entries (including
      // "available" entries which carry pricing info).
      final dayLabels = <DateTime, String>{};
      for (final e in state.entries) {
        if (e.startDate == null || e.endDate == null) continue;
        final rev = _extractRevenue(e);
        num? rate = rev.nightlyRate;
        if (rate == null && rev.total != null) {
          final nights = _dateOnly(
            e.endDate!,
          ).difference(_dateOnly(e.startDate!)).inDays;
          if (nights > 0) rate = rev.total! / nights;
        }
        if (rate == null) continue;
        final rateStr = _formatAmount(rate, rev.currency);
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
          () => _formatAmount(entry.value, ratesState.rateCurrency),
        );
      }

      final isCompact = _timelineDensity == _TimelineDensity.compact;
      final timelineSummary = _monthSummary(_focusedMonth, timelineBookings);
      final locale = Localizations.localeOf(context).toString();

      final timelineEntries = timelineBookings
          .where((e) => e.startDate != null && e.endDate != null)
          .map((e) {
            final isPast =
                _dateOnly(e.endDate!).isBefore(today) ||
                _dateOnly(e.endDate!).isAtSameMomentAs(today);
            final baseColor = BookingSourceIcon.barColor(e.source);
            final guestInfo = _guestBreakdown(e, unknownLabel: '');
            final name = e.guestName ?? 'Onbekende boeker';
            final label = guestInfo.isNotEmpty ? '$name ($guestInfo)' : name;
            final nights = _stayNights(e.startDate, e.endDate);
            final tooltipParts = <String>[
              name,
              '${dateFormatter.format(e.startDate!.toLocal())} → ${dateFormatter.format(e.endDate!.toLocal())}',
              if (nights != null) '$nights nachten',
              if (guestInfo.isNotEmpty) 'Gasten: $guestInfo',
              if (e.source != null && e.source!.isNotEmpty) 'Bron: ${e.source}',
              if (e.status != null && e.status!.isNotEmpty)
                'Status: ${e.status}',
            ];
            return TimelineCalendarEntry(
              start: e.startDate!,
              end: e.endDate!,
              label: label,
              tooltip: tooltipParts.join('\n'),
              color: isPast
                  ? Color.lerp(baseColor, const Color(0xFFE0E0E0), 0.55)!
                  : baseColor,
              textColor: isPast ? const Color(0xFF9E9E9E) : null,
              outlined: isPast,
              leading: isPast
                  ? Opacity(
                      opacity: 0.45,
                      child: BookingSourceIcon(
                        source: e.source,
                        size: isCompact ? 14 : 18,
                      ),
                    )
                  : BookingSourceIcon(
                      source: e.source,
                      size: isCompact ? 14 : 18,
                    ),
              data: e,
            );
          })
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_continuousMonths) ...[
            // Metrics + navigation listen to ValueNotifier — only these
            // rebuild when the active month changes during scroll, NOT the
            // 24+ TimelineCalendar grids below.
            ValueListenableBuilder<DateTime>(
              valueListenable: _continuousActiveMonth,
              builder: (context, activeMonth, _) {
                final summary = _monthSummary(activeMonth, timelineBookings);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 700;
                        return Wrap(
                          spacing: compact ? 8 : 12,
                          runSpacing: compact ? 8 : 12,
                          children: [
                            _MetricTile(
                              label: 'Boekingen maand',
                              value: '${summary.bookingCount}',
                              icon: Icons.book_online_outlined,
                              compact: compact,
                            ),
                            _MetricTile(
                              label: 'Aankomsten',
                              value: '${summary.arrivals}',
                              icon: Icons.login_outlined,
                              compact: compact,
                            ),
                            _MetricTile(
                              label: 'Vertrekken',
                              value: '${summary.departures}',
                              icon: Icons.logout_outlined,
                              compact: compact,
                            ),
                            _MetricTile(
                              label: 'Nachten bezet',
                              value: '${summary.occupiedNights}',
                              icon: Icons.hotel_outlined,
                              compact: compact,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
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
            const SizedBox(height: 8),
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
                                  if (i > 0) const SizedBox(height: 24),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
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
                                    barHeight: isCompact ? 22.0 : 30.0,
                                    dayNumberHeight: isCompact ? 18.0 : 24.0,
                                    barTopPadding: isCompact ? 3.0 : 6.0,
                                    rowBottomPadding: isCompact ? 4.0 : 10.0,
                                    dayLabels: isCompact ? null : dayLabels,
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
            // Single-month mode: metrics use _focusedMonth directly
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;
                return Wrap(
                  spacing: compact ? 8 : 12,
                  runSpacing: compact ? 8 : 12,
                  children: [
                    _MetricTile(
                      label: 'Boekingen maand',
                      value: '${timelineSummary.bookingCount}',
                      icon: Icons.book_online_outlined,
                      compact: compact,
                    ),
                    _MetricTile(
                      label: 'Aankomsten',
                      value: '${timelineSummary.arrivals}',
                      icon: Icons.login_outlined,
                      compact: compact,
                    ),
                    _MetricTile(
                      label: 'Vertrekken',
                      value: '${timelineSummary.departures}',
                      icon: Icons.logout_outlined,
                      compact: compact,
                    ),
                    _MetricTile(
                      label: 'Nachten bezet',
                      value: '${timelineSummary.occupiedNights}',
                      icon: Icons.hotel_outlined,
                      compact: compact,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TimelineCalendar(
                focusedMonth: _focusedMonth,
                outOfMonthDisplay: _outOfMonthDisplay,
                barHeight: isCompact ? 22.0 : 30.0,
                dayNumberHeight: isCompact ? 18.0 : 24.0,
                barTopPadding: isCompact ? 3.0 : 6.0,
                rowBottomPadding: isCompact ? 4.0 : 10.0,
                entries: timelineEntries,
                dayLabels: isCompact ? null : dayLabels,
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
          'Geen reserveringen gevonden voor deze periode.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (_viewMode == _ReservationsViewMode.list) {
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

    // Unreachable – only list and timeline modes exist.
    return const SizedBox.shrink();
  }

  Future<void> _showReservationDetails(
    BuildContext context,
    Reservation entry, {
    required DateFormat dateFormatter,
    required DateFormat dateTimeFormatter,
  }) {
    final rateCurrency = context.read<NightlyRatesCubit>().state.rateCurrency;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _ReservationDetailsDialog(
          entry: entry,
          dateFormatter: dateFormatter,
          dateTimeFormatter: dateTimeFormatter,
          rateCurrency: rateCurrency,
        );
      },
    );
  }

  void _loadReservationsForProperty(PropertySummary? property) {
    final lodgifyId = property?.lodgifyId?.trim();
    if (lodgifyId == null || lodgifyId.isEmpty) {
      _lastPropertyId = null;
      return;
    }
    if (_lastPropertyId == lodgifyId) return;
    _lastPropertyId = lodgifyId;
    context.read<ReservationsCubit>().loadReservations(propertyId: lodgifyId);
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
    final theme = Theme.of(context);
    String labeledWithNew(String label) {
      return switch (newCount) {
        0 => label,
        _ => '$label (${l10n.reservationNewCount(newCount)})',
      };
    }

    return StyledPopupMenuButton<String>(
      tooltip: 'Delen & exporteren',
      verticalOffset: 8,
      showDividers: true,
      child: _HeaderIconChip(
        icon: Icons.ios_share,
        isActive: false,
        theme: theme,
      ),
      entries: [
        StyledPopupMenuEntry(
          value: 'pdf',
          label: labeledWithNew('PDF downloaden'),
          leading: const Icon(Icons.picture_as_pdf_outlined),
        ),
        StyledPopupMenuEntry(
          value: 'pdf_share',
          label: labeledWithNew('PDF delen'),
          leading: const Icon(Icons.mail_outlined),
        ),
        StyledPopupMenuEntry(
          value: 'excel',
          label: labeledWithNew('Excel'),
          leading: const Icon(Icons.table_chart_outlined),
        ),
        const StyledPopupMenuEntry(
          value: 'csv',
          label: 'CSV',
          leading: Icon(Icons.download_outlined),
        ),
        const StyledPopupMenuEntry(
          value: 'settings',
          label: 'Instellingen',
          leading: Icon(Icons.settings_outlined),
        ),
      ],
      onSelected: (value) async {
        final settings = context.read<SettingsCubit>().state.settings;
        final exportLanguageCode = _normalizeLanguageCode(
          settings?.exportLanguageCode,
        );
        final exportPdfOrientation = _normalizePdfOrientation(
          settings?.exportPdfOrientation,
        );
        switch (value) {
          case 'pdf':
            await _ensureLanguageMessagesInitialized(exportLanguageCode);
            await _exportPdf(
              entries,
              dateFormatter,
              exportLang: exportLanguageCode,
              exportPdfOrientation: exportPdfOrientation,
              columns: settings?.exportColumns ?? _ExportColumn.defaults,
            );
          case 'pdf_share':
            await _ensureLanguageMessagesInitialized(exportLanguageCode);
            await _sharePdf(
              entries,
              dateFormatter,
              exportLang: exportLanguageCode,
              exportPdfOrientation: exportPdfOrientation,
              columns: settings?.exportColumns ?? _ExportColumn.defaults,
            );
          case 'excel':
            await _ensureLanguageMessagesInitialized(exportLanguageCode);
            _exportExcel(
              entries,
              dateFormatter,
              exportLang: exportLanguageCode,
              columns: settings?.exportColumns ?? _ExportColumn.defaults,
            );
          case 'csv':
            _exportCsv(entries, dateFormatter);
          case 'settings':
            () async {
              final settings = context.read<SettingsCubit>().state.settings;
              final currentLang = _normalizeLanguageCode(
                settings?.exportLanguageCode ??
                    Localizations.localeOf(context).languageCode,
              );
              final currentColumns =
                  settings?.exportColumns ?? _ExportColumn.defaults;
              final currentPdfOrientation = _normalizePdfOrientation(
                settings?.exportPdfOrientation,
              );
              final result = await _showExportSettingsDialog(
                context,
                currentLanguageCode: currentLang,
                currentColumns: currentColumns,
                currentPdfOrientation: currentPdfOrientation,
              );
              if (result == null || !context.mounted) return;
              context.read<UserSettingsCubit>().changeExportSettings(
                exportLanguageCode: result.exportLanguageCode,
                exportColumns: result.enabledColumns,
                exportPdfOrientation: result.exportPdfOrientation,
              );
            }();
        }
      },
    );
  }

  void _exportExcel(
    List<Reservation> entries,
    DateFormat dateFormatter, {
    String? exportLang,
    List<String>? columns,
  }) {
    final languageCode = _normalizeLanguageCode(exportLang);
    final enabledColumns = columns ?? _ExportColumn.defaults;
    final yesLabel = _localizedForLanguage(languageCode, (l10n) => l10n.yes);
    final exportedLabel = _localizedForLanguage(
      languageCode,
      (l10n) => l10n.reservationExportedLabel,
    );

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
      buf.write(
        '<th>${_localizedForLanguage(languageCode, (l10n) => _ExportColumn.label(key, l10n: l10n))}</th>',
      );
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
        _ExportColumn.guestName: _escapeHtml(_guestDisplayName(e)),
        _ExportColumn.guests: _escapeHtml(_guestBreakdown(e, unknownLabel: '')),
        _ExportColumn.babyBed: _formatBabyExportValue(
          e.infantCount,
          languageCode: languageCode,
        ),
        _ExportColumn.nights:
            _stayNights(e.startDate, e.endDate)?.toString() ?? '',
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

  void _exportCsv(List<Reservation> entries, DateFormat dateFormatter) {
    const exportLanguageCode = 'en';
    final buf = StringBuffer();
    buf.writeln(
      'Nieuw\tArrival\tDeparture\tGuest name\tGuests\tBaby bed\tCheck-in\tCheck-out\tNotes',
    );
    for (final e in entries) {
      final id = _reservationKey(e);
      final isNew = _markedAsNew.contains(id) ? 'Ja' : '';
      final arrival = e.startDate != null
          ? dateFormatter.format(e.startDate!.toLocal())
          : '';
      final departure = e.endDate != null
          ? dateFormatter.format(e.endDate!.toLocal())
          : '';
      final guestName = _guestDisplayName(e);
      final guests = _guestBreakdown(e, unknownLabel: '');
      final babyBed = _formatBabyExportValue(
        e.infantCount,
        languageCode: exportLanguageCode,
      );
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
    List<Reservation> entries,
    DateFormat dateFormatter, {
    String? exportLang,
    String? exportPdfOrientation,
    List<String>? columns,
  }) async {
    final languageCode = _normalizeLanguageCode(exportLang);
    final pdfOrientation = _normalizePdfOrientation(exportPdfOrientation);
    final enabledColumns = columns ?? _ExportColumn.defaults;
    final yesLabel = _localizedForLanguage(languageCode, (l10n) => l10n.yes);
    final exportedLabel = _localizedForLanguage(
      languageCode,
      (l10n) => l10n.reservationExportedLabel,
    );
    final titleLabel = _localizedForLanguage(
      languageCode,
      (l10n) => l10n.reservations,
    );

    final now = DateTime.now();
    final exportDate = DateFormat('yyyy-MM-dd').format(now);
    final exportDateDisplay = DateFormat('d MMM yyyy, HH:mm').format(now);
    final headers = enabledColumns
        .map(
          (key) => _localizedForLanguage(
            languageCode,
            (l10n) => _ExportColumn.label(key, l10n: l10n),
          ),
        )
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
        _ExportColumn.guestName: _guestDisplayName(entry),
        _ExportColumn.guests: _guestBreakdown(entry, unknownLabel: ''),
        _ExportColumn.babyBed: _formatBabyExportValue(
          entry.infantCount,
          languageCode: languageCode,
        ),
        _ExportColumn.nights:
            _stayNights(entry.startDate, entry.endDate)?.toString() ?? '',
        _ExportColumn.status: entry.status ?? '',
        _ExportColumn.source: entry.source ?? '',
        _ExportColumn.notes: (entry.notes ?? '')
            .replaceAll(RegExp(r'[\t\r\n]+'), ' '),
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
    List<Reservation> entries,
    DateFormat dateFormatter, {
    String? exportLang,
    String? exportPdfOrientation,
    List<String>? columns,
  }) async {
    final (bytes, filename) = await _buildPdfBytes(
      entries,
      dateFormatter,
      exportLang: exportLang,
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
    List<Reservation> entries,
    DateFormat dateFormatter, {
    String? exportLang,
    String? exportPdfOrientation,
    List<String>? columns,
  }) async {
    final (bytes, filename) = await _buildPdfBytes(
      entries,
      dateFormatter,
      exportLang: exportLang,
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
    final theme = Theme.of(context);
    final isTimeline = viewMode == _ReservationsViewMode.timeline;
    final hasActiveFilter = hiddenStatuses.isNotEmpty || showHistorical;

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StyledSegmentedControl(
                labels: const ['Lijst', 'Tijdlijn'],
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
              _buildFilterButton(context, theme, hasActiveFilter),
              if (viewMode == _ReservationsViewMode.list)
                _buildListColumnsButton(context, theme),
              if (isTimeline) _buildViewButton(context, theme),
            ],
          ),
        ),
        if (exportMenu != null) ...[const SizedBox(width: 8), exportMenu!],
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    ThemeData theme,
    bool hasActiveFilter,
  ) {
    return StyledPopupMenuButton<String>(
      tooltip: 'Filter',
      verticalOffset: 8,
      showDividers: allStatuses.isNotEmpty,
      entries: [
        _checkEntry('_historical', 'Historische boekingen', showHistorical),
        ...allStatuses.map(
          (status) => _checkEntry(
            status,
            status,
            !hiddenStatuses.contains(status),
          ),
        ),
      ],
      onSelected: (value) {
        if (value == '_historical') {
          onShowHistoricalChanged(!showHistorical);
        } else {
          onStatusToggled(value);
        }
      },
      child: _HeaderIconChip(
        icon: Icons.filter_list_rounded,
        isActive: hasActiveFilter,
        theme: theme,
      ),
    );
  }

  Widget _buildListColumnsButton(BuildContext context, ThemeData theme) {
    final hasActiveColumnToggles = hiddenListColumns.isNotEmpty;
    final l10n = context.s;

    return StyledPopupMenuButton<String>(
      tooltip: 'Kolommen',
      verticalOffset: 8,
      entries: [
        for (final key in _ReservationListColumn.all)
          _checkEntry(
            key,
            _ReservationListColumn.label(key, l10n: l10n),
            !hiddenListColumns.contains(key),
            enabled: !hiddenListColumns.contains(key) ||
                hiddenListColumns.length <
                    _ReservationListColumn.all.length - 1,
          ),
      ],
      onSelected: (value) {
        onListColumnToggled(value);
      },
      child: _HeaderIconChip(
        icon: Icons.view_column_outlined,
        isActive: hasActiveColumnToggles,
        theme: theme,
      ),
    );
  }

  Widget _buildViewButton(BuildContext context, ThemeData theme) {
    final density = timelineDensity;
    final continuous = continuousMonths;
    final outOfMonth = outOfMonthDisplay;

    final entries = <StyledPopupMenuEntry<String>>[];
    if (density != null) {
      entries.add(
        _checkEntry(
          'compact',
          'Compact',
          density == _TimelineDensity.compact,
        ),
      );
      entries.add(
        _checkEntry(
          'comfortable',
          'Gedetailleerd',
          density == _TimelineDensity.comfortable,
        ),
      );
    }
    if (continuous != null) {
      entries.add(_checkEntry('single', '1 maand', !continuous));
      entries.add(_checkEntry('continuous', 'Doorlopend', continuous));
    }
    if (outOfMonth != null && continuous == false) {
      entries.add(
        _checkEntry(
          'outOfMonth_hide',
          'Buiten maand verbergen',
          outOfMonth == OutOfMonthDisplay.hide,
        ),
      );
      entries.add(
        _checkEntry(
          'outOfMonth_bookedOnly',
          'Alleen geboekte dagen',
          outOfMonth == OutOfMonthDisplay.bookedOnly,
        ),
      );
    }

    return StyledPopupMenuButton<String>(
      tooltip: 'Weergave',
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
      child: _HeaderIconChip(icon: Icons.tune, isActive: false, theme: theme),
    );
  }

  static StyledPopupMenuEntry<String> _checkEntry(
    String value,
    String label,
    bool checked, {
    bool enabled = true,
  }) {
    return StyledPopupMenuEntry<String>(
      value: value,
      enabled: enabled,
      label: label,
      leading: Icon(
        Icons.check_rounded,
        size: 18,
        color: enabled
            ? checked
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFFD0D0D0)
            : const Color(0xFFBDBDBD),
      ),
    );
  }
}

class _HeaderIconChip extends StatelessWidget {
  const _HeaderIconChip({
    required this.icon,
    required this.isActive,
    required this.theme,
  });

  final IconData icon;
  final bool isActive;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.dividerColor,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
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
        _buildArrowButton(context, Icons.chevron_left_rounded, onPrevious),
        const SizedBox(width: 12),
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
            const SizedBox(height: 2),
            Text(rangeLabel, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(width: 12),
        _buildArrowButton(context, Icons.chevron_right_rounded, onNext),
      ],
    );
  }

  Widget _buildArrowButton(
    BuildContext context,
    IconData iconData,
    VoidCallback onPressed,
  ) {
    final colors = Theme.of(context).colorScheme;
    return StyledButton(
      titleWidget: Icon(iconData, size: 24, color: colors.onPrimaryContainer),
      onPressed: onPressed,
      minWidth: 56,
      minHeight: 44,
      horizontalSpacing: 0,
      padding: EdgeInsets.zero,
      cornerRadius: 10,
      borderWidth: 1.2,
      backgroundColor: colors.primaryContainer,
      borderColor: colors.primary.withValues(alpha: 0.45),
      enableShadow: false,
      enableShrinking: true,
    );
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
    final now = DateTime.now();
    final upcomingCount = entries
        .where((entry) => !_bookingEnded(entry, _dateOnly(now)))
        .length;
    final arrivalsThisWeek = entries.where((entry) {
      final start = entry.startDate;
      if (start == null) return false;
      final date = _dateOnly(start);
      final today = _dateOnly(now);
      final weekAhead = today.add(const Duration(days: 7));
      return !date.isBefore(today) && !date.isAfter(weekAhead);
    }).length;
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
        _ReservationListColumn.guestName => const StyledDataColumn(
            columnHeaderLabel: 'Boeker',
            flex: 2,
            minWidth: 128,
          ),
        _ReservationListColumn.checkIn => const StyledDataColumn(
            columnHeaderLabel: 'Check-in',
            flex: 1,
            minWidth: 96,
          ),
        _ReservationListColumn.checkOut => const StyledDataColumn(
            columnHeaderLabel: 'Check-out',
            flex: 1,
            minWidth: 96,
          ),
        _ReservationListColumn.nights => const StyledDataColumn(
            columnHeaderLabel: 'Nachten',
            flex: 0,
            width: 66,
            alignment: Alignment.centerLeft,
          ),
        _ReservationListColumn.guests => const StyledDataColumn(
            columnHeaderLabel: 'Gasten',
            flex: 0,
            width: 66,
            alignment: Alignment.centerLeft,
          ),
        _ReservationListColumn.babyBed => const StyledDataColumn(
            columnHeaderLabel: 'Baby\'s',
            flex: 0,
            width: 52,
            alignment: Alignment.centerLeft,
          ),
        _ReservationListColumn.status => const StyledDataColumn(
            columnHeaderLabel: 'Status',
            flex: 1,
            minWidth: 78,
          ),
        _ReservationListColumn.booked => const StyledDataColumn(
            columnHeaderLabel: 'Geboekt',
            flex: 2,
            minWidth: 132,
          ),
        _ReservationListColumn.isNew => const StyledDataColumn(
            columnHeaderLabel: 'Nieuw',
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
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            return Wrap(
              spacing: compact ? 8 : 12,
              runSpacing: compact ? 8 : 12,
              children: [
                _MetricTile(
                  label: 'Totaal',
                  value: '${entries.length}',
                  icon: Icons.receipt_long_outlined,
                  compact: compact,
                ),
                _MetricTile(
                  label: 'Komend',
                  value: '$upcomingCount',
                  icon: Icons.upcoming_outlined,
                  compact: compact,
                ),
                _MetricTile(
                  label: 'Aankomst deze week',
                  value: '$arrivalsThisWeek',
                  icon: Icons.login_outlined,
                  compact: compact,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              StyledDataTable(
                variant: StyledTableVariant.card,
                dense: true,
                uppercaseHeaderLabels: false,
                layout: const StyledTableLayout(
                  columnGap: 8,
                  tablePadding: EdgeInsets.fromLTRB(10, 8, 10, 16),
                ),
                itemCount: entries.length,
                columns: safeVisibleColumns
                    .map((column) => _columnFor(column))
                    .toList(),
                rowBuilder: (tableContext, index) {
                  final entry = entries[index];
                  final nights = _stayNights(entry.startDate, entry.endDate);
                  final key = _reservationKey(entry);
                  final isNew = markedAsNew.contains(key);

              Widget textCell(
                String? value, {
                FontWeight? fontWeight,
                TextAlign textAlign = TextAlign.left,
              }) {
                final safeValue = _valueOrDash(value);
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
                        _guestDisplayName(entry),
                        fontWeight: FontWeight.w600,
                      ),
                      _ReservationListColumn.checkIn => textCell(
                        _formatDateTime(dateFormatter, entry.startDate),
                      ),
                      _ReservationListColumn.checkOut => textCell(
                        _formatDateTime(dateFormatter, entry.endDate),
                      ),
                      _ReservationListColumn.nights => textCell(
                        nights?.toString(),
                        textAlign: TextAlign.right,
                      ),
                      _ReservationListColumn.guests => textCell(
                        _guestBreakdown(entry, unknownLabel: ''),
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
                      _ReservationListColumn.status => textCell(entry.status),
                      _ReservationListColumn.booked => textCell(
                        _formatDateTime(dateTimeFormatter, entry.createdAt),
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
                emptyLabel: 'Geen reserveringen gevonden.',
                showTableWhenEmpty: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReservationDetailsDialog extends StatefulWidget {
  const _ReservationDetailsDialog({
    required this.entry,
    required this.dateFormatter,
    required this.dateTimeFormatter,
    this.rateCurrency,
  });

  final Reservation entry;
  final DateFormat dateFormatter;
  final DateFormat dateTimeFormatter;
  final String? rateCurrency;

  @override
  State<_ReservationDetailsDialog> createState() =>
      _ReservationDetailsDialogState();
}

class _ReservationDetailsDialogState extends State<_ReservationDetailsDialog> {
  late final TextEditingController _notesController;
  bool _isSavingNotes = false;
  bool _notesSaved = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.entry.notes?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    final reservationId = widget.entry.reservationId;
    if (reservationId == null || reservationId.isEmpty) return;

    setState(() {
      _isSavingNotes = true;
      _notesSaved = false;
    });

    try {
      await context.read<ReservationsCubit>().updateNotes(
        reservationId,
        _notesController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _isSavingNotes = false;
        _notesSaved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSavingNotes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final dateFormatter = widget.dateFormatter;
    final dateTimeFormatter = widget.dateTimeFormatter;
    final theme = Theme.of(context);
    final prettyRaw = const JsonEncoder.withIndent('  ').convert(entry.raw);
    final rawRevenue = _extractRevenue(entry);
    // Use rateCurrency from Lodgify rate settings as fallback.
    final effectiveCurrency = rawRevenue.currency ?? widget.rateCurrency;
    final revenue = rawRevenue.currency == null && effectiveCurrency != null
        ? _RevenueData(
            currency: effectiveCurrency,
            nightlyRate: rawRevenue.nightlyRate,
            total: rawRevenue.total,
            paid: rawRevenue.paid,
            outstanding: rawRevenue.outstanding,
            net: rawRevenue.net,
            payout: rawRevenue.payout,
            breakdown: rawRevenue.breakdown,
          )
        : rawRevenue;
    final nights = _stayNights(entry.startDate, entry.endDate);
    final hasReservationId =
        entry.reservationId != null && entry.reservationId!.isNotEmpty;

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
                      _guestDisplayName(entry),
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
                      header: 'Boeker',
                      children: [
                        StyledTile(
                          title: 'Naam',
                          value: _guestDisplayName(entry),
                        ),
                        StyledTile(
                          title: 'E-mail',
                          value: _valueOrDash(entry.guestEmail),
                        ),
                        StyledTile(
                          title: 'Telefoon',
                          value: _valueOrDash(entry.guestPhone),
                        ),
                      ],
                    ),
                    StyledSection(
                      header: 'Verblijf',
                      children: [
                        StyledTile(
                          title: 'Check-in',
                          value:
                              _formatDateTime(dateFormatter, entry.startDate) ??
                              '-',
                        ),
                        StyledTile(
                          title: 'Check-out',
                          value:
                              _formatDateTime(dateFormatter, entry.endDate) ??
                              '-',
                        ),
                        StyledTile(
                          title: 'Nachten',
                          value: nights != null ? '$nights' : '-',
                        ),
                        StyledTile(
                          title: 'Status',
                          value: _valueOrDash(entry.status),
                        ),
                        StyledTile(
                          title: 'Bron',
                          trailing: BookingSourceIcon(
                            source: entry.source,
                            size: 24,
                          ),
                        ),
                        if (hasReservationId)
                          StyledTile(
                            title: 'Reservering-ID',
                            value: entry.reservationId!,
                          ),
                      ],
                    ),
                    StyledSection(
                      header: 'Gasten',
                      children: [
                        StyledTile(
                          title: 'Totaal',
                          value: _guestBreakdown(entry),
                        ),
                        StyledTile(
                          title: 'Volwassenen',
                          value: entry.adultCount?.toString() ?? '-',
                        ),
                        StyledTile(
                          title: 'Kinderen',
                          value: entry.childCount?.toString() ?? '-',
                        ),
                        StyledTile(
                          title: 'Baby\'s',
                          value: entry.infantCount?.toString() ?? '-',
                        ),
                      ],
                    ),
                    if (revenue.hasAnyData)
                      StyledSection(
                        header: 'Opbrengsten',
                        children: [
                          if (revenue.total != null)
                            StyledTile(
                              title: 'Bruto',
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
                              title: 'Netto',
                              value: _formatAmount(
                                revenue.net,
                                revenue.currency,
                              ),
                            ),
                          if (revenue.outstanding != null)
                            StyledTile(
                              title: 'Openstaand',
                              value: _formatAmount(
                                revenue.outstanding,
                                revenue.currency,
                              ),
                            ),
                        ],
                      ),
                    StyledSection(
                      header: 'Notities',
                      grouped: false,
                      children: [
                        TextField(
                          controller: _notesController,
                          enabled: hasReservationId && !_isSavingNotes,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: hasReservationId
                                ? 'Voeg een notitie toe...'
                                : 'Geen reservering-ID — opslaan niet mogelijk',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (_notesSaved)
                              Text(
                                'Opgeslagen',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green[700],
                                ),
                              ),
                            const Spacer(),
                            if (_isSavingNotes)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else if (hasReservationId)
                              TextButton.icon(
                                onPressed: _saveNotes,
                                icon: const Icon(Icons.save_outlined, size: 18),
                                label: const Text('Opslaan in Lodgify'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  textStyle: const TextStyle(fontSize: 13),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    StyledSection(
                      header: 'Overig',
                      children: [
                        StyledTile(
                          title: 'Aangemaakt',
                          value:
                              _formatDateTime(
                                dateTimeFormatter,
                                entry.createdAt,
                              ) ??
                              '-',
                        ),
                        StyledTile(
                          title: 'Bijgewerkt',
                          value:
                              _formatDateTime(
                                dateTimeFormatter,
                                entry.updatedAt,
                              ) ??
                              '-',
                        ),
                      ],
                    ),
                    StyledSection(
                      header: 'Volledige payload',
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

class _CircularCloseButton extends StatelessWidget {
  const _CircularCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sluiten',
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Tooltip(
        message: label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueData {
  const _RevenueData({
    required this.currency,
    required this.nightlyRate,
    required this.total,
    required this.paid,
    required this.outstanding,
    required this.net,
    required this.payout,
    required this.breakdown,
  });

  final String? currency;
  final num? nightlyRate;
  final num? total;
  final num? paid;
  final num? outstanding;
  final num? net;
  final num? payout;
  final List<_RevenueBreakdownItem> breakdown;

  bool get hasAnyData {
    return nightlyRate != null ||
        total != null ||
        paid != null ||
        outstanding != null ||
        net != null ||
        payout != null ||
        breakdown.isNotEmpty;
  }
}

class _RevenueBreakdownItem {
  const _RevenueBreakdownItem({required this.label, required this.amount});

  final String label;
  final num amount;
}

class _MonthSummary {
  const _MonthSummary({
    required this.bookingCount,
    required this.arrivals,
    required this.departures,
    required this.occupiedNights,
  });

  final int bookingCount;
  final int arrivals;
  final int departures;
  final int occupiedNights;
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

int? _stayNights(DateTime? start, DateTime? end) {
  if (start == null || end == null) return null;
  final nights = _dateOnly(end).difference(_dateOnly(start)).inDays;
  return nights <= 0 ? 1 : nights;
}

String _guestDisplayName(Reservation entry) {
  final name = entry.guestName?.trim();
  if (name == null || name.isEmpty) return 'Onbekende boeker';
  return name;
}

String? _formatDateTime(DateFormat formatter, DateTime? date) {
  if (date == null) return null;
  return formatter.format(date.toLocal());
}

_RevenueData _extractRevenue(Reservation entry) {
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

  final nightlyRate = _normalizeMoney(
    _readFirstNumFromMap(raw, const [
      ['nightlyRate'],
      ['nightly_rate'],
      ['ratePerNight'],
      ['rate_per_night'],
      ['pricing', 'nightlyRate'],
      ['pricing', 'nightly_rate'],
      ['financials', 'nightlyRate'],
      ['financials', 'nightly_rate'],
    ]),
  );

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

  final breakdown = <_RevenueBreakdownItem>[];
  _addBreakdownItem(
    breakdown,
    'Huur / nachttarief',
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
  _addBreakdownItem(
    breakdown,
    'Schoonmaakkosten',
    _readFirstNumFromMap(raw, const [
          ['cleaningFee'],
          ['cleaning_fee'],
          ['fees', 'cleaning'],
          ['pricing', 'cleaningFee'],
          ['pricing', 'cleaning_fee'],
          ['financials', 'cleaning'],
        ]) ??
        _feeFromPriceTypes(raw, (label) {
          final l = label.toLowerCase();
          return l.contains('clean') || l.contains('schoon');
        }),
  );
  _addBreakdownItem(
    breakdown,
    'Linnen / bedlinnen',
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
        }),
  );
  _addBreakdownItem(
    breakdown,
    'Servicekosten',
    _readFirstNumFromMap(raw, const [
      ['serviceFee'],
      ['service_fee'],
      ['fees', 'service'],
      ['pricing', 'serviceFee'],
      ['pricing', 'service_fee'],
      ['financials', 'service'],
    ]),
  );
  _addBreakdownItem(
    breakdown,
    'Belasting / btw',
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
  _addBreakdownItem(
    breakdown,
    'Commissie / kanaalkosten',
    _readFirstNumFromMap(raw, const [
      ['commission'],
      ['commissionFee'],
      ['commission_fee'],
      ['channelFee'],
      ['channel_fee'],
      ['otaFee'],
      ['ota_fee'],
      ['fees', 'commission'],
      ['financials', 'commission'],
    ]),
  );
  _addBreakdownItem(
    breakdown,
    'Kortingen',
    _readFirstNumFromMap(raw, const [
      ['discount'],
      ['discountAmount'],
      ['discount_amount'],
      ['pricing', 'discount'],
      ['financials', 'discount'],
    ]),
  );
  _addBreakdownItem(
    breakdown,
    'Borg',
    _readFirstNumFromMap(raw, const [
      ['deposit'],
      ['securityDeposit'],
      ['security_deposit'],
      ['pricing', 'deposit'],
      ['financials', 'deposit'],
    ]),
  );
  _addBreakdownItem(
    breakdown,
    'Extra kosten',
    _readFirstNumFromMap(raw, const [
      ['extras'],
      ['extraFees'],
      ['extra_fees'],
      ['fees', 'extras'],
      ['pricing', 'extras'],
      ['financials', 'extras'],
    ]),
  );

  return _RevenueData(
    currency: currency,
    nightlyRate: nightlyRate,
    total: total,
    paid: paid,
    outstanding: outstanding,
    net: net,
    payout: payout,
    breakdown: breakdown,
  );
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

void _addBreakdownItem(
  List<_RevenueBreakdownItem> items,
  String label,
  num? amount,
) {
  final normalized = _normalizeMoney(amount);
  if (normalized == null) return;
  items.add(_RevenueBreakdownItem(label: label, amount: normalized));
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

num? _parseAmount(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final cleaned = trimmed.replaceAll(RegExp(r'[^0-9,.\-]'), '');
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

String _reservationKey(Reservation entry) {
  if (entry.reservationId != null && entry.reservationId!.isNotEmpty) {
    return entry.reservationId!;
  }
  return '${entry.guestName ?? ''}_${entry.startDate?.toIso8601String() ?? ''}';
}

String _normalizeLanguageCode(String? languageCode) {
  final normalized = languageCode?.trim().toLowerCase() ?? '';
  if (normalized.startsWith('nl')) return 'nl';
  return 'en';
}

String _normalizePdfOrientation(String? orientation) {
  final normalized = orientation?.trim().toLowerCase() ?? '';
  if (normalized == _ExportPdfOrientation.landscape) {
    return _ExportPdfOrientation.landscape;
  }
  return _ExportPdfOrientation.portrait;
}

Future<void> _ensureLanguageMessagesInitialized(String? languageCode) async {
  await l10n_messages.initializeMessages(_normalizeLanguageCode(languageCode));
}

String _localizedForLanguage(
  String? languageCode,
  String Function(S l10n) selector,
) {
  final normalized = _normalizeLanguageCode(languageCode);
  return Intl.withLocale(normalized, () => selector(S.current));
}

String _formatBabyExportValue(
  int? infantCount, {
  required String languageCode,
}) {
  if (infantCount == null) return '-';
  if (infantCount > 0) return infantCount.toString();
  return _localizedForLanguage(languageCode, (l10n) => l10n.no);
}

// ---------------------------------------------------------------------------
// Export Settings Dialog
// ---------------------------------------------------------------------------

class _ExportSettingsResult {
  const _ExportSettingsResult({
    required this.exportLanguageCode,
    required this.enabledColumns,
    required this.exportPdfOrientation,
  });

  final String exportLanguageCode;
  final List<String> enabledColumns;
  final String exportPdfOrientation;
}

Future<_ExportSettingsResult?> _showExportSettingsDialog(
  BuildContext context, {
  required String currentLanguageCode,
  required List<String> currentColumns,
  required String currentPdfOrientation,
}) async {
  return showStyledModal<_ExportSettingsResult>(
    context,
    title: context.s.exportSettingsTitle,
    isDismissible: true,
    showLeading: true,
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
      exportLanguageCode: currentLanguageCode,
      enabledColumns: currentColumns,
      exportPdfOrientation: currentPdfOrientation,
    ),
    dataBuilder: (dialogContext, onDataChanged) {
      return _ExportSettingsDialogContent(
        initialLanguageCode: currentLanguageCode,
        initialColumns: currentColumns,
        initialPdfOrientation: currentPdfOrientation,
        onDataChanged: onDataChanged,
      );
    },
  );
}

class _ExportSettingsDialogContent extends StatefulWidget {
  const _ExportSettingsDialogContent({
    required this.initialLanguageCode,
    required this.initialColumns,
    required this.initialPdfOrientation,
    required this.onDataChanged,
  });

  final String initialLanguageCode;
  final List<String> initialColumns;
  final String initialPdfOrientation;
  final void Function(_ExportSettingsResult?) onDataChanged;

  @override
  State<_ExportSettingsDialogContent> createState() =>
      _ExportSettingsDialogContentState();
}

class _ExportSettingsDialogContentState
    extends State<_ExportSettingsDialogContent> {
  late String _languageCode;
  late String _pdfOrientation;
  late List<String> _orderedColumns;
  late Set<String> _toggledColumns;

  @override
  void initState() {
    super.initState();
    _languageCode = _normalizeLanguageCode(widget.initialLanguageCode);
    _pdfOrientation = _normalizePdfOrientation(widget.initialPdfOrientation);
    unawaited(_ensureLanguageMessagesInitialized(_languageCode));
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
        exportLanguageCode: _languageCode,
        enabledColumns:
            _orderedColumns.where(_toggledColumns.contains).toList(),
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
          grouped: false,
          children: [
            StyledSelectionTile<String>.dropdown(
              title: context.s.exportLanguageTitle,
              modalTitle: context.s.exportLanguageTitle,
              currentValue: _languageCode,
              options: const ['en', 'nl'],
              optionLabelBuilder: (value) => switch (value) {
                'nl' => 'Nederlands',
                _ => 'English',
              },
              dropdownFieldAutoSize: true,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _languageCode = value);
                unawaited(_ensureLanguageMessagesInitialized(value));
                _notifyDataChanged();
              },
            ),
            StyledSelectionTile<String>.dropdown(
              title: context.s.exportPdfOrientationTitle,
              modalTitle: context.s.exportPdfOrientationTitle,
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
              dropdownFieldAutoSize: true,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _pdfOrientation = value);
                _notifyDataChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        StyledReorderableSection(
          header: context.s.exportColumnsTitle,
          grouped: false,
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
                _localizedForLanguage(
                  _languageCode,
                  (l10n) => _ExportColumn.label(key, l10n: l10n),
                ),
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

String _valueOrDash(String? value) {
  if (value == null) return '-';
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '-';
  return trimmed;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
