import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/users/data/admin_user_repository.dart';

void registerUsersDependencies(SupabaseClient client) {
  if (!I.isRegistered<AdminUserRepository>()) {
    I.registerSingleton<AdminUserRepository>(
      AdminUserRepository(client),
      signalsReady: true,
    );
  }
}
