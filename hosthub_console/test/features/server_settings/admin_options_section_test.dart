import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/server_settings/presentation/widgets/admin_options_section.dart';

class _FakeServerSettingsCubit extends Cubit<ServerSettingsState>
    implements ServerSettingsCubit {
  _FakeServerSettingsCubit(super.initialState);

  final List<AdminSettings> saved = [];
  int loadCalls = 0;

  @override
  Future<void> load() async => loadCalls++;

  @override
  Future<void> save(AdminSettings settings) async {
    saved.add(settings);
    emit(
      state.copyWith(status: ServerSettingsStatus.ready, settings: settings),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _loaded = AdminSettings(
  id: 'admin',
  maintenanceModeEnabled: false,
  emailUserOnCreate: true,
);

Future<_FakeServerSettingsCubit> pumpSection(
  WidgetTester tester, {
  ServerSettingsState? state,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = _FakeServerSettingsCubit(
    state ??
        const ServerSettingsState(
          status: ServerSettingsStatus.ready,
          settings: _loaded,
        ),
  );
  addTearDown(cubit.close);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final styledTheme = HosthubThemePreset.styledTheme(
    lightMaterialTheme: lightTheme,
  );

  await tester.pumpWidget(
    BlocProvider<ServerSettingsCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: styledTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: AdminOptionsSection()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('renders the admin-only section with the server switches', (
    tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('Admin options'), findsOneWidget);
    expect(find.text('Admins only'), findsOneWidget);
    expect(find.text('Maintenance mode'), findsOneWidget);
    expect(find.text('Email new users'), findsOneWidget);
    expect(find.text('Create user'), findsNWidgets(2)); // tile title + button
  });

  testWidgets('loads the settings when the section arrives without them', (
    tester,
  ) async {
    final cubit = await pumpSection(
      tester,
      state: const ServerSettingsState.initial(),
    );

    expect(cubit.loadCalls, 1);
  });

  testWidgets('saving is only possible after a switch actually changed', (
    tester,
  ) async {
    final cubit = await pumpSection(tester);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(cubit.saved, isEmpty);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(cubit.saved, hasLength(1));
    expect(cubit.saved.single.maintenanceModeEnabled, isTrue);
    expect(cubit.saved.single.emailUserOnCreate, isTrue);
  });

  testWidgets('restore defaults resets the drafts without saving', (
    tester,
  ) async {
    final cubit = await pumpSection(
      tester,
      state: const ServerSettingsState(
        status: ServerSettingsStatus.ready,
        settings: AdminSettings(
          id: 'admin',
          maintenanceModeEnabled: true,
          emailUserOnCreate: false,
        ),
      ),
    );

    await tester.tap(find.text('Restore defaults'));
    await tester.pumpAndSettle();

    expect(cubit.saved, isEmpty);
    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.first.value, isFalse); // maintenance mode default
    expect(switches.last.value, isTrue); // email-on-create default

    // The reset is a draft, so it still has to be saved explicitly.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(cubit.saved.single.maintenanceModeEnabled, isFalse);
    expect(cubit.saved.single.emailUserOnCreate, isTrue);
  });
}
