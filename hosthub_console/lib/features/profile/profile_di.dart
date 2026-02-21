import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/profile/data/profile_repository.dart';

void registerProfileDependencies(SupabaseClient client) {
  if (!I.isRegistered<ProfileRepository>()) {
    I.registerSingleton<ProfileRepository>(
      ProfileRepository(supabase: client),
      signalsReady: true,
    );
  }
}
