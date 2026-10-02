import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/reservations/application/nightly_rates_cubit.dart';

/// Rates are non-critical: a failed fetch keeps what is there, and the report
/// hears of it once.
void main() {
  tearDown(DomainErrors.resetForTesting);

  test(
    'a failed fetch keeps the calendar loaded and is reported once',
    () async {
      final reported = <DomainError>[];
      DomainError.onUnexpectedError = reported.add;
      final cubit = NightlyRatesCubit(
        channelManagerRepository: _FailingRates(StateError('lodgify down')),
      );
      addTearDown(cubit.close);

      await cubit.loadRates(propertyId: 'L-1', focusedMonth: DateTime(2027, 7));

      expect(cubit.state.status, NightlyRatesStatus.loaded);
      expect(cubit.state.rates, isEmpty);
      expect(reported, hasLength(1));
    },
  );

  test(
    'a failure the repository already converted is not reported again',
    () async {
      final reported = <DomainError>[];
      DomainError.onUnexpectedError = reported.add;
      final cubit = NightlyRatesCubit(
        channelManagerRepository: _FailingRates(
          DomainErrorCode.serverError.err(message: 'converted upstream'),
        ),
      );
      addTearDown(cubit.close);

      await cubit.loadRates(propertyId: 'L-1', focusedMonth: DateTime(2027, 7));

      expect(cubit.state.status, NightlyRatesStatus.loaded);
      expect(reported, isEmpty);
    },
  );
}

class _FailingRates implements ChannelManagerRepository {
  _FailingRates(this.failure);

  final Object failure;

  @override
  Future<({Map<DateTime, num> rates, String? currency})> fetchNightlyRates(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  }) async => throw failure;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
