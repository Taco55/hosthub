import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/user_settings/data/current_user_provider_supabase.dart';
import 'package:hosthub_console/features/user_settings/data/user_settings_repository.dart';
import 'package:hosthub_console/features/user_settings/data/user_settings_repository_supabase.dart';
import 'package:hosthub_console/features/user_settings/domain/current_user_provider.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';

void registerServerSettingsDependencies(SupabaseClient client) {
  if (!I.isRegistered<UserSettingsRepository>()) {
    I.registerSingleton<UserSettingsRepository>(
      UserSettingsRepositorySupabase(supabase: client),
      signalsReady: true,
    );
  }
  if (!I.isRegistered<CurrentUserProvider>()) {
    I.registerSingleton<CurrentUserProvider>(
      CurrentUserProviderSupabase(client: client),
      signalsReady: true,
    );
  }
  if (!I.isRegistered<AdminSettingsRepository>()) {
    I.registerSingleton<AdminSettingsRepository>(
      AdminSettingsRepository(client),
      signalsReady: true,
    );
  }
}
