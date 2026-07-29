import 'dart:math';

import 'package:equatable/equatable.dart';

/// Why a field is not readable as text on its own page.
///
/// Every field must be pointable at in the preview (README §E). A field the
/// reader cannot find in the rendered page needs a note saying where it lands
/// and why — or it does not belong in the editor. [inPage] fields need none:
/// the preview marks the section they land in.
enum FieldVisibility {
  /// Readable as text on its own page; the preview marks its section.
  inPage,

  /// Not on the page: the browser-tab title and the Google listing.
  seo,

  /// Not text: it decides where the map pin sits.
  map,

  /// Only visible after the form was submitted successfully.
  stateSuccess,

  /// Only visible after the form failed.
  stateError,
}

/// One row in a card's schema (the handoff's Part D vocabulary).
///
/// The schema is data, read by one renderer: what a card *is* lives here, how
/// it looks lives in the widget layer. A new card is a schema entry and no new
/// widget — that is the test of whether this is built right. Labels are not
/// part of the schema: they are localized content and resolve through the ARB
/// layer (`website_editor_strings.dart`).
sealed class EditorRow {
  const EditorRow();
}

/// A single field bound to one field key.
class FieldRow extends EditorRow {
  const FieldRow(
    this.key, {
    this.multiline = false,
    this.visibility = FieldVisibility.inPage,
  });

  /// Stable field key, e.g. `cabin.hero.title`.
  final String key;
  final bool multiline;

  /// Where this field surfaces. Anything but [FieldVisibility.inPage] carries
  /// a note in the UI; the schema test refuses a field without one.
  final FieldVisibility visibility;
}

/// A repeatable list of single-value rows, keyed `<listKey>.<rowId>.<sub>`.
///
/// Which rows exist — and in what order — comes from the content, never from
/// the schema: the row id is identity, the array index is display order.
class ListRow extends EditorRow {
  const ListRow(
    this.listKey, {
    this.sub,
    this.multiline = false,
    this.repeatable = false,
    this.minItems = 1,
    this.maxItems,
  });

  /// Prefix of the row keys (`cabin.description` →
  /// `cabin.description.<id>.text`).
  final String listKey;

  /// The row's editable subfield (`text`, `description`); appended to the
  /// field key. Null when the row itself is the value.
  final String? sub;
  final bool multiline;

  /// Whether the owner can add, delete and reorder rows.
  final bool repeatable;

  /// Below this count the delete action dims with its reason.
  final int minItems;

  /// At this count the add action dims with its reason.
  final int? maxItems;
}

/// A list of label + value pairs, one row per pair (README §B.2).
class PairListRow extends EditorRow {
  const PairListRow(
    this.listKey, {
    required this.labelSub,
    required this.valueSub,
    this.repeatable = true,
    this.minItems = 1,
    this.maxItems,
    this.sharedValue = false,
    this.wideValue = false,
    this.fixedRows,
    this.fixedRowsAreValues = false,
  });

  final String listKey;

  /// Subfield holding the label and the value (`label` / `value`).
  final String labelSub;
  final String valueSub;
  final bool repeatable;
  final int minItems;
  final int? maxItems;

  /// Whether the value is language-independent (`8–9`, `800 m`, `17:00`).
  ///
  /// A schema flag and not pattern recognition: "7 minuten lopen" is a value
  /// too and must be translated. Shared values are read-only in a target
  /// language, carry the `gedeeld` micro chip, and stay out of the
  /// translation request.
  final bool sharedValue;

  /// Values that are sentences (the form placeholders) get the full width
  /// instead of the narrow numeric column.
  final bool wideValue;

  /// Rows the owner cannot add, delete or reorder — they were never theirs to
  /// restructure. Each entry is a key; what it addresses depends on
  /// [fixedRowsAreValues].
  final List<String>? fixedRows;

  /// Whether a [fixedRows] entry *is* the value's field key (`checkIn`), with
  /// the label a system fact that renders as the row title. False means the
  /// entry is a slot and the row has two fields, `<slot>.<labelSub>` and
  /// `<slot>.<valueSub>` — the contact form, whose four slots are fixed by a
  /// backend contract but whose copy is the owner's.
  final bool fixedRowsAreValues;
}

