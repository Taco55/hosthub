import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:auth_ui_flutter/auth_ui_flutter.dart'
    as auth_ui
    show AuthPackageVersionInfo;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/app/shell/application/sidebar_mode_cubit.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/menu_item.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/property_setup_gate.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/side_menu.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/reservations/reservations.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/presentation/pages/property_section_page.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/revenue/revenue.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';
import 'package:hosthub_console/features/server_settings/server_settings.dart';
import 'package:hosthub_console/features/sites/sites.dart';
import 'package:hosthub_console/features/team/team.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

class HosthubRouter {
  static GoRouter create({
    required Listenable refreshListenable,
    required GoRouterRedirect redirect,
    required AuthUiPaths authUiPaths,
    required String homePath,
    required String authLoadingPath,
    required AuthErrorDisplayMode authErrorDisplayMode,
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
            versionInfo: const _LoginVersionInfo(),
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
            // The tree's expansion and selection are read off the location, so
            // a deep link renders the same as having clicked there.
            final route = ConsoleRoute.parse(state.uri.path);
            return MultiBlocProvider(
              providers: [
                BlocProvider<ServerSettingsCubit>(
                  create: (context) => ServerSettingsCubit(
                    context.read<AdminSettingsRepository>(),
                  ),
                ),
                BlocProvider<ReservationsCubit>(
                  create: (context) => ReservationsCubit(
                    channelManagerRepository: context
                        .read<ChannelManagerRepository>(),
                  ),
                ),
                BlocProvider<NightlyRatesCubit>(
                  create: (context) => NightlyRatesCubit(
                    channelManagerRepository: context
                        .read<ChannelManagerRepository>(),
                  ),
                ),
                BlocProvider<CmsCubit>(
                  create: (context) =>
                      CmsCubit(cmsRepository: context.read<CmsRepository>()),
                ),
                BlocProvider<SiteMembersCubit>(
                  create: (_) => SiteMembersCubit(
                    repository: I.get<SiteMemberRepository>(),
                  ),
                ),
              ],
              // The shared shell owns the three-band responsive layout (full
              // menu / pinned icon rail / hamburger drawer) and hands the menu
              // its placement; the console only supplies the menu, the body and
              // its pin preference.
              child: BlocBuilder<SidebarModeCubit, StyledSideMenuMode>(
                builder: (context, sidebarMode) {
                  final shell = StyledSideMenuScaffold(
                    compact: sidebarMode == StyledSideMenuMode.compact,
                    // §7: the rail expands on hover after 0.35s. Long enough
                    // that crossing the left edge on the way somewhere else does
                    // not slide a panel over the page.
                    hoverIntentDelay: kSidebarHoverIntentDelay,
                    drawerMenuTooltip: context.s.menuTooltip,
                    // Nothing from the placement is needed here: the menu and
                    // its rows read it themselves.
                    menuBuilder: (context, _) => SideMenu(route: route),
                    bodyBuilder: (context, _) =>
                        PropertySetupGate(selectedItem: item, child: child),
                  );
                  // Text selection is a desktop affordance; on the web the
                  // browser already provides it.
                  return kIsWeb ? shell : SelectionArea(child: shell);
                },
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/sites',
              builder: (context, state) => const SitesPage(),
            ),
            GoRoute(
              path: '/website-editor',
              builder: (context, state) => WebsiteEditorPage(
                siteId: state.uri.queryParameters['siteId'],
              ),
            ),
            // Literal-suffixed site routes must precede the generic
            // '/sites/:siteName/:siteId' — go_router matches in order, so the
            // generic route would otherwise swallow '/sites/<id>/team' etc.
            // Legacy raw-JSON document editor, kept reachable for admin use.
            GoRoute(
              path: '/sites/:siteId/documents',
              builder: (context, state) {
                final siteId = state.pathParameters['siteId']!;
                return SiteContentPage(siteId: siteId);
              },
            ),
            GoRoute(
              path: '/sites/:siteId/team',
              builder: (context, state) {
                final siteId = state.pathParameters['siteId']!;
                final siteName = state.uri.queryParameters['name'] ?? '';
                context.read<SiteMembersCubit>().loadTeam(siteId);
                return SiteTeamPage(siteId: siteId, siteName: siteName);
              },
            ),
            GoRoute(
              path: '/sites/:siteId/settings',
              builder: (context, state) {
                final siteId = state.pathParameters['siteId']!;
                return SiteSettingsPage(siteId: siteId);
              },
            ),
            GoRoute(
              path: '/sites/:siteName/:siteId',
              builder: (context, state) {
                final siteId = state.pathParameters['siteId']!;
                return WebsiteEditorPage(siteId: siteId);
              },
            ),
            GoRoute(
              path: '/sites/:siteId',
              builder: (context, state) {
                final siteId = state.pathParameters['siteId']!;
                return WebsiteEditorPage(siteId: siteId);
              },
            ),
            // The tree's own routes. Property sections carry the property in
            // the path, so every one of them is deep-linkable and the sidebar
            // needs no state of its own to render them expanded.
            GoRoute(
              path: ConsoleRoute.propertiesPath,
              builder: (context, state) => const PropertiesPage(),
            ),
            GoRoute(
              path: '${ConsoleRoute.propertiesPath}/:propertyId',
              redirect: (context, state) {
                final propertyId = state.pathParameters['propertyId'];
                return propertyId == null
                    ? ConsoleRoute.propertiesPath
                    : '${ConsoleRoute.propertiesPath}/$propertyId/'
                          '${ConsoleRoute.propertySectionSegment(PropertySection.overview)}';
              },
            ),
            GoRoute(
              path: '${ConsoleRoute.propertiesPath}/:propertyId/:section',
              builder: (context, state) {
                final route = ConsoleRoute.parse(state.uri.path);
                final propertyId = route.propertyId;
                if (propertyId == null) return const PropertiesPage();
                return PropertySectionPage(
                  propertyId: propertyId,
                  section: route.propertySection ?? PropertySection.overview,
                );
              },
            ),
            GoRoute(
              path: ConsoleRoute.accountPath,
              builder: (context, state) => const UserSettingsPage(),
            ),
            // Kept so links and bookmarks from before the tree still land.
            GoRoute(
              path: '/settings',
              redirect: (context, state) => ConsoleRoute.accountPath,
            ),
            GoRoute(
              path: '/reservations',
              redirect: (context, state) => ConsoleRoute.bookingsPath,
            ),
            GoRoute(
              path: ConsoleRoute.bookingsPath,
              builder: (context, state) => const ReservationsPage(),
            ),
            GoRoute(
              path: ConsoleRoute.revenuePath,
              builder: (context, state) => const RevenuePage(),
            ),
            // The admin options are a section on Settings now; the old
            // destination keeps working as a link.
            GoRoute(
              path: '/admin-options',
              redirect: (context, state) => ConsoleRoute.accountPath,
            ),
          ],
        ),
      ],
      debugLogDiagnostics: debugLogDiagnostics,
    );
  }
}

