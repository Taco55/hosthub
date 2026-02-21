import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/properties/data/property_repository.dart';

void registerPropertiesDependencies(SupabaseClient client) {
  if (!I.isRegistered<PropertyRepository>()) {
    I.registerSingleton<PropertyRepository>(
      PropertyRepository(supabase: client),
      signalsReady: true,
    );
  }
}
