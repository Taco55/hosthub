import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/core/widgets/layout/layout.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/editor_column.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/preview_pane.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/publish_modal.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// Pumps the full editor (editor column + preview) inside a BlocProvider at a
/// desktop-like size, under the app's real Material + StyledWidgets theming
/// (mirrors `app.dart`).
Future<SiteContentCubit> pumpEditor(
  WidgetTester tester, {

  /// A tall surface builds every card instead of only what fits: the editor's
  /// card list is lazy, so counting or finding a card further down needs room.
  Size surfaceSize = const Size(1360, 880),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
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
              // Mirrors WebsiteEditorPage's own bindings so the preview
              // toggle behaves here as it does in the app.
              leftPaneSize: state.previewVisible
                  ? const StyledPaneSize.fixed(512)
                  : null,
              contentMaxWidth: state.previewVisible ? null : 760,
              leftChild: EditorColumn(state: state),
              rightChild: PreviewPane(state: state),
              showRightPane: state.previewVisible,
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
  testWidgets('the title bar names the property, not the open page', (
    tester,
  ) async {
    await pumpEditor(tester);

    // Regression: the bar showed the page name, so the title flipped from the
    // property to "Home" as soon as content loaded. The page you are on is the
    // selected tab right below the title.
    expect(find.text('Trysil Panorama'), findsOneWidget);
    expect(find.text('Website'), findsOneWidget);
    final tabs = find.descendant(
      of: find.byType(StyledSegmentedControl),
      matching: find.text('Home'),
    );
    expect(tabs, findsOneWidget, reason: 'Home is a tab, not the title');
  });

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
      cubit.state.translatedField('en', 'cabin.hero.title')!.status,
      FieldTranslationStatus.locked,
    );
  });

  testWidgets('the chip is the switch, both ways, and the switch back is '
      'undoable', (tester) async {
    final cubit = await pumpEditor(tester);
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    cubit.editTranslationField('en', 'cabin.hero.title', 'Manual override');
    await tester.pumpAndSettle();
    expect(find.text('Locked'), findsOneWidget);

    // Clicking the chip switches back to automatic — no separate link.
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();

    var field = cubit.state.translatedField('en', 'cabin.hero.title')!;
    expect(field.status, FieldTranslationStatus.auto);
    expect(field.value, 'Your mountain home in Trysil');
    expect(find.text('Locked'), findsNothing);

    // The owner's wording is one click away for the rest of the session.
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    field = cubit.state.translatedField('en', 'cabin.hero.title')!;
    expect(field.status, FieldTranslationStatus.locked);
    expect(field.value, 'Manual override');

    // And the chip switches forward again from Auto.
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();
    expect(
      cubit.state.translatedField('en', 'cabin.hero.title')!.status,
      FieldTranslationStatus.auto,
    );
  });

  testWidgets('the lane header states what changed and what is the owner\'s', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    // §D.1: two figures, no coverage percentage — that can only read 100%.
    expect(find.textContaining('%'), findsNothing);
    final line = find.textContaining('in your own words');
    expect(line, findsOneWidget);
    expect(tester.widget<Text>(line).data, startsWith('0 changed · 0 of '));

    cubit.editTranslationField('en', 'cabin.hero.title', 'Mine');
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.textContaining('in your own words')).data,
      startsWith('0 changed · 1 of '),
    );

    // Moving the source on makes that field reviewable again: the first
    // figure counts what to look at, the second what the owner wrote.
    cubit.editSourceField('cabin.hero.subtitle', 'Nieuwe ondertitel');
    await cubit.save();
    await tester.pumpAndSettle();
    expect(
      // Two: the field the owner took over reads differently on the live site
      // too, so it is part of the delta — "changed" is about what publish will
      // put on the pages, not only about what went stale.
      tester.widget<Text>(find.textContaining('in your own words')).data,
      startsWith('2 changed · 1 of '),
    );
  });

  testWidgets('the filter hides every card without a changed field', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester, surfaceSize: const Size(1360, 4000));
    // Opening a language translates what is stale (lazy translation, par.
    // 11a), so the change has to happen *after* EN is open — which is also
    // the real review flow: you are in EN and the source moves on.
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();
    cubit.editSourceField('cabin.hero.subtitle', 'Nieuwe ondertitel');
    await cubit.save();
    await tester.pumpAndSettle();

    // Off by default (CONFORMANCE par. 5): every card is there.
    expect(find.byType(ContentCard), findsWidgets);
    final allCards = tester.widgetList<ContentCard>(find.byType(ContentCard));
    expect(allCards.length, greaterThan(1));

    cubit.setOnlyChangedFields(true);
    await tester.pumpAndSettle();

    // Only the card holding that field survives — header included, so no
    // empty husks are left behind.
    final filtered = tester.widgetList<ContentCard>(find.byType(ContentCard));
    expect(filtered.length, 1);
    // It is the Hero card: the field whose source moved lives there.
    expect(find.text('Subtitle'), findsOneWidget);

    cubit.setOnlyChangedFields(false);
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<ContentCard>(find.byType(ContentCard)).length,
      allCards.length,
    );
  });

  testWidgets('a card head carries its own changed count', (tester) async {
    final cubit = await pumpEditor(tester, surfaceSize: const Size(1360, 4000));
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();
    cubit.editSourceField('cabin.hero.subtitle', 'Nieuwe ondertitel');
    await cubit.save();
    await tester.pumpAndSettle();

    // The rollup states the number per card; absent where nothing changed.
    expect(find.text('1 changed'), findsOneWidget);

    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    await cubit.save();
    await tester.pumpAndSettle();
    expect(find.text('2 changed'), findsOneWidget);
    expect(find.text('1 changed'), findsNothing);
  });

  testWidgets('a row the source just gained reads New, not Locked', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester, surfaceSize: const Size(1360, 4000));
    cubit.addRow('home.highlights');
    // The row carries a generated id for life; ask the state which one.
    final rowId = cubit.state.rowIdsOfList('home.highlights').last;
    cubit.editSourceField(
      'home.highlights.$rowId.description',
      'Een nieuw hoogtepunt',
    );
    cubit.setPreviewLanguage('en');
    await tester.pumpAndSettle();

    // The row is on screen, its English counterpart is empty: `New`, and not
    // an empty `Locked` field.
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Locked'), findsNothing);
    // Never an empty locked field: an empty string is not the owner's words.
    final field = cubit.state.translatedField(
      'en',
      'home.highlights.$rowId.description',
    )!;
    expect(field.status, FieldTranslationStatus.auto);
  });

  testWidgets('hiding the preview widens the editor but keeps the line short', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    final scaffold = () => tester.widget<StyledWebPageScaffold>(
      find.byType(StyledWebPageScaffold),
    );

    // Beside the preview the column is fixed; the width cap does not apply.
    expect(scaffold().contentMaxWidth, isNull);

    cubit.togglePreview();
    await tester.pumpAndSettle();

    // §11d: full width, but the form still reads at a sane measure.
    expect(scaffold().contentMaxWidth, 760);
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

    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    // Translation follows the saved source, so the ribbon does too.
    await cubit.save();
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
    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    await cubit.save();
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
    // par. D.2: reviewing is page-granular. The owner opened EN while Home was
    // the page with changes, so EN is reviewed; NO was never opened.
    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('Not reviewed'), findsOneWidget);
    // And the row states the delta, not the total.
    expect(find.textContaining('changed fields on 1 pages'), findsWidgets);
    expect(find.text('Publish 3 languages'), findsOneWidget);

    // Unchecking a target says what happens to it and drops the count.
    await tester.tap(find.byType(StyledCheckbox).first);
    await tester.pumpAndSettle();
    expect(find.text('Skipped'), findsOneWidget);
    expect(find.text('Publish 2 languages'), findsOneWidget);

    // With every target skipped the label names the source instead of
    // rendering "Publish 1 languages".
    await tester.tap(find.byType(StyledCheckbox).last);
    await tester.pumpAndSettle();
    expect(find.text('Publish Dutch only'), findsOneWidget);
  });

  testWidgets('a skipped language is not published', (tester) async {
    final cubit = await pumpEditor(tester);
    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    await cubit.save();
    await tester.pumpAndSettle();

    await cubit.publishAll(skipLanguages: {'no'});
    await tester.pumpAndSettle();

    // EN was translated and shipped; NO kept whatever is live.
    expect(cubit.state.isLanguageStale('en'), isFalse);
    expect(cubit.state.isLanguageStale('no'), isTrue);
  });

  testWidgets('the publish dialog breaks a language down per page', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    cubit.editSourceField('practical.header.title', 'Nieuwe kop');
    await cubit.save();
    await tester.pumpAndSettle();

    final opened = <(String, String)>[];
    final context = tester.element(find.byType(EditorColumn));
    showPublishModal(
      context,
      state: cubit.state,
      onOpenReview: (language, page) => opened.add((language, page)),
    );
    await tester.pumpAndSettle();

    // Collapsed by default: the dialog answers "what goes live" first. The
    // page names also appear in the tabs behind the dialog, so the page rows
    // are identified by their own note instead.
    expect(find.textContaining('not reviewed yet'), findsNothing);
    expect(find.text('Per page'), findsWidgets);

    await tester.tap(find.text('Per page').first);
    await tester.pumpAndSettle();

    // One row per changed page — and only those: Area has no changes.
    expect(find.textContaining('not reviewed yet'), findsNWidgets(2));
    expect(find.text('Open'), findsNWidgets(2));

    await tester.tap(find.text('Open').first);
    await tester.pumpAndSettle();
    expect(opened, isNotEmpty);
    expect(opened.first.$1, 'en');
    expect(opened.first.$2, 'home');
  });

  testWidgets('confirm publish clears dirty + stale', (tester) async {
    final cubit = await pumpEditor(tester);
    cubit.editSourceField('cabin.hero.title', 'Nieuwe titel');
    await cubit.save();
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

  testWidgets('the save bar walks the three states in order', (tester) async {
    final cubit = await pumpEditor(tester);

    // Clean: publish is the only action.
    expect(find.text('Everything published'), findsOneWidget);
    expect(find.text('Save changes'), findsNothing);
    expect(find.text('Discard'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Jouw bergwoning in Trysil'),
      'Nieuwe titel',
    );
    await tester.pumpAndSettle();

    // Unsaved: both actions appear and publish is dimmed, not hidden.
    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(
      find.text('Nothing is saved until you press Save changes'),
      findsOneWidget,
    );
    expect(find.text('Discard'), findsOneWidget);
    final publish = tester.widget<StyledButton>(
      find.widgetWithText(StyledButton, 'Publish'),
    );
    expect(publish.enabled, isFalse);

    await tester.tap(find.widgetWithText(StyledButton, 'Save changes'));
    await tester.pumpAndSettle();

    // Saved, not published: the draft actions are gone, publish is live again.
    expect(find.text('Saved · not published'), findsOneWidget);
    expect(find.text('Save changes'), findsNothing);
    expect(
      tester
          .widget<StyledButton>(find.widgetWithText(StyledButton, 'Publish'))
          .enabled,
      isTrue,
    );
    expect(cubit.state.dirty, isTrue);
  });

  testWidgets('discard asks first, then puts the saved text back', (
    tester,
  ) async {
    final cubit = await pumpEditor(tester);
    final headline = find.widgetWithText(
      TextFormField,
      'Jouw bergwoning in Trysil',
    );
    await tester.enterText(headline, 'Toch maar niet');
    await tester.pumpAndSettle();
    expect(cubit.state.unsavedChanges, isTrue);

    await tester.tap(find.widgetWithText(StyledButton, 'Discard'));
    await tester.pumpAndSettle();
    // Losing typed copy is exactly what this screen protects against, so the
    // one action that destroys it confirms.
    expect(find.text('Discard your unsaved changes?'), findsOneWidget);

    await tester.tap(find.widgetWithText(StyledButton, 'Discard').last);
    await tester.pumpAndSettle();

    expect(cubit.state.unsavedChanges, isFalse);
    // The field shows the saved text again — not just the state behind it.
    expect(find.text('Jouw bergwoning in Trysil'), findsWidgets);
    expect(find.text('Toch maar niet'), findsNothing);
  });

  testWidgets('publish cannot be opened while a draft exists', (tester) async {
    final cubit = await pumpEditor(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Jouw bergwoning in Trysil'),
      'Half af',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(StyledButton, 'Publish'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(cubit.state.publishOpen, isFalse);
    expect(find.text('What goes live'), findsNothing);
  });
}
