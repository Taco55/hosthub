import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// Per-(field, language) translation status.
///
/// * [auto] — machine-translated; always follows the source unless it is stale.
/// * [locked] — owner-edited by hand; never overwritten by (re)translation.
enum FieldTranslationStatus { auto, locked }

/// A single field's value in one target language, with its translation status
/// and the hash of the source text the [auto] value was generated from.
///
/// A field is *stale* when it is [auto] and [sourceHash] no longer matches the
/// hash of the current source text — i.e. the source changed after this auto
/// value was produced. Locked fields are never stale.
class TranslatedField extends Equatable {
  const TranslatedField({
    required this.value,
    required this.status,
    this.sourceHash,
  });

  final String value;
  final FieldTranslationStatus status;

  /// Hash of the source text this [auto] value was generated from (sha256
  /// hex, matching the translate-content Edge Function's cache key). Null for
  /// [locked] fields (their value is owner-authored, not source-derived).
  final String? sourceHash;

  bool get isLocked => status == FieldTranslationStatus.locked;
  bool get isAuto => status == FieldTranslationStatus.auto;

  bool isStaleFor(String currentSourceHash) =>
      isAuto && sourceHash != currentSourceHash;

  TranslatedField copyWith({
    String? value,
    FieldTranslationStatus? status,
    String? sourceHash,
  }) {
    return TranslatedField(
      value: value ?? this.value,
      status: status ?? this.status,
      sourceHash: sourceHash ?? this.sourceHash,
    );
  }

  @override
  List<Object?> get props => [value, status, sourceHash];
}

/// One row in a card's schema (the handoff's Part D vocabulary).
///
/// The schema is data, read by one renderer: what a card *is* lives here,
/// how it looks lives in the widget layer. A new field is a row in
/// [kPageCards] plus its path in `WebsiteContentRepository`, never a widget.
/// Labels are not part of the schema — they are localized content and resolve
/// through the ARB layer (`website_editor_strings.dart`).
sealed class EditorRow {
  const EditorRow();
}

/// A single field bound to one field key.
class FieldRow extends EditorRow {
  const FieldRow(this.key, {this.multiline = false});

  /// Stable field key, e.g. `hero.headline`.
  final String key;
  final bool multiline;
}

/// A repeatable list of fields keyed `<listKey>.<rowId>[.<sub>]`.
///
/// Which rows exist — and in what order — comes from the content
/// (`listOrder`), never from the schema: the row id is identity, the array
/// index is display order.
class ListRow extends EditorRow {
  const ListRow(
    this.listKey, {
    this.sub,
    this.multiline = false,
    this.repeatable = false,
  });

  /// Prefix of the row keys (`home.highlights` ->
  /// `home.highlights.<id>.description`).
  final String listKey;

  /// The row's editable subfield (`text`, `description`); appended to the
  /// field key. Null when the row itself is the value.
  final String? sub;
  final bool multiline;

  /// Whether the owner can add and reorder rows in the editor.
  final bool repeatable;
}

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

/// One card in the editor: an identity (icon + localized title resolve
/// through the presentation layer) and the rows it holds.
class EditorCard {
  const EditorCard({required this.id, required this.rows});

  /// Stable card id (`hero`, `highlights`, `content`, `contact`).
  final String id;
  final List<EditorRow> rows;
}

/// The pages of the website (tabs in the editor) — one tab per route the
/// public site actually serves. There is no chalet page and no contact page:
/// that content renders on the homepage (README fase 2, §0).
const List<String> kWebsitePages = ['home', 'practical', 'area', 'gallery'];

/// The editor's page schema. Field keys are globally unique; the mapping to
/// the site's document JSON lives in WebsiteContentRepository.
///
/// This phase-0 layout carries exactly the fields the editor had before it
/// became schema-driven; the full fase-2 card layout (README §A.1–A.4)
/// replaces the card contents later without touching the renderer.
const Map<String, List<EditorCard>> kPageCards = {
  'home': [
    EditorCard(
      id: 'hero',
      rows: [
        FieldRow('cabin.hero.title'),
        FieldRow('cabin.hero.subtitle', multiline: true),
      ],
    ),
    EditorCard(
      id: 'highlights',
      rows: [
        ListRow('home.highlights', sub: 'description', repeatable: true),
      ],
    ),
    EditorCard(
      id: 'content',
      rows: [
        ListRow('cabin.description', sub: 'text', multiline: true),
        ListRow('cabin.experience', sub: 'text'),
      ],
    ),
    EditorCard(
      id: 'contact',
      rows: [
        FieldRow('contact.title'),
        FieldRow('contact.subtitle', multiline: true),
      ],
    ),
  ],
  'practical': [
    EditorCard(
      id: 'content',
      rows: [
        FieldRow('practical.header.title'),
        FieldRow('practical.header.subtitle', multiline: true),
      ],
    ),
  ],
  'area': [
    EditorCard(
      id: 'content',
      rows: [FieldRow('area.intro', multiline: true)],
    ),
  ],
  // The gallery tab exists because /gallery exists; its fields (tagline,
  // the photo sets) arrive with the fase-2 cards.
  'gallery': [],
};

/// One concrete editable field, expanded from the schema: a [FieldRow] as-is,
/// or one row of a [ListRow] (`home.highlights.<id>.description`).
class EditorField extends Equatable {
  const EditorField({
    required this.key,
    required this.cardId,
    this.multiline = false,
    this.listKey,
    this.rowId,
  });

  /// Stable field key, e.g. `cabin.hero.title`,
  /// `home.highlights.a1b2c3d4.description`.
  final String key;

  /// The card this field renders on.
  final String cardId;
  final bool multiline;

  /// The list this field is a row of; null for a plain field.
  final String? listKey;

