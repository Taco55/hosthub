import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:app_errors/supabase_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hosthub_console/app/app.dart';
import 'package:hosthub_console/app/bootstrap/bootstrap.dart';
import 'package:hosthub_console/core/widgets/auth/auth_ui_styled_overrides.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _authUiConfig = AuthUiConfig(usePathRouting: true);

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AuthUi.initialize(_authUiConfig);
      AppErrors.configure(
        adapters: const [supabaseAdapter],
        showDebugDetails: true,
        errorPresenter: styledAppErrorPresenter,
        onLogoutRequired: handleAppErrorLogout,
      );

      initializeAppConfig(
        enableLogging: kDebugMode,
        enableApiLogger: kDebugMode,
      );

      setupErrorWidget();

      final client = await initializeSupabase();
      final prefs = await SharedPreferences.getInstance();
      await registerCoreServices(prefs: prefs);
      await registerFeatureServices(client: client);
      registerBlocs();

      runApp(const ConsoleApp());
    },
    (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'hosthub_console',
          context: ErrorDescription('while running app zone'),
        ),
      );
    },
  );
}
