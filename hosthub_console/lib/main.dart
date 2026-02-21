import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:app_errors/supabase_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hosthub_console/app/app.dart';
import 'package:hosthub_console/app/bootstrap/bootstrap.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppErrors.configure(
      adapters: const [supabaseAdapter],
      showDebugDetails: true,
      errorPresenter: styledAppErrorPresenter,
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
  }, (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'hosthub_console',
        context: ErrorDescription('while running app zone'),
      ),
    );
  });
}
