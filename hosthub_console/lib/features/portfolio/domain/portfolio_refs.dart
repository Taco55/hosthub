import 'package:hosthub_console/features/portfolio/domain/property_ref.dart';
import 'package:hosthub_console/features/properties/data/property_repository.dart';

/// The account's properties as the loader addresses them.
///
/// A property with no channel id has nothing to fetch — it exists in the console
/// but not yet at the channel manager — so it is left out of the request rather
/// than sent as an empty id. It still shows in the tree and in the filter; it
/// simply has no bookings to contribute.
List<PropertyRef> portfolioPropertyRefs(List<PropertySummary> properties) {
  final refs = <PropertyRef>[];
  for (final property in properties) {
    final channelPropertyId = property.lodgifyId?.trim();
    if (channelPropertyId == null || channelPropertyId.isEmpty) continue;
    refs.add(
      PropertyRef(
        propertyId: property.id,
        channelPropertyId: channelPropertyId,
      ),
    );
  }
  return refs;
}
