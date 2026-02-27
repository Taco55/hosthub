import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/menu_item.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/section_scaffold.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/calendar/calendar.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/revenue/revenue.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';
import 'package:hosthub_console/features/server_settings/server_settings.dart';
import 'package:hosthub_console/features/sites/sites.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';

const _authLoadingPath = '/auth-loading';
const _verifySignUpPath = '/verify-signup';
const _magicLinkPath = '/magic-link';
const _calendarPath = '/calendar';
const _legacyResetPath = '/reset';

AuthUiPaths get _authUiPaths => AuthUi.config.paths;

const _debugDemoCredentials = <DemoCredential>[
  DemoCredential(
    shortcut: 'taco.',
    email: 'taco.kind@gmail.com',
    password: '1234abcd',
  ),
];

GoRouter createRouter({required Listenable refreshListenable}) {
  return GoRouter(
    initialLocation: _calendarPath,
    refreshListenable: refreshListenable,
    redirect: _handleAuthRedirect,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => _calendarPath),
      GoRoute(
        path: _authLoadingPath,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: _authUiPaths.login,
        builder: (context, state) => AuthLoginPage(
          variant: AuthLayoutVariant.web,
          errorDisplayMode: AppConfig.current.authErrorsInDialog
              ? AuthLoginErrorDisplayMode.dialogOnly
              : AuthLoginErrorDisplayMode.inlineExpectedAuthErrors,
          demoCredentials: kDebugMode ? _debugDemoCredentials : const [],
          onAuthenticated: (ctx) => ctx.go(_calendarPath),
          onForgotPassword: (ctx) => ctx.push(_authUiPaths.forgotPassword),
          onMagicLink: (ctx) => ctx.push(_magicLinkPath),
        ),
      ),
      GoRoute(
        path: _authUiPaths.forgotPassword,
        builder: (context, state) => AuthForgotPasswordPage(
          variant: AuthLayoutVariant.web,
          onResetEmailSent: (ctx) => ctx.go(_authUiPaths.resetPasswordSent),
        ),
      ),
      GoRoute(
        path: _authUiPaths.resetPasswordSent,
        builder: (context, state) => AuthResetPasswordSentPage(
          variant: AuthLayoutVariant.web,
          onBackToLogin: (ctx) => ctx.go(_authUiPaths.login),
        ),
      ),
      GoRoute(
        path: _magicLinkPath,
        builder: (context, state) => AuthMagicLinkPage(
          variant: AuthLayoutVariant.web,
          onMagicLinkSent: (ctx, email) {
            final encodedEmail = Uri.encodeComponent(email);
            ctx.go('${_authUiPaths.verifyOtp}?email=$encodedEmail');
          },
          onBackToLogin: (ctx) => ctx.go(_authUiPaths.login),
        ),
      ),
      GoRoute(
        path: _authUiPaths.verifyOtp,
        redirect: (_, state) => _authUiPaths.verifyOtpToSetPasswordLocation(
          queryParameters: state.uri.queryParameters,
        ),
      ),
      GoRoute(
        path: _verifySignUpPath,
        builder: (context, state) => BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == AuthStatus.authenticated,
          listener: (context, state) => context.go(_calendarPath),
          child: const AuthVerificationPage(variant: AuthLayoutVariant.web),
        ),
      ),
      GoRoute(
        path: _authUiPaths.resetPasswordCode,
        builder: (context, state) => AuthResetPasswordCodePage(
          variant: AuthLayoutVariant.web,
          onPasswordUpdated: (ctx) => ctx.go(_calendarPath),
        ),
      ),
      GoRoute(
        path: _authUiPaths.resetPassword,
        builder: (context, state) => AuthResetPasswordRedirectPage(
          variant: AuthLayoutVariant.web,
          errorDisplayMode: AppConfig.current.authErrorsInDialog
              ? AuthLoginErrorDisplayMode.dialogOnly
              : AuthLoginErrorDisplayMode.inlineExpectedAuthErrors,
          onPasswordUpdated: (ctx) => ctx.go(_calendarPath),
          onBackToLogin: (ctx) {
            ctx.read<AuthBloc>().add(const AuthEvent.logout());
            ctx.go(_authUiPaths.login);
          },
          onForgotPassword: (ctx) => ctx.go(_authUiPaths.forgotPassword),
        ),
      ),
      GoRoute(
        path: _authUiPaths.setPassword,
        builder: (context, state) => AuthResetPasswordRedirectPage(
          variant: AuthLayoutVariant.web,
          errorDisplayMode: AppConfig.current.authErrorsInDialog
              ? AuthLoginErrorDisplayMode.dialogOnly
              : AuthLoginErrorDisplayMode.inlineExpectedAuthErrors,
          onPasswordUpdated: (ctx) => ctx.go(_calendarPath),
          onBackToLogin: (ctx) {
            ctx.read<AuthBloc>().add(const AuthEvent.logout());
            ctx.go(_authUiPaths.login);
          },
          onForgotPassword: (ctx) => ctx.go(_authUiPaths.forgotPassword),
        ),
      ),
      GoRoute(
        path: _legacyResetPath,
        redirect: (context, state) {
          final query = state.uri.query;
          if (query.isEmpty) return _authUiPaths.resetPassword;
          return '${_authUiPaths.resetPassword}?$query';
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          final item = _selectedMenuItem(state.uri.path);
          return MultiBlocProvider(
            providers: [
              BlocProvider<ServerSettingsCubit>(
                create: (context) => ServerSettingsCubit(
                  context.read<AdminSettingsRepository>(),
                ),
              ),
              BlocProvider<CalendarCubit>(
                create: (context) => CalendarCubit(
                  channelManagerRepository: context
                      .read<ChannelManagerRepository>(),
                ),
              ),
              BlocProvider<CmsCubit>(
                create: (context) =>
                    CmsCubit(cmsRepository: context.read<CmsRepository>()),
              ),
            ],
            child: SectionScaffold(
              selectedItem: item,
              builder: (_, __) => child,
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/sites',
            builder: (context, state) => const SitesPage(),
          ),
          GoRoute(
            path: '/sites/:siteName/:siteId',
            builder: (context, state) {
              final siteId = state.pathParameters['siteId']!;
              return SiteContentPage(siteId: siteId);
            },
          ),
          GoRoute(
            path: '/sites/:siteId',
            builder: (context, state) {
              final siteId = state.pathParameters['siteId']!;
              return SiteContentPage(siteId: siteId);
            },
          ),
          GoRoute(
            path: '/properties/details',
            builder: (context, state) => const PropertyDetailsPage(),
          ),
          GoRoute(
            path: '/properties/pricing',
            builder: (context, state) => const PropertyPricingPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const UserSettingsPage(),
          ),
          GoRoute(
            path: _calendarPath,
            builder: (context, state) => const CalendarPage(),
          ),
          GoRoute(
            path: '/revenue',
            builder: (context, state) => const RevenuePage(),
          ),
          GoRoute(
            path: '/admin-options',
            builder: (context, state) => const ServerSettingsPage(),
          ),
        ],
      ),
    ],
    debugLogDiagnostics: AppConfig.current.enableRouterLogging,
  );
}