/// A repeatable list whose rows hold several fields (a highlight: title,
/// subline, image, alt).
class RowListRow extends EditorRow {
  const RowListRow(
    this.listKey, {
    required this.subs,
    this.repeatable = true,
    this.minItems = 1,
    this.maxItems,
    this.media = false,
  });

  final String listKey;

  /// The row's editable subfields, in order: `(sub, multiline)`.
  final List<({String sub, bool multiline})> subs;
  final bool repeatable;
  final int minItems;
  final int? maxItems;

  /// Whether each row carries one image (chosen through the media picker).
  final bool media;
}

/// A list of groups, each a title plus its own list of items (README §B.3).
class GroupListRow extends EditorRow {
  const GroupListRow(
    this.listKey, {
    required this.titleSub,
    required this.itemsListKey,
    required this.itemsSub,
    this.introSub,
    this.repeatable = true,
    this.maxItems,
    this.maxItemsPerGroup,
    this.fixedTitles = false,
  });

  final String listKey;

  /// Subfield holding the group's own title.
  final String titleSub;

  /// Suffix of the nested list inside a group (`bullets`, `items`); the full
  /// key is `<listKey>.<groupId>.<itemsListKey>.<itemId>.<itemsSub>`.
  final String itemsListKey;
  final String itemsSub;

  /// Subfield holding the group's introduction, when it has one
  /// (`area.sections`, `practical.layout.sections`).
  final String? introSub;
  final bool repeatable;
  final int? maxItems;
  final int? maxItemsPerGroup;

  /// Whether the group titles are fixed (`practical.transport.columns`): the
  /// title renders as a label and the group cannot be added, deleted or
  /// reordered.
  final bool fixedTitles;
}

/// A set of images plus one summarizing alt-text field (README §C).
class MediaRow extends EditorRow {
  const MediaRow(
    this.mediaKey, {
    required this.altFieldKey,
    required this.minItems,
    required this.maxItems,
    this.grid = false,
    this.primaryBadge = false,
  });

  /// Where the file keys live in `site_config` (`images.heroPhotos`).
  final String mediaKey;

  /// The summarizing alt text — a sentence that gets read out, so content,
  /// so per language (README §C.4).
  final String altFieldKey;
  final int minItems;
  final int maxItems;

  /// Renders as a grid rather than a strip (the gallery sets).
  final bool grid;

  /// Whether the first tile carries the `Eerste` badge and is the share image.
  final bool primaryBadge;
}

/// A read-only card whose content comes from elsewhere (§A.2, Lodgify).
class ExternalRow extends EditorRow {
  const ExternalRow({required this.source, required this.lineCount});

  /// The system that owns this content (`lodgify`).
  final String source;

  /// How many summary lines the card shows.
  final int lineCount;
}

/// One card in the editor: an identity (icon + localized title resolve through
/// the presentation layer) and the rows it holds.
class EditorCard {
  const EditorCard({
    required this.id,
    required this.rows,
    this.readOnly = false,
  });

  /// Stable card id; keys the localized title, the icon and the subtitle.
  final String id;
  final List<EditorRow> rows;

  /// Whether the card is a read-only surface (the section renders disabled
  /// and states its source).
  final bool readOnly;
}

/// The pages of the website (tabs in the editor) — one tab per route the
/// public site actually serves. There is no chalet page and no contact page:
/// that content renders on the homepage (README fase 2 §0). Privacy has no
/// tab either; it lives under Settings → Legal (§A.6).
const List<String> kWebsitePages = ['home', 'practical', 'area', 'gallery'];

/// The legal document's page key.
///
/// Deliberately outside [kWebsitePages]: it is a page of the site but not a tab
/// of the editor. A fifth tab invites editing exactly what you do not want
/// casually edited, so it is reached through Site-instellingen instead — while
/// running through the same schema, the same translation model and the same
/// explicit save as everything else.
const String kLegalPage = 'legal';

