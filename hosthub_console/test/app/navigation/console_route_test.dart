import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';

/// The route is the console's scope: which property is open and which section of
/// it. Covers the Navigation and Scope-integrity checks in the multi-property
/// handoff's CONFORMANCE.md that are about the location rather than the pixels.
void main() {
  group('reading a location', () {
    test('the portfolio destinations', () {
      expect(
        ConsoleRoute.parse('/bookings'),
        const ConsoleRoute.portfolio(PortfolioSection.bookings),
      );
      expect(
        ConsoleRoute.parse('/revenue'),
        const ConsoleRoute.portfolio(PortfolioSection.revenue),
      );
    });

    test('the properties list and the account', () {
      expect(
        ConsoleRoute.parse('/properties'),
        const ConsoleRoute.propertiesList(),
      );
      expect(ConsoleRoute.parse('/account'), const ConsoleRoute.account());
    });

    test('a property section — the deep link the sidebar has to render', () {
      final route = ConsoleRoute.parse('/properties/3/pricing');

      expect(route.propertyId, 3);
      expect(route.propertySection, PropertySection.pricing);
      expect(route.hasOpenProperty, isTrue);
    });

    test('every section round-trips through its path', () {
      for (final section in PropertySection.values) {
        final path = ConsoleRoute.propertyPath(7, section);
        expect(ConsoleRoute.parse(path), ConsoleRoute.property(7, section));
      }
    });

    test('a property without a section is its overview', () {
      expect(
        ConsoleRoute.parse('/properties/5'),
        const ConsoleRoute.property(5, PropertySection.overview),
      );
      expect(
        ConsoleRoute.propertyRootPath(5),
        ConsoleRoute.propertyPath(5, PropertySection.overview),
      );
    });

    test('a section that does not exist still opens that property', () {
      final route = ConsoleRoute.parse('/properties/5/invoices');

      expect(route.propertyId, 5);
      expect(route.propertySection, PropertySection.overview);
    });

    test('a property id that is not a number is the list, not a property', () {
      expect(
        ConsoleRoute.parse('/properties/trysil/pricing'),
        const ConsoleRoute.propertiesList(),
      );
    });

    test('query and fragment do not change the destination', () {
      expect(
        ConsoleRoute.parse('/properties/3/website?locale=nl#hero'),
        const ConsoleRoute.property(3, PropertySection.website),
      );
    });

    test('a path outside the tree selects nothing', () {
      for (final path in ['/admin-options', '/sites/9/team', '/', '']) {
        final route = ConsoleRoute.parse(path);
        expect(route, ConsoleRoute.elsewhere, reason: path);
        expect(route.hasOpenProperty, isFalse, reason: path);
      }
    });

    test('trailing and doubled slashes read the same', () {
      expect(
        ConsoleRoute.parse('/properties/3/pricing/'),
        const ConsoleRoute.property(3, PropertySection.pricing),
      );
      expect(
        ConsoleRoute.parse('//bookings'),
        const ConsoleRoute.portfolio(PortfolioSection.bookings),
      );
    });
  });

  group('exactly one property is open', () {
    test('a portfolio or account route opens none', () {
      expect(
        const ConsoleRoute.portfolio(PortfolioSection.bookings).hasOpenProperty,
        isFalse,
      );
      expect(const ConsoleRoute.account().hasOpenProperty, isFalse);
      expect(const ConsoleRoute.propertiesList().hasOpenProperty, isFalse);
    });

    test('a property route opens that one and no other', () {
      const route = ConsoleRoute.property(2, PropertySection.website);

      expect(route.propertyId, 2);
      // There is one field to hold it, so a second property cannot be open.
      expect(route.propertyId, isNot(1));
    });
  });

  group('clamping the open property', () {
    test('a property that still exists is left alone', () {
      const route = ConsoleRoute.property(2, PropertySection.pricing);

      expect(route.clampedTo([1, 2, 3]), route);
    });

    test('a removed property gives way to the first, same section', () {
      const route = ConsoleRoute.property(9, PropertySection.pricing);

      final clamped = route.clampedTo([1, 2, 3]);

      // The sidebar and the body then agree — without this the sidebar shows
      // property A while the body loads B.
      expect(clamped.propertyId, 1);
      expect(clamped.propertySection, PropertySection.pricing);
    });

    test('an account with no properties falls back to the list', () {
      const route = ConsoleRoute.property(9, PropertySection.overview);

      expect(route.clampedTo(const []), const ConsoleRoute.propertiesList());
    });

    test('a route with no property is untouched', () {
      const route = ConsoleRoute.portfolio(PortfolioSection.revenue);

      expect(route.clampedTo(const []), route);
    });
  });

  group('paths', () {
    test('the tree\'s destinations are stable strings', () {
      expect(ConsoleRoute.bookingsPath, '/bookings');
      expect(ConsoleRoute.revenuePath, '/revenue');
      expect(ConsoleRoute.propertiesPath, '/properties');
      expect(ConsoleRoute.accountPath, '/account');
      expect(
        ConsoleRoute.propertyPath(4, PropertySection.settings),
        '/properties/4/settings',
      );
    });

    test('a route describes the path it came from', () {
      for (final path in [
        '/bookings',
        '/revenue',
        '/properties',
        '/account',
        '/properties/6/website',
      ]) {
        expect(ConsoleRoute.parse(path).path, path);
      }
    });
  });
}
