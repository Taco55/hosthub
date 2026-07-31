import 'package:hosthub_console/features/channel_manager/domain/models/channel_property.dart';
import 'package:hosthub_console/features/properties/data/property_repository.dart';

/// What applying a sync would do with one Lodgify listing.
enum LodgifyListingAction {
  /// No local property points at it and none carries its name: applying creates
  /// one.
  create,

  /// A property created by hand carries the same name and no `lodgify_id`.
  /// Applying gives that row its id, so the listing arrives *on* the property
  /// the owner already built a website for instead of beside it.
  link,

  /// A property already carries this listing's `lodgify_id`. Nothing to do.
  linked,
}

/// One Lodgify listing, and the property it does or would belong to.
class LodgifyListingPlan {
  const LodgifyListingPlan({
    required this.listing,
    required this.action,
    this.existing,
  });

  final ChannelProperty listing;
  final LodgifyListingAction action;

  /// The local property this listing is about — the one that would be linked,
  /// or the one that already is. Null only for [LodgifyListingAction.create].
  final PropertySummary? existing;

  /// The listing's name, or its id when Lodgify reports no name.
  String get label {
    final name = listing.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return listing.id?.trim() ?? '';
  }
}

/// What one sync found, resolved against the properties the account already has.
///
/// The resolution lives here rather than in the cubit or the modal because both
/// used to do it: the cubit computed a "missing" list and the dialog re-derived
/// per row which of them were missing, comparing on id *and* name. That second
/// derivation is what silently swallowed a name match — the listing counted as
/// not-missing, so nothing was created and nothing was linked either, and the
/// property stayed manual forever.
class LodgifySyncPlan {
  const LodgifySyncPlan(this.listings);

  final List<LodgifyListingPlan> listings;

  /// Resolves [listings] against [properties].
  ///
  /// A listing Lodgify reports without a name *and* without a known id is left
  /// out: `properties.name` is NOT NULL, so there is nothing to create and
  /// nothing to link — listing it with no action to offer would only be a row
  /// the owner cannot act on.
  factory LodgifySyncPlan.from({
    required Iterable<ChannelProperty> listings,
    required Iterable<PropertySummary> properties,
  }) {
    final byLodgifyId = <String, PropertySummary>{};
    final unlinkedByName = <String, PropertySummary>{};
    for (final property in properties) {
      final lodgifyId = property.lodgifyId?.trim();
      if (lodgifyId != null && lodgifyId.isNotEmpty) {
        byLodgifyId[lodgifyId] = property;
      } else {
        unlinkedByName[property.name.trim().toLowerCase()] = property;
      }
    }

    final plans = <LodgifyListingPlan>[];
    for (final listing in listings) {
      final id = listing.id?.trim();
      final name = listing.name?.trim();

      final alreadyLinked = (id == null || id.isEmpty) ? null : byLodgifyId[id];
      if (alreadyLinked != null) {
        plans.add(
          LodgifyListingPlan(
            listing: listing,
            action: LodgifyListingAction.linked,
            existing: alreadyLinked,
          ),
        );
        continue;
      }

      final sameName = (name == null || name.isEmpty)
          ? null
          : unlinkedByName[name.toLowerCase()];
      if (sameName != null && id != null && id.isNotEmpty) {
        plans.add(
          LodgifyListingPlan(
            listing: listing,
            action: LodgifyListingAction.link,
            existing: sameName,
          ),
        );
        continue;
      }

      // A name match without an id cannot be linked — there is no id to write.
      // It is the property the owner made by hand, and it stays that way.
      if (sameName != null) {
        plans.add(
          LodgifyListingPlan(
            listing: listing,
            action: LodgifyListingAction.linked,
            existing: sameName,
          ),
        );
        continue;
      }

      if (name != null && name.isNotEmpty) {
        plans.add(
          LodgifyListingPlan(
            listing: listing,
            action: LodgifyListingAction.create,
          ),
        );
      }
    }
    return LodgifySyncPlan(plans);
  }

  List<LodgifyListingPlan> get toCreate =>
      listings.where((p) => p.action == LodgifyListingAction.create).toList();

  List<LodgifyListingPlan> get toLink =>
      listings.where((p) => p.action == LodgifyListingAction.link).toList();

  /// How many properties applying this plan would add or repair. Zero means the
  /// sync found nothing to do, which is a result worth stating rather than an
  /// empty dialog.
  int get changeCount => toCreate.length + toLink.length;

  bool get hasWork => changeCount > 0;

  @override
  String toString() =>
      'LodgifySyncPlan(listings: ${listings.length}, '
      'create: ${toCreate.length}, link: ${toLink.length})';
}
