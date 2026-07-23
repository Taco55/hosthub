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

/// Which card a field belongs to on a page.
enum EditorCard { hero, highlights }

/// Static definition of an editable field on a page.
class EditorFieldDef extends Equatable {
  const EditorFieldDef({
    required this.key,
    required this.card,
    this.multiline = false,
  });

  /// Stable field key, e.g. `hero.headline`, `highlights.0`.
  final String key;
  final EditorCard card;
  final bool multiline;

  @override
  List<Object?> get props => [key, card, multiline];
}

/// The pages of the website (tabs in the editor).
const List<String> kWebsitePages = [
  'home',
  'chalet',
  'practical',
  'area',
  'contact',
];

/// Field layout for the Home page (the page the design fully specifies).
const List<EditorFieldDef> kHomeFields = [
  EditorFieldDef(key: 'hero.headline', card: EditorCard.hero),
  EditorFieldDef(key: 'hero.subtitle', card: EditorCard.hero, multiline: true),
  EditorFieldDef(key: 'highlights.0', card: EditorCard.highlights),
  EditorFieldDef(key: 'highlights.1', card: EditorCard.highlights),
];

/// Computes the source-text hash used to detect stale auto translations.
/// sha256 hex — identical to the hash the translate-content Edge Function
/// stores in `site_translations.source_hash`, so staleness survives reloads.
String sourceHashOf(String text) => sha256.convert(utf8.encode(text)).toString();

/// Seed content for the Trysil Panorama Home page (from the design prototype).
/// Source = `nl`; `en`/`no` are the reference AI translations.
class WebsiteSeed {
  static const String propertyName = 'Trysil Panorama';
  static const String sourceLanguage = 'nl';
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
    },
    'en': {
      'hero.headline': 'Your mountain home in Trysil',
      'hero.subtitle':
          "Ski-in, ski-out luxury for eight, a stone's throw from the slopes and the forest.",
      'highlights.0': 'Straight onto the Trysilfjellet trails.',
      'highlights.1': 'Unwind after a day on the mountain.',
    },
    'no': {
      'hero.headline': 'Ditt fjellhjem i Trysil',
      'hero.subtitle':
          'Ski-in, ski-out-luksus for åtte, et steinkast fra bakkene og skogen.',
      'highlights.0': 'Rett ut i Trysilfjellet-løypene.',
      'highlights.1': 'Slapp av etter en dag på fjellet.',
    },
  };
}
