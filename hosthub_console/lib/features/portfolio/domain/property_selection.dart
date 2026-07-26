import 'package:flutter/foundation.dart';

/// Which properties a portfolio screen is about.
///
/// Carries the account's properties as well as the chosen ones, for two reasons:
/// the button label needs both (`2 van 4 properties`), and "never empty" is only
/// enforceable when the type knows what there is to fall back to.
///
/// A view preference, not app state: Boekingen and Omzet each hold their own and
/// neither may reach a property screen.
@immutable
class PropertySelection {
  const PropertySelection._({
    required this.availablePropertyIds,
    required this.selectedPropertyIds,
  });

  /// An account with no properties yet: nothing to select, nothing to divide by.
  static const PropertySelection empty = PropertySelection._(
    availablePropertyIds: <int>[],
    selectedPropertyIds: <int>{},
  );

  /// Everything the account has — the default a portfolio screen opens in.
  factory PropertySelection.all(Iterable<int> availablePropertyIds) {
    final available = List<int>.unmodifiable(availablePropertyIds);
    return PropertySelection._(
      availablePropertyIds: available,
      selectedPropertyIds: Set<int>.unmodifiable(available),
    );
  }

  /// A stored or partial selection, clamped to what currently exists.
  ///
  /// Ids that no longer exist are dropped, and a selection that ends up empty
  /// becomes all of them — never nothing. That is the load path for a persisted
  /// preference and for a property that was removed while it was selected.
  factory PropertySelection.of(
    Iterable<int> availablePropertyIds, {
    required Iterable<int> selectedPropertyIds,
  }) {
    final available = List<int>.unmodifiable(availablePropertyIds);
    final selected = selectedPropertyIds.where(available.contains).toSet();
    if (selected.isEmpty) return PropertySelection.all(available);
    return PropertySelection._(
      availablePropertyIds: available,
      selectedPropertyIds: Set<int>.unmodifiable(selected),
    );
  }

  /// The account's properties, in the order the account lists them.
  final List<int> availablePropertyIds;

  /// The chosen properties. Empty only when the account has none.
  final Set<int> selectedPropertyIds;

  /// The divisor for a rate: how many properties' calendars the period covers.
  int get selectedCount => selectedPropertyIds.length;

  int get availableCount => availablePropertyIds.length;

  bool get isEmpty => selectedPropertyIds.isEmpty;

  bool get isAll =>
      availablePropertyIds.isNotEmpty &&
      selectedPropertyIds.length == availablePropertyIds.length;

  /// Exactly one property chosen — the case that hides the property column.
  bool get isSingle => selectedPropertyIds.length == 1;

  bool contains(int propertyId) => selectedPropertyIds.contains(propertyId);

  /// The chosen properties in the account's order, for a label or a menu.
  List<int> get selectedInOrder => List<int>.unmodifiable(
    availablePropertyIds.where(selectedPropertyIds.contains),
  );

  /// Check or uncheck one property.
  ///
  /// Unchecking the last one is a **no-op**: an empty portfolio view shows
  /// nothing and reads as broken rather than as a filter.
  PropertySelection toggled(int propertyId) {
    if (!availablePropertyIds.contains(propertyId)) return this;
    if (selectedPropertyIds.contains(propertyId)) {
      if (selectedPropertyIds.length == 1) return this;
      return PropertySelection._(
        availablePropertyIds: availablePropertyIds,
        selectedPropertyIds: Set<int>.unmodifiable(
          selectedPropertyIds.where((id) => id != propertyId),
        ),
      );
    }
    return PropertySelection._(
      availablePropertyIds: availablePropertyIds,
      selectedPropertyIds: Set<int>.unmodifiable({
        ...selectedPropertyIds,
        propertyId,
      }),
    );
  }

  /// Select everything, what the "Alle properties" row does.
  PropertySelection selectAll() => PropertySelection.all(availablePropertyIds);

  /// The same choice against a new set of properties.
  ///
  /// A property that was added joins the selection when everything was selected
  /// — a new listing should not silently sit outside the totals — and stays out
  /// of a narrowed one. A property that disappeared is dropped.
  PropertySelection clampedTo(Iterable<int> availablePropertyIds) {
    final available = List<int>.unmodifiable(availablePropertyIds);
    if (isAll || isEmpty) return PropertySelection.all(available);
    return PropertySelection.of(
      available,
      selectedPropertyIds: selectedPropertyIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertySelection &&
          runtimeType == other.runtimeType &&
          listEquals(availablePropertyIds, other.availablePropertyIds) &&
          setEquals(selectedPropertyIds, other.selectedPropertyIds);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(availablePropertyIds),
    Object.hashAllUnordered(selectedPropertyIds),
  );

  @override
  String toString() =>
      'PropertySelection($selectedCount/$availableCount: $selectedInOrder)';
}
