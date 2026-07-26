import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/properties/domain/property_abbreviation.dart';

/// The sidebar chip is an identifier, so two properties must never share one.
void main() {
  group('deriving one', () {
    test('the initials of the first two words', () {
      expect(propertyAbbreviationFor('Trysil Panorama'), 'TP');
      expect(propertyAbbreviationFor('Hemsedal Lodge'), 'HL');
      expect(propertyAbbreviationFor('Geilo Fjellhytte'), 'GF');
      expect(propertyAbbreviationFor('Voss Fjordhus'), 'VF');
    });

    test('a third word is ignored', () {
      expect(propertyAbbreviationFor('Voss Fjordhus Annexe'), 'VF');
    });

    test('one word gives its first two letters', () {
      expect(propertyAbbreviationFor('Fjordhus'), 'FJ');
    });

    test('a one-letter name doubles it rather than half-filling the chip', () {
      expect(propertyAbbreviationFor('A'), 'AA');
    });

    test('punctuation and extra spacing do not become letters', () {
      expect(propertyAbbreviationFor('  trysil–panorama '), 'TP');
      expect(propertyAbbreviationFor('Ski/Sun'), 'SS');
      expect(propertyAbbreviationFor('Lodge (north)'), 'LN');
    });

    test('digits count as characters', () {
      expect(propertyAbbreviationFor('4 Seasons'), '4S');
    });

    test('a name with no letters at all gets a placeholder', () {
      // Better a visible placeholder than an empty chip, which reads as a
      // rendering fault.
      expect(propertyAbbreviationFor(''), '??');
      expect(propertyAbbreviationFor('   '), '??');
      expect(propertyAbbreviationFor('!!!'), '??');
    });
  });

  group('across an account', () {
    test('distinct names keep their natural codes', () {
      final codes = uniquePropertyAbbreviations(const [
        (id: 1, name: 'Trysil Panorama'),
        (id: 2, name: 'Hemsedal Lodge'),
        (id: 3, name: 'Geilo Fjellhytte'),
        (id: 4, name: 'Voss Fjordhus'),
      ]);

      expect(codes, {1: 'TP', 2: 'HL', 3: 'GF', 4: 'VF'});
    });

    test('a collision is resolved, and the first one keeps its code', () {
      final codes = uniquePropertyAbbreviations(const [
        (id: 1, name: 'Voss Fjordhus'),
        (id: 2, name: 'Voss Fjellhytte'),
      ]);

      expect(codes[1], 'VF');
      expect(codes[2], isNot('VF'));
      // Still spelled from its own name.
      expect(codes[2]!.startsWith('V'), isTrue);
    });

    test('no two properties ever share a code', () {
      final codes = uniquePropertyAbbreviations(const [
        (id: 1, name: 'Voss A'),
        (id: 2, name: 'Voss A'),
        (id: 3, name: 'Voss A'),
        (id: 4, name: 'Voss A'),
      ]);

      expect(codes.values.toSet(), hasLength(4));
    });

    test('identical unnameable properties are still told apart', () {
      final codes = uniquePropertyAbbreviations(const [
        (id: 1, name: 'A'),
        (id: 2, name: 'A'),
        (id: 3, name: 'A'),
      ]);

      expect(codes.values.toSet(), hasLength(3));
    });

    test('an empty account has no codes', () {
      expect(uniquePropertyAbbreviations(const []), isEmpty);
    });

    test('the same account in the same order gives the same codes', () {
      const account = [
        (id: 1, name: 'Voss Fjordhus'),
        (id: 2, name: 'Voss Fjellhytte'),
      ];

      expect(
        uniquePropertyAbbreviations(account),
        uniquePropertyAbbreviations(account),
      );
    });
  });
}
