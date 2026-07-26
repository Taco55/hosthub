import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

/// The page header the design draws (`.top`): a 12px crumb over a 19/700
/// title, and the content starting on the title's own left edge.
///
/// A golden will not catch a 4px drift between the two left edges; these
/// assertions will. They live at the scaffold level on purpose — the console's
/// pages pass strings and a child, nothing that could move an edge, so one
/// change to `StyledWebPageScaffold` or to the preset cannot silently break
/// every page at once.
Future<void> _pumpPage(
  WidgetTester tester, {
  Size window = const Size(1800, 900),
  String? overline,
  bool decoratePane = true,
  bool intrinsicPaneHeight = false,
  List<Widget>? actions,
}) async {
  await tester.binding.setSurfaceSize(window);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      builder: (context, child) => StyledWidgetsTheme(
        styledThemeData: HosthubThemePreset.styledTheme(
          lightMaterialTheme: lightTheme,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      home: StyledWebPageScaffold(
        overline: overline,
        title: 'Boekingen · Trysil',
        actions: actions,
        decorateLeftPane: decoratePane,
        intrinsicPaneHeight: intrinsicPaneHeight,
        leftChild: const Align(
          alignment: Alignment.topLeft,
          child: Text('content'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _dx(WidgetTester tester, Finder finder) =>
    tester.getTopLeft(finder).dx;

void main() {
  group('page header alignment', () {
    // Each entry is a shape a console page actually uses.
    testWidgets('undecorated wide pane (reservations, revenue, pricing)',
        (tester) async {
      await _pumpPage(tester, overline: 'Reserveringen', decoratePane: false);

      expect(
        _dx(tester, find.text('content')),
        _dx(tester, find.text('Boekingen · Trysil')),
      );
      expect(
        _dx(tester, find.text('Reserveringen')),
        _dx(tester, find.text('Boekingen · Trysil')),
      );
    });

    testWidgets('decorated pane keeps the card on the title edge',
        (tester) async {
      await _pumpPage(tester, overline: 'Details');

      // The card, not its inner padding, is what lines up with the title.
      final card = find
          .ancestor(of: find.text('content'), matching: find.byType(Material))
          .first;
      expect(_dx(tester, card), _dx(tester, find.text('Boekingen · Trysil')));
    });

    testWidgets('the scrolling page (settings) keeps the same edge',
        (tester) async {
      await _pumpPage(
        tester,
        overline: 'Instellingen',
        intrinsicPaneHeight: true,
      );

      final card = find
          .ancestor(of: find.text('content'), matching: find.byType(Material))
          .first;
      expect(_dx(tester, card), _dx(tester, find.text('Boekingen · Trysil')));
    });

    testWidgets('a header action does not move the title edge', (tester) async {
      await _pumpPage(
        tester,
        overline: 'Omzet',
        decoratePane: false,
        actions: [
          StyledToolbarButton(iconData: Icons.refresh, onPressed: () {}),
        ],
      );

      expect(
        _dx(tester, find.text('content')),
        _dx(tester, find.text('Boekingen · Trysil')),
      );
    });

    testWidgets('a narrow window keeps them together', (tester) async {
      await _pumpPage(
        tester,
        window: const Size(820, 700),
        overline: 'Prijzen',
        decoratePane: false,
      );

      expect(
        _dx(tester, find.text('content')),
        _dx(tester, find.text('Boekingen · Trysil')),
      );
    });
  });

  group('page header rule', () {
    testWidgets('runs the full page width under the title band',
        (tester) async {
      const window = Size(1800, 900);
      await _pumpPage(
        tester,
        window: window,
        overline: 'Reserveringen',
        decoratePane: false,
      );

      final rule = tester.getRect(
        find.byWidgetPredicate(
          (w) =>
              w is ColoredBox && w.color == HosthubDiploraV1Palette.softGrey,
        ),
      );
      expect(rule.left, 0);
      expect(rule.right, window.width);
      expect(rule.height, 1);
      // It separates the two bands: title above, content below.
      expect(
        tester.getBottomLeft(find.text('Boekingen · Trysil')).dy,
        lessThan(rule.top),
      );
      expect(tester.getTopLeft(find.text('content')).dy, greaterThan(rule.top));
    });
  });

  group('page header type', () {
    testWidgets('crumb and title match the design', (tester) async {
      await _pumpPage(tester, overline: 'Reserveringen', decoratePane: false);

      final title = tester.widget<Text>(find.text('Boekingen · Trysil')).style!;
      expect(title.fontSize, 19); // design `.top h1{font-size:19px}`
      expect(title.fontWeight, FontWeight.w700);
      expect(title.letterSpacing, -0.3);
      expect(title.color, HosthubDiploraV1Palette.secondary);

      final crumb = tester.widget<Text>(find.text('Reserveringen')).style!;
      expect(crumb.fontSize, 12); // design `.crumb{font-size:12px}`
      expect(crumb.color, HosthubDiploraV1Palette.outlineGrey);
    });
  });

  group('page header conformance', () {
    test('no page puts a sentence under its title', () {
      // The design's `.top` is a crumb over a title — nothing else. A page
      // that needs to explain itself does so in its body.
      final offenders = <String>[];
      for (final file in Directory('lib/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('_page.dart'))) {
        final lines = file.readAsLinesSync();
        var insideScaffold = false;
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains('StyledWebPageScaffold(')) insideScaffold = true;
          if (insideScaffold && line.contains('leftChild:')) {
            insideScaffold = false;
          }
          if (insideScaffold && line.trimLeft().startsWith('description:')) {
            offenders.add('${file.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'Use `overline` for the section and `title` for the subject:\n'
            '${offenders.join('\n')}',
      );
    });
  });
}
