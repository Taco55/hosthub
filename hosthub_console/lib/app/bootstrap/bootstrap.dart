import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth_ui_flutter/auth_ui_flutter.dart';
import 'package:supabase_auth_flutter/supabase_auth_flutter.dart';
import 'package:hosthub_console/app/bootstrap/bloc_registry.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/auth/auth_di.dart';
import 'package:hosthub_console/features/cms/cms_di.dart';
import 'package:hosthub_console/features/messaging/messaging_di.dart';
import 'package:hosthub_console/features/profile/profile_di.dart';
import 'package:hosthub_console/features/properties/properties_di.dart';
import 'package:hosthub_console/features/server_settings/server_settings_di.dart';
import 'package:hosthub_console/features/users/users_di.dart';
import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/lodgify_di.dart';
import 'package:hosthub_console/features/team/team_di.dart';
import 'package:hosthub_console/features/website_editor/website_editor_di.dart';
import 'package:hosthub_console/core/services/services.dart';

void initializeAppConfig({required bool enableLogging, bool? enableApiLogger}) {
  AppConfig.initialize(
    clientAppKey: 'hosthub_console',
    deepLinkScheme: 'rentaladmin',
    enableLogging: enableLogging,
    enableApiLogger: enableApiLogger ?? enableLogging,
  );
}

/// Starts Supabase the one way `supabase_auth_flutter` allows: the client,
/// the exchange of a sign-in link the console was opened with (on
/// `/auth/callback`), and `AuthUi` with [ui] — in that order, before `runApp`.
Future<SupabaseAuthRuntime> initializeSupabase({required AuthUiConfig ui}) =>
    SupabaseAuth.initialize(
      url: AppConfig.current.supabaseUrl.toString(),
      publishableKey: AppConfig.current.supabaseAnonKey,
      callback: AuthCallbackLink(AppConfig.current.deepLinkScheme),
      ui: ui,
    );

Future<void> registerCoreServices({required SharedPreferences prefs}) async {
  if (!I.isRegistered<LocalStorageManager>()) {
    I.registerSingleton<LocalStorageManager>(
      LocalStorageManager(prefs: prefs),
      signalsReady: true,
    );
  }
}

Future<void> registerFeatureServices({
  required SupabaseAuthRuntime auth,
}) async {
  final client = auth.client;
  registerServerSettingsDependencies(client);
  registerProfileDependencies(client);
  registerAuthDependencies(auth);
  registerUsersDependencies(client);
  registerCmsDependencies(client);
  registerPropertiesDependencies(client);
  registerLodgifyDependencies();
  registerMessagingDependencies(client);
  registerTeamDependencies(client);
  registerWebsiteEditorDependencies();
}

void registerBlocs() {
  registerBlocLayer();
}