/// The editor's page schema: README §A.1–A.4, card for card, in page order —
/// so scrolling the editor and scrolling the preview are the same movement.
const Map<String, List<EditorCard>> kPageCards = {
  kLegalPage: [
    EditorCard(
      id: 'privacy',
      rows: [
        FieldRow('legal.privacy.intro', multiline: true),
        ListRow(
          'legal.privacy.bullets',
          sub: 'text',
          multiline: true,
          repeatable: true,
          minItems: 1,
        ),
      ],
    ),
  ],
  'home': [
    EditorCard(
      id: 'hero',
      rows: [
        FieldRow('cabin.hero.title'),
        FieldRow('cabin.meta.locationShort'),
        MediaRow(
          'hero.photos',
          altFieldKey: 'cabin.hero.photosAlt',
          minItems: 1,
          maxItems: 5,
          primaryBadge: true,
        ),
        FieldRow(
          'cabin.hero.subtitle',
          multiline: true,
          visibility: FieldVisibility.seo,
        ),
        FieldRow('cabin.meta.name', visibility: FieldVisibility.seo),
      ],
    ),
    EditorCard(
      id: 'keyFacts',
      rows: [
        PairListRow(
          'home.keyFacts',
          labelSub: 'label',
          valueSub: 'value',
          minItems: 3,
          maxItems: 6,
          sharedValue: true,
        ),
      ],
    ),
    EditorCard(
      id: 'description',
      rows: [
        ListRow(
          'cabin.description',
          sub: 'text',
          multiline: true,
          repeatable: true,
          maxItems: 4,
        ),
      ],
    ),
    EditorCard(
      id: 'homeGallery',
      rows: [
        MediaRow(
          'home.gallery',
          altFieldKey: 'home.galleryAlt',
          minItems: 5,
          maxItems: 8,
          grid: true,
        ),
      ],
    ),
    EditorCard(
      id: 'amenities',
      rows: [
        FieldRow('cabin.amenities.title'),
        GroupListRow(
          'cabin.amenities.groups',
          titleSub: 'title',
          itemsListKey: 'items',
          itemsSub: 'text',
          maxItems: 12,
        ),
      ],
    ),
    EditorCard(
      id: 'location',
      rows: [
        FieldRow('cabin.location.title'),
        PairListRow(
          'cabin.location.distances',
          labelSub: 'label',
          valueSub: 'value',
          maxItems: 8,
          sharedValue: true,
        ),
        FieldRow('cabin.location.mapQuery', visibility: FieldVisibility.map),
      ],
    ),
    EditorCard(
      id: 'highlights',
      rows: [
        RowListRow(
          'home.highlights',
          subs: [
            (sub: 'title', multiline: false),
            (sub: 'description', multiline: false),
          ],
          minItems: 2,
          maxItems: 6,
          media: true,
        ),
      ],
    ),
    EditorCard(
      id: 'houseRules',
      rows: [
        FieldRow('cabin.rules.title'),
        ListRow(
          'cabin.rules.bullets',
          sub: 'text',
          repeatable: true,
          maxItems: 8,
        ),
        PairListRow(
          'cabin.rules.times',
          labelSub: 'label',
          valueSub: 'value',
          sharedValue: true,
          repeatable: false,
          fixedRows: ['cabin.rules.checkIn', 'cabin.rules.checkOut'],
          fixedRowsAreValues: true,
        ),
        FieldRow('cabin.rules.checkInNote', multiline: true),
        FieldRow('cabin.rules.cleaningNote', multiline: true),
        FieldRow('cabin.rules.wifiNote', multiline: true),
      ],
    ),
    EditorCard(
      id: 'contact',
      rows: [
        FieldRow('contact.title'),
        FieldRow('contact.subtitle', multiline: true),
        // The four fields are fixed: the form has a backend contract, so only
        // the copy is the owner's.
        PairListRow(
          'contact.form.fields',
          labelSub: 'label',
          valueSub: 'placeholder',
          repeatable: false,
          wideValue: true,
          fixedRows: [
            'contact.form.fields.name',
            'contact.form.fields.email',
            'contact.form.fields.period',
            'contact.form.fields.message',
          ],
        ),
        FieldRow('contact.form.submit'),
        FieldRow(
          'contact.form.success',
          multiline: true,
          visibility: FieldVisibility.stateSuccess,
        ),
        FieldRow(
          'contact.form.error',
          multiline: true,
          visibility: FieldVisibility.stateError,
        ),
      ],
    ),
  ],
  'practical': [
    EditorCard(
      id: 'practicalHeader',
      rows: [
        FieldRow('practical.header.title'),
        FieldRow('practical.header.subtitle', multiline: true),
      ],
    ),
    EditorCard(
      id: 'quickFacts',
      rows: [
        PairListRow(
          'practical.quickFacts',
          labelSub: 'label',
          valueSub: 'value',
          minItems: 2,
          maxItems: 6,
          sharedValue: true,
        ),
      ],
    ),
    EditorCard(
      id: 'arrival',
      rows: [
        FieldRow('practical.arrival.title'),
        PairListRow(
          'practical.arrival.times',
          labelSub: 'label',
          valueSub: 'value',
          sharedValue: true,
          repeatable: false,
          fixedRows: [
            'practical.arrival.checkIn',
            'practical.arrival.checkOut',
          ],
          fixedRowsAreValues: true,
        ),
        ListRow(
          'practical.arrival.bullets',
          sub: 'text',
          multiline: true,
          repeatable: true,
          maxItems: 8,
        ),
      ],
    ),
    EditorCard(
      id: 'parking',
      rows: [
        FieldRow('practical.parking.title'),
        ListRow(
          'practical.parking.bullets',
          sub: 'text',
          multiline: true,
          repeatable: true,
          maxItems: 6,
        ),
        FieldRow('practical.parking.callout', multiline: true),
      ],
    ),
    EditorCard(
      id: 'layout',
      rows: [
        FieldRow('practical.layout.title'),
        GroupListRow(
          'practical.layout.sections',
          titleSub: 'title',
          itemsListKey: 'bullets',
          itemsSub: 'text',
          introSub: 'intro',
          maxItems: 6,
        ),
      ],
    ),
    EditorCard(
      id: 'transport',
      rows: [
        FieldRow('practical.transport.title'),
        GroupListRow(
          'practical.transport.columns',
          titleSub: 'title',
          itemsListKey: 'bullets',
          itemsSub: 'text',
          maxItems: 5,
          fixedTitles: true,
        ),
      ],
    ),
    EditorCard(
      id: 'goodToKnow',
      rows: [
        FieldRow('practical.goodToKnow.title'),
        ListRow(
          'practical.goodToKnow.bullets',
          sub: 'text',
          multiline: true,
          repeatable: true,
          maxItems: 10,
        ),
      ],
    ),
    EditorCard(
      id: 'contactHelp',
      rows: [
        FieldRow('practical.contactHelp.title'),
        ListRow(
          'practical.contactHelp.bullets',
          sub: 'text',
          multiline: true,
          repeatable: true,
          maxItems: 6,
        ),
      ],
    ),
    EditorCard(
      id: 'agreements',
      readOnly: true,
      rows: [ExternalRow(source: 'lodgify', lineCount: 3)],
    ),
  ],
  'area': [
    EditorCard(
      id: 'areaIntro',
      rows: [FieldRow('area.intro', multiline: true)],
    ),
    EditorCard(
      id: 'areaSections',
      rows: [
        GroupListRow(
          'area.sections',
          titleSub: 'title',
          itemsListKey: 'bullets',
          itemsSub: 'text',
          introSub: 'intro',
          maxItems: 8,
        ),
      ],
    ),
  ],
  'gallery': [
    EditorCard(
      id: 'galleryHeader',
      rows: [FieldRow('home.tagline', multiline: true)],
    ),
    EditorCard(
      id: 'galleryAll',
      rows: [
        MediaRow(
          'gallery.all',
          altFieldKey: 'gallery.allAlt',
          minItems: 6,
          maxItems: 40,
          grid: true,
        ),
      ],
    ),
  ],
};

