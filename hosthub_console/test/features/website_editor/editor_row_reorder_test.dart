import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/editor_card_view.dart';
import 'package:hosthub_console/features/website_editor/presentation/widgets/website_field_row.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// The editor's repeatable rows are dragged into order, and the order that
/// comes out is what gets saved and published. Two things about a real drag are
/// invisible to a cubit test, and both of them shipped broken once:
///
/// **The indices.** `StyledFieldList.onReorder` reports **plain** list indices:
/// it normalizes `ReorderableListView`'s pre-removal `newIndex` itself, and its
/// up/down buttons emit the same pair. Adjusting a second time in `moveRow` —
/// the `if (newIndex > oldIndex) newIndex -= 1` the raw callback contract asks
/// for — makes a two-row swap do nothing at all and lands every longer downward
/// drag one slot short. A cubit test that passes the raw convention in agrees
/// with the bug; only a real drag disagrees. See
/// `test/features/sites/content_section_reorder_test.dart` for the same hazard
/// on the site-config renderer, which drives `ReorderableListView` directly.
///
/// **The tree the row is rebuilt in.** Picking a row up lifts it out of the
/// list and rebuilds it in the Navigator's overlay, which sits *above* the
/// route that provides [SiteContentCubit] — so every row widget that reads the
/// cubit from its context throws the moment it is dragged. Hence the provider
/// lives inside `home:` here, exactly where `WebsiteEditorPage` puts it:
/// hoisting it above the `MaterialApp` puts it above the overlay too and makes
/// every drag below pass while the real editor crashes.
String Function() _sequentialIds() {
  var next = 0;
  return () => 'r${++next}';
}