String? _handleAuthRedirect(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;
  final paths = _authUiPaths;
  return generateRedirectFromAuth(
    request: AuthRedirectRequest(
      path: state.uri.path,
      queryParameters: state.uri.queryParameters,
      authStatus: authState.status,
      authStep: authState.step,
    ),
    config: AuthRedirectConfig(
      homePath: _calendarPath,
      loadingPath: _authLoadingPath,
      paths: paths,
      extraAuthPaths: const {_verifySignUpPath, _magicLinkPath},
      unauthenticatedStepRules: {
        AuthenticatorStep.confirmSignUp: const AuthStepRedirectRule(
          targetPath: _verifySignUpPath,
        ),
        AuthenticatorStep.confirmSignInWithNewPassword: AuthStepRedirectRule(
          targetPath: paths.resetPasswordCode,
          allowedPaths: {paths.resetPassword, paths.setPassword},
        ),
      },
    ),
  );
}

MenuItem _selectedMenuItem(String path) {
  if (path.startsWith('/sites')) {
    return MenuItem.sites;
  }
  if (path.startsWith('/settings')) {
    return MenuItem.settings;
  }
  if (path.startsWith('/calendar')) {
    return MenuItem.calendar;
  }
  if (path.startsWith('/revenue')) {
    return MenuItem.revenue;
  }
  if (path.startsWith('/admin-options')) {
    return MenuItem.adminOptions;
  }
  if (path.startsWith('/properties/pricing')) {
    return MenuItem.pricing;
  }
  if (path.startsWith('/properties/details')) {
    return MenuItem.propertyDetails;
  }
  return MenuItem.sites;
}