/// The field key of one list row: `<listKey>.<rowId>[.<sub>]`.
String listFieldKey(String listKey, String rowId, String? sub) =>
    sub == null ? '$listKey.$rowId' : '$listKey.$rowId.$sub';

/// Makes the stable id a new list row carries for life: 8 lowercase base36
/// characters. It only has to be unique within one list; the migration gives
/// existing rows deterministic ids of the same shape.
String generateRowId() {
  final random = Random.secure();
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return [
    for (var i = 0; i < 8; i++) alphabet[random.nextInt(alphabet.length)],
  ].join();
}

/// The list key of a group's nested item list:
/// `<listKey>.<groupId>.<itemsListKey>`.
String groupItemsListKey(String listKey, String groupId, String itemsListKey) =>
    '$listKey.$groupId.$itemsListKey';

/// One concrete editable field, expanded from the schema.
class EditorField extends Equatable {
  const EditorField({
    required this.key,
    required this.cardId,
    this.multiline = false,
    this.visibility = FieldVisibility.inPage,
    this.listKey,
    this.rowId,
    this.sharedValue = false,
  });

  /// Stable field key, e.g. `cabin.hero.title`,
  /// `home.highlights.a1b2c3d4.description`.
  final String key;

  /// The card this field renders on.
  final String cardId;
  final bool multiline;
  final FieldVisibility visibility;

