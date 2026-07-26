import 'package:flutter/foundation.dart';

/// One property as a loader needs it: our id, and the channel manager's.
///
/// The pair travels together so a fetch can address the channel and still tag
/// what comes back with the id the aggregates filter on. Keeping them in one
/// value is what makes a portfolio fetch a loop rather than two parallel lists
/// that can fall out of step.
@immutable
class PropertyRef {
  const PropertyRef({
    required this.propertyId,
    required this.channelPropertyId,
  });

  /// The console's own `properties.id`.
  final int propertyId;

  /// The id the channel manager knows this property by.
  final String channelPropertyId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyRef &&
          runtimeType == other.runtimeType &&
          propertyId == other.propertyId &&
          channelPropertyId == other.channelPropertyId;

  @override
  int get hashCode => Object.hash(propertyId, channelPropertyId);

  @override
  String toString() => 'PropertyRef($propertyId → $channelPropertyId)';
}
