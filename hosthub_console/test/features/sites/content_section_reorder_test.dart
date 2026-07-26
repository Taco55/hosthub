import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/cms/data/cms_repository.dart';
import 'package:hosthub_console/features/sites/presentation/widgets/content_section_renderer.dart';

/// The string lists in the site config editor (hero images, gallery filenames)
/// are dragged into order, and the list they emit is what gets published.
///
/// The renderer hands `ReorderableListView` an `onReorderItem` callback, which
/// receives a `newIndex` the framework has **already** adjusted for the item
/// removed at `oldIndex`. Adjusting it a second time in the callback — the
/// `if (newIndex > oldIndex) newIndex -= 1` that the obsolete `onReorder`
/// contract required — silently puts every downward drag one slot too high.
/// A golden cannot see that; this can.
Future<List<String>?> _dragHeroImage(
  WidgetTester tester, {
  required int from,
  required int to,
}) async {
  await tester.binding.setSurfaceSize(const Size(1400, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  List<String>? emitted;

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );

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
      home: Scaffold(
        body: SingleChildScrollView(
          child: ContentSectionRenderer(
            document: ContentDocument(
              id: 'doc-1',
              siteId: 'site-1',
              contentType: 'site_config',
              slug: 'config',
              locale: 'nl',
              content: const {},
              status: 'draft',
              updatedAt: DateTime(2026, 7, 26),
            ),
            content: const {
              'heroImages': ['first.jpeg', 'second.jpeg', 'third.jpeg'],
            },
            onContentChanged: (content) {
              emitted = List<String>.from(content['heroImages'] as List);
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // The hero list is the first reorderable string list in the site config
  // editor; its handles are the drag_indicator icons inside it.
  final handles = find.descendant(
    of: find.byType(ReorderableListView).first,
    matching: find.byIcon(Icons.drag_indicator),
  );
  expect(handles, findsNWidgets(3));

  final pitch =
      tester.getCenter(handles.at(1)).dy - tester.getCenter(handles.at(0)).dy;

  // Rows shift by one pitch per slot the drag crosses, so travelling exactly
  // `slots × pitch` lands mid-window between the two neighbouring thresholds.
  final distance = (to - from) * pitch;

  // The handles are `ReorderableDragStartListener`s, so the drag starts on
  // touch — no long press to wait out.
  final gesture = await tester.startGesture(tester.getCenter(handles.at(from)));
  await tester.pump(const Duration(milliseconds: 100));
  // Step it, so every slot the drag passes gets a frame to reorder in.
  const steps = 12;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(0, distance / steps));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();

  return emitted;
}

void main() {
  group('site config string list reorder', () {
    testWidgets('dragging an item down lands it on the dragged-to slot', (
      tester,
    ) async {
      // This is the direction the index adjustment governs.
      expect(await _dragHeroImage(tester, from: 0, to: 1), [
        'second.jpeg',
        'first.jpeg',
        'third.jpeg',
      ]);
    });

    testWidgets('dragging the last item to the top keeps the rest in order', (
      tester,
    ) async {
      expect(await _dragHeroImage(tester, from: 2, to: 0), [
        'third.jpeg',
        'first.jpeg',
        'second.jpeg',
      ]);
    });

    testWidgets('dragging across the whole list lands at the bottom', (
      tester,
    ) async {
      expect(await _dragHeroImage(tester, from: 0, to: 2), [
        'second.jpeg',
        'third.jpeg',
        'first.jpeg',
      ]);
    });
  });
}
