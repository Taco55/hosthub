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
  testWidgets('source mode marks NL as the source and shows its content', (
    tester,
  ) async {
    await pumpEditor(tester);

    // §11g: the editor header's locale switcher labels the source language and
    // says nothing about the targets.
    expect(find.text('NL'), findsOneWidget);
    expect(find.text('source'), findsOneWidget);
    expect(find.text('AI'), findsNothing);
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

      // The switcher's selection is what says which language you're editing;
      // the separate mode chip it used to duplicate is gone.
      expect(find.text('EN'), findsOneWidget);
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

  testWidgets('typing in an auto field flips its chip to Locked', (
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
    expect(
      cubit.state.translatedField('en', 'hero.headline')!.status,
      FieldTranslationStatus.locked,
    );
  });

  testWidgets('the chip is the switch, both ways, and the switch back is '
      'undoable', (tester) async {
    final cubit = await pumpEditor(tester);
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    cubit.editTranslationField('en', 'hero.headline', 'Manual override');
    await tester.pumpAndSettle();
    expect(find.text('Locked'), findsOneWidget);

    // Clicking the chip switches back to automatic — no separate link.
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();

    var field = cubit.state.translatedField('en', 'hero.headline')!;
    expect(field.status, FieldTranslationStatus.auto);
    expect(field.value, 'Your mountain home in Trysil');
    expect(find.text('Locked'), findsNothing);

    // The owner's wording is one click away for the rest of the session.
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    field = cubit.state.translatedField('en', 'hero.headline')!;
    expect(field.status, FieldTranslationStatus.locked);
    expect(field.value, 'Manual override');

    // And the chip switches forward again from Auto.
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();
    expect(
      cubit.state.translatedField('en', 'hero.headline')!.status,
      FieldTranslationStatus.auto,
    );
  });

  testWidgets('the lane header counts the fields the owner took over', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    // No coverage percentage — that figure can only ever read 100%.
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('fields yours'), findsOneWidget);
    final before = tester
        .widget<Text>(find.textContaining('fields yours'))
        .data!;
    expect(before, startsWith('0 of '));

    cubit.editTranslationField('en', 'hero.headline', 'Mine');
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.textContaining('fields yours')).data,
      startsWith('1 of '),
    );
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

  testWidgets('the publish dialog is the last checkpoint, per language', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.editSourceField('hero.headline', 'Nieuwe titel');
    // Opening a language is what reviewing it means.
    cubit.setPreviewLanguage('en');
    cubit.setPreviewLanguage('nl');
    await tester.pumpAndSettle();

    // Open via the state (the page listener owns the modal in the app; here we
    // drive the modal helper directly).
    final context = tester.element(find.byType(EditorColumn));
    showPublishModal(context, state: cubit.state);
    await tester.pumpAndSettle();

    expect(find.text('What goes live'), findsWidgets);
    expect(find.text('Dutch · source'), findsOneWidget);
    // The opened language is reviewed; the untouched one is still a draft.
    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('Draft — not reviewed yet'), findsOneWidget);
    expect(find.text('Publish 3 languages'), findsOneWidget);

    // Unchecking a target says what happens to it and drops the count.
    await tester.tap(find.byType(StyledCheckbox).first);
    await tester.pumpAndSettle();
    expect(find.text('Skipped · stays as it is live now'), findsOneWidget);
    expect(find.text('Publish 2 languages'), findsOneWidget);

    // With every target skipped the label names the source instead of
    // rendering "Publish 1 languages".
    await tester.tap(find.byType(StyledCheckbox).last);
    await tester.pumpAndSettle();
    expect(find.text('Publish Dutch only'), findsOneWidget);
  });

  testWidgets('a skipped language is not published', (tester) async {
    final cubit = await pumpEditor(tester);
    cubit.editSourceField('hero.headline', 'Nieuwe titel');
    await tester.pumpAndSettle();

    await cubit.publishAll(skipLanguages: {'no'});
    await tester.pumpAndSettle();

    // EN was translated and shipped; NO kept whatever is live.
    expect(cubit.state.isLanguageStale('en'), isFalse);
    expect(cubit.state.isLanguageStale('no'), isTrue);
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
    // §11b: the status line says what is — never "published" while dirty.
    expect(find.text('Everything published'), findsOneWidget);
    expect(find.text('Dutch + 2 translations are live'), findsOneWidget);
  });
}
