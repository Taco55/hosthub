
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hosthub_console/app/bootstrap/bloc_registry.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/auth/auth_di.dart';
import 'package:hosthub_console/features/cms/cms_di.dart';
import 'package:hosthub_console/features/profile/profile_di.dart';
import 'package:hosthub_console/features/properties/properties_di.dart';
import 'package:hosthub_console/features/server_settings/server_settings_di.dart';
import 'package:hosthub_console/features/users/users_di.dart';
import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/lodgify_di.dart';
import 'package:hosthub_console/core/services/services.dart';

void initializeAppConfig({
  required bool enableLogging,
  bool? enableApiLogger,
}) {
  AppConfig.initialize(
    clientAppKey: 'hosthub_console',
    deepLinkScheme: 'rentaladmin',
    enableLogging: enableLogging,
    enableApiLogger: enableApiLogger ?? enableLogging,
  );
}

Future<SupabaseClient> initializeSupabase() async {
  await Supabase.initialize(
    url: AppConfig.current.supabaseUrl.toString(),
    anonKey: AppConfig.current.supabaseAnonKey,
  );

  return Supabase.instance.client;
}

Future<void> registerCoreServices({required SharedPreferences prefs}) async {
  if (!I.isRegistered<LocalStorageManager>()) {
    I.registerSingleton<LocalStorageManager>(
      LocalStorageManager(prefs: prefs),
      signalsReady: true,
    );
  }
}

Future<void> registerFeatureServices({required SupabaseClient client}) async {
  registerServerSettingsDependencies(client);
  registerProfileDependencies(client);
  registerAuthDependencies(client);
  registerUsersDependencies(client);
  registerCmsDependencies(client);
  registerPropertiesDependencies(client);
  registerLodgifyDependencies();
}

void registerBlocs() {
  registerBlocLayer();
}
