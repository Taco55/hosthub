import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/properties/properties.dart';

/// One rule with three outcomes: a listing we do not have (create), a listing
/// whose name is already a hand-made property (link), and a listing we already
/// point at (nothing).
///
/// The link case is the regression: it used to be filtered out as "not missing"
/// and then skipped, so a synced listing with an existing name was neither
/// added nor linked and the property stayed manual forever.
void main() {
  const trysil = PropertySummary(
    id: 1,
    name: 'Trysil Panorama',
    lodgifyId: '428193',
  );
  const madeByHand = PropertySummary(id: 2, name: 'Vestfjord Cabin');

  test('a listing nothing points at is created', () {
    final plan = LodgifySyncPlan.from(
      listings: const [ChannelProperty(id: '999', name: 'New Cabin')],
      properties: const [trysil],
    );

    expect(plan.listings.single.action, LodgifyListingAction.create);
    expect(plan.toCreate, hasLength(1));
    expect(plan.toLink, isEmpty);
    expect(plan.changeCount, 1);
    expect(plan.hasWork, isTrue);
  });

  test('a name that matches a hand-made property links to it', () {
    final plan = LodgifySyncPlan.from(
      listings: const [ChannelProperty(id: '706211', name: 'Vestfjord Cabin')],
      properties: const [trysil, madeByHand],
    );

    final entry = plan.listings.single;
    expect(entry.action, LodgifyListingAction.link);
    expect(entry.existing?.id, madeByHand.id);
    expect(plan.toCreate, isEmpty);
    expect(plan.toLink, hasLength(1));
  });

  test('the name match ignores case and surrounding space', () {
    final plan = LodgifySyncPlan.from(
      listings: const [
        ChannelProperty(id: '706211', name: '  vestfjord cabin '),
      ],
      properties: const [madeByHand],
    );

    expect(plan.listings.single.action, LodgifyListingAction.link);
  });

  test('a listing we already carry the id of is left alone', () {
    final plan = LodgifySyncPlan.from(
      listings: const [ChannelProperty(id: '428193', name: 'Renamed upstream')],
      properties: const [trysil],
    );

    final entry = plan.listings.single;
    expect(entry.action, LodgifyListingAction.linked);
    expect(entry.existing?.id, trysil.id);
    expect(plan.hasWork, isFalse);
    expect(plan.changeCount, 0);
  });

  test('an id match wins over a name match, so nothing is linked twice', () {
    final plan = LodgifySyncPlan.from(
      listings: const [ChannelProperty(id: '428193', name: 'Vestfjord Cabin')],
      properties: const [trysil, madeByHand],
    );

    expect(plan.listings.single.action, LodgifyListingAction.linked);
    expect(plan.listings.single.existing?.id, trysil.id);
  });

  test('a name match without an id cannot be linked and stays manual', () {
    final plan = LodgifySyncPlan.from(
      listings: const [ChannelProperty(name: 'Vestfjord Cabin')],
      properties: const [madeByHand],
    );

    expect(plan.listings.single.action, LodgifyListingAction.linked);
    expect(plan.hasWork, isFalse);
  });

  test(
    'a nameless unknown listing is left out — there is nothing to create',
    () {
      final plan = LodgifySyncPlan.from(
        listings: const [ChannelProperty(id: '555')],
        properties: const [trysil],
      );

      expect(plan.listings, isEmpty);
    },
  );

  test('a plan counts creates and links together', () {
    final plan = LodgifySyncPlan.from(
      listings: const [
        ChannelProperty(id: '428193', name: 'Trysil Panorama'),
        ChannelProperty(id: '706211', name: 'Vestfjord Cabin'),
        ChannelProperty(id: '999', name: 'New Cabin'),
      ],
      properties: const [trysil, madeByHand],
    );

    expect(plan.toCreate.map((entry) => entry.label), ['New Cabin']);
    expect(plan.toLink.map((entry) => entry.label), ['Vestfjord Cabin']);
    expect(plan.changeCount, 2);
  });
}
