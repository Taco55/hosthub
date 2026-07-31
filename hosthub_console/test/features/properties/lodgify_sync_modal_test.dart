import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/channel_property.dart';
import 'package:hosthub_console/features/properties/domain/lodgify_sync_plan.dart';
import 'package:hosthub_console/features/properties/presentation/dialogs/lodgify_sync_modal.dart';

/// The modal answers a question — "did the owner apply this?" — and the footer
/// is what answers it. The intent that renders that footer takes no controller,
/// so the result no longer travels through the button's own close call; these
/// tests pin that the answer still reaches the caller either way.
LodgifySyncPlan _planWithWork() => LodgifySyncPlan(const [
  LodgifyListingPlan(
    listing: ChannelProperty(id: 'lg-1', name: 'Chalet Birch'),
    action: LodgifyListingAction.create,
  ),
]);

LodgifySyncPlan _planWithoutWork() => LodgifySyncPlan(const [
  LodgifyListingPlan(
    listing: ChannelProperty(id: 'lg-2', name: 'Chalet Pine'),
    action: LodgifyListingAction.linked,
  ),
]);

/// Opens the modal and hands back the future the caller awaits.
Future<Future<bool>> _open(WidgetTester tester, LodgifySyncPlan plan) async {
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

  final result = showLodgifySyncModal(pageContext, plan: plan);
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('applying reports true to the caller', (tester) async {
    final result = await _open(tester, _planWithWork());

    // `Add` is the primary; the shell closes the modal once it has run.
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(await result, isTrue);
  });

  testWidgets('cancelling reports false', (tester) async {
    final result = await _open(tester, _planWithWork());

    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });

  testWidgets('nothing to apply: one Close, no filled call to action', (
    tester,
  ) async {
    final result = await _open(tester, _planWithoutWork());

    expect(find.text('Already linked'), findsOneWidget);
    // No apply verb is offered, so there is nothing to confirm.
    expect(find.text('Add'), findsNothing);
    expect(find.text('Cancel'), findsNothing);

    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });
}
