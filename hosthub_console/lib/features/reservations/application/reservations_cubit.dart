import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';

enum ReservationsStatus { initial, loading, loaded, error }

class ReservationsState extends Equatable {
  const ReservationsState({
    required this.status,
    required this.entries,
    required this.rangeStart,
    required this.rangeEnd,
    this.propertyId,
    this.channelPropertyId,
    this.lastUpdated,
    this.error,
  });

  const ReservationsState.initial()
    : status = ReservationsStatus.initial,
      entries = const [],
      rangeStart = null,
      rangeEnd = null,
      propertyId = null,
      channelPropertyId = null,
      lastUpdated = null,
      error = null;

  final ReservationsStatus status;
  final List<Reservation> entries;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  /// The console's own property id these entries were loaded for.
  final int? propertyId;

  /// The channel manager's id the request was addressed to. Only the loader
  /// cares about it; everything downstream filters on [propertyId].
  final String? channelPropertyId;

  final DateTime? lastUpdated;
  final DomainError? error;

  ReservationsState copyWith({
    ReservationsStatus? status,
    List<Reservation>? entries,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    int? propertyId,
    String? channelPropertyId,
    DateTime? lastUpdated,
    DomainError? error,
  }) {
    return ReservationsState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      propertyId: propertyId ?? this.propertyId,
      channelPropertyId: channelPropertyId ?? this.channelPropertyId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    rangeStart,
    rangeEnd,
    propertyId,
    channelPropertyId,
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

    return 'ReservationsState('
        'status=$status, '
        'entries=${entries.length}, '
        'withReservationId=$withReservationId, '
        'statusCounts={$statusSummary}, '
        'range=${_dateOnly(rangeStart) ?? '-'}..${_dateOnly(rangeEnd) ?? '-'}, '
        'propertyId=${propertyId ?? '-'}, '
        'channelPropertyId=${channelPropertyId ?? '-'}, '
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

class ReservationsCubit extends Cubit<ReservationsState> {
  ReservationsCubit({
    required ChannelManagerRepository channelManagerRepository,
  }) : _channelManagerRepository = channelManagerRepository,
       super(const ReservationsState.initial());

  final ChannelManagerRepository _channelManagerRepository;

  Future<void> loadReservations({
    required int propertyId,
    required String channelPropertyId,
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final rangeStart = start ?? DateTime(now.year - 1, now.month, 1);
    final rangeEnd =
        end ??
        DateTime(now.year, now.month + 12, 0).add(const Duration(days: 14));

    if (state.status == ReservationsStatus.loading &&
        state.propertyId == propertyId &&
        state.rangeStart == rangeStart &&
        state.rangeEnd == rangeEnd) {
      return;
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          status: ReservationsStatus.loading,
          propertyId: propertyId,
          channelPropertyId: channelPropertyId,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          error: null,
        ),
      );
    }

    try {
      final entries = await _channelManagerRepository.fetchReservations(
        propertyId: propertyId,
        channelPropertyId: channelPropertyId,
        start: rangeStart,
        end: rangeEnd,
      );

      if (!isClosed) {
        emit(
          state.copyWith(
            status: ReservationsStatus.loaded,
            entries: entries,
            lastUpdated: DateTime.now(),
            error: null,
          ),
        );
      }
    } catch (error, stack) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ReservationsStatus.error,
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