  /// The stable id of the row this field belongs to; null for a plain field.
  final String? rowId;

  @override
  List<Object?> get props => [key, cardId, multiline, listKey, rowId];
}

/// Expands one page's schema: plain fields as-is, list rows one field per row
/// id in [listOrder] (identity from the content, order from the content).
List<EditorField> effectiveFieldsFor(
  String pageKey,
  Map<String, List<String>> listOrder,
) {
  final cards = kPageCards[pageKey] ?? const <EditorCard>[];
  return [
    for (final card in cards)
      for (final row in card.rows)
        ...switch (row) {
          FieldRow(:final key, :final multiline) => [
            EditorField(key: key, cardId: card.id, multiline: multiline),
          ],
          ListRow(:final listKey, :final sub, :final multiline) => [
            for (final rowId in listOrder[listKey] ?? const <String>[])
              EditorField(
                key: listFieldKey(listKey, rowId, sub),
                cardId: card.id,
                multiline: multiline,
                listKey: listKey,
                rowId: rowId,
              ),
          ],
        },
  ];
}

/// Computes the source-text hash used to detect stale auto translations.
/// sha256 hex — identical to the hash the translate-content Edge Function
/// stores in `site_translations.source_hash`, so staleness survives reloads.
String sourceHashOf(String text) =>
    sha256.convert(utf8.encode(text)).toString();

/// The authoring language assumed before a site has said what its own is
/// (`sites.default_locale` is authoritative and arrives with the content).
const String kDefaultSourceLanguage = 'nl';

/// Seed content for the Trysil Panorama Home page (from the design prototype).
/// Source = `nl`; `en`/`no` are the reference AI translations.
class WebsiteSeed {
  static const String propertyName = 'Trysil Panorama';
  static const String sourceLanguage = kDefaultSourceLanguage;
  static const List<String> locales = ['nl', 'en', 'no'];

  static const Map<String, String> languageNames = {
    'nl': 'Dutch',
    'en': 'English',
    'no': 'Norwegian',
  };

  static const Map<String, String> languageShort = {
    'nl': 'NL',
    'en': 'EN',
    'no': 'NO',
  };

  /// Row ids per repeatable list, in display order. Fixed ids: the seed is a
  /// demo document, and its ids behave exactly like the generated ones.
  static const Map<String, List<String>> listOrder = {
    'home.highlights': ['h1', 'h2'],
    'cabin.description': ['d1'],
    'cabin.experience': ['e1', 'e2'],
  };

  /// Home-page field text per language.
  static const Map<String, Map<String, String>> home = {
    'nl': {
      'cabin.hero.title': 'Jouw bergwoning in Trysil',
      'cabin.hero.subtitle':
          'Ski-in, ski-out luxe voor acht personen, op een steenworp van piste en bos.',
      'home.highlights.h1.description': 'Direct de Trysilfjellet-pistes op.',
      'home.highlights.h2.description': 'Ontspan na een dag op de berg.',
      'cabin.description.d1.text':
          'Vrijstaand chalet in Fageråsen met privésauna en panoramisch uitzicht op de bergen.',
      'cabin.experience.e1.text': 'Ski-in/ski-out via de transportpiste.',
      'cabin.experience.e2.text': 'Sauna met uitzicht na een dag op de piste.',
      'practical.header.title': 'Praktische informatie',
      'practical.header.subtitle':
          'Alles voor aankomst, verblijf en vertrek op een rij.',
      'area.intro':
          'Trysil is het grootste skigebied van Noorwegen, met pistes voor elk niveau.',
      'contact.title': 'Neem contact op',
      'contact.subtitle': 'Vragen of boeken? We reageren snel.',
    },
    'en': {
      'cabin.hero.title': 'Your mountain home in Trysil',
      'cabin.hero.subtitle':
          "Ski-in, ski-out luxury for eight, a stone's throw from the slopes and the forest.",
      'home.highlights.h1.description': 'Straight onto the Trysilfjellet trails.',
      'home.highlights.h2.description': 'Unwind after a day on the mountain.',
      'cabin.description.d1.text':
          'Detached chalet in Fageråsen with a private sauna and panoramic mountain views.',
      'cabin.experience.e1.text': 'Ski-in/ski-out via the transport track.',
      'cabin.experience.e2.text': 'A sauna with a view after a day on the slopes.',
      'practical.header.title': 'Practical information',
      'practical.header.subtitle':
          'Everything for arrival, stay and departure at a glance.',
      'area.intro':
          "Trysil is Norway's largest ski resort, with slopes for every level.",
      'contact.title': 'Get in touch',
      'contact.subtitle': 'Questions or booking? We reply quickly.',
    },
    'no': {
      'cabin.hero.title': 'Ditt fjellhjem i Trysil',
      'cabin.hero.subtitle':
          'Ski-in, ski-out-luksus for åtte, et steinkast fra bakkene og skogen.',
      'home.highlights.h1.description': 'Rett ut i Trysilfjellet-løypene.',
      'home.highlights.h2.description': 'Slapp av etter en dag på fjellet.',
      'cabin.description.d1.text':
          'Frittliggende hytte i Fageråsen med privat badstue og panoramautsikt over fjellene.',
      'cabin.experience.e1.text': 'Ski-in/ski-out via transportløypa.',
      'cabin.experience.e2.text': 'Badstue med utsikt etter en dag i bakken.',
      'practical.header.title': 'Praktisk informasjon',
      'practical.header.subtitle':
          'Alt om ankomst, opphold og avreise på ett sted.',
      'area.intro':
          'Trysil er Norges største skianlegg, med løyper for alle nivåer.',
      'contact.title': 'Ta kontakt',
      'contact.subtitle': 'Spørsmål eller booking? Vi svarer raskt.',
    },
  };
}
