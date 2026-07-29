import 'dart:convert';

export 'editor_schema.dart';

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
      'home.highlights.h1.description':
          'Straight onto the Trysilfjellet trails.',
      'home.highlights.h2.description': 'Unwind after a day on the mountain.',
      'cabin.description.d1.text':
          'Detached chalet in Fageråsen with a private sauna and panoramic mountain views.',
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
