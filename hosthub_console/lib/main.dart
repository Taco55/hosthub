import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:app_errors/supabase_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hosthub_console/app/app.dart';
import 'package:hosthub_console/app/bootstrap/bootstrap.dart';
import 'package:hosthub_console/core/config/app_environment.dart';
import 'package:hosthub_console/core/widgets/auth/auth_ui_styled_overrides.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _authUiConfig = AuthUiConfig(usePathRouting: true);

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Right-click has to reach Flutter's own Copy / Paste menu. Chrome's
      // menu knows nothing about a selection painted onto a canvas, so
      // leaving it in place means right-clicking selected text offers
      // everything except copying it. The trade is the browser menu itself
      // (Back, Reload, Inspect) — still reachable from the keyboard and the
      // Chrome menu. Drop this line to hand it back.
      if (kIsWeb) await BrowserContextMenu.disableContextMenu();
      AuthUi.initialize(_authUiConfig);
      AppErrors.configure(
        adapters: const [supabaseAdapter],
        showDebugDetails:
            AppEnvironment.fromEnvironment().showsErrorDiagnostics,
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
