import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/portfolio/domain/portfolio_page.dart';
import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';

/// The stored property filter: per page, per user, never empty, clamped to what
/// exists. Covers the Scope-integrity checks in the multi-property handoff's
/// CONFORMANCE.md that are about the preference rather than the control.
void main() {
  const account = [1, 2, 3, 4];

  group('reading a stored selection', () {
    test('nothing stored is all properties — the default costs no write', () {
      final selection = propertySelectionFor(
        page: PortfolioPage.bookings,
        availablePropertyIds: account,
      );

      expect(selection.selectedPropertyIds, {1, 2, 3, 4});
      expect(selection.isAll, isTrue);
    });

    test('a page with nothing stored is all, even when the other page has', () {
      final selection = propertySelectionFor(
        page: PortfolioPage.revenue,
        availablePropertyIds: account,
        storedScope: const {
          'bookings': [1],
        },
      );

      expect(selection.isAll, isTrue);
    });

    test('each page reads its own selection', () {
      const stored = {
        'bookings': [1, 2],
        'revenue': [3],
      };

      expect(
        propertySelectionFor(
          page: PortfolioPage.bookings,
          availablePropertyIds: account,
          storedScope: stored,
        ).selectedPropertyIds,
        {1, 2},
      );
      expect(
        propertySelectionFor(
          page: PortfolioPage.revenue,
          availablePropertyIds: account,
          storedScope: stored,
        ).selectedPropertyIds,
        {3},
      );
    });

    test('a stored selection survives the round trip', () {
      final narrowed = PropertySelection.all(account).toggled(2).toggled(4);

      final stored = storedScopeWith(
        page: PortfolioPage.bookings,
        selection: narrowed,
      );
      final restored = propertySelectionFor(
        page: PortfolioPage.bookings,
        availablePropertyIds: account,
        storedScope: stored,
      );

      expect(restored, narrowed);
    });

    test('writing one page leaves the other page\'s selection alone', () {
      const stored = {
        'bookings': [1],
        'revenue': [2, 3],
      };

      final updated = storedScopeWith(
        page: PortfolioPage.bookings,
        selection: PropertySelection.of(
          account,
          selectedPropertyIds: const [4],
        ),
        storedScope: stored,
      );

      expect(updated['bookings'], [4]);
      expect(updated['revenue'], [2, 3]);
    });
  });

  group('never empty, always real', () {
    test(
      'a stored selection of properties that are gone falls back to all',
      () {
        final selection = propertySelectionFor(
          page: PortfolioPage.bookings,
          availablePropertyIds: account,
          storedScope: const {
            'bookings': [77, 88],
          },
        );

        // An empty portfolio view reads as broken, not as a filter.
        expect(selection.selectedPropertyIds, {1, 2, 3, 4});
      },
    );

    test('a partly stale selection keeps what still exists', () {
      final selection = propertySelectionFor(
        page: PortfolioPage.revenue,
        availablePropertyIds: account,
        storedScope: const {
          'revenue': [2, 77],
        },
      );

      expect(selection.selectedPropertyIds, {2});
    });

    test('an empty stored list is not an empty selection', () {
      final selection = propertySelectionFor(
        page: PortfolioPage.bookings,
        availablePropertyIds: account,
        storedScope: const {'bookings': <int>[]},
      );

      expect(selection.isAll, isTrue);
    });

    test('an account with no properties selects nothing to divide by', () {
      final selection = propertySelectionFor(
        page: PortfolioPage.bookings,
        availablePropertyIds: const <int>[],
        storedScope: const {
          'bookings': [1],
        },
      );

      expect(selection.isEmpty, isTrue);
      expect(selection.selectedCount, 0);
    });

    test('a selection loaded for fewer properties than stored clamps down', () {
      // What the page does: available = the properties whose bookings loaded.
      final selection = propertySelectionFor(
        page: PortfolioPage.bookings,
        availablePropertyIds: const [1, 2],
        storedScope: const {
          'bookings': [1, 2, 3, 4],
        },
      );

      expect(selection.selectedPropertyIds, {1, 2});
      // And the occupancy divisor follows, so it cannot exceed what was summed.
      expect(selection.selectedCount, 2);
    });
  });

  group('page keys', () {
    test('are stable strings, because they are stored', () {
      expect(PortfolioPage.bookings.key, 'bookings');
      expect(PortfolioPage.revenue.key, 'revenue');
    });
  });
}
