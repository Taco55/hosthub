import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/dto/lodgify_property_details_dto.dart';

/// The mapping the record page depends on: a Lodgify property payload becoming
/// the fields the console stores. A key this DTO misses is a card that stays
/// empty on the page, so the shapes Lodgify actually serves are pinned here.
void main() {
  test('maps a snake_case Lodgify property onto the record fields', () {
    final details = LodgifyPropertyDetailsDto.fromMap({
      'id': 706211,
      'name': 'Comfortabel bergchalet met sauna bij de skipiste',
      'address': 'Fageråsvegen 22',
      'zip': '2420',
      'city': 'Trysil',
      'country': 'Norway',
      'image_url': '/media/chalet.jpg',
      'has_addons': true,
      'has_agreement': false,
      'owner_spoken_languages': ['nb', 'en'],
      'rating': 4.8,
      'price_unit_in_days': 1,
      'min_price': 2400,
      'max_price': 4100.5,
      'original_min_price': 2600,
      'original_max_price': 4400,
      'rooms': [
        {'name': 'Main bedroom', 'max_people': 2},
      ],
      'in_out_max_date': '2027-01-31T00:00:00Z',
      'in_out': {'check_in': '16:00'},
      'currency': {'code': 'NOK'},
      'subscription_plans': ['Professional'],
    }).toDomain();

    expect(details.id, '706211');
    expect(details.name, 'Comfortabel bergchalet met sauna bij de skipiste');
    expect(details.address, 'Fageråsvegen 22');
    expect(details.zip, '2420');
    expect(details.city, 'Trysil');
    expect(details.country, 'Norway');
    expect(details.imageUrl, '/media/chalet.jpg');
    expect(details.hasAddons, isTrue);
    expect(details.hasAgreement, isFalse);
    expect(details.ownerSpokenLanguages, ['nb', 'en']);
    expect(details.rating, 4.8);
    expect(details.priceUnitInDays, 1);
    expect(details.minPrice, 2400);
    expect(details.maxPrice, 4100.5);
    expect(details.originalMinPrice, 2600);
    expect(details.originalMaxPrice, 4400);
    expect(details.rooms, isA<List<dynamic>>());
    expect(details.inOutMaxDate, DateTime.utc(2027, 1, 31));
    expect(details.inOut, {'check_in': '16:00'});
    expect(details.currency, {'code': 'NOK'});
    expect(details.subscriptionPlans, ['Professional']);
  });

  test('reads camelCase keys and a nested address object', () {
    final details = LodgifyPropertyDetailsDto.fromMap({
      'propertyId': '428193',
      'title': 'Trysil Panorama',
      'address': {'street': 'Fageråsvegen 22', 'zip': '2420', 'city': 'Trysil'},
      'hasAddons': 'false',
      'minPrice': '2400',
      'priceUnitInDays': 7,
      'roomTypes': [
        {'name': 'Suite'},
      ],
      'currencyCode': 'NOK',
    }).toDomain();

    expect(details.id, '428193');
    expect(details.name, 'Trysil Panorama');
    expect(details.address, 'Fageråsvegen 22');
    expect(details.zip, '2420');
    expect(details.city, 'Trysil');
    expect(details.hasAddons, isFalse);
    expect(details.minPrice, 2400);
    expect(details.priceUnitInDays, 7);
    expect(details.rooms, isA<List<dynamic>>());
    expect(details.currency, 'NOK');
  });

  test(
    'a field Lodgify did not send stays null instead of becoming a zero',
    () {
      // The record page renders null as "—". A 0 or an empty string here would
      // read as if Lodgify had reported one.
      final details = LodgifyPropertyDetailsDto.fromMap({
        'id': 706211,
        'name': 'Chalet',
      }).toDomain();

      expect(details.address, isNull);
      expect(details.zip, isNull);
      expect(details.city, isNull);
      expect(details.country, isNull);
      expect(details.rating, isNull);
      expect(details.minPrice, isNull);
      expect(details.maxPrice, isNull);
      expect(details.hasAddons, isNull);
      expect(details.hasAgreement, isNull);
      expect(details.rooms, isNull);
      expect(details.ownerSpokenLanguages, isNull);
      expect(details.subscriptionPlans, isNull);
    },
  );
}
