import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hosthub_console/app/shell/presentation/widgets/menu_item.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/section_scaffold.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/calendar/calendar.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/revenue/revenue.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';
import 'package:hosthub_console/features/server_settings/server_settings.dart';
import 'package:hosthub_console/features/sites/sites.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

class HosthubRouter {
  static GoRouter create({
    required Listenable refreshListenable,
    required GoRouterRedirect redirect,
    required AuthUiPaths authUiPaths,
    required String homePath,
    required String authLoadingPath,
    required AuthLoginErrorDisplayMode authErrorDisplayMode,
    required Iterable<DemoCredential> demoCredentials,
    bool debugLogDiagnostics = false,
  }) {
    return GoRouter(
      initialLocation: homePath,
      refreshListenable: refreshListenable,
      redirect: redirect,
      routes: [
        GoRoute(path: '/', redirect: (context, state) => homePath),
        GoRoute(
          path: authLoadingPath,
          builder: (context, state) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        GoRoute(
          path: authUiPaths.login,
          builder: (context, state) => AuthLoginPage(
            variant: AuthLayoutVariant.web,
            errorDisplayMode: authErrorDisplayMode,
            demoCredentials: demoCredentials.toList(growable: false),
            onAuthenticated: (ctx) => ctx.go(homePath),
            onForgotPassword: (ctx) => ctx.push(authUiPaths.forgotPassword),
          ),
        ),
        GoRoute(
          path: authUiPaths.forgotPassword,
          builder: (context, state) => AuthForgotPasswordPage(
            variant: AuthLayoutVariant.web,
            onResetEmailSent: (ctx) => ctx.go(authUiPaths.resetPasswordSent),
          ),
        ),
        GoRoute(
          path: authUiPaths.resetPasswordSent,
          builder: (context, state) => AuthResetPasswordSentPage(
            variant: AuthLayoutVariant.web,
            onBackToLogin: (ctx) => ctx.go(authUiPaths.login),
          ),
        ),
        GoRoute(
          path: authUiPaths.verifyOtp,
          redirect: (_, state) => authUiPaths.verifyOtpToSetPasswordLocation(
            queryParameters: state.uri.queryParameters,
          ),
        ),
        GoRoute(
          path: authUiPaths.resetPasswordCode,
          builder: (context, state) => AuthResetPasswordCodePage(
            variant: AuthLayoutVariant.web,
            onPasswordUpdated: (ctx) => ctx.go(homePath),
          ),
        ),
        GoRoute(
          path: authUiPaths.resetPassword,
          builder: (context, state) => AuthResetPasswordRedirectPage(
            variant: AuthLayoutVariant.web,
            errorDisplayMode: authErrorDisplayMode,
            onPasswordUpdated: (ctx) => ctx.go(homePath),
            onBackToLogin: (ctx) => ctx.go(authUiPaths.login),
            onForgotPassword: (ctx) => ctx.go(authUiPaths.forgotPassword),
          ),
        ),
        GoRoute(
          path: authUiPaths.setPassword,
          builder: (context, state) => AuthResetPasswordRedirectPage(
            variant: AuthLayoutVariant.web,
            errorDisplayMode: authErrorDisplayMode,
            onPasswordUpdated: (ctx) => ctx.go(homePath),
            onBackToLogin: (ctx) => ctx.go(authUiPaths.login),
            onForgotPassword: (ctx) => ctx.go(authUiPaths.forgotPassword),
          ),
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
              path: homePath,
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
      debugLogDiagnostics: debugLogDiagnostics,
    );
  }
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