  /// The list this field is a row of; null for a plain field.
  final String? listKey;

  /// The stable id of the row this field belongs to; null for a plain field.
  final String? rowId;

  /// Whether this field's value is language-independent — read-only in a
  /// target language and left out of the translation request.
  final bool sharedValue;

  @override
  List<Object?> get props => [
    key,
    cardId,
    multiline,
    visibility,
    listKey,
    rowId,
    sharedValue,
  ];
}

/// Expands one page's schema into concrete fields: plain fields as-is, list
/// rows one field per row id in [listOrder] (identity from the content, order
/// from the content). Media rows contribute their alt-text field; the image
/// keys themselves are not translatable text.
List<EditorField> effectiveFieldsFor(
  String pageKey,
  Map<String, List<String>> listOrder,
) {
  final fields = <EditorField>[];
  for (final card in kPageCards[pageKey] ?? const <EditorCard>[]) {
    for (final row in card.rows) {
      fields.addAll(_fieldsOfRow(row, card.id, listOrder));
    }
  }
  return fields;
}

List<EditorField> _fieldsOfRow(
  EditorRow row,
  String cardId,
  Map<String, List<String>> listOrder,
) {
  switch (row) {
    case FieldRow(:final key, :final multiline, :final visibility):
      return [
        EditorField(
          key: key,
          cardId: cardId,
          multiline: multiline,
          visibility: visibility,
        ),
      ];

    case ListRow(:final listKey, :final sub, :final multiline):
      return [
        for (final rowId in listOrder[listKey] ?? const <String>[])
          EditorField(
            key: listFieldKey(listKey, rowId, sub),
            cardId: cardId,
            multiline: multiline,
            listKey: listKey,
            rowId: rowId,
          ),
      ];

    case PairListRow(
      :final listKey,
      :final labelSub,
      :final valueSub,
      :final sharedValue,
      :final wideValue,
      :final fixedRows,
      :final fixedRowsAreValues,
    ):
      if (fixedRows != null) {
        // A fixed *value* row is one field on a scalar path; the label is a
        // system fact and not a field at all.
        if (fixedRowsAreValues) {
          return [
            for (final key in fixedRows)
              EditorField(
                key: key,
                cardId: cardId,
                listKey: listKey,
                rowId: key,
                multiline: wideValue,
                sharedValue: sharedValue,
              ),
          ];
        }
        // A fixed *slot* row has both fields; only the copy is the owner's.
        return [
          for (final slot in fixedRows) ...[
            EditorField(
              key: '$slot.$labelSub',
              cardId: cardId,
              listKey: listKey,
              rowId: slot,
            ),
            EditorField(
              key: '$slot.$valueSub',
              cardId: cardId,
              listKey: listKey,
              rowId: slot,
              multiline: wideValue,
              sharedValue: sharedValue,
            ),
          ],
        ];
      }
      return [
        for (final rowId in listOrder[listKey] ?? const <String>[]) ...[
          EditorField(
            key: listFieldKey(listKey, rowId, labelSub),
            cardId: cardId,
            listKey: listKey,
            rowId: rowId,
          ),
          EditorField(
            key: listFieldKey(listKey, rowId, valueSub),
            cardId: cardId,
            listKey: listKey,
            rowId: rowId,
            multiline: wideValue,
            sharedValue: sharedValue,
          ),
        ],
      ];

    case RowListRow(:final listKey, :final subs, :final media):
      return [
        for (final rowId in listOrder[listKey] ?? const <String>[]) ...[
          for (final sub in subs)
            EditorField(
              key: listFieldKey(listKey, rowId, sub.sub),
              cardId: cardId,
              multiline: sub.multiline,
              listKey: listKey,
              rowId: rowId,
            ),
          // The photo is language-independent; its alt text is not (§C.4).
          if (media)
            EditorField(
              key: listFieldKey(listKey, rowId, 'alt'),
              cardId: cardId,
              listKey: listKey,
              rowId: rowId,
            ),
        ],
      ];

    case GroupListRow(
      :final listKey,
      :final titleSub,
      :final itemsListKey,
      :final itemsSub,
      :final introSub,
      :final fixedTitles,
    ):
      final fields = <EditorField>[];
      for (final groupId in listOrder[listKey] ?? const <String>[]) {
        // A fixed group's title is a label, not a field.
        if (!fixedTitles) {
          fields.add(
            EditorField(
              key: listFieldKey(listKey, groupId, titleSub),
              cardId: cardId,
              listKey: listKey,
              rowId: groupId,
            ),
          );
        }
        if (introSub != null) {
          fields.add(
            EditorField(
              key: listFieldKey(listKey, groupId, introSub),
              cardId: cardId,
              multiline: true,
              listKey: listKey,
              rowId: groupId,
            ),
          );
        }
        final itemsKey = groupItemsListKey(listKey, groupId, itemsListKey);
        for (final itemId in listOrder[itemsKey] ?? const <String>[]) {
          fields.add(
            EditorField(
              key: listFieldKey(itemsKey, itemId, itemsSub),
              cardId: cardId,
              listKey: itemsKey,
              rowId: itemId,
            ),
          );
        }
      }
      return fields;

    case MediaRow(:final altFieldKey):
      // The files are language-independent; the summarizing alt text is the
      // translatable field of a media row.
      return [EditorField(key: altFieldKey, cardId: cardId)];

    case ExternalRow():
      // Read-only: its content belongs to another system.
      return const [];
  }
}

