import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/portfolio/domain/portfolio_chrome.dart';

/// §5 of the multi-property handoff, row by row: what a one-property account
/// does not pay for. One place says it, so the sidebar, the two portfolio
/// screens and the tables cannot disagree.
void main() {
  group('a one-property account', () {
    const chrome = PortfolioChrome(propertyCount: 1);

    test('is the collapsed case', () {
      expect(chrome.isSingleProperty, isTrue);
    });

    test('shows no property filter — nothing to choose between', () {
      expect(chrome.showsPropertyFilter, isFalse);
    });

    test('shows no property node; its sections sit flat instead', () {
      expect(chrome.showsPropertyNode, isFalse);
    });

    test('shows no count, because the group label is the property\'s name', () {
      expect(chrome.showsPropertyCount, isFalse);
    });

  });

  group('an account with several properties', () {
    test('keeps every piece of the portfolio chrome', () {
      for (final count in [2, 3, 4, 12]) {
        final chrome = PortfolioChrome(propertyCount: count);
        expect(chrome.isSingleProperty, isFalse, reason: '$count');
        expect(chrome.showsPropertyFilter, isTrue, reason: '$count');
        expect(chrome.showsPropertyNode, isTrue, reason: '$count');
        expect(chrome.showsPropertyCount, isTrue, reason: '$count');
      }
    });

    test('four properties filtered down to one keeps its filter', () {
      // The count is the account's, not the selection's: narrowing the filter
      // must not make the filter disappear.
      const chrome = PortfolioChrome(propertyCount: 4);

      expect(chrome.showsPropertyFilter, isTrue);
    });
  });

  group('an account with no properties', () {
    const chrome = PortfolioChrome(propertyCount: 0);

    test('is not the single-property case', () {
      // Nothing to collapse onto, so the ordinary chrome (and its empty states)
      // applies rather than a property-shaped one.
      expect(chrome.isSingleProperty, isFalse);
    });
  });
}
