import 'dart:convert';

extension ApiJsonDecode on Object? {
  Object? asDecodedJsonOrSelf() {
    // If the backend sometimes returns JSON as a string, decode it here.
    final v = this;
    if (v == null) return null;
    if (v is String) {
      final text = v.trim();
      if (text.isEmpty) return null;
      return jsonDecode(text);
    }
    return v;
  }
}

extension ApiJsonExtract on Object? {
  Map<String, dynamic> extractMap({List<String> fallbackKeys = const []}) {
    final v = this;
    if (v is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object.');
    }

    for (final key in fallbackKeys) {
      final nested = v[key];
      if (nested is Map<String, dynamic>) return nested;
    }

    return v;
  }

  List<dynamic> extractList({List<String> fallbackKeys = const []}) {
    final v = this;
    if (v is List) return v;

    if (v is Map<String, dynamic>) {
      for (final key in fallbackKeys) {
        final nested = v[key];
        if (nested is List) return nested;
      }
    }

    throw const FormatException('Expected JSON list.');
  }
}

extension ApiMapRead on Map<String, dynamic> {
  String? readString(List<String> keys) {
    for (final key in keys) {
      final value = this[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  DateTime? readDateTime(List<String> keys) {
    for (final key in keys) {
      final value = this[key];
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
