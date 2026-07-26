import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/portfolio/domain/property_ref.dart';

enum ReservationsStatus { initial, loading, loaded, error }

class ReservationsState extends Equatable {
  const ReservationsState({
    required this.status,
    required this.entries,
    required this.rangeStart,
    required this.rangeEnd,
    this.properties = const [],
    this.stalePropertyIds = const {},
    this.lastUpdated,
    this.error,
  });

  const ReservationsState.initial()
    : status = ReservationsStatus.initial,
      entries = const [],
      rangeStart = null,
      rangeEnd = null,
      properties = const [],
      stalePropertyIds = const {},
      lastUpdated = null,
      error = null;

  final ReservationsStatus status;

  /// Every booking loaded, across [properties]. Each one carries its own
  /// `propertyId`; narrowing to a selection is `bookingsForSelection`'s job, not
  /// this state's.
  final List<Reservation> entries;

  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  /// The properties [entries] covers — and therefore what a rate divides by.
  ///
  /// Occupancy scales with the number of properties in view, so the set that was
  /// loaded and the set that is counted have to be the same one. Keeping it on
  /// the state makes that structural instead of a convention.
  final List<PropertyRef> properties;

  /// Properties whose fetch failed.
  ///
  /// Their bookings are missing from [entries] while the rest of the portfolio
  /// still shows: a failed sync on one property must not blank the view (§9).
  /// The screen marks these stale rather than reporting they have no bookings.
  final Set<int> stalePropertyIds;

  final DateTime? lastUpdated;
  final DomainError? error;

  /// The single property in view, or null for a portfolio of several.
  ///
  /// Only loader-adjacent concerns use this — nightly rates and the currency
  /// write-back are per property and have no answer for a mixed portfolio.
  PropertyRef? get singleProperty =>
      properties.length == 1 ? properties.single : null;

  ReservationsState copyWith({
    ReservationsStatus? status,
    List<Reservation>? entries,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    List<PropertyRef>? properties,
    Set<int>? stalePropertyIds,
    DateTime? lastUpdated,
    DomainError? error,
  }) {
    return ReservationsState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      properties: properties ?? this.properties,
      stalePropertyIds: stalePropertyIds ?? this.stalePropertyIds,
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
    properties,
    stalePropertyIds,
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
        'properties=${properties.map((p) => p.propertyId).toList()}, '
        'stale=${stalePropertyIds.toList()}, '
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

  /// Load the bookings of every property in [properties].
  ///
  /// One request per property, because sync is per property (§9): each one
  /// carries its own channel id and each one can fail on its own. A property
  /// that fails lands in [ReservationsState.stalePropertyIds] and the others
  /// still load — the alternative, one throw blanking the portfolio, hides three
  /// properties because of one.
  ///
  /// The whole load only reports an error when **every** property failed; that
  /// is the case where there is genuinely nothing to show.
  Future<void> loadReservations({
    required List<PropertyRef> properties,
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final rangeStart = start ?? DateTime(now.year - 1, now.month, 1);
    final rangeEnd =
        end ??
        DateTime(now.year, now.month + 12, 0).add(const Duration(days: 14));

    if (state.status == ReservationsStatus.loading &&
        listEquals(state.properties, properties) &&
        state.rangeStart == rangeStart &&
        state.rangeEnd == rangeEnd) {
      return;
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          status: ReservationsStatus.loading,
          properties: properties,
          stalePropertyIds: const {},
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          error: null,
        ),
      );
    }

    if (properties.isEmpty) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ReservationsStatus.loaded,
            entries: const [],
            lastUpdated: DateTime.now(),
            error: null,
          ),
        );
      }
      return;
    }

    final entries = <Reservation>[];
    final stale = <int>{};
    DomainError? firstError;

    final results = await Future.wait(
      properties.map((property) async {
        try {
          return (
            property: property,
            bookings: await _channelManagerRepository.fetchReservations(
              propertyId: property.propertyId,
              channelPropertyId: property.channelPropertyId,
              start: rangeStart,
              end: rangeEnd,
            ),
            error: null,
          );
        } catch (error, stack) {
          return (
            property: property,
            bookings: const <Reservation>[],
            error: DomainError.from(error, stack: stack),
          );
        }
      }),
    );

    // Ordered by the property list rather than by whichever request answered
    // first, so a reload cannot reshuffle the table.
    for (final result in results) {
      final error = result.error;
      if (error != null) {
        stale.add(result.property.propertyId);
        firstError ??= error;
        continue;
      }
      entries.addAll(result.bookings);
    }

    if (isClosed) return;

    final everyPropertyFailed = stale.length == properties.length;
    emit(
      state.copyWith(
        status: everyPropertyFailed
            ? ReservationsStatus.error
            : ReservationsStatus.loaded,
        entries: entries,
        stalePropertyIds: stale,
        lastUpdated: DateTime.now(),
        error: everyPropertyFailed ? firstError : null,
      ),
    );
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
