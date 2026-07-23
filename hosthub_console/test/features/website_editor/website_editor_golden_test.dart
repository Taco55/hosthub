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

/// Golden baselines for the four key design states (CONFORMANCE.md) at the
/// prototype's desktop size. These are regression baselines rendered with the
/// test font — compare layout/geometry, not typography, against
/// `hosthub-design/design_handoff_hosthub_cms/screenshots/`.
/// Regenerate with: flutter test --update-goldens test/features/website_editor/website_editor_golden_test.dart
void main() {
  Future<SiteContentCubit> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1360, 880));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit =
        SiteContentCubit(translationService: const SeedTranslationService());
    addTearDown(cubit.close);

    final lightTheme = HosthubThemePreset.applyMaterialTheme(
      baseTheme: ThemeData.light(),
      brightness: Brightness.light,
    );
    final styledTheme =
        HosthubThemePreset.styledTheme(lightMaterialTheme: lightTheme);

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
              builder: (context, state) => StyledSplitView(
                primaryWidth: 512,
                primary: EditorColumn(state: state),
                secondary: PreviewPane(state: state),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('golden: source editor (mode A)', (tester) async {
    await pump(tester);
    await expectLater(
      find.byType(StyledSplitView),
      matchesGoldenFile('goldens/01_source_editor.png'),
    );
  });

  testWidgets('golden: translation editor (mode B, EN)', (tester) async {
    final cubit = await pump(tester);
    cubit.setPreviewLanguage('en');
    cubit.editTranslationField('en', 'hero.headline', 'Your mountain home in Trysil');
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StyledSplitView),
      matchesGoldenFile('goldens/02_edit_translation.png'),
    );
  });

  testWidgets('golden: mobile preview frame', (tester) async {
    final cubit = await pump(tester);
    cubit.setPreviewDevice(PreviewDevice.mobile);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StyledSplitView),
      matchesGoldenFile('goldens/03_mobile_preview.png'),
    );
  });

  testWidgets('golden: publish modal', (tester) async {
    final cubit = await pump(tester);
    final context = tester.element(find.byType(StyledSplitView));
    showPublishModal(context, state: cubit.state);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/04_publish_modal.png'),
    );
  });
}
