import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';

enum CalendarStatus { initial, loading, loaded, error }

class CalendarState extends Equatable {
  const CalendarState({
    required this.status,
    required this.entries,
    required this.rangeStart,
    required this.rangeEnd,
    this.nightlyRates = const {},
    this.rateCurrency,
    this.propertyId,
    this.lastUpdated,
    this.error,
  });

  const CalendarState.initial()
    : status = CalendarStatus.initial,
      entries = const [],
      nightlyRates = const {},
      rateCurrency = null,
      rangeStart = null,
      rangeEnd = null,
      propertyId = null,
      lastUpdated = null,
      error = null;

  final CalendarStatus status;
  final List<Reservation> entries;

  /// Nightly rates keyed by date (midnight), used for showing prices on
  /// non-booked days in the timeline calendar.
  final Map<DateTime, num> nightlyRates;

  /// Currency code from the channel manager's rate settings (e.g. "NOK").
  final String? rateCurrency;

  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final String? propertyId;
  final DateTime? lastUpdated;
  final DomainError? error;

  CalendarState copyWith({
    CalendarStatus? status,
    List<Reservation>? entries,
    Map<DateTime, num>? nightlyRates,
    String? rateCurrency,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    String? propertyId,
    DateTime? lastUpdated,
    DomainError? error,
  }) {
    return CalendarState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      nightlyRates: nightlyRates ?? this.nightlyRates,
      rateCurrency: rateCurrency ?? this.rateCurrency,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      propertyId: propertyId ?? this.propertyId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    nightlyRates,
    rateCurrency,
    rangeStart,
    rangeEnd,
    propertyId,
    lastUpdated,
    error,
  ];

  @override
  String toString() {
    final withReservationId = entries
        .where((entry) => entry.reservationId?.trim().isNotEmpty ?? false)
        .length;

    final statusCounts = <String, int>{};
    for (final entry in entries) {
      final key = (entry.status?.trim().isNotEmpty ?? false)
          ? entry.status!.trim().toLowerCase()
          : '(empty)';
      statusCounts.update(key, (value) => value + 1, ifAbsent: () => 1);
    }
    final statusSummary = statusCounts.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(', ');

    final sample = entries
        .take(3)
        .map((entry) {
          final reservation = entry.reservationId?.trim();
          final reservationText = reservation == null || reservation.isEmpty
              ? '-'
              : reservation;
          final date =
              _dateOnly(entry.startDate) ?? _dateOnly(entry.endDate) ?? '-';
          final entryStatus = entry.status?.trim();
          final statusText = entryStatus == null || entryStatus.isEmpty
              ? '-'
              : entryStatus;
          return '$reservationText@$date:$statusText';
        })
        .join(' | ');

    return 'CalendarState('
        'status=$status, '
        'entries=${entries.length}, '
        'withReservationId=$withReservationId, '
        'statusCounts={$statusSummary}, '
        'range=${_dateOnly(rangeStart) ?? '-'}..${_dateOnly(rangeEnd) ?? '-'}, '
        'propertyId=${propertyId ?? '-'}, '
        'lastUpdated=${lastUpdated?.toIso8601String() ?? '-'}, '
        'hasError=${error != null}'
        '${sample.isNotEmpty ? ', sample=[$sample]' : ''})';
  }
}

String? _dateOnly(DateTime? value) {
  if (value == null) return null;
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({required ChannelManagerRepository channelManagerRepository})
    : _channelManagerRepository = channelManagerRepository,
      super(const CalendarState.initial());

  final ChannelManagerRepository _channelManagerRepository;

  Future<void> loadCalendar({
    required String propertyId,
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final rangeStart =
        start ?? DateTime(now.year - 1, now.month, 1);
    final rangeEnd =
        end ??
        DateTime(now.year, now.month + 12, 0).add(const Duration(days: 14));

    if (state.status == CalendarStatus.loading &&
        state.propertyId == propertyId &&
        state.rangeStart == rangeStart &&
        state.rangeEnd == rangeEnd) {
      return;
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          status: CalendarStatus.loading,
          propertyId: propertyId,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          error: null,
        ),
      );
    }

    try {
      // Fetch reservations and nightly rates in parallel.
      final reservationsFuture = _channelManagerRepository.fetchReservations(
        propertyId,
        start: rangeStart,
        end: rangeEnd,
      );
      final ratesFuture = _channelManagerRepository
          .fetchNightlyRates(propertyId, start: rangeStart, end: rangeEnd)
          .catchError(
            (_) => (rates: <DateTime, num>{}, currency: null as String?),
          );

      final results = await Future.wait([reservationsFuture, ratesFuture]);
      final entries = results[0] as List<Reservation>;
      final ratesResult =
          results[1] as ({Map<DateTime, num> rates, String? currency});

      if (!isClosed) {
        emit(
          state.copyWith(
            status: CalendarStatus.loaded,
            entries: entries,
            nightlyRates: ratesResult.rates,
            rateCurrency: ratesResult.currency,
            lastUpdated: DateTime.now(),
            error: null,
          ),
        );
      }
    } catch (error, stack) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CalendarStatus.error,
            entries: const [],
            error: DomainError.from(error, stack: stack),
          ),
        );
      }
    }
  }

  Future<void> updateNotes(String reservationId, String notes) async {
    try {
      await _channelManagerRepository.updateReservationNotes(
        reservationId,
        notes,
      );
      if (isClosed) return;

      // Update the local entry so the UI reflects the change immediately.
      final updatedEntries = state.entries.map((e) {
        if (e.reservationId == reservationId) {
          return e.copyWith(notes: notes);
        }
        return e;
      }).toList();

      emit(state.copyWith(entries: updatedEntries));
    } catch (error, stack) {
      if (!isClosed) {
        emit(state.copyWith(error: DomainError.from(error, stack: stack)));
      }
    }
  }

  void clearError() {
    if (state.error == null) return;
    if (!isClosed) {
      emit(state.copyWith(error: null));
    }
  }
}
