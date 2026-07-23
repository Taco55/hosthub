import '../domain/website_content.dart';

/// Translates page fields into a target language.
///
/// Implementations must be safe to call repeatedly; only [auto] fields are ever
/// passed in (the cubit skips locked fields). In production this is backed by a
/// Supabase Edge Function that holds the provider key (see `TRANSLATION.md`);
/// [SeedTranslationService] is a key-free fake used for local dev and tests.
abstract class TranslationService {
  /// Returns `{fieldKey: translatedText}` for the given source fields.
  Future<Map<String, String>> translateFields({
    required String sourceLanguage,
    required String targetLanguage,
    required Map<String, String> sourceFields,
  });
}

/// Key-free translation using the bundled seed translations. When a field's
/// current source text matches the seed source, it returns the reference seed
/// translation; otherwise it echoes the source text so edits stay visible.
class SeedTranslationService implements TranslationService {
  const SeedTranslationService();

  @override
  Future<Map<String, String>> translateFields({
    required String sourceLanguage,
    required String targetLanguage,
    required Map<String, String> sourceFields,
  }) async {
    final seedSource = WebsiteSeed.home[sourceLanguage] ?? const {};
    final seedTarget = WebsiteSeed.home[targetLanguage] ?? const {};
    return {
      for (final entry in sourceFields.entries)
        entry.key: (seedSource[entry.key] == entry.value)
            ? (seedTarget[entry.key] ?? entry.value)
            : entry.value,
    };
  }
}
