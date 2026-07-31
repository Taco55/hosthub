import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/user_settings/presentation/dialogs/lodgify_api_key_modal.dart';

/// The footer is declared as an intent, so its callbacks get no controller
/// handed to them: the form resolves one from its own context instead. That only
/// works while the form is mounted below the modal that owns it, which is what
/// these tests pin — a broken lookup asserts rather than failing quietly.
Future<Future<LodgifyApiKeyResult?>> _open(
  WidgetTester tester, {
  required bool hasApiKey,
  String? currentApiKey,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final styledTheme = HosthubThemePreset.styledTheme(
    lightMaterialTheme: lightTheme,
  );

  late BuildContext pageContext;
  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      builder: (context, child) => StyledWidgetsTheme(
        styledThemeData: styledTheme,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            pageContext = context;
            return const SizedBox.expand();
          },
        ),
      ),
    ),
  );

  final result = showLodgifyApiKeyModal(
    pageContext,
    hasApiKey: hasApiKey,
    currentApiKey: currentApiKey,
  );
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('the primary saves what was typed', (tester) async {
    final result = await _open(tester, hasApiKey: false);

    await tester.enterText(find.byType(TextField), 'lg-secret');
    await tester.pumpAndSettle();

    // A first key is added, not saved.
    await tester.tap(find.widgetWithText(StyledButton, 'Add'));
    await tester.pumpAndSettle();

    final outcome = await result;
    expect(outcome?.apiKey, 'lg-secret');
    expect(outcome?.remove, isFalse);
  });

  testWidgets('an unchanged key closes without saving', (tester) async {
    final result = await _open(
      tester,
      hasApiKey: true,
      currentApiKey: 'lg-secret',
    );

    await tester.tap(find.widgetWithText(StyledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(await result, isNull);
  });

  testWidgets('the leading slot asks before removing, then removes', (
    tester,
  ) async {
    final result = await _open(
      tester,
      hasApiKey: true,
      currentApiKey: 'lg-secret',
    );

    // Low weight in the footer: a text button, not a filled red one beside Save.
    final footerDelete = find.widgetWithText(StyledTextButton, 'Delete');
    expect(footerDelete, findsOneWidget);

    await tester.tap(footerDelete);
    await tester.pumpAndSettle();

    // It asks first — destroying is never one tap from the save button. Only
    // there is destroying the primary action, so only there is it filled.
    expect(find.text('Remove the API key?'), findsOneWidget);
    final confirmDelete = find.byWidgetPredicate(
      (widget) =>
          widget is StyledButton &&
          widget.title == 'Delete' &&
          widget.variant == StyledButtonVariant.destructive,
    );
    expect(confirmDelete, findsOneWidget);
    await tester.tap(confirmDelete);
    await tester.pumpAndSettle();

    final outcome = await result;
    expect(outcome?.remove, isTrue);
    expect(outcome?.apiKey, isNull);
  });

  testWidgets('with no key stored there is nothing to remove', (tester) async {
    final result = await _open(tester, hasApiKey: false);

    expect(find.text('Delete'), findsNothing);

    await tester.tap(find.widgetWithText(StyledTextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(await result, isNull);
  });
}
