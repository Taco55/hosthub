import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';

/// The scope of a portfolio screen. Covers the Scope integrity checks in the
/// multi-property handoff's CONFORMANCE.md that are the type's own
/// responsibility: defaults to all, never empty, clamped to what exists.
void main() {
  const account = [1, 2, 3, 4];

  group('defaults', () {
    test('a portfolio screen opens on every property', () {
      final selection = PropertySelection.all(account);

      expect(selection.selectedPropertyIds, {1, 2, 3, 4});
      expect(selection.selectedCount, 4);
      expect(selection.availableCount, 4);
      expect(selection.isAll, isTrue);
      expect(selection.isSingle, isFalse);
    });

    test('an account with no properties selects nothing', () {
      final selection = PropertySelection.all(const <int>[]);

      expect(selection.isEmpty, isTrue);
      expect(selection.selectedCount, 0);
      // Nothing to select is not "everything is selected".
      expect(selection.isAll, isFalse);
    });

    test('the chosen properties come back in the account\'s order', () {
      final selection = PropertySelection.of(
        account,
        selectedPropertyIds: const [4, 1],
      );

      expect(selection.selectedInOrder, [1, 4]);
    });
  });

  group('never empty', () {
    test('unchecking the last property is a no-op', () {
      final single = PropertySelection.of(
        account,
        selectedPropertyIds: const [2],
      );

      final after = single.toggled(2);

      expect(after.selectedPropertyIds, {2});
      expect(after, single);
    });

    test('unchecking any other property narrows the selection', () {
      final selection = PropertySelection.all(account).toggled(3);

      expect(selection.selectedPropertyIds, {1, 2, 4});
      expect(selection.isAll, isFalse);
    });

    test('checking a property widens it again', () {
      final selection = PropertySelection.all(account).toggled(3).toggled(3);

      expect(selection.selectedPropertyIds, {1, 2, 3, 4});
      expect(selection.isAll, isTrue);
    });

    test(
      'a stored selection of properties that no longer exist falls to all',
      () {
        final selection = PropertySelection.of(
          account,
          selectedPropertyIds: const [77, 88],
        );

        expect(selection.selectedPropertyIds, {1, 2, 3, 4});
      },
    );

    test('a stored selection keeps the ids that do exist', () {
      final selection = PropertySelection.of(
        account,
        selectedPropertyIds: const [2, 77],
      );

      expect(selection.selectedPropertyIds, {2});
    });

    test('toggling a property the account does not have changes nothing', () {
      final selection = PropertySelection.all(account);

      expect(selection.toggled(99), selection);
    });

    test('"Alle properties" selects everything again', () {
      final selection = PropertySelection.all(account).toggled(1).toggled(2);

      expect(selection.selectAll().selectedPropertyIds, {1, 2, 3, 4});
    });
  });

  group('clamping to the properties that exist', () {
    test('a removed property drops out of a narrowed selection', () {
      final narrowed = PropertySelection.of(
        account,
        selectedPropertyIds: const [2, 3],
      );

      final clamped = narrowed.clampedTo(const [1, 2, 4]);

      expect(clamped.selectedPropertyIds, {2});
      expect(clamped.availablePropertyIds, [1, 2, 4]);
    });

    test('removing every selected property falls back to all', () {
      final narrowed = PropertySelection.of(
        account,
        selectedPropertyIds: const [3],
      );

      final clamped = narrowed.clampedTo(const [1, 2, 4]);

      expect(clamped.selectedPropertyIds, {1, 2, 4});
    });

    test('a newly added property joins a full selection', () {
      // §6: a new listing must not sit silently outside the totals.
      final clamped = PropertySelection.all(
        account,
      ).clampedTo(const [1, 2, 3, 4, 5]);

      expect(clamped.selectedPropertyIds, {1, 2, 3, 4, 5});
      expect(clamped.isAll, isTrue);
    });

    test('a newly added property stays out of a narrowed selection', () {
      final narrowed = PropertySelection.of(
        account,
        selectedPropertyIds: const [1, 2],
      );

      final clamped = narrowed.clampedTo(const [1, 2, 3, 4, 5]);

      expect(clamped.selectedPropertyIds, {1, 2});
    });

    test('an empty selection clamps to all of the new set', () {
      final clamped = PropertySelection.empty.clampedTo(account);

      expect(clamped.selectedPropertyIds, {1, 2, 3, 4});
    });
  });

  group('equality', () {
    test('the same choice over the same account is the same value', () {
      expect(
        PropertySelection.of(account, selectedPropertyIds: const [1, 2]),
        PropertySelection.of(account, selectedPropertyIds: const [2, 1]),
      );
    });

    test('the same choice over a different account is not', () {
      expect(
        PropertySelection.of(account, selectedPropertyIds: const [1]),
        isNot(
          PropertySelection.of(const [1, 2], selectedPropertyIds: const [1]),
        ),
      );
    });
  });
}
