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
  for (final list in kSchemaLists) {
    listOrder[list.listKey] = ['x1'];
    final items = list.itemsListKey;
    if (items != null) {
      listOrder[groupItemsListKey(list.listKey, 'x1', items)] = ['y1'];
    }
  }
  return [
    for (final page in kPageCards.keys) ...effectiveFieldsFor(page, listOrder),
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
  test('the tabs are the routes the site serves', () {
    expect(kWebsitePages, ['home', 'practical', 'area', 'gallery']);
    // There is no chalet page and no contact page: that content renders on
    // the homepage (README fase 2 §0). Privacy is Settings → Legal.
    expect(kWebsitePages, isNot(contains('chalet')));
    expect(kWebsitePages, isNot(contains('contact')));
    expect(kWebsitePages, isNot(contains('privacy')));
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
    for (final page in kPageCards.keys) {
      for (final card in kPageCards[page]!) {
        final title = cardTitle(context, card.id);
        expect(title, isNotEmpty, reason: 'card ${card.id} has no title');
        expect(
          title,
          isNot(card.id),
          reason: 'card ${card.id} falls through to the generic title',
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
    for (final list in kSchemaLists) {
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

  test('a media row contributes its alt text and no image field', () {
    final fields = _allSchemaFields().map((f) => f.key).toList();
    // Alt text is a sentence that gets read out: content, so per language.
    expect(fields, contains('cabin.hero.photosAlt'));
    expect(fields, contains('home.galleryAlt'));
    expect(fields, contains('gallery.allAlt'));
    // The files themselves are language-independent and are not text fields.
    expect(fields.where((key) => key.endsWith('.photos')), isEmpty);
    expect(fields.where((key) => key == 'home.gallery'), isEmpty);
  });

  test('a read-only card contributes no editable field', () {
    // §A.2: the Lodgify terms are read-only; the card states its source.
    final agreements = kPageCards['practical']!.firstWhere(
      (card) => card.id == 'agreements',
    );
    expect(agreements.readOnly, isTrue);
    expect(agreements.rows.single, isA<ExternalRow>());
    expect(_allSchemaFields().where((f) => f.cardId == 'agreements'), isEmpty);
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
