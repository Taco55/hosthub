import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';

/// The two screens that are about the portfolio rather than about one property.
///
/// Each keeps its own property filter: Boekingen and Omzet are asked different
/// questions, and one shared selection would make narrowing the scope on one
/// screen silently narrow the other.
enum PortfolioPage { bookings, revenue }

/// The stored key for a page's selection.
extension PortfolioPageKey on PortfolioPage {
  String get key {
    switch (this) {
      case PortfolioPage.bookings:
        return 'bookings';
      case PortfolioPage.revenue:
        return 'revenue';
    }
  }
}

/// A page's filter, from what the user last chose and what the account has now.
///
/// The stored value is a preference, not state: it is clamped to the properties
/// that currently exist, and a selection that survives nothing falls back to all
/// of them. A page with nothing stored — a new user, or one who has never touched
/// the filter — is all properties too, so the default costs no write.
PropertySelection propertySelectionFor({
  required PortfolioPage page,
  required Iterable<int> availablePropertyIds,
  Map<String, List<int>>? storedScope,
}) {
  final stored = storedScope?[page.key];
  if (stored == null || stored.isEmpty) {
    return PropertySelection.all(availablePropertyIds);
  }
  return PropertySelection.of(
    availablePropertyIds,
    selectedPropertyIds: stored,
  );
}

/// The stored scope with [page] set to [selection].
///
/// Everything selected is stored as such rather than as an absent key: the two
/// read the same today, but writing it down is what lets a later property join
/// the selection knowingly instead of by accident.
Map<String, List<int>> storedScopeWith({
  required PortfolioPage page,
  required PropertySelection selection,
  Map<String, List<int>>? storedScope,
}) {
  return {...?storedScope, page.key: selection.selectedInOrder};
}
