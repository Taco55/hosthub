import 'dart:convert';

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

/// A repeatable list of fields keyed `<listKey>.<row>`.
///
/// The number of rows is derived from the content, never stored in the
/// schema: `max(minRows, rows present in the source)`.
class ListRow extends EditorRow {
  const ListRow(
    this.listKey, {
    this.minRows = 1,
    this.multiline = false,
    this.repeatable = false,
  });

  /// Prefix of the row keys (`highlights` -> `highlights.0`, `highlights.1`).
  final String listKey;

  /// Rows the list always shows, even when the content has fewer.
  final int minRows;
  final bool multiline;

  /// Whether the owner can add and reorder rows in the editor.
  final bool repeatable;
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
        FieldRow('hero.headline'),
        FieldRow('hero.subtitle', multiline: true),
      ],
    ),
    EditorCard(
      id: 'highlights',
      rows: [ListRow('highlights', minRows: 2, repeatable: true)],
    ),
    EditorCard(
      id: 'content',
      rows: [
        ListRow('chalet.description', multiline: true),
        ListRow('chalet.experience', minRows: 2),
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
/// or one row of a [ListRow] (`highlights.2`).
class EditorField extends Equatable {
  const EditorField({
    required this.key,
    required this.cardId,
    this.multiline = false,
    this.listKey,
  });

  /// Stable field key, e.g. `hero.headline`, `highlights.0`.
  final String key;

  /// The card this field renders on.
  final String cardId;
  final bool multiline;

  /// The list this field is a row of; null for a plain field.
  final String? listKey;

  @override
  List<Object?> get props => [key, cardId, multiline, listKey];
}

/// Number of `<listKey>.<n>` rows present in [source], at least [minRows].
int listRowCount(String listKey, int minRows, Map<String, String> source) {
  var maxIndex = minRows - 1;
  final pattern = RegExp('^${RegExp.escape(listKey)}\\.(\\d+)\$');
  for (final key in source.keys) {
    final match = pattern.firstMatch(key);
    if (match != null) {
      final index = int.parse(match.group(1)!);
      if (index > maxIndex) maxIndex = index;
    }
  }
  return maxIndex + 1;
}

/// Expands one page's schema against the source content: plain fields as-is,
/// list rows one field per row present (minimum: the schema's [ListRow.minRows]).
List<EditorField> effectiveFieldsFor(
  String pageKey,
  Map<String, String> source,
) {
  final cards = kPageCards[pageKey] ?? const <EditorCard>[];
  return [
    for (final card in cards)
      for (final row in card.rows)
        ...switch (row) {
          FieldRow(:final key, :final multiline) => [
            EditorField(key: key, cardId: card.id, multiline: multiline),
          ],
          ListRow(:final listKey, :final minRows, :final multiline) => [
            for (var i = 0; i < listRowCount(listKey, minRows, source); i++)
              EditorField(
                key: '$listKey.$i',
                cardId: card.id,
                multiline: multiline,
                listKey: listKey,
              ),
          ],
        },
  ];
}

/// Every editable field across all pages at its schema minimum — the
/// source-independent enumeration (seed state, load-time field set).
List<EditorField> get kAllFields => [
  for (final page in kPageCards.keys) ...effectiveFieldsFor(page, const {}),
];

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

  /// Home-page field text per language.
  static const Map<String, Map<String, String>> home = {
    'nl': {
      'hero.headline': 'Jouw bergwoning in Trysil',
      'hero.subtitle':
          'Ski-in, ski-out luxe voor acht personen, op een steenworp van piste en bos.',
      'highlights.0': 'Direct de Trysilfjellet-pistes op.',
      'highlights.1': 'Ontspan na een dag op de berg.',
      'chalet.description.0':
          'Vrijstaand chalet in Fageråsen met privésauna en panoramisch uitzicht op de bergen.',
      'chalet.experience.0': 'Ski-in/ski-out via de transportpiste.',
      'chalet.experience.1': 'Sauna met uitzicht na een dag op de piste.',
      'practical.header.title': 'Praktische informatie',
      'practical.header.subtitle':
          'Alles voor aankomst, verblijf en vertrek op een rij.',
      'area.intro':
          'Trysil is het grootste skigebied van Noorwegen, met pistes voor elk niveau.',
      'contact.title': 'Neem contact op',
      'contact.subtitle': 'Vragen of boeken? We reageren snel.',
    },
    'en': {
      'hero.headline': 'Your mountain home in Trysil',
      'hero.subtitle':
          "Ski-in, ski-out luxury for eight, a stone's throw from the slopes and the forest.",
      'highlights.0': 'Straight onto the Trysilfjellet trails.',
      'highlights.1': 'Unwind after a day on the mountain.',
      'chalet.description.0':
          'Detached chalet in Fageråsen with a private sauna and panoramic mountain views.',
      'chalet.experience.0': 'Ski-in/ski-out via the transport track.',
      'chalet.experience.1': 'A sauna with a view after a day on the slopes.',
      'practical.header.title': 'Practical information',
      'practical.header.subtitle':
          'Everything for arrival, stay and departure at a glance.',
      'area.intro':
          "Trysil is Norway's largest ski resort, with slopes for every level.",
      'contact.title': 'Get in touch',
      'contact.subtitle': 'Questions or booking? We reply quickly.',
    },
    'no': {
      'hero.headline': 'Ditt fjellhjem i Trysil',
      'hero.subtitle':
          'Ski-in, ski-out-luksus for åtte, et steinkast fra bakkene og skogen.',
      'highlights.0': 'Rett ut i Trysilfjellet-løypene.',
      'highlights.1': 'Slapp av etter en dag på fjellet.',
      'chalet.description.0':
          'Frittliggende hytte i Fageråsen med privat badstue og panoramautsikt over fjellene.',
      'chalet.experience.0': 'Ski-in/ski-out via transportløypa.',
      'chalet.experience.1': 'Badstue med utsikt etter en dag i bakken.',
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
