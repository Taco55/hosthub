import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/website_editor/data/website_content_repository.dart';
import 'package:hosthub_console/features/website_editor/domain/editor_schema.dart';

/// A group list holds groups, and each group holds its own items. Both levels
/// have to resolve from the document, or the card renders its groups with
/// nothing in them — which is what the amenities card did: the site listed ten
/// groups of facilities and the editor showed none of their lines.
void main() {
  Map<String, dynamic> cabinDocument() => <String, dynamic>{
    'amenities': <String, dynamic>{
      'title': 'Voorzieningen',
      'groups': <dynamic>[
        <String, dynamic>{
          'id': 'g1',
          'title': 'Wellness & spa',
          'items': <dynamic>[
            <String, dynamic>{'id': 'i1', 'text': 'Privé droge sauna'},
          ],
        },
        <String, dynamic>{
          'id': 'g2',
          'title': 'Parkeren',
          'items': <dynamic>[
            <String, dynamic>{'id': 'i2', 'text': 'Parkeren inbegrepen'},
            <String, dynamic>{'id': 'i3', 'text': 'Laadpunt bij het chalet'},
          ],
        },
      ],
    },
  };

  test('a group list resolves its groups and each group\'s items', () {
    final cabin = cabinDocument();

    expect(
      WebsiteContentRepository.listRowIdsIn('cabin.amenities.groups', cabin),
      ['g1', 'g2'],
    );
    expect(
      WebsiteContentRepository.listRowIdsIn(
        // The enclosing placeholder stays in the key: that is the shape the
        // pattern table is compared against.
        'cabin.amenities.groups.{id}.items',
        cabin,
        enclosingIds: ['g2'],
      ),
      ['i2', 'i3'],
    );
  });

  test('the resolved ids expand into the fields the card renders', () {
    final cabin = cabinDocument();
    final groups = WebsiteContentRepository.listRowIdsIn(
      'cabin.amenities.groups',
      cabin,
    );

    final order = <String, List<String>>{
      'cabin.amenities.groups': groups,
      for (final groupId in groups)
        groupItemsListKey(
          'cabin.amenities.groups',
          groupId,
          'items',
        ): WebsiteContentRepository.listRowIdsIn(
          'cabin.amenities.groups.{id}.items',
          cabin,
          enclosingIds: [groupId],
        ),
    };

    final keys = kDefaultTemplate
        .fieldsFor('home', order)
        .map((f) => f.key)
        .toSet();
    expect(keys, contains('cabin.amenities.title'));
    expect(keys, contains('cabin.amenities.groups.g1.title'));
    expect(keys, contains('cabin.amenities.groups.g1.items.i1.text'));
    expect(keys, contains('cabin.amenities.groups.g2.items.i3.text'));
  });

  test('a row id is resolved on a list whose element type is not nullable', () {
    // A decoded document can hand us List<Map<String, Object>>; resolving a
    // row on it used to throw rather than miss.
    final typed = <String, dynamic>{
      'amenities': <String, dynamic>{
        'groups': <Map<String, Object>>[
          {'id': 'g1', 'title': 'Wellness', 'items': <Map<String, Object>>[]},
        ],
      },
    };

    expect(
      WebsiteContentRepository.listRowIdsIn('cabin.amenities.groups', typed),
      ['g1'],
    );
    expect(
      WebsiteContentRepository.listRowIdsIn(
        'cabin.amenities.groups.{id}.items',
        typed,
        enclosingIds: ['missing'],
      ),
      isEmpty,
    );
  });
}
