import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:auth_ui_flutter/auth_ui_flutter.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/app/shell/application/sidebar_mode_cubit.dart';
import 'package:hosthub_console/app/shell/navigation/navigation_guard_controller.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/menu_item.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/property_setup_gate.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/side_menu.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/messaging/application/inbox_cubit.dart';
import 'package:hosthub_console/features/messaging/domain/messaging_repository.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

/// Shared harness for the shell tests: watch-only stand-ins for the blocs the
/// menu reads, plus a pump that pins the surface size (the responsive
/// breakpoints read `MediaQuery`).
class _FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  _FakeAuthBloc() : super(const AuthState(status: AuthStatus.authenticated));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _FakeProfileCubit()
    : super(
        const ProfileState(
          profile: Profile(id: 'p1', email: 'marta@trysil.no'),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePropertyContextCubit extends Cubit<PropertyContextState>
    implements PropertyContextCubit {
  _FakePropertyContextCubit(List<PropertySummary> properties)
    : super(
        PropertyContextState(
          status: PropertyContextStatus.loaded,
          properties: properties,
          currentProperty: properties.isEmpty ? null : properties.first,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The account tier the rail's override badges resolve against. Zeroes: these
/// tests are about the tree, not about what a channel costs.
class _FakeAccountDefaultsCubit extends Cubit<AccountChannelDefaultsState>
    implements AccountChannelDefaultsCubit {
  _FakeAccountDefaultsCubit()
    : super(
        const AccountChannelDefaultsState(
          status: AccountChannelDefaultsStatus.loaded,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeServerSettingsCubit extends Cubit<ServerSettingsState>
    implements ServerSettingsCubit {
  _FakeServerSettingsCubit()
    : super(
        ServerSettingsState(
          status: ServerSettingsStatus.ready,
          settings: AdminSettings.defaults(),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Account settings as the rail needs them: only *Property toevoegen* reads
/// this, and only to decide whether the Lodgify route is offered.
class _FakeUserSettingsCubit extends Cubit<UserSettingsState>
    implements UserSettingsCubit {
  _FakeUserSettingsCubit({required bool lodgifyConnected})
    : super(
        UserSettingsState(
          status: UserSettingsStatus.ready,
          settings: UserSettings(
            profileId: 'p1',
            lodgifyConnected: lodgifyConnected,
          ),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A source with nothing in it: the rail's unread badge is absent, which is
/// what these tests assert about every state but the one that has messages.
class _SilentMessagingRepository implements MessagingRepository {
  @override
  final MessagingCapabilities capabilities = const MessagingCapabilities(
    sourceName: 'Testbron',
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The account the shell tests render: one property unless a test asks for more.
const List<PropertySummary> defaultShellProperties = [
  PropertySummary(id: 1, name: 'Trysil Panorama'),
];

final ThemeData _lightTheme = HosthubThemePreset.applyMaterialTheme(
  baseTheme: ThemeData.light(),
  brightness: Brightness.light,
);

final StyledWidgetsThemeData _styledTheme = HosthubThemePreset.styledTheme(
  lightMaterialTheme: _lightTheme,
);

/// The rail geometry and breakpoints under test, straight from the preset —
/// the same source the shell reads at runtime.
StyledSideMenuThemeData get sidebarTokens => _styledTheme.sideMenu;

Future<SidebarModeCubit> pumpShell(
  WidgetTester tester, {
  required Size surface,
  ConsoleRoute route = const ConsoleRoute.portfolio(PortfolioSection.bookings),
  List<PropertySummary> properties = defaultShellProperties,
  bool lodgifyConnected = true,
}) async {
  // setSurfaceSize drives layout, view.physicalSize drives MediaQuery — the
  // breakpoints read the latter.
  await tester.binding.setSurfaceSize(surface);
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final authBloc = _FakeAuthBloc();
  final profileCubit = _FakeProfileCubit();
  final propertyCubit = _FakePropertyContextCubit(properties);
  final serverSettingsCubit = _FakeServerSettingsCubit();
  final sidebarModeCubit = SidebarModeCubit();
  final inboxCubit = InboxCubit(repository: _SilentMessagingRepository());
  final accountDefaultsCubit = _FakeAccountDefaultsCubit();
  final userSettingsCubit = _FakeUserSettingsCubit(
    lodgifyConnected: lodgifyConnected,
  );
  final guard = NavigationGuardController();
  addTearDown(authBloc.close);
  addTearDown(profileCubit.close);
  addTearDown(propertyCubit.close);
  addTearDown(serverSettingsCubit.close);
  addTearDown(sidebarModeCubit.close);
  addTearDown(inboxCubit.close);
  addTearDown(accountDefaultsCubit.close);
  addTearDown(userSettingsCubit.close);
  addTearDown(guard.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<PropertyContextCubit>.value(value: propertyCubit),
        BlocProvider<ServerSettingsCubit>.value(value: serverSettingsCubit),
        BlocProvider<SidebarModeCubit>.value(value: sidebarModeCubit),
        BlocProvider<InboxCubit>.value(value: inboxCubit),
        BlocProvider<AccountChannelDefaultsCubit>.value(
          value: accountDefaultsCubit,
        ),
        BlocProvider<UserSettingsCubit>.value(value: userSettingsCubit),
        ChangeNotifierProvider<NavigationGuardController>.value(value: guard),
      ],
      child: MaterialApp(
        theme: _lightTheme,
        locale: const Locale('en'),
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: _styledTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        // Mirrors the shell composition in HosthubRouter's ShellRoute.
        home: BlocBuilder<SidebarModeCubit, StyledSideMenuMode>(
          builder: (context, sidebarMode) => StyledSideMenuScaffold(
            compact: sidebarMode == StyledSideMenuMode.compact,
            drawerMenuTooltip: context.s.menuTooltip,
            menuBuilder: (context, placement) => SideMenu(route: route),
            bodyBuilder: (context, layout) => const PropertySetupGate(
              selectedItem: MenuItem.sites,
              child: Text('body'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return sidebarModeCubit;
}
