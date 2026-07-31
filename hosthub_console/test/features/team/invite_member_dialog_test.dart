import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/team/application/site_members_cubit.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';
import 'package:hosthub_console/features/team/presentation/dialogs/invite_member_dialog.dart';

class _FakeSiteMembersCubit extends Cubit<SiteMembersState>
    implements SiteMembersCubit {
  _FakeSiteMembersCubit({this.succeeds = true})
    : super(const SiteMembersState());

  final bool succeeds;
  final List<String> invited = [];

  @override
  Future<bool> inviteMember({
    required String email,
    required SiteMemberRole role,
    required String siteName,
  }) async {
    invited.add('member:$email:${role.name}');
    return succeeds;
  }

  @override
  Future<bool> invitePartner({
    required String email,
    required SiteMemberRole role,
  }) async {
    invited.add('partner:$email:${role.name}');
    return succeeds;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The footer intent hands its callback no controller, so the form resolves one
/// from its own context. These tests pin that lookup end to end — it asserts
/// rather than failing quietly if the form ever stops being a descendant of the
/// modal that owns it.
Future<(Future<bool?>, _FakeSiteMembersCubit)> _open(
  WidgetTester tester, {
  bool succeeds = true,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = _FakeSiteMembersCubit(succeeds: succeeds);
  addTearDown(cubit.close);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );
  final styledTheme = HosthubThemePreset.styledTheme(
    lightMaterialTheme: lightTheme,
  );

  late BuildContext pageContext;
  await tester.pumpWidget(
    BlocProvider<SiteMembersCubit>.value(
      value: cubit,
      child: MaterialApp(
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
    ),
  );

  final result = showInviteMemberDialog(pageContext, siteName: 'Trysil');
  await tester.pumpAndSettle();
  return (result, cubit);
}

void main() {
  testWidgets('a sent invitation closes the modal with success', (
    tester,
  ) async {
    final (result, cubit) = await _open(tester);

    await tester.enterText(find.byType(TextField).first, 'guest@example.com');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(StyledButton, 'Send invitation'));
    await tester.pumpAndSettle();

    expect(cubit.invited, ['member:guest@example.com:editor']);
    expect(await result, isTrue);
  });

  testWidgets('an invalid address keeps the modal open and sends nothing', (
    tester,
  ) async {
    final (result, cubit) = await _open(tester);

    await tester.enterText(find.byType(TextField).first, 'not-an-address');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(StyledButton, 'Send invitation'));
    await tester.pumpAndSettle();

    expect(cubit.invited, isEmpty);
    // Still up, with what was typed.
    expect(
      find.widgetWithText(StyledButton, 'Send invitation'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(StyledTextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
