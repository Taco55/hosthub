import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/shared/l10n/application/language_cubit.dart';

import 'package:talker_bloc_logger/talker_bloc_logger.dart';

void registerBlocLayer() {
  Bloc.observer = TalkerBlocObserver(
    settings: TalkerBlocLoggerSettings(
      enabled: true,
      printEventFullData: false,
      printStateFullData: true,
      printChanges: true,
      printClosings: true,
      printCreations: true,
      printEvents: true,
      printTransitions: true,
      // If you want log only AuthBloc transitions
      transitionFilter: (bloc, transition) =>
          bloc.runtimeType.toString() == 'AuthBloc',
      // If you want log only AuthBloc events
      eventFilter: (bloc, event) => bloc.runtimeType.toString() == 'AuthBloc',
    ),
  );

  // Bloc.observer = AppConfig.current.enableLogging ? AppBlocObserver() : const _SilentBlocObserver();

  final languageCubit = LanguageCubit();
  final themeCubit = ThemeCubit();
  final themeModeCubit = ThemeModeCubit();
  final sessionManager = SessionManager(authService: I.get<AuthPort>());

  I.registerSingleton<LanguageCubit>(languageCubit, signalsReady: true);
  I.registerSingleton<ThemeCubit>(themeCubit, signalsReady: true);
  I.registerSingleton<ThemeModeCubit>(themeModeCubit, signalsReady: true);
  I.registerSingleton<SessionManager>(sessionManager, signalsReady: true);
}
