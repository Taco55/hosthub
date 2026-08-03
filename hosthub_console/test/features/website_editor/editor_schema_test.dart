import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/features/website_editor/presentation/website_editor_strings.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// Every field the schema declares, across every page, with the list rows
/// expanded against one row id per list so nested lists are covered too.
List<EditorField> _allSchemaFields() {
  final listOrder = <String, List<String>>{};
  for (final list in kDefaultTemplate.lists) {
    listOrder[list.listKey] = ['x1'];
    final items = list.itemsListKey;
    if (items != null) {
      listOrder[groupItemsListKey(list.listKey, 'x1', items)] = ['y1'];
    }
  }
  return [
    for (final page in kDefaultTemplate.pageKeys)
      ...kDefaultTemplate.fieldsFor(page, listOrder),
  ];
}

/// Pumps a localized context so the label lookups can be exercised.
Future<BuildContext> _localizedContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: const Locale('nl'),
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  test('the template orders its own pages, tabs and all', () {
    // Order is the list, not a map's key order. It used to be the latter, and
    // `legal` — which is not even a tab — came first in everything that walked
    // the pages, including the publish dialog's per-page breakdown.
    expect(kDefaultTemplate.pageKeys, [
      'home',
      'practical',
      'area',
      'gallery',
      kLegalPage,
    ]);
    expect(kDefaultTemplate.pageKeys.first, isNot(kLegalPage));
    // Each page names itself; the switch this replaced answered the raw key.
    for (final page in kDefaultTemplate.pages) {
      expect(page.label, isNotNull, reason: 'page ${page.key} has no label');
    }
    expect(kDefaultTemplate.tabPages, isNot(contains(kLegalPage)));
    // Every page reachable by key carries cards; a typo would read as empty.
    for (final key in kDefaultTemplate.pageKeys) {
      expect(
        kDefaultTemplate.cardsOf(key),
        isNotEmpty,
        reason: '$key is empty',
      );
    }
  });

  test('the tabs are the routes the site serves', () {
    expect(kDefaultTemplate.tabPages, ['home', 'practical', 'area', 'gallery']);
    // There is no chalet page and no contact page: that content renders on
    // the homepage (README fase 2 §0). Privacy is Settings → Legal.
    expect(kDefaultTemplate.tabPages, isNot(contains('chalet')));
    expect(kDefaultTemplate.tabPages, isNot(contains('contact')));
    expect(kDefaultTemplate.tabPages, isNot(contains('privacy')));
  });

  test('every field has a document and a JSON path', () {
    // The check that keeps the schema and the mapping table in step: a field
    // the repository cannot place would silently never be read or written.
    for (final field in _allSchemaFields()) {
      expect(
        WebsiteContentRepository.locationOf(field.key),
        isNotNull,
        reason: '${field.key} has no path in WebsiteContentRepository',
      );
    }
  });

  testWidgets('a field that is not readable on its page carries a note', (
    tester,
  ) async {
    // CONFORMANCE §1/§8: every field must be pointable at in the preview. A
    // field the reader cannot find needs a line saying where it lands.
    final context = await _localizedContext(tester);
    var checked = 0;
    for (final field in _allSchemaFields()) {
      if (field.visibility == FieldVisibility.inPage) continue;
      checked++;
      expect(
        visibilityHint(context, field.visibility),
        isNotNull,
        reason: '${field.key} (${field.visibility}) has no note',
      );
    }
    // The check is worthless if the schema declares no such field at all.
    expect(checked, greaterThan(0));
  });

  testWidgets('every field and card resolves a localized label', (
    tester,
  ) async {
    final context = await _localizedContext(tester);

    // A card without a title would render an empty header.
    for (final page in kDefaultTemplate.pageKeys) {
      for (final card in kDefaultTemplate.cardsOf(page)) {
        final title = cardTitle(context, card);
        expect(title, isNotEmpty, reason: 'card ${card.id} has no title');
        // A card that declares no title falls through to the generic one,
        // which is what a second template's cards used to all read.
        expect(
          card.title,
          isNotNull,
          reason: 'card ${card.id} declares no title',
        );
      }
    }

    // A plain field whose label falls back to its key is an untranslated
    // field wearing a machine name in the UI.
    for (final field in _allSchemaFields()) {
      if (field.listKey != null) continue;
      expect(
        fieldLabel(context, field.key),
        isNot(field.key),
        reason: '${field.key} has no localized label',
      );
    }

    // Every list names itself and its rows.
    for (final list in kDefaultTemplate.lists) {
      expect(
        listTitle(context, list.listKey),
        isNot(list.listKey),
        reason: '${list.listKey} has no localized list title',
      );
      expect(
        listItemLabel(context, list.listKey),
        isNotEmpty,
        reason: '${list.listKey} has no localized item label',
      );
    }
  });

  test('nesting stops at two levels', () {
    // CONFORMANCE §4: a list in a list in a list is a document structure and
    // does not belong in a form. A group's items are the deepest level, so no
    // field key may carry three row ids.
    for (final field in _allSchemaFields()) {
      final location = WebsiteContentRepository.locationOf(field.key);
      final rowIds = location!.path.whereType<RowId>().length;
      expect(
        rowIds,
        lessThanOrEqualTo(2),
        reason: '${field.key} nests $rowIds levels deep',
      );
    }
  });

  test('dead content has no field', () {
    // README §0.1: what nothing renders gets no field. A field the owner edits
    // that appears nowhere is worse than a field that is not there.
    const dead = [
      'cabin.experience',
      'cabin.layoutAndFacilities',
      'cabin.accessAndTransport',
      'cabin.policies',
      'home.amenities',
      'location.description',
      'home.reviews',
      'home.faq',
    ];
    final keys = _allSchemaFields().map((field) => field.key).toList();
    for (final prefix in dead) {
      expect(
        keys.where((key) => key.startsWith('$prefix.')),
        isEmpty,
        reason: '$prefix is dead content and must not have a field',
      );
    }
  });

  test('shared values are a schema flag on the values that are facts', () {
    // §B.2: `8–9`, `800 m`, `17:00` are language-independent; "7 minuten
    // lopen" is a value too and must be translated. So the flag sits on the
    // list, not on a pattern — and the form placeholders are *not* shared.
    final fields = _allSchemaFields();
    String? sharedOf(String key) =>
        fields.firstWhere((f) => f.key == key).sharedValue ? key : null;

    for (final key in [
      'home.keyFacts.x1.value',
      'cabin.location.distances.x1.value',
      'practical.quickFacts.x1.value',
      'cabin.rules.checkIn',
      'practical.arrival.checkOut.value',
    ]) {
      expect(sharedOf(key), key, reason: '$key should be shared');
    }
    for (final key in [
      'contact.form.fields.name.placeholder',
      'contact.form.fields.message.placeholder',
      'home.keyFacts.x1.label',
      // The time is a shared fact; what it is *called* is copy, and Norwegian
      // calls it "Innsjekk".
      'practical.arrival.checkIn.label',
      'practical.arrival.checkOut.label',
    ]) {
      expect(sharedOf(key), isNull, reason: '$key must be translated');
    }
  });

  test('a fixed group names itself, not by position in a switch', () {
    // The five transport columns were labelled by array index in a switch on
    // the list key: a label resolved by position, which is the one thing the
    // row ids exist to avoid.
    final transport = kDefaultTemplate
        .cardsOf('practical')
        .expand((card) => card.rows)
        .whereType<GroupListRow>()
        .firstWhere((row) => row.listKey == 'practical.transport.columns');

    expect(transport.fixedTitles, isTrue);
    expect(transport.fixedTitleLabels, hasLength(transport.maxItems));

    // Any row that fixes its titles has to name them, or the renderer falls
    // back to "Item 3" for a slot the template meant something by.
    for (final page in kDefaultTemplate.pages) {
      for (final card in page.cards) {
        for (final row in card.rows.whereType<GroupListRow>()) {
          if (!row.fixedTitles) continue;
          expect(
            row.fixedTitleLabels,
            isNotNull,
            reason: '${row.listKey} fixes its titles but does not name them',
          );
        }
      }
    }
  });

  test('a field key knows which page it is on', () {
    // The translation row's `page` column was the constant 'home' for every
    // field of every page, and it sat in the unique key — so it asserted
    // something false and could not be corrected without the upsert inserting
    // duplicates.
    expect(kDefaultTemplate.pageOfField('cabin.hero.title'), 'home');
    expect(kDefaultTemplate.pageOfField('practical.header.title'), 'practical');
    expect(kDefaultTemplate.pageOfField('area.intro'), 'area');
    expect(kDefaultTemplate.pageOfField('legal.privacy.intro'), kLegalPage);
    // A list row's field key belongs to the page its list is on.
    expect(
      kDefaultTemplate.pageOfField('practical.transport.columns.x1.title'),
      'practical',
    );
    // And a key no card claims says so rather than guessing a page.
    expect(kDefaultTemplate.pageOfField('nothing.claims.this'), isNull);
  });

  test('a second template answers with its own paths', () {
    // The point of the field table living on the template: two templates can
    // map the same key to different documents. While it was static on the
    // repository they necessarily shared one answer, so this is the assertion
    // that a second template is possible at all.
    final other = WebsiteTemplate(
      id: 'other',
      pages: [
        TemplatePage(
          key: 'home',
          cards: [
            EditorCard(
              id: 'hero',
              title: (s) => s.weCardHero,
              rows: const [FieldRow('cabin.hero.title')],
            ),
          ],
        ),
      ],
      fieldPaths: [
        (
          pattern: 'cabin.hero.title',
          document: kDocPractical,
          path: ['somewhereElse'],
        ),
      ],
    );

    expect(
      kDefaultTemplate.locationOf('cabin.hero.title')!.address,
      'cabin/main:hero.title',
    );
    expect(
      other.locationOf('cabin.hero.title')!.address,
      'page/practical:somewhereElse',
    );
    // And a key the other template does not declare is simply unknown to it.
    expect(other.locationOf('area.intro'), isNull);
    expect(kDefaultTemplate.locationOf('area.intro'), isNotNull);
  });

  test('a field resolves to the document that actually holds it', () {
    // The path table addressed documents by index into a list until now, so
    // inserting one entry repointed every later pattern — silently, because a
    // path that is not there reads as an empty string rather than throwing.
    // These are the anchors: if a key ever answers a different document, the
    // editor is reading and writing someone else's content.
    const expected = {
      'cabin.hero.title': 'cabin/main',
      'home.tagline': 'page/home',
      'practical.header.title': 'page/practical',
      'area.intro': 'page/area',
      'contact.title': 'contact_form/main',
      'site.name': 'site_config/main',
      'legal.privacy.intro': 'page/privacy',
    };

    expected.forEach((key, document) {
      final location = WebsiteContentRepository.locationOf(key);
      expect(location, isNotNull, reason: '$key is not mapped');
      expect(
        '${location!.contentType}/${location.slug}',
        document,
        reason: '$key must live in $document',
      );
    });
  });

  test('a media row contributes no field the site cannot read', () {
    final fields = _allSchemaFields().map((f) => f.key).toList();

    // The files themselves are language-independent and are not text fields.
    expect(fields.where((key) => key.startsWith('images.')), isEmpty);

    // Nor is there a summarizing alt text: the hero's alt comes from
    // cabin.meta.name and both galleries caption per image, so the three
    // per-set fields that used to live here wrote text nothing rendered.
    for (final dead in const [
      'cabin.hero.photosAlt',
      'home.galleryAlt',
      'gallery.allAlt',
    ]) {
      expect(fields, isNot(contains(dead)), reason: '$dead is unread');
    }
  });

  test('a media key addresses the document path the website reads', () {
    // The repository writes `images[key.split('.').last]` and the website
    // reads `images.heroPhotos` / `.homeGallery` / `.galleryAll`. A media key
    // that is not the full path silently writes somewhere nobody reads and
    // never matches on the way back, leaving every photo picker empty.
    final mediaKeys = [
      for (final page in kDefaultTemplate.pages)
        for (final card in page.cards)
          for (final row in card.rows)
            if (row is MediaRow) row.mediaKey,
    ];

    expect(mediaKeys, isNotEmpty);
    for (final key in mediaKeys) {
      expect(
        key,
        startsWith('images.'),
        reason: '$key must be the images.<slot> path, not a short name',
      );
    }
    expect(
      mediaKeys,
      containsAll([
        'images.heroPhotos',
        'images.homeGallery',
        'images.galleryAll',
      ]),
    );

    // And every one of them resolves against the template's own slot key, so
    // the document routing is not a literal in the repository any more.
    for (final key in mediaKeys) {
      expect(
        kDefaultTemplate.mediaJsonKeyOf(key),
        isNotNull,
        reason: '$key is not under ${kDefaultTemplate.mediaSlots.jsonKey}',
      );
    }
    expect(kDefaultTemplate.mediaJsonKeyOf('images.heroPhotos'), 'heroPhotos');
    expect(kDefaultTemplate.mediaJsonKeyOf('elsewhere.photos'), isNull);
    expect(kDefaultTemplate.mediaSlots.document, kDocSiteConfig);
  });

  test('a read-only card contributes no editable field', () {
    // Nothing is read-only today: the agreements card claimed a Lodgify
    // source that never existed and is editable now. The rule still holds for
    // whatever declares itself read-only next.
    for (final page in kDefaultTemplate.pages) {
      for (final card in page.cards.where((card) => card.readOnly)) {
        expect(
          _allSchemaFields().where((f) => f.cardId == card.id),
          isEmpty,
          reason: '${card.id} is read-only and must contribute no field',
        );
      }
    }
  });

  test('the agreements terms are the owner\'s, not an external feed', () {
    // They render on the live Practical page and nothing syncs them from
    // Lodgify, so a read-only card left the owner unable to change their own
    // payment and cancellation terms.
    final agreements = kDefaultTemplate
        .cardsOf('practical')
        .firstWhere((card) => card.id == 'agreements');

    expect(agreements.readOnly, isFalse);
    expect(agreements.rows.whereType<ExternalRow>(), isEmpty);
    final keys = _allSchemaFields()
        .where((f) => f.cardId == 'agreements')
        .map((f) => f.key);
    expect(keys, contains('practical.agreements.title'));
    expect(
      keys.any((k) => k.startsWith('practical.agreements.blocks.')),
      isTrue,
    );
  });

  test('the highlight row carries title, subline and its alt text', () {
    // Two things that were not editable and now are: the title of a highlight
    // (the card was half-editorial without it) and its alt text.
    final keys = _allSchemaFields().map((f) => f.key);
    expect(keys, contains('home.highlights.x1.title'));
    expect(keys, contains('home.highlights.x1.description'));
    expect(keys, contains('home.highlights.x1.alt'));
  });

  test('house rules and amenity items are editable', () {
    // README §0.1: the two exceptions to "dead content gets no field".
    final keys = _allSchemaFields().map((f) => f.key);
    expect(keys, contains('cabin.rules.title'));
    expect(keys, contains('cabin.rules.bullets.x1.text'));
    expect(keys, contains('cabin.amenities.groups.x1.items.y1.text'));
  });
}
