import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

/// Visual baselines for the chrome the three screens are built from, rendered
/// under the real `HosthubThemePreset`.
///
/// These exist because the page-level goldens need a signed-in session, while
/// the things that actually went wrong against the design are theme-level: the
/// KPI row's anatomy, the table's header band and row colour, and the toolbar
/// buttons. Compare against `HostHub CMS.dc.html` — `.kpis` / `.kpi`, `.dt th` /
/// `.dt tbody tr`, `.tbtn` and `.seg`.
///
/// Regenerate with:
/// flutter test --update-goldens test/core/theme/design_chrome_golden_test.dart
void main() {
  Future<void> pump(WidgetTester tester, Widget child, {Size? size}) async {
    await tester.binding.setSurfaceSize(size ?? const Size(1040, 260));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
        builder: (context, inner) => StyledWidgetsTheme(
          styledThemeData: styledTheme,
          child: inner ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          // The design's page plane is white (`--jo-surface`), so the cards
          // must be visible against it by their own border.
          backgroundColor: Colors.white,
          body: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('golden: KPI row (.kpis)', (tester) async {
    await pump(
      tester,
      const Align(
        alignment: Alignment.topCenter,
        child: MetricsGrid(
          metrics: [
            MetricTileData(
              label: 'Boekingen',
              value: '3',
              icon: Icons.book_online_outlined,
              caption: 'deze maand',
            ),
            MetricTileData(
              label: 'Aankomsten',
              value: '2',
              icon: Icons.login_outlined,
              caption: 'check-in',
            ),
            MetricTileData(
              label: 'Vertrekken',
              value: '1',
              icon: Icons.logout_outlined,
              caption: 'check-out',
            ),
            MetricTileData(
              label: 'Bezetting',
              value: '68%',
              icon: Icons.hotel_outlined,
              caption: '21 nachten',
            ),
          ],
        ),
      ),
      size: const Size(1040, 140),
    );

    await expectLater(
      find.byType(MetricsGrid),
      matchesGoldenFile('goldens/chrome_01_kpis.png'),
    );
  });

  testWidgets('golden: booking table (.dt header band + white rows)',
      (tester) async {
    const rows = [
      ['Dina Simonsen', '7 feb 2027', '12 feb 2027', '5', '8 (4 + 4)'],
      ['Thomas Fogt Nielsen', '13 feb 2027', '19 feb 2027', '6', '8 (8 + 0)'],
      ['Jörn Hampicke', '7 mrt 2027', '13 mrt 2027', '6', '6 (6 + 0)'],
    ];

    await pump(
      tester,
      StyledDataTable(
        variant: StyledTableVariant.plain,
        dense: true,
        itemCount: rows.length,
        columns: const [
          StyledDataColumn(columnHeaderLabel: 'Boeker', flex: 2, minWidth: 160),
          StyledDataColumn(columnHeaderLabel: 'Check-in', flex: 1),
          StyledDataColumn(columnHeaderLabel: 'Check-out', flex: 1),
          StyledDataColumn(
            columnHeaderLabel: 'Nachten',
            flex: 0,
            width: 80,
            alignment: Alignment.centerRight,
            headerAlignment: Alignment.centerRight,
          ),
          StyledDataColumn(columnHeaderLabel: 'Gasten', flex: 1),
        ],
        rowBuilder: (context, index) => [
          for (final cell in rows[index])
            Text(cell, style: Theme.of(context).textTheme.bodySmall),
        ],
        showTableWhenEmpty: true,
        emptyLabel: 'Geen reserveringen gevonden.',
      ),
      size: const Size(1040, 260),
    );

    await expectLater(
      find.byType(StyledDataTable),
      matchesGoldenFile('goldens/chrome_02_table.png'),
    );
  });

  testWidgets('golden: toolbar (.seg + .tbtn, plain and selected)',
      (tester) async {
    await pump(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StyledSegmentedControl(
              labels: const ['Lijst', 'Tijdlijn'],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
            const SizedBox(width: 8),
            // Selected == an active filter, per the design's `.tbtn.on`.
            StyledToolbarButton.menu<String>(
              iconData: Icons.filter_list_rounded,
              isSelected: true,
              entries: const [
                StyledMenuOverlayEntry(
                  value: 'booked',
                  label: 'Bevestigd',
                  checked: true,
                ),
              ],
            ),
            const SizedBox(width: 8),
            StyledToolbarButton.menu<String>(
              iconData: Icons.view_column_outlined,
              entries: const [
                StyledMenuOverlayEntry(
                  value: 'guest',
                  label: 'Boeker',
                  checked: true,
                ),
              ],
            ),
            const SizedBox(width: 8),
            const StyledToolbarButton(iconData: Icons.ios_share),
          ],
        ),
      ),
      size: const Size(520, 100),
    );

    await expectLater(
      find.byType(Row).first,
      matchesGoldenFile('goldens/chrome_03_toolbar.png'),
    );
  });
}
