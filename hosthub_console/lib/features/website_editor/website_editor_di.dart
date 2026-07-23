import 'package:hosthub_console/core/core.dart';

import 'data/translation_service.dart';

/// Registers the website-editor dependencies. The translation service is a
/// singleton so the real (Edge-Function-backed) implementation can be swapped
/// in without touching the cubit; the cubit itself is provided per-route via
/// `BlocProvider` reading this service.
void registerWebsiteEditorDependencies() {
  if (!I.isRegistered<TranslationService>()) {
    I.registerSingleton<TranslationService>(const SeedTranslationService());
  }
}
