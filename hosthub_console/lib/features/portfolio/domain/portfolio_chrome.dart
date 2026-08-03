import 'package:flutter/foundation.dart';

/// Which of the portfolio's chrome an account actually needs.
///
/// A one-property account should not pay for the machinery of several: a filter
/// with one row, a group counting to one, a property node you must open to reach
/// its own screens. §5 of the handoff lists exactly what collapses, and this
/// type is that list — one place the sidebar, the two portfolio screens and the
/// tables all read, so they cannot disagree about what a single-property account
/// looks like.
///
/// It is a **configuration of the same screens**, not a second set: the routes,
/// the aggregation and the widgets are identical, and the selection is simply a
/// single-element one.
@immutable
class PortfolioChrome {
  const PortfolioChrome({required this.propertyCount});

  /// How many properties the account has — the real count, not how many are
  /// selected. A four-property account filtered down to one keeps its filter.
  final int propertyCount;

  /// The case §5 describes: one property, so the portfolio chrome is noise.
  bool get isSingleProperty => propertyCount == 1;

  /// The filter in a portfolio screen's header. With one property there is
  /// nothing to choose between.
  bool get showsPropertyFilter => !isSingleProperty;

  /// The expandable property row in the sidebar. With one property its sections
  /// sit flat at the top level instead, always visible — there is no other
  /// property to collapse it in favour of.
  bool get showsPropertyNode => !isSingleProperty;

  /// The count pill on the Properties group. With one property the group label
  /// *is* the property's name, and there is nothing to count.
  ///
  /// The group heading is a label in both shapes — never a link to the list, so
  /// there is no destination here that a single-property account loses. The list
  /// is reached from Account · Koppelingen. What does *not* collapse is the `+`
  /// beside the heading: the chrome a one-property account is spared is the
  /// filter, the count and the node to open, not the way to get a second
  /// property.
  bool get showsPropertyCount => !isSingleProperty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioChrome &&
          runtimeType == other.runtimeType &&
          propertyCount == other.propertyCount;

  @override
  int get hashCode => propertyCount.hashCode;

  @override
  String toString() => 'PortfolioChrome($propertyCount properties)';
}
