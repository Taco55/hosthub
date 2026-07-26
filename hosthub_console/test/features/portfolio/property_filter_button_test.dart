import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';
import 'package:hosthub_console/features/portfolio/presentation/widgets/property_filter_button.dart';

/// The one control a portfolio screen's header carries. The button says what the
/// scope *is*, not what it does, so the current scope is readable without
/// opening it.
void main() {
  const account = [1, 2, 3, 4];
  const options = [
    PropertyFilterOption(id: 1, name: 'Trysil Panorama', abbreviation: 'TP'),
    PropertyFilterOption(id: 2, name: 'Hemsedal Lodge', abbreviation: 'HL'),
    PropertyFilterOption(id: 3, name: 'Geilo Fjellhytte', abbreviation: 'GF'),
    PropertyFilterOption(id: 4, name: 'Voss Fjordhus', abbreviation: 'VF'),
  ];

  final theme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final styledTheme = HosthubThemePreset.styledTheme(lightMaterialTheme: theme);

  Future<PropertySelection?> pump(
    WidgetTester tester,
    PropertySelection selection,
  ) async {
    PropertySelection? changed;
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: styledTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: Center(
            child: PropertyFilterButton(
              selection: selection,
              options: options,
              onChanged: (value) => changed = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return changed;
  }

  group('the label says what the scope is', () {
    testWidgets('everything selected reads "All properties"', (tester) async {
      await pump(tester, PropertySelection.all(account));

      expect(find.text('All properties'), findsOneWidget);
    });

    testWidgets('exactly one selected reads that property\'s name', (
      tester,
    ) async {
      await pump(
        tester,
        PropertySelection.of(account, selectedPropertyIds: const [3]),
      );

      expect(find.text('Geilo Fjellhytte'), findsOneWidget);
    });

    testWidgets('some selected reads the count out of the total', (
      tester,
    ) async {
      await pump(
        tester,
        PropertySelection.of(account, selectedPropertyIds: const [1, 3]),
      );

      expect(find.text('2 of 4 properties'), findsOneWidget);
    });
  });

  group('the menu', () {
    testWidgets('offers every property, with the selected ones checked', (
      tester,
    ) async {
      await pump(
        tester,
        PropertySelection.of(account, selectedPropertyIds: const [1, 3]),
      );

      await tester.tap(find.byType(StyledToolbarButton));
      await tester.pumpAndSettle();

      for (final option in options) {
        expect(find.text(option.name), findsWidgets, reason: option.name);
      }
      // The chips come along, so a property reads the same here as in the rail.
      expect(find.text('TP'), findsOneWidget);
      expect(find.text('VF'), findsOneWidget);
    });

    testWidgets('checking a property widens the selection', (tester) async {
      PropertySelection? changed;
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: const Locale('en'),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          builder: (context, child) => StyledWidgetsTheme(
            styledThemeData: styledTheme,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(
            body: Center(
              child: PropertyFilterButton(
                selection: PropertySelection.of(
                  account,
                  selectedPropertyIds: const [1],
                ),
                options: options,
                onChanged: (value) => changed = value,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(StyledToolbarButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hemsedal Lodge'));
      await tester.pumpAndSettle();

      expect(changed?.selectedPropertyIds, {1, 2});
    });

    testWidgets('"All properties" selects everything again', (tester) async {
      PropertySelection? changed;
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: const Locale('en'),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          builder: (context, child) => StyledWidgetsTheme(
            styledThemeData: styledTheme,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(
            body: Center(
              child: PropertyFilterButton(
                selection: PropertySelection.of(
                  account,
                  selectedPropertyIds: const [2],
                ),
                options: options,
                onChanged: (value) => changed = value,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(StyledToolbarButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All properties').last);
      await tester.pumpAndSettle();

      expect(changed?.isAll, isTrue);
    });

    testWidgets('unchecking the last property changes nothing', (tester) async {
      PropertySelection? changed;
      final single = PropertySelection.of(
        account,
        selectedPropertyIds: const [2],
      );
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: const Locale('en'),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          builder: (context, child) => StyledWidgetsTheme(
            styledThemeData: styledTheme,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(
            body: Center(
              child: PropertyFilterButton(
                selection: single,
                options: options,
                onChanged: (value) => changed = value,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(StyledToolbarButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hemsedal Lodge').last);
      await tester.pumpAndSettle();

      // A no-op, not an empty view.
      expect(changed, single);
      expect(changed!.selectedPropertyIds, {2});
    });
  });
}