/// Pumps one card of the page schema — the real `StyledFieldList` →
/// `SiteContentCubit.moveRow` wiring — after letting [seed] stock its lists
/// (rows are added as 'r1', 'r2', … in call order).
Future<SiteContentCubit> _pumpCard(
  WidgetTester tester, {
  required String cardId,
  String page = 'home',
  void Function(SiteContentCubit cubit)? seed,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 3600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = SiteContentCubit(
    translationService: const SeedTranslationService(),
    rowIdGenerator: _sequentialIds(),
  );
  addTearDown(cubit.close);
  seed?.call(cubit);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final card = kDefaultTemplate.cardsOf(page).firstWhere((c) => c.id == cardId);

  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      builder: (context, child) => StyledWidgetsTheme(
        styledThemeData: HosthubThemePreset.styledTheme(
          lightMaterialTheme: lightTheme,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      // Route-scoped, like the real page: the cubit sits below the Navigator's
      // overlay, so a dragged row only stays buildable if the list hands its
      // floating proxy the same scope. See the note above.
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
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

/// Pumps the highlights card — a `RowListRow` — with [extraRows] rows appended
/// on top of the seeded 'h1' and 'h2'.
Future<SiteContentCubit> _pumpHighlights(
  WidgetTester tester, {
  int extraRows = 0,
}) => _pumpCard(
  tester,
  cardId: 'highlights',
  seed: (cubit) {
    for (var i = 0; i < extraRows; i++) {
      cubit.addRow('home.highlights');
    }
  },
);

/// The grips of the [listIndex]'th reorderable list on screen. A group card has
/// two levels of list, so the index says which one — 0 is the outer list, and
/// scoping to the inner one keeps the outer group's own grip out of the match.
Finder _handlesIn(int listIndex) => find.descendant(
  of: find.byType(ReorderableListView).at(listIndex),
  matching: find.byIcon(Icons.drag_indicator),
);

Finder get _handles => _handlesIn(0);

/// Asserts the row now floating under the pointer can still reach
/// [SiteContentCubit] — the property `dragProxyBuilder` exists for.
///
/// The floating row is the one that is no longer a descendant of any list: the
/// original stays behind as an empty gap and the proxy renders in the
/// Navigator's overlay. Asserting the *lookup* rather than waiting for a throw
/// is what makes this a gate for every shape: whether the row's `build` re-runs
/// in the overlay is Flutter's business (a row whose body is one widget can be
/// re-parented instead of rebuilt, and then it survives on luck), but a lookup
/// from the proxy's own context fails for all of them without the fix.
void _expectFloatingRowKeepsCubit() {
  final inSomeList = find
      .descendant(
        of: find.byType(ReorderableListView),
        matching: find.byType(WebsiteFieldRow),
      )
      .evaluate()
      .toSet();
  final floating = find
      .byType(WebsiteFieldRow)
      .evaluate()
      .where((element) => !inSomeList.contains(element))
      .toList();

  expect(
    floating,
    isNotEmpty,
    reason: 'no row is floating in the overlay — the drag never lifted one',
  );
  for (final row in floating) {
    expect(
      () => row.read<SiteContentCubit>(),
      returnsNormally,
      reason: 'the dragged row lost the editor cubit in the overlay',
    );
  }
}

/// Drags the row at [from] onto the slot the row at [to] occupies.
Future<void> _dragRow(
  WidgetTester tester, {
  required int from,
  required int to,
  Finder? handles,
}) async {
  final grips = handles ?? _handles;
  final distance =
      tester.getCenter(grips.at(to)).dy - tester.getCenter(grips.at(from)).dy;

  // The handles are `ReorderableDragStartListener`s, so the drag starts on
  // touch — no long press to wait out.
  final gesture = await tester.startGesture(tester.getCenter(grips.at(from)));
  await tester.pump(const Duration(milliseconds: 100));
  // Step it, so every slot the drag passes gets a frame to reorder in.
  const steps = 12;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(0, distance / steps));
    await tester.pump(const Duration(milliseconds: 16));
    if (i == 0) _expectFloatingRowKeepsCubit();
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

  // Every list shape the schema has, because the proxy scope is passed per
  // `StyledFieldList`: dropping it at one call site breaks that shape only, and
  // does it silently until an owner drags that particular row. Each drag here
  // also runs [_expectFloatingRowKeepsCubit], so the row is checked while it is
  // still in the air, not only by the order it lands in.
  group('a dragged row keeps the editor cubit in reach', () {
    testWidgets('rows with several fields (highlights)', (tester) async {
      final cubit = await _pumpHighlights(tester);

      await _dragRow(tester, from: 0, to: 1);

      expect(cubit.state.rowIdsOfList('home.highlights'), ['h2', 'h1']);
    });

    testWidgets('single-value rows (description)', (tester) async {
      final cubit = await _pumpCard(
        tester,
        cardId: 'description',
        seed: (cubit) => cubit.addRow('cabin.description'),
      );
      expect(cubit.state.rowIdsOfList('cabin.description'), ['d1', 'r1']);

      await _dragRow(tester, from: 0, to: 1);

      expect(cubit.state.rowIdsOfList('cabin.description'), ['r1', 'd1']);
    });

    testWidgets('label + value pairs (key facts)', (tester) async {
      final cubit = await _pumpCard(
        tester,
        cardId: 'keyFacts',
        seed: (cubit) {
          cubit.addRow('home.keyFacts');
          cubit.addRow('home.keyFacts');
        },
      );
      expect(cubit.state.rowIdsOfList('home.keyFacts'), ['r1', 'r2']);

      await _dragRow(tester, from: 0, to: 1);

      expect(cubit.state.rowIdsOfList('home.keyFacts'), ['r2', 'r1']);
    });

    testWidgets('whole groups (amenities)', (tester) async {
      // A group replaces the row chrome with its own block, so it is the one
      // shape whose proxy rebuilds a `rowBuilder` result.
      final cubit = await _pumpCard(
        tester,
        cardId: 'amenities',
        seed: (cubit) {
          cubit.addRow('cabin.amenities.groups');
          cubit.addRow('cabin.amenities.groups');
        },
      );
      expect(cubit.state.rowIdsOfList('cabin.amenities.groups'), ['r1', 'r2']);

      await _dragRow(tester, from: 0, to: 1);

      expect(cubit.state.rowIdsOfList('cabin.amenities.groups'), ['r2', 'r1']);
    });

    testWidgets('items inside a group (amenities)', (tester) async {
      final itemsKey = groupItemsListKey(
        'cabin.amenities.groups',
        'r1',
        'items',
      );
      final cubit = await _pumpCard(
        tester,
        cardId: 'amenities',
        seed: (cubit) {
          cubit.addRow('cabin.amenities.groups');
          cubit.addRow(itemsKey);
          cubit.addRow(itemsKey);
        },
      );
      expect(cubit.state.rowIdsOfList(itemsKey), ['r2', 'r3']);

      // The group's own list is list 0; the items live in the nested one.
      await _dragRow(tester, from: 0, to: 1, handles: _handlesIn(1));

      expect(cubit.state.rowIdsOfList(itemsKey), ['r3', 'r2']);
    });
  });
}
