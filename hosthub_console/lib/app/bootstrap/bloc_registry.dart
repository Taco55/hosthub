import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/app/bootstrap/app_bloc_observer.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/l10n/application/language_cubit.dart';

void registerBlocLayer() {
  // Compact, colored, one-line-per-transition logging (see AppBlocObserver).
  // Replaces Talker's boxed full-state output.
  if (AppConfig.current.enableLogging) {
    Bloc.observer = AppBlocObserver();
  }

  final languageCubit = LanguageCubit();
  final themeCubit = ThemeCubit();
  final themeModeCubit = ThemeModeCubit();
  final sessionManager = SessionManager(authService: I.get<AuthPort>());

  I.registerSingleton<LanguageCubit>(languageCubit, signalsReady: true);
  I.registerSingleton<ThemeCubit>(themeCubit, signalsReady: true);
  I.registerSingleton<ThemeModeCubit>(themeModeCubit, signalsReady: true);
  I.registerSingleton<SessionManager>(sessionManager, signalsReady: true);
}
