import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/portfolio/domain/property_ref.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';

/// Loading a portfolio: one request per property, merged into one tagged set.
///
/// The partial-failure behaviour is §9 of the multi-property handoff — a failed
/// sync on one property must not blank the portfolio view.
class _FakeChannelManager implements ChannelManagerRepository {
  _FakeChannelManager({
    this.bookingsPerProperty = 1,
    this.failingChannelIds = const {},
  });

  /// How many bookings each property answers with.
  final int bookingsPerProperty;

  /// Channel ids whose fetch throws, standing in for one property's sync being
  /// down while the others answer. Mutable so a test can bring it back up.
  Set<String> failingChannelIds;

  final List<String> requestedChannelIds = [];

  @override
  Future<List<Reservation>> fetchReservations({
    required int propertyId,
    required String channelPropertyId,
    DateTime? start,
    DateTime? end,
  }) async {
    requestedChannelIds.add(channelPropertyId);
    if (failingChannelIds.contains(channelPropertyId)) {
      throw Exception('lodgify down for $channelPropertyId');
    }
    return [
      for (var index = 0; index < bookingsPerProperty; index++)
        Reservation(
          propertyId: propertyId,
          reservationId: '$channelPropertyId-$index',
          startDate: DateTime(2027, 7, 1 + index),
          endDate: DateTime(2027, 7, 3 + index),
        ),
    ];
  }

  @override
  Future<List<ChannelProperty>> fetchProperties() async =>
      throw UnimplementedError();

  @override
  Future<ChannelPropertyDetails> fetchPropertyDetails(
    String propertyId,
  ) async => throw UnimplementedError();

  @override
  Future<void> updateReservationNotes(
    String reservationId,
    String notes,
  ) async => throw UnimplementedError();

  @override
  Future<({Map<DateTime, num> rates, String? currency})> fetchNightlyRates(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  }) async => throw UnimplementedError();

  @override
  Future<void> testConnection() async => throw UnimplementedError();
}

void main() {
  const trysil = PropertyRef(propertyId: 1, channelPropertyId: 'L-1');
  const hemsedal = PropertyRef(propertyId: 2, channelPropertyId: 'L-2');
  const geilo = PropertyRef(propertyId: 3, channelPropertyId: 'L-3');

  final range = (start: DateTime(2027, 7, 1), end: DateTime(2027, 8, 1));

  group('loading several properties', () {
    test('asks the channel once per property and merges the answers', () async {
      final repository = _FakeChannelManager(bookingsPerProperty: 2);
      final cubit = ReservationsCubit(channelManagerRepository: repository);

      await cubit.loadReservations(
        properties: const [trysil, hemsedal, geilo],
        start: range.start,
        end: range.end,
      );

      expect(repository.requestedChannelIds, ['L-1', 'L-2', 'L-3']);
      expect(cubit.state.status, ReservationsStatus.loaded);
      expect(cubit.state.entries, hasLength(6));
      expect(cubit.state.stalePropertyIds, isEmpty);
      expect(cubit.state.error, isNull);

      await cubit.close();
    });

    test('every booking carries the property it was loaded for', () async {
      final cubit = ReservationsCubit(
        channelManagerRepository: _FakeChannelManager(),
      );

      await cubit.loadReservations(properties: const [trysil, hemsedal]);

      expect(cubit.state.entries.map((booking) => booking.propertyId), [1, 2]);

      await cubit.close();
    });

    test('the state says which properties the entries cover', () async {
      final cubit = ReservationsCubit(
        channelManagerRepository: _FakeChannelManager(),
      );

      await cubit.loadReservations(properties: const [trysil, hemsedal]);

      // The occupancy divisor is read from this, so it has to be the set that
      // was actually loaded.
      expect(cubit.state.properties, [trysil, hemsedal]);
      expect(cubit.state.singleProperty, isNull);

      await cubit.close();
    });

    test('one property in view is addressable for its rates', () async {
      final cubit = ReservationsCubit(
        channelManagerRepository: _FakeChannelManager(),
      );

      await cubit.loadReservations(properties: const [trysil]);

      expect(cubit.state.singleProperty, trysil);

      await cubit.close();
    });

    test(
      'an account with no properties loads an empty set, not an error',
      () async {
        final cubit = ReservationsCubit(
          channelManagerRepository: _FakeChannelManager(),
        );

        await cubit.loadReservations(properties: const []);

        expect(cubit.state.status, ReservationsStatus.loaded);
        expect(cubit.state.entries, isEmpty);
        expect(cubit.state.error, isNull);

        await cubit.close();
      },
    );
  });

  group('a failed sync on one property', () {
    test('keeps the others and marks that one stale', () async {
      final repository = _FakeChannelManager(failingChannelIds: const {'L-2'});
      final cubit = ReservationsCubit(channelManagerRepository: repository);

      await cubit.loadReservations(properties: const [trysil, hemsedal, geilo]);

      // §9: three properties must not go dark because one channel is down.
      expect(cubit.state.status, ReservationsStatus.loaded);
      expect(cubit.state.entries.map((booking) => booking.propertyId), [1, 3]);
      expect(cubit.state.stalePropertyIds, {2});
      // Not an error state: there is a portfolio to show.
      expect(cubit.state.error, isNull);

      await cubit.close();
    });

    test('every property failing is an error, with nothing to show', () async {
      final repository = _FakeChannelManager(
        failingChannelIds: const {'L-1', 'L-2'},
      );
      final cubit = ReservationsCubit(channelManagerRepository: repository);

      await cubit.loadReservations(properties: const [trysil, hemsedal]);

      expect(cubit.state.status, ReservationsStatus.error);
      expect(cubit.state.entries, isEmpty);
      expect(cubit.state.stalePropertyIds, {1, 2});
      expect(cubit.state.error, isNotNull);

      await cubit.close();
    });

    test('a reload that succeeds clears the stale marks', () async {
      final repository = _FakeChannelManager(failingChannelIds: {'L-2'});
      final cubit = ReservationsCubit(channelManagerRepository: repository);

      await cubit.loadReservations(properties: const [trysil, hemsedal]);
      expect(cubit.state.stalePropertyIds, {2});

      repository.failingChannelIds = {};
      await cubit.loadReservations(
        properties: const [trysil, hemsedal],
        // A different range, so the request is not deduplicated.
        start: range.start,
        end: range.end,
      );

      expect(cubit.state.stalePropertyIds, isEmpty);
      expect(cubit.state.entries, hasLength(2));

      await cubit.close();
    });
  });
}