/// Which destination the shell's non-tree concerns are on — the setup gate.
/// The tree itself reads [ConsoleRoute] instead.
MenuItem _selectedMenuItem(String path) {
  if (path.startsWith('/sites') || path.startsWith('/website-editor')) {
    return MenuItem.sites;
  }
  if (path.startsWith(ConsoleRoute.accountPath) ||
      path.startsWith('/settings')) {
    return MenuItem.settings;
  }
  if (path.startsWith(ConsoleRoute.bookingsPath) ||
      path.startsWith('/reservations')) {
    return MenuItem.reservations;
  }
  if (path.startsWith(ConsoleRoute.revenuePath)) {
    return MenuItem.revenue;
  }
  if (path.startsWith(ConsoleRoute.propertiesPath)) {
    return MenuItem.propertyDetails;
  }
  return MenuItem.sites;
}

class _LoginVersionInfo extends StatefulWidget {
  const _LoginVersionInfo();

  @override
  State<_LoginVersionInfo> createState() => _LoginVersionInfoState();
}

class _LoginVersionInfoState extends State<_LoginVersionInfo> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version = info?.version.trim() ?? '';
        if (version.isEmpty) return const SizedBox.shrink();

        return auth_ui.AuthPackageVersionInfo(
          version: version,
          buildNumber: info?.buildNumber,
          environment: AppConfig.current.environment.name.toUpperCase(),
          visible: kDebugMode,
        );
      },
    );
  }
}
