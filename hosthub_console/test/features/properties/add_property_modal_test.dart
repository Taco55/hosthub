import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/application/user_settings_cubit.dart';
import 'package:hosthub_console/features/user_settings/application/user_settings_state.dart';

/// Adding a property by hand: the manual step must create it, and — when the
/// write fails — must *say so where the button is*. The `+` on the nav tree's
/// property headings opens this flow from every screen in the console, so it
/// cannot rely on the Properties page being behind it to report the failure.
class _StubRepository implements PropertyRepository {
  _StubRepository({this.failing = false});

  final bool failing;
  final List<String> created = [];
  final List<PropertySummary> rows = [];

  @override
  Future<List<PropertySummary>> fetchProperties() async => List.of(rows);

  @override
  Future<PropertySummary> createProperty({
    required String name,
    String? lodgifyId,
  }) async {
    created.add(name);
    if (failing) {
      throw DomainError.of(
        DomainErrorCode.unknown,
        reason: DomainErrorReason.cannotSaveData,
        context: const {'op': 'createProperty'},
      );
    }
    final property = PropertySummary(id: rows.length + 1, name: name);
    rows.add(property);
    return property;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserSettingsCubit extends Cubit<UserSettingsState>
    implements UserSettingsCubit {
  _FakeUserSettingsCubit() : super(const UserSettingsState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The modal opened the way the nav tree's `+` opens it: from the shell, with
/// no page listening for the cubit's error.
Future<PropertyContextCubit> pumpAddProperty(
  WidgetTester tester, {
  required _StubRepository repository,
}) async {
  await tester.binding.setSurfaceSize(const Size(1180, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(resetAppErrorDedupForTesting);

  final propertyContext = PropertyContextCubit(repository: repository);
  final settings = _FakeUserSettingsCubit();
  addTearDown(propertyContext.close);
  addTearDown(settings.close);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<PropertyContextCubit>.value(value: propertyContext),
        BlocProvider<UserSettingsCubit>.value(value: settings),
      ],
      child: MaterialApp(
        theme: lightTheme,
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          AppErrorLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: HosthubThemePreset.styledTheme(
            lightMaterialTheme: lightTheme,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => showAddPropertyModal(context),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return propertyContext;
}

/// Through the root step into the manual one, and press *Create*.
Future<S> createManually(WidgetTester tester, {String name = 'test'}) async {
  final s = S.of(tester.element(find.byType(Scaffold).first));
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.tap(find.text(s.addPropertyManualTitle).last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, name);
  await tester.pumpAndSettle();
  await tester.tap(find.text(s.addPropertyManualAction));
  // Not pumpAndSettle: a failure leaves an error dialog awaiting dismissal
  // while the footer button still spins, so nothing ever settles.
  for (var frame = 0; frame < 6; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return s;
}

void main() {
  testWidgets('a name creates the property and closes the modal', (
    tester,
  ) async {
    final repository = _StubRepository();
    final propertyContext = await pumpAddProperty(
      tester,
      repository: repository,
    );

    final s = await createManually(tester);

    expect(repository.created, ['test']);
    expect(find.text(s.addPropertyManualTitle), findsNothing);
    expect(propertyContext.state.properties.single.name, 'test');
    expect(propertyContext.state.currentProperty?.name, 'test');
  });

  testWidgets('a failed create is reported here, not silently swallowed', (
    tester,
  ) async {
    final repository = _StubRepository(failing: true);
    final propertyContext = await pumpAddProperty(
      tester,
      repository: repository,
    );

    final s = await createManually(tester);

    // The dialog is the point: opened from the nav tree there is no page
    // listener, so without this the button looks broken.
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextButton),
      ).last,
    );
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Still on the step, with the name intact, so a retry costs one tap.
    expect(find.text(s.addPropertyManualTitle), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'test',
    );
    // Shown once, and consumed: no stale error left for Properties to raise
    // again the next time it is opened.
    expect(propertyContext.state.error, isNull);
  });
}
