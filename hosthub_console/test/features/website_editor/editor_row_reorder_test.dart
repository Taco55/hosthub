import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/editor_card_view.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// The editor's repeatable rows are dragged into order, and the order that
/// comes out is what gets saved and published.
///
/// `StyledFieldList.onReorder` reports **plain** list indices: it normalizes
/// `ReorderableListView`'s pre-removal `newIndex` itself, and its up/down
/// buttons emit the same pair. Adjusting a second time in `moveRow` — the
/// `if (newIndex > oldIndex) newIndex -= 1` the raw callback contract asks for
/// — makes a two-row swap do nothing at all and lands every longer downward
/// drag one slot short. A cubit test that passes the raw convention in agrees
/// with the bug; only a real drag disagrees. See
/// `test/features/sites/content_section_reorder_test.dart` for the same hazard
/// on the site-config renderer, which drives `ReorderableListView` directly.
String Function() _sequentialIds() {
  var next = 0;
  return () => 'r${++next}';
}

/// Pumps the highlights card — a `RowListRow`, so the real
/// `StyledFieldList` → `SiteContentCubit.moveRow` wiring — with [extraRows]
/// rows appended ('r1', 'r2', …) on top of the seeded 'h1' and 'h2'.
Future<SiteContentCubit> _pumpHighlights(
  WidgetTester tester, {
  int extraRows = 0,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 3600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = SiteContentCubit(
    translationService: const SeedTranslationService(),
    rowIdGenerator: _sequentialIds(),
  );
  addTearDown(cubit.close);
  for (var i = 0; i < extraRows; i++) {
    cubit.addRow('home.highlights');
  }

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final card = kPageCards['home']!.firstWhere((c) => c.id == 'highlights');

  await tester.pumpWidget(
    // Above the MaterialApp, not inside `home`: a drag lifts the row into the
    // Navigator's overlay and rebuilds it there, so a provider scoped to the
    // route is out of reach for the floating proxy.
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: HosthubThemePreset.styledTheme(
            lightMaterialTheme: lightTheme,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: BlocBuilder<SiteContentCubit, SiteContentState>(
            builder: (context, state) => SingleChildScrollView(
              child: EditorCardView(state: state, card: card),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

Finder get _handles => find.descendant(
  of: find.byType(ReorderableListView),
  matching: find.byIcon(Icons.drag_indicator),
);

/// Drags the row at [from] onto the slot the row at [to] occupies.
Future<void> _dragRow(
  WidgetTester tester, {
  required int from,
  required int to,
}) async {
  final distance =
      tester.getCenter(_handles.at(to)).dy -
      tester.getCenter(_handles.at(from)).dy;

  // The handles are `ReorderableDragStartListener`s, so the drag starts on
  // touch — no long press to wait out.
  final gesture = await tester.startGesture(
    tester.getCenter(_handles.at(from)),
  );
  await tester.pump(const Duration(milliseconds: 100));
  // Step it, so every slot the drag passes gets a frame to reorder in.
  const steps = 12;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(0, distance / steps));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  group('website editor row reorder', () {
    testWidgets('dragging the first of two rows down swaps them', (
      tester,
    ) async {
      // The failing case: two rows is the shortest list the editor allows, and
      // the double adjustment turned this drag into a no-op.
      final cubit = await _pumpHighlights(tester);
      expect(cubit.state.rowIdsOfList('home.highlights'), ['h1', 'h2']);
      expect(_handles, findsNWidgets(2));

      await _dragRow(tester, from: 0, to: 1);

      expect(cubit.state.rowIdsOfList('home.highlights'), ['h2', 'h1']);
    });

    testWidgets('dragging a row to the bottom of three lands it there', (
      tester,
    ) async {
      // Longer lists did move, just never far enough: this landed 'h1' in the
      // middle instead of last.
      final cubit = await _pumpHighlights(tester, extraRows: 1);
      expect(cubit.state.rowIdsOfList('home.highlights'), ['h1', 'h2', 'r1']);
      expect(_handles, findsNWidgets(3));

      await _dragRow(tester, from: 0, to: 2);

      expect(cubit.state.rowIdsOfList('home.highlights'), ['h2', 'r1', 'h1']);
    });

    testWidgets('dragging the last row to the top keeps the rest in order', (
      tester,
    ) async {
      // Upward drags were never adjusted, so this is the control: it has to
      // keep working after the fix.
      final cubit = await _pumpHighlights(tester, extraRows: 1);

      await _dragRow(tester, from: 2, to: 0);

      expect(cubit.state.rowIdsOfList('home.highlights'), ['r1', 'h1', 'h2']);
    });

    testWidgets('the down arrow moves a row one slot, like the drag does', (
      tester,
    ) async {
      // The buttons are the keyboard-and-screen-reader path to the same move,
      // and they report the same plain indices.
      final cubit = await _pumpHighlights(tester);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
      await tester.pumpAndSettle();

      expect(cubit.state.rowIdsOfList('home.highlights'), ['h2', 'h1']);
    });

    testWidgets('the up arrow puts it back', (tester) async {
      final cubit = await _pumpHighlights(tester);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up).last);
      await tester.pumpAndSettle();

      expect(cubit.state.rowIdsOfList('home.highlights'), ['h1', 'h2']);
      // Back at the saved order is not a change (§B.4).
      expect(cubit.state.draftListOrder, isEmpty);
    });
  });
}
