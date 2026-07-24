import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/editor_column.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/preview_pane.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/publish_modal.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// Pumps the full editor (editor column + preview) inside a BlocProvider at a
/// desktop-like size, under the app's real Material + StyledWidgets theming
/// (mirrors `app.dart`).
Future<SiteContentCubit> pumpEditor(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1360, 880));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = SiteContentCubit(
    translationService: const SeedTranslationService(),
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
    MaterialApp(
      theme: lightTheme,
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      builder: (context, child) => StyledWidgetsTheme(
        styledThemeData: styledTheme,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: BlocBuilder<SiteContentCubit, SiteContentState>(
            builder: (context, state) => StyledWebPageScaffold(
              // White editor column (design .editcol); preview stays bare.
              decorateLeftPane: true,
              panePadding: EdgeInsets.zero,
              decorateRightPane: false,
              title: 'Website',
              showHeader: false,
              padding: EdgeInsets.zero,
              paneGap: 0,
              leftPaneSize: const StyledPaneSize.fixed(512),
              leftChild: EditorColumn(state: state),
              rightChild: PreviewPane(state: state),
              showRightPane: true,
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
  testWidgets('source mode shows the Source chip and the source content', (
    tester,
  ) async {
    await pumpEditor(tester);

    expect(find.text('Source · NL'), findsOneWidget);
    // Headline field holds the Dutch source text.
    expect(find.text('Jouw bergwoning in Trysil'), findsWidgets);
    // No per-field status chips in source mode.
    expect(find.text('Locked'), findsNothing);
    expect(find.text('Auto'), findsNothing);
  });

  testWidgets(
    'switching preview locale to EN shows the editable translation form',
    (tester) async {
      final cubit = await pumpEditor(tester);

      cubit.setPreviewLanguage('en');
      await tester.pumpAndSettle();

      expect(find.text('Editing · EN'), findsOneWidget);
      // Fields are editable and hold the English values.
      expect(find.text('Your mountain home in Trysil'), findsWidgets);
      // Visible fields carry an Auto chip (the editor list is lazy, so only
      // on-screen fields are built); none is locked.
      expect(find.text('Auto'), findsWidgets);
      expect(find.text('Locked'), findsNothing);
      // Source-reference line shows the NL tag.
      expect(find.text('NL'), findsWidgets);
    },
  );

  testWidgets('typing in an auto field flips it to Locked with Reset to AI', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    // Type into the headline (first text field in the form).
    final headlineField = find.widgetWithText(
      TextFormField,
      'Your mountain home in Trysil',
    );
    expect(headlineField, findsOneWidget);
    await tester.enterText(headlineField, 'My personal headline');
    await tester.pumpAndSettle();

    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Reset to AI'), findsOneWidget);
    expect(
      cubit.state.translatedField('en', 'hero.headline')!.status,
      FieldTranslationStatus.locked,
    );
  });

  testWidgets('Reset to AI restores the source-derived auto value', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    cubit.editTranslationField('en', 'hero.headline', 'Manual override');
    await tester.pumpAndSettle();
    expect(find.text('Reset to AI'), findsOneWidget);

    await tester.tap(find.text('Reset to AI'));
    await tester.pumpAndSettle();

    final field = cubit.state.translatedField('en', 'hero.headline')!;
    expect(field.status, FieldTranslationStatus.auto);
    expect(field.value, 'Your mountain home in Trysil');
    expect(find.text('Locked'), findsNothing);
  });

  testWidgets('preview binds to the selected language and device toggles', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);

    // Source preview: browser frame with NL url + content.
    expect(find.text('trysilpanorama.com/nl'), findsOneWidget);

    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();
    expect(find.text('trysilpanorama.com/en'), findsOneWidget);

    cubit.setPreviewDevice(PreviewDevice.mobile);
    await tester.pumpAndSettle();
    // Mobile frame: status-bar time + host, no address bar.
    expect(find.text('9:41'), findsOneWidget);
    expect(find.text('trysilpanorama.com/en'), findsNothing);
    expect(find.text('trysilpanorama.com'), findsOneWidget);
  });

  testWidgets('stale translation shows the warning ribbon; fresh shows draft', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    // Fresh state → draft ribbon.
    expect(
      find.text('Draft translation — visible only to you until you publish.'),
      findsOneWidget,
    );

    cubit.editSourceField('hero.headline', 'Nieuwe titel');
    await tester.pumpAndSettle();

    // Stale → warning ribbon with a Preview latest action.
    expect(
      find.text('Earlier preview — updates automatically on publish.'),
      findsOneWidget,
    );
    expect(find.text('Preview latest'), findsWidgets);
  });

  testWidgets('publish modal lists all languages with correct status chips', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.editSourceField('hero.headline', 'Nieuwe titel');
    await tester.pumpAndSettle();

    // Open via the state (the page listener owns the modal in the app; here we
    // drive the modal helper directly).
    final context = tester.element(find.byType(EditorColumn));
    showPublishModal(context, state: cubit.state);
    await tester.pumpAndSettle();

    expect(find.text('Publish all languages'), findsWidgets);
    expect(find.text('Dutch · source'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Re-translate'), findsNWidgets(2));
    expect(find.text('Publish 3 languages'), findsOneWidget);
  });

  testWidgets('confirm publish clears dirty + stale', (tester) async {
    final cubit = await pumpEditor(tester);
    cubit.editSourceField('hero.headline', 'Nieuwe titel');
    await tester.pumpAndSettle();
    expect(cubit.state.dirty, isTrue);
    expect(cubit.state.staleLanguages, isNotEmpty);

    await cubit.publishAll();
    await tester.pumpAndSettle();

    expect(cubit.state.dirty, isFalse);
    expect(cubit.state.staleLanguages, isEmpty);
    expect(find.text('Published · all languages'), findsOneWidget);
  });
}
