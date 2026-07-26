import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/dto/lodgify_calendar_dto.dart';

/// The one place the channel manager's property id and the console's own id
/// meet. A booking that reaches the domain without the console's id cannot be
/// filtered or costed, so this pins the tagging rather than the parsing (which
/// [lodgify_property_details_dto_test.dart] covers).
void main() {
  final payload = <String, dynamic>{
    'id': 'B-9',
    'arrival': '2027-02-07',
    'departure': '2027-02-12',
    'status': 'Booked',
    'source': 'airbnb',
    // Lodgify names its own property, and only its own.
    'property_id': 4321,
  };

  test('the caller\'s property id lands on the booking', () {
    final booking = LodgifyCalendarDto.fromMap(payload).toDomain(propertyId: 7);

    expect(booking.propertyId, 7);
  });

  test('Lodgify\'s own property id does not become the booking\'s', () {
    final booking = LodgifyCalendarDto.fromMap(payload).toDomain(propertyId: 7);

    // 4321 is Lodgify's id: it stays in the raw payload and is never the id the
    // aggregates filter on.
    expect(booking.propertyId, isNot(4321));
    expect(booking.raw['property_id'], 4321);
  });

  test('two properties fetched in one pass keep their own tags', () {
    final first = LodgifyCalendarDto.fromMap(payload).toDomain(propertyId: 1);
    final second = LodgifyCalendarDto.fromMap(payload).toDomain(propertyId: 2);

    expect(first.propertyId, 1);
    expect(second.propertyId, 2);
  });
}
