import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/core/l10n/application/language_cubit.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/user_settings/presentation/widgets/site_settings_sections.dart';

class _FakeSiteContextCubit extends Cubit<SiteContextState>
    implements SiteContextCubit {
  _FakeSiteContextCubit(super.initialState);

  final List<String> calls = [];

  @override
  Future<void> addLanguage(String code) async => calls.add('add:$code');

  @override
  Future<void> removeLanguage(String code) async => calls.add('remove:$code');

  @override
  Future<void> setSourceLanguage(String locale) async =>
      calls.add('source:$locale');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SiteContextState _state({
  List<String> locales = const ['nl', 'en', 'no'],
  String? primaryDomain = 'trysilpanorama.com',
  String? bookingUrl = 'https://book.trysilpanorama.com',
}) => SiteContextState(
  status: SiteContextStatus.loaded,
  site: SiteSummary(
    id: 'site-1',
    name: 'Trysil Panorama',
    defaultLocale: 'nl',
    locales: locales,
    timezone: 'Europe/Oslo',
    createdAt: DateTime.utc(2026, 2, 18),
  ),
  primaryDomain: primaryDomain,
  bookingUrl: bookingUrl,
);

Future<_FakeSiteContextCubit> pumpSections(
  WidgetTester tester,
  SiteContextState state,
) async {
  await tester.binding.setSurfaceSize(const Size(900, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = _FakeSiteContextCubit(state);
  final languageCubit = LanguageCubit();
  addTearDown(cubit.close);
  addTearDown(languageCubit.close);

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
        BlocProvider<SiteContextCubit>.value(value: cubit),
        BlocProvider<LanguageCubit>.value(value: languageCubit),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: styledTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildSiteSettingsSections(context, cubit.state),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('renders site details with name, domain and booking link', (
    tester,
  ) async {
    await pumpSections(tester, _state());

    // Section headers render sentence-case (theme: dark-blue 13/w600).
    expect(find.text('Site details'), findsOneWidget);
    expect(find.text('Trysil Panorama'), findsOneWidget);
    expect(find.text('trysilpanorama.com'), findsOneWidget);
    expect(find.text('https://book.trysilpanorama.com'), findsOneWidget);
  });

  testWidgets('empty domain and booking link show the dimmed placeholder', (
    tester,
  ) async {
    await pumpSections(tester, _state(primaryDomain: null, bookingUrl: null));

    expect(find.text('Not set'), findsNWidgets(2));
  });

  testWidgets(
    'language list marks the source (badge, no remove) and lets the other '
    'languages be removed after confirmation',
    (tester) async {
      final cubit = await pumpSections(tester, _state());

      expect(find.text('SOURCE'), findsOneWidget);
      // Two removable target languages → two delete buttons.
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.delete_outline).last);
      await tester.pumpAndSettle();
      // Confirmation dialog → confirm.
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(cubit.calls, contains('remove:no'));
    },
  );

  testWidgets('Add language offers the remaining catalog and adds the pick', (
    tester,
  ) async {
    final cubit = await pumpSections(tester, _state());

    await tester.tap(find.text('Add language'));
    await tester.pumpAndSettle();

    // Without the LocaleNames delegate both the tag and the label render the
    // upper-cased code.
    expect(find.text('DE'), findsWidgets);
    await tester.tap(find.text('DE').last);
    await tester.pumpAndSettle();

    expect(cubit.calls, contains('add:de'));
  });

  testWidgets(
    'adopt-interface-language action asks for confirmation and then sets '
    'the source language once',
    (tester) async {
      // Test platform locale is English; source is nl → adopt is enabled.
      final cubit = await pumpSections(tester, _state());

      expect(find.text('Use my interface language'), findsOneWidget);
      await tester.tap(find.text('Use my interface language'));
      await tester.pumpAndSettle();

      // Confirmation explains the re-translation consequence; cancel first.
      expect(find.textContaining('Change the source language'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cubit.calls, isEmpty);

      await tester.tap(find.text('Use my interface language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      expect(cubit.calls, ['source:en']);
    },
  );

  testWidgets('source dropdown is always visible and confirms the change', (
    tester,
  ) async {
    final cubit = await pumpSections(tester, _state());

    // The dropdown field shows the current source language.
    expect(find.text('Source language'), findsWidgets);

    // Open the dropdown on the source-language tile and pick Norwegian
    // (labels fall back to upper-cased codes without the names delegate).
    await tester.tap(find.text('NL').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('NO').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();

    expect(cubit.calls, ['source:no']);
  });

  testWidgets('no sections render when no site is linked', (tester) async {
    await pumpSections(
      tester,
      const SiteContextState(status: SiteContextStatus.loaded),
    );

    expect(find.text('Site details'), findsNothing);
    expect(find.text('Website languages'), findsNothing);
  });
}
