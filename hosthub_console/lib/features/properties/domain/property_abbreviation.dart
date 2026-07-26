/// The two-letter code that stands in for a property in the sidebar chip and in
/// table cells.
///
/// It is an identifier in the interface, not decoration: two properties sharing
/// one would make a row lie about which property it belongs to. So the account's
/// codes are assigned together ([uniquePropertyAbbreviations]) rather than each
/// property deriving its own in isolation.
library;

/// A property's code, derived from its name.
///
/// The initials of the first two words ("Trysil Panorama" → `TP`), the first two
/// letters when there is only one word ("Fjordhus" → `FJ`), and `??` for a name
/// with no letters at all — a placeholder is better than an empty chip that
/// looks like a rendering fault.
String propertyAbbreviationFor(String name) {
  // Any run of non-letters is a word break, so a hyphen, an en dash, a slash or
  // a bracket all separate initials the way a space does.
  final words = name
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) return '??';
  if (words.length == 1) {
    final word = words.first;
    return (word.length == 1 ? '$word$word' : word.substring(0, 2))
        .toUpperCase();
  }
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}

/// Codes for a whole account, guaranteed distinct.
///
/// Properties are keyed by id and read in the order given, so the codes are
/// stable as long as the account's order is: the first "Voss Fjordhus" keeps
/// `VF` when a second one arrives. A collision takes the next letter of the
/// second word, then falls back to a digit — `VF`, `VO`, `V2` — because the
/// owner can rename or (later) edit the code, and until then the chips still
/// have to be told apart.
Map<int, String> uniquePropertyAbbreviations(
  Iterable<({int id, String name})> properties,
) {
  final assigned = <int, String>{};
  final taken = <String>{};

  for (final property in properties) {
    final preferred = propertyAbbreviationFor(property.name);
    var code = preferred;
    if (taken.contains(code)) {
      code = _firstFreeAlternative(property.name, preferred, taken);
    }
    taken.add(code);
    assigned[property.id] = code;
  }

  return assigned;
}

/// A distinct code for a name whose natural one is already taken.
String _firstFreeAlternative(String name, String preferred, Set<String> taken) {
  final first = preferred[0];

  // Later letters of the name, so the code still reads as an abbreviation of it.
  for (final letter in _lettersOnly(
    name.replaceAll(' ', ''),
  ).substring(1).split('')) {
    final candidate = '$first$letter'.toUpperCase();
    if (!taken.contains(candidate)) return candidate;
  }

  // Nothing left to spell with: number them.
  for (var digit = 2; digit <= 9; digit++) {
    final candidate = '$first$digit';
    if (!taken.contains(candidate)) return candidate;
  }

  return preferred;
}

String _lettersOnly(String value) =>
    value.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
