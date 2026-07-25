import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:auth_ui_flutter/auth_ui_flutter.dart';

import 'package:hosthub_console/app/shell/application/sidebar_mode_cubit.dart';
import 'package:hosthub_console/app/shell/navigation/navigation_guard_controller.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/menu_item.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/section_scaffold.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';

/// Shared harness for the shell tests: watch-only stand-ins for the blocs the
/// [SectionScaffold] reads, plus a pump that pins the surface size (the
/// responsive breakpoints read `MediaQuery`).
class _FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  _FakeAuthBloc() : super(const AuthState(status: AuthStatus.authenticated));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _FakeProfileCubit()
    : super(
        const ProfileState(profile: Profile(id: 'p1', email: 'marta@trysil.no')),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePropertyContextCubit extends Cubit<PropertyContextState>
    implements PropertyContextCubit {
  _FakePropertyContextCubit()
    : super(
        const PropertyContextState(
          status: PropertyContextStatus.loaded,
          properties: [_property],
          currentProperty: _property,
        ),
      );

  static const _property = PropertySummary(id: 1, name: 'Trysil Panorama');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<SidebarModeCubit> pumpShell(
  WidgetTester tester, {
  required Size surface,
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
  final propertyCubit = _FakePropertyContextCubit();
  final sidebarModeCubit = SidebarModeCubit();
  final guard = NavigationGuardController();
  addTearDown(authBloc.close);
  addTearDown(profileCubit.close);
  addTearDown(propertyCubit.close);
  addTearDown(sidebarModeCubit.close);
  addTearDown(guard.dispose);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final styledTheme = HosthubThemePreset.styledTheme(
    lightMaterialTheme: lightTheme,
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<PropertyContextCubit>.value(value: propertyCubit),
        BlocProvider<SidebarModeCubit>.value(value: sidebarModeCubit),
        ChangeNotifierProvider<NavigationGuardController>.value(value: guard),
      ],
      child: MaterialApp(
        theme: lightTheme,
        locale: const Locale('en'),
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: styledTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        home: SectionScaffold(
          selectedItem: MenuItem.sites,
          builder: (context, isPinned) => const Text('body'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return sidebarModeCubit;
}