/// Every repeatable list in the schema, with the row type that owns it — what
/// the repository enumerates to learn which lists to read row ids for.
List<({String listKey, String? itemsListKey})> get kSchemaLists => [
  for (final cards in kPageCards.values)
    for (final card in cards)
      for (final row in card.rows)
        ...switch (row) {
          ListRow(:final listKey) => [(listKey: listKey, itemsListKey: null)],
          PairListRow(:final listKey, :final fixedRows) =>
            fixedRows == null ? [(listKey: listKey, itemsListKey: null)] : [],
          RowListRow(:final listKey) => [
            (listKey: listKey, itemsListKey: null),
          ],
          GroupListRow(:final listKey, :final itemsListKey) => [
            (listKey: listKey, itemsListKey: itemsListKey),
          ],
          FieldRow() || MediaRow() || ExternalRow() => const [],
        },
];

/// The schema row that owns a list key, or null when it is unknown. Used by
/// the cubit to learn a list's subfield and by the renderer to look up limits.
EditorRow? schemaRowForList(String listKey) {
  for (final cards in kPageCards.values) {
    for (final card in cards) {
      for (final row in card.rows) {
        switch (row) {
          case ListRow(listKey: final key):
          case PairListRow(listKey: final key):
          case RowListRow(listKey: final key):
          case GroupListRow(listKey: final key):
            if (key == listKey) return row;
            // A group's nested item list is addressed through its group.
            if (row is GroupListRow &&
                listKey.startsWith('${row.listKey}.') &&
                listKey.endsWith('.${row.itemsListKey}')) {
              return row;
            }
          case FieldRow():
          case MediaRow():
          case ExternalRow():
            break;
        }
      }
    }
  }
  return null;
}
