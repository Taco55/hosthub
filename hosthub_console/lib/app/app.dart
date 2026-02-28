import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/auth/auth_ui_styled_overrides.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/core/l10n/application/language_cubit.dart';

import 'package:hosthub_console/app/router/hosthub_router.dart';
import 'package:hosthub_console/app/router/go_router_refresh_stream.dart';
import 'package:hosthub_console/app/shell/navigation/navigation_guard_controller.dart';
import 'package:hosthub_console/app/session/session_bloc_listeners.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';
import 'package:hosthub_console/features/users/users.dart';

const _authLoadingPath = '/auth-loading';
const _calendarPath = '/calendar';

AuthUiPaths get _authUiPaths => AuthUi.config.paths;

AuthLoginErrorDisplayMode get _authErrorDisplayMode =>
    AppConfig.current.authErrorsInDialog
    ? AuthLoginErrorDisplayMode.dialogOnly
    : AuthLoginErrorDisplayMode.inlineExpectedAuthErrors;

const _debugDemoCredentials = <DemoCredential>[
  DemoCredential(
    shortcut: 'taco.',
    email: 'taco.kind@gmail.com',
    password: '1234abcd',
  ),
];

class ConsoleApp extends StatelessWidget {
  const ConsoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        RepositoryProvider<AdminUserRepository>.value(
          value: I.get<AdminUserRepository>(),
        ),
        RepositoryProvider<CmsRepository>.value(value: I.get<CmsRepository>()),
        RepositoryProvider<PropertyRepository>.value(
          value: I.get<PropertyRepository>(),
        ),
        RepositoryProvider<CurrentUserProvider>.value(
          value: I.get<CurrentUserProvider>(),
        ),
        RepositoryProvider<ChannelManagerRepository>.value(
          value: I.get<ChannelManagerRepository>(),
        ),
        RepositoryProvider<AdminSettingsRepository>.value(
          value: I.get<AdminSettingsRepository>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(authService: I.get<AuthPort>())
                ..add(const AuthEvent.appStart()),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            repository: I.get<UserSettingsRepository>(),
            currentUserProvider: I.get<CurrentUserProvider>(),
          ),
        ),
        BlocProvider<UserSettingsCubit>(
          create: (context) => UserSettingsCubit(
            userSettingsRepository: I.get<UserSettingsRepository>(),
            channelManagerRepository: I.get<ChannelManagerRepository>(),
            propertyRepository: I.get<PropertyRepository>(),
            settingsCubit: context.read<SettingsCubit>(),
            currentUserProvider: I.get<CurrentUserProvider>(),
          ),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(
            sessionManager: I.get<SessionManager>(),
            profileRepository: I.get<ProfileRepository>(),
          ),
        ),
        BlocProvider<PropertyContextCubit>(
          create: (_) =>
              PropertyContextCubit(repository: I.get<PropertyRepository>()),
        ),
        BlocProvider<LanguageCubit>.value(value: I.get<LanguageCubit>()),
        BlocProvider<ThemeCubit>.value(value: I.get<ThemeCubit>()),
        BlocProvider<ThemeModeCubit>.value(value: I.get<ThemeModeCubit>()),
        ChangeNotifierProvider<NavigationGuardController>(
          create: (_) => NavigationGuardController(),
        ),
      ],
      child: const _ConsoleRouterHost(),
    );
  }
}

class _ConsoleRouterHost extends StatefulWidget {
  const _ConsoleRouterHost();

  @override
  State<_ConsoleRouterHost> createState() => _ConsoleRouterHostState();
}

class _ConsoleRouterHostState extends State<_ConsoleRouterHost> {
  late final GoRouterRefreshStream _refresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();
    _refresh = GoRouterRefreshStream(authBloc.stream);

    final paths = _authUiPaths;
    _router = HosthubRouter.create(
      refreshListenable: _refresh,
      redirect: (_, state) {
        if (kDebugMode && state.uri.path == paths.login) {
          return null;
        }
        return generateRedirectFromAuthBloc(
          authBloc: authBloc,
          path: state.uri.path,
          queryParameters: state.uri.queryParameters,
          config: AuthRedirectConfig(
            homePath: _calendarPath,
            loadingPath: _authLoadingPath,
            paths: paths,
          ),
        );
      },
      authUiPaths: paths,
      homePath: _calendarPath,
      authLoadingPath: _authLoadingPath,
      authErrorDisplayMode: _authErrorDisplayMode,
      demoCredentials: kDebugMode ? _debugDemoCredentials : const [],
      debugLogDiagnostics: AppConfig.current.enableRouterLogging,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeCubit>().state;
    final locale = context.watch<LanguageCubit>().state;

    final lightTheme = HosthubThemePreset.applyMaterialTheme(
      baseTheme: ThemeData.light(),
      brightness: Brightness.light,
    );
    final darkTheme = HosthubThemePreset.applyMaterialTheme(
      baseTheme: ThemeData.dark(),
      brightness: Brightness.dark,
    );

    final localizationDelegates = <LocalizationsDelegate<dynamic>>[
      S.delegate,
      authUiDelegate,
      AppErrorLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      FormBuilderLocalizations.delegate,
      LocaleNamesLocalizationsDelegate(),
    ];
    final supportedLocales = <Locale>[
      ...S.delegate.supportedLocales,
      ...AppErrorLocalizations.supportedLocales,
    ];

    return ToastificationWrapper(
      child: MaterialApp.router(
        routerConfig: _router,
        builder: (context, child) {
          final styledTheme = HosthubThemePreset.styledTheme(
            lightMaterialTheme: lightTheme,
          );

          final appChild = SessionBlocListeners(
            child: child ?? const SizedBox.shrink(),
          );
          return StyledWidgetsTheme(
            styledThemeData: styledTheme,
            child: AuthUiOverrides.data(
              data: styledAuthUiOverrides,
              child: appChild,
            ),
          );
        },
        scrollBehavior: TouchAndMouseScrollBehavior(),
        title: "HostHub",
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        localizationsDelegates: localizationDelegates,
        locale: locale,
        supportedLocales: supportedLocales,
      ),
    );
  }
}
