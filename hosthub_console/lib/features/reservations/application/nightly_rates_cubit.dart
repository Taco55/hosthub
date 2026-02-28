import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';

enum NightlyRatesStatus { initial, loading, loaded }

class NightlyRatesState extends Equatable {
  const NightlyRatesState({
    this.status = NightlyRatesStatus.initial,
    this.rates = const {},
    this.rateCurrency,
    this.loadedStart,
    this.loadedEnd,
    this.propertyId,
  });

  final NightlyRatesStatus status;

  /// Accumulated nightly rates keyed by date (midnight).
  final Map<DateTime, num> rates;

  /// Currency code from the channel manager (e.g. "NOK").
  final String? rateCurrency;

  /// Earliest date for which rates have been loaded.
  final DateTime? loadedStart;

  /// Latest date for which rates have been loaded.
  final DateTime? loadedEnd;

  /// Property these rates belong to.
  final String? propertyId;

  NightlyRatesState copyWith({
    NightlyRatesStatus? status,
    Map<DateTime, num>? rates,
    String? rateCurrency,
    DateTime? loadedStart,
    DateTime? loadedEnd,
    String? propertyId,
  }) {
    return NightlyRatesState(
      status: status ?? this.status,
      rates: rates ?? this.rates,
      rateCurrency: rateCurrency ?? this.rateCurrency,
      loadedStart: loadedStart ?? this.loadedStart,
      loadedEnd: loadedEnd ?? this.loadedEnd,
      propertyId: propertyId ?? this.propertyId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rates,
    rateCurrency,
    loadedStart,
    loadedEnd,
    propertyId,
  ];
}

class NightlyRatesCubit extends Cubit<NightlyRatesState> {
  NightlyRatesCubit({
    required ChannelManagerRepository channelManagerRepository,
  })  : _repo = channelManagerRepository,
        super(const NightlyRatesState());

  final ChannelManagerRepository _repo;

  /// Load rates for a window around [focusedMonth] (±2 months).
  ///
  /// Skips the fetch if the requested window is already covered by
  /// [loadedStart]..[loadedEnd], unless [force] is true.
  Future<void> loadRates({
    required String propertyId,
    required DateTime focusedMonth,
    bool force = false,
  }) async {
    final windowStart = DateTime(focusedMonth.year, focusedMonth.month - 2);
    final windowEnd = DateTime(focusedMonth.year, focusedMonth.month + 3, 0);

    final isNewProperty = state.propertyId != propertyId;

    // Skip if the window is already covered.
    if (!force &&
        !isNewProperty &&
        state.loadedStart != null &&
        state.loadedEnd != null &&
        !windowStart.isBefore(state.loadedStart!) &&
        !windowEnd.isAfter(state.loadedEnd!)) {
      return;
    }

    if (!isClosed) {
      emit(state.copyWith(
        status: NightlyRatesStatus.loading,
        propertyId: propertyId,
      ));
    }

    try {
      final result = await _repo.fetchNightlyRates(
        propertyId,
        start: windowStart,
        end: windowEnd,
      );

      if (isClosed) return;

      final mergedRates = isNewProperty
          ? Map<DateTime, num>.of(result.rates)
          : {...state.rates, ...result.rates};

      final newStart = (state.loadedStart != null && !isNewProperty)
          ? (windowStart.isBefore(state.loadedStart!)
              ? windowStart
              : state.loadedStart!)
          : windowStart;
      final newEnd = (state.loadedEnd != null && !isNewProperty)
          ? (windowEnd.isAfter(state.loadedEnd!)
              ? windowEnd
              : state.loadedEnd!)
          : windowEnd;

      emit(NightlyRatesState(
        status: NightlyRatesStatus.loaded,
        rates: mergedRates,
        rateCurrency: result.currency ?? state.rateCurrency,
        loadedStart: newStart,
        loadedEnd: newEnd,
        propertyId: propertyId,
      ));
    } catch (_) {
      // Rates are non-critical — silently keep whatever we already have.
      if (!isClosed) {
        emit(state.copyWith(status: NightlyRatesStatus.loaded));
      }
    }
  }

  void reset() {
    if (!isClosed) {
      emit(const NightlyRatesState());
    }
  }
}
