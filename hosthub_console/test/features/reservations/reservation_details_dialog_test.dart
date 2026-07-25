import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/reservations/presentation/dialogs/reservation_details_dialog.dart';

/// The booking detail dialog is opened from three places (the reservations
/// list, a timeline bar and a revenue row) and used to exist twice, once per
/// screen. These pin the union: the revenue figures are passed in, and the
/// notes editor only appears for the screen that can actually save.
void main() {
  setUpAll(() => initializeDateFormatting('nl'));

  final entry = Reservation(
    reservationId: 'B-1001',
    startDate: DateTime(2027, 2, 7),
    endDate: DateTime(2027, 2, 12),
    status: 'Booked',
    guestName: 'Dina Simonsen',
    guestEmail: 'dina@example.com',
    guestPhone: '+47 900 00 000',
    adultCount: 4,
    childCount: 2,
    infantCount: 1,
    source: 'airbnb',
    notes: 'Late arrival',
    createdAt: DateTime(2027),
    updatedAt: DateTime(2027, 1, 20),
    raw: const {'id': 'B-1001'},
  );

  Future<void> pumpDialog(
    WidgetTester tester, {
    ReservationRevenueSummary revenue = ReservationRevenueSummary.empty,
    Future<void> Function(String, String)? onSaveNotes,
  }) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final lightTheme = HosthubThemePreset.applyMaterialTheme(
      baseTheme: ThemeData.light(),
      brightness: Brightness.light,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        locale: const Locale('nl'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: HosthubThemePreset.styledTheme(
            lightMaterialTheme: lightTheme,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: ReservationDetailsDialog(
            entry: entry,
            dateFormatter: DateFormat('d MMM yyyy', 'nl'),
            dateTimeFormatter: DateFormat('d MMM yyyy HH:mm', 'nl'),
            revenue: revenue,
            onSaveNotes: onSaveNotes,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows booker, stay and guests', (tester) async {
    await pumpDialog(tester);

    expect(find.text('Dina Simonsen'), findsAtLeastNWidgets(1));
    expect(find.text('dina@example.com'), findsOneWidget);
    expect(find.text('B-1001'), findsOneWidget);
    // Adults + children is the party the breakdown states; the infant is not
    // part of that sum.
    expect(find.text('6 (4 + 2)'), findsOneWidget);
  });

  testWidgets('the revenue section is driven by what the screen passes in',
      (tester) async {
    await pumpDialog(tester);
    expect(find.text('Opbrengsten'), findsNothing);

    await pumpDialog(
      tester,
      revenue: const ReservationRevenueSummary(
        currency: 'NOK',
        total: 12000,
        net: 9400,
        outstanding: 0,
        lines: [
          ReservationRevenueLine(label: 'Commissie', amount: -1800),
          ReservationRevenueLine(label: 'Schoonmaak', amount: -800),
        ],
      ),
    );

    expect(find.text('Opbrengsten'), findsOneWidget);
    expect(find.text('12000 NOK'), findsOneWidget);
    expect(find.text('9400 NOK'), findsOneWidget);
    expect(find.text('Commissie'), findsOneWidget);
    expect(find.text('-1800 NOK'), findsOneWidget);
  });

  testWidgets('without a save callback the note is read-only', (tester) async {
    await pumpDialog(tester);

    expect(find.text('Late arrival'), findsOneWidget);
    expect(find.byType(StyledTextField), findsNothing);
    expect(find.text('Opslaan in Lodgify'), findsNothing);
  });

  testWidgets('with a save callback the note becomes an editor',
      (tester) async {
    final saved = <(String, String)>[];
    await pumpDialog(
      tester,
      onSaveNotes: (id, notes) async => saved.add((id, notes)),
    );

    expect(find.byType(StyledTextField), findsOneWidget);

    await tester.enterText(find.byType(StyledTextField), 'Kat meegenomen');
    await tester.ensureVisible(find.text('Opslaan in Lodgify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Opslaan in Lodgify'));
    await tester.pumpAndSettle();

    expect(saved, [('B-1001', 'Kat meegenomen')]);
    // Confirms the write instead of leaving the editor looking untouched.
    expect(find.text('Opgeslagen'), findsOneWidget);
  });

  testWidgets('a failed save stops the spinner and keeps the text',
      (tester) async {
    await pumpDialog(
      tester,
      onSaveNotes: (id, notes) async => throw Exception('offline'),
    );

    await tester.enterText(find.byType(StyledTextField), 'Nieuwe notitie');
    await tester.ensureVisible(find.text('Opslaan in Lodgify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Opslaan in Lodgify'));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Opgeslagen'), findsNothing);
    expect(find.text('Nieuwe notitie'), findsOneWidget);
  });
}
