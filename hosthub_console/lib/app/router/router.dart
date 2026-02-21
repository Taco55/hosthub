import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/menu_item.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/section_scaffold.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/auth/presentation/auth_gate.dart';
import 'package:hosthub_console/features/auth/presentation/pages/password_reset_redirect_page.dart';
import 'package:hosthub_console/features/calendar/calendar.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/revenue/revenue.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';
import 'package:hosthub_console/features/server_settings/server_settings.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';
import 'package:hosthub_console/features/sites/sites.dart';
import 'package:hosthub_console/shared/domain/channel_manager/channel_manager_repository.dart';

GoRouter createRouter({required Listenable refreshListenable}) {
  return GoRouter(
    initialLocation: '/calendar',
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/calendar'),
      GoRoute(
        path: '/reset',
        builder: (context, state) {
          final payload = AuthRedirectPayload.fromUri(state.uri);
          return PasswordResetRedirectPage(payload: payload);
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
            child: AuthGate(
              child: SectionScaffold(
                selectedItem: item,
                builder: (_, __) => child,
              ),
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
            path: '/calendar',
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
