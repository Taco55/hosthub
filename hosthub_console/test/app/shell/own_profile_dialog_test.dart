import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/application/sidebar_mode_cubit.dart';
import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/app/shell/presentation/dialogs/own_profile_dialog.dart';
import 'package:hosthub_console/core/l10n/application/language_cubit.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

/// Watch-only stand-ins: the dialog reads state and calls the recorded
/// methods; everything else is unreachable in these tests.
class _FakeProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _FakeProfileCubit() : super(const ProfileState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserSettingsCubit extends Cubit<UserSettingsState>
    implements UserSettingsCubit {
  _FakeUserSettingsCubit() : super(const UserSettingsState());

  final List<String> languageChanges = [];

  @override
  Future<void> changeLanguage(String languageCode) async {
    languageChanges.add(languageCode);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records every member access so tests can prove the dialog never touches
/// the property-scope site context (interface language is user scope only).
class _FakeSiteContextCubit extends Cubit<SiteContextState>
    implements SiteContextCubit {
  _FakeSiteContextCubit() : super(const SiteContextState());

  final List<Symbol> invocations = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    invocations.add(invocation.memberName);
    return super.noSuchMethod(invocation);
  }
}

const _profile = Profile(id: 'p1', email: 'marta@trysilpanorama.com');

Future<
  ({
    _FakeUserSettingsCubit userSettings,
    SidebarModeCubit sidebarMode,
    _FakeSiteContextCubit siteContext,
  })
>
pumpProfileDialog(
  WidgetTester tester, {
  Size surface = const Size(1360, 880),
}) async {
  // Both are needed: setSurfaceSize drives layout, view.physicalSize drives
  // MediaQuery (the desktop-breakpoint check reads the latter).
  await tester.binding.setSurfaceSize(surface);
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final profileCubit = _FakeProfileCubit();
  final userSettingsCubit = _FakeUserSettingsCubit();
  final languageCubit = LanguageCubit();
  final sidebarModeCubit = SidebarModeCubit();
  final siteContextCubit = _FakeSiteContextCubit();
  addTearDown(profileCubit.close);
  addTearDown(userSettingsCubit.close);
  addTearDown(languageCubit.close);
  addTearDown(sidebarModeCubit.close);
  addTearDown(siteContextCubit.close);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final styledTheme = HosthubThemePreset.styledTheme(
    lightMaterialTheme: lightTheme,
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<UserSettingsCubit>.value(value: userSettingsCubit),
        BlocProvider<LanguageCubit>.value(value: languageCubit),
        BlocProvider<SidebarModeCubit>.value(value: sidebarModeCubit),
        BlocProvider<SiteContextCubit>.value(value: siteContextCubit),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: styledTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    showOwnProfileDialog(context, profile: _profile),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  return (
    userSettings: userSettingsCubit,
    sidebarMode: sidebarModeCubit,
    siteContext: siteContextCubit,
  );
}

void main() {
  testWidgets(
    'profile modal shows a Preferences section with the interface-language '
    'dropdown and the compact-side-menu switch on desktop',
    (tester) async {
      await pumpProfileDialog(tester);

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Interface language'), findsOneWidget);
      expect(find.text('Compact side menu'), findsOneWidget);
      expect(find.byType(StyledSwitchTile), findsOneWidget);
    },
  );

  testWidgets('compact-side-menu switch drives SidebarModeCubit', (
    tester,
  ) async {
    final cubits = await pumpProfileDialog(tester);
    expect(cubits.sidebarMode.state, StyledSideMenuMode.expanded);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(cubits.sidebarMode.state, StyledSideMenuMode.compact);
  });

  testWidgets('picking another interface language persists via '
      'UserSettingsCubit.changeLanguage', (tester) async {
    final cubits = await pumpProfileDialog(tester);

    // Open the dropdown on the interface-language tile and pick Dutch.
    await tester.tap(
      find
          .descendant(
            of: find.byType(StyledSelectionTile<String>),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('NL').last);
    await tester.pumpAndSettle();

    expect(cubits.userSettings.languageChanges, ['nl']);
    // Interface language is user scope: the change must never reach the
    // property-scope site context (source language stays untouched).
    expect(cubits.siteContext.invocations, isEmpty);
  });

  testWidgets(
    'compact-side-menu switch is hidden below the desktop breakpoint',
    (tester) async {
      await pumpProfileDialog(tester, surface: const Size(900, 800));

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Compact side menu'), findsNothing);
    },
  );
}
