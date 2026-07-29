import 'package:flutter/foundation.dart';

/// What is true of an account rather than of one property.
///
/// The languages here are the **starting point of the next property**, never a
/// switch over the ones that exist: changing them writes one row and touches no
/// site. That is stated in the section footer too, because a language list that
/// looks global is read as global.
@immutable
class AccountSettings {
  const AccountSettings({
    this.sourceLanguage = 'nl',
    this.languages = const ['nl', 'en'],
    this.vatNumber,
  });

  static const AccountSettings defaults = AccountSettings();

  /// The language a new property's content is written in.
  final String sourceLanguage;

  /// The languages a new property's website is published in. Always contains
  /// [sourceLanguage] — [copyWith] keeps that true rather than trusting callers.
  final List<String> languages;

  /// The company or VAT number that goes on the invoice. One optional field:
  /// the business user needs a number on a receipt, not a second account type.
  final String? vatNumber;

  factory AccountSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return defaults;
    final source = (map['default_source_language'] as String?)
        ?.trim()
        .toLowerCase();
    final languages = (map['default_languages'] as List<dynamic>? ?? const [])
        .map((value) => value.toString().trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final vat = (map['vat_number'] as String?)?.trim();
    return AccountSettings(
      sourceLanguage: (source == null || source.isEmpty) ? 'nl' : source,
      languages: languages.isEmpty ? const ['nl', 'en'] : languages,
      vatNumber: (vat == null || vat.isEmpty) ? null : vat,
    );
  }

  Map<String, dynamic> toMap(String ownerProfileId) => {
    'owner_profile_id': ownerProfileId,
    'default_source_language': sourceLanguage,
    'default_languages': languages,
    'vat_number': vatNumber,
  };

  /// The languages a new property could still be given.
  List<String> addableFrom(Iterable<String> available) => [
    for (final code in available)
      if (!languages.contains(code)) code,
  ];

  AccountSettings copyWith({
    String? sourceLanguage,
    List<String>? languages,
    String? vatNumber,
    bool clearVatNumber = false,
  }) {
    final nextSource = sourceLanguage ?? this.sourceLanguage;
    final nextLanguages = [...(languages ?? this.languages)];
    // The source language is by definition one of the published ones; enforcing
    // it here means no caller can produce a list that contradicts itself.
    if (!nextLanguages.contains(nextSource))
      nextLanguages.insert(0, nextSource);
    return AccountSettings(
      sourceLanguage: nextSource,
      languages: List<String>.unmodifiable(nextLanguages),
      vatNumber: clearVatNumber ? null : (vatNumber ?? this.vatNumber),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountSettings &&
          runtimeType == other.runtimeType &&
          sourceLanguage == other.sourceLanguage &&
          listEquals(languages, other.languages) &&
          vatNumber == other.vatNumber;

  @override
  int get hashCode =>
      Object.hash(sourceLanguage, Object.hashAll(languages), vatNumber);

  @override
  String toString() =>
      'AccountSettings($sourceLanguage, ${languages.join('/')}'
      '${vatNumber == null ? '' : ', vat'})';
}
