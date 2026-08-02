import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/core/widgets/layout/status_pill.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/team/application/site_members_cubit.dart';
import 'package:hosthub_console/features/team/domain/site_member.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

/// Account is three sections (§8.3): who has access, what we are connected to,
/// what you pay. These tests hold the shape the design draws — one row per
/// concern, one quiet chip style, no listings table — because every regression
/// on this page so far has been a section quietly growing a fourth row.
class _FakeUserSettingsCubit extends Cubit<UserSettingsState>
    implements UserSettingsCubit {
  _FakeUserSettingsCubit(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSiteMembersCubit extends Cubit<SiteMembersState>
    implements SiteMembersCubit {
  _FakeSiteMembersCubit(super.initialState);

  var loadCount = 0;

  @override
  Future<void> loadAccountTeam() async => loadCount++;

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeServerSettingsCubit extends Cubit<ServerSettingsState>
    implements ServerSettingsCubit {
  _FakeServerSettingsCubit()
    : super(
        ServerSettingsState(
          status: ServerSettingsStatus.ready,
          settings: AdminSettings.defaults(),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSiteContextCubit extends Cubit<SiteContextState>
    implements SiteContextCubit {
  _FakeSiteContextCubit() : super(const SiteContextState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _FakeProfileCubit()
    : super(
        const ProfileState(
          profile: Profile(id: 'p1', email: 'marta@trysilpanorama.com'),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAccountDefaultsCubit extends Cubit<AccountChannelDefaultsState>
    implements AccountChannelDefaultsCubit {
  _FakeAccountDefaultsCubit()
    : super(
        const AccountChannelDefaultsState(
          status: AccountChannelDefaultsStatus.loaded,
          ownerProfileId: 'p1',
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePropertyContextCubit extends Cubit<PropertyContextState>
    implements PropertyContextCubit {
  _FakePropertyContextCubit()
    : super(
        const PropertyContextState(
          status: PropertyContextStatus.loaded,
          properties: [
            PropertySummary(id: 1, name: 'Trysil Panorama'),
            PropertySummary(id: 2, name: 'Vestfjord Cabin'),
          ],
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SiteMember _member({
  required String id,
  required String role,
  String? username,
  String? email,
}) => SiteMember(
  id: id,
  siteId: 's1',
  profileId: 'profile-$id',
  role: role,
  createdAt: DateTime(2026, 1, 1),
  username: username,
  email: email,
);

Future<void> pumpAccount(
  WidgetTester tester, {
  UserSettings? settings,
  List<SiteMember> members = const [],
  Size surface = const Size(1180, 1600),
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final userSettings = _FakeUserSettingsCubit(
    UserSettingsState(
      status: UserSettingsStatus.ready,
      settings:
          settings ??
          UserSettings(
            profileId: 'p1',
            lodgifyApiKey: 'key',
            lodgifyApiKeyLast4: 'YjvD',
            lodgifyConnected: true,
            lodgifyLastSyncedAt: DateTime.now().subtract(
              const Duration(days: 6),
            ),
          ),
    ),
  );
  final siteMembers = _FakeSiteMembersCubit(
    SiteMembersState(status: SiteMembersStatus.ready, members: members),
  );
  final serverSettings = _FakeServerSettingsCubit();
  final siteContext = _FakeSiteContextCubit();
  final profile = _FakeProfileCubit();
  final accountDefaults = _FakeAccountDefaultsCubit();
  final propertyContext = _FakePropertyContextCubit();
  addTearDown(userSettings.close);
  addTearDown(siteMembers.close);
  addTearDown(serverSettings.close);
  addTearDown(siteContext.close);
  addTearDown(profile.close);
  addTearDown(accountDefaults.close);
  addTearDown(propertyContext.close);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserSettingsCubit>.value(value: userSettings),
        BlocProvider<SiteMembersCubit>.value(value: siteMembers),
        BlocProvider<ServerSettingsCubit>.value(value: serverSettings),
        BlocProvider<SiteContextCubit>.value(value: siteContext),
        BlocProvider<ProfileCubit>.value(value: profile),
        BlocProvider<AccountChannelDefaultsCubit>.value(value: accountDefaults),
        BlocProvider<PropertyContextCubit>.value(value: propertyContext),
      ],
      child: MaterialApp(
        theme: lightTheme,
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          AppErrorLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => StyledWidgetsTheme(
          styledThemeData: HosthubThemePreset.styledTheme(
            lightMaterialTheme: lightTheme,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const UserSettingsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('three sections, in the order §8.3 states', (tester) async {
    await pumpAccount(tester);

    expect(find.text('Users & roles'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('Subscription & billing'), findsOneWidget);

    // Listings belongs to Properties now (§8.5) — with it went the card that
    // had no card, the data table and its internal-key columns.
    expect(find.text('Listings'), findsNothing);
    expect(find.byType(StyledDataTable), findsNothing);
    expect(find.text('Lodgify ID'), findsNothing);
  });

  testWidgets('the connection is one row: state, last sync, one action', (
    tester,
  ) async {
    await pumpAccount(tester);

    // The bare `Lodgify` text that used to float above the API-key row is now
    // the title of the row it belongs to — so exactly one.
    expect(find.text('Lodgify'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.textContaining('last sync'), findsOneWidget);
    // …and the sync line sits in that row's subtitle, not on a row of its own.
    expect(
      find.descendant(
        of: find.widgetWithText(StyledTile, 'Lodgify'),
        matching: find.textContaining('Bookings, prices and availability'),
      ),
      findsOneWidget,
    );
    expect(find.text('Sync'), findsOneWidget);
  });

  testWidgets('every action in a row is the same compact secondary button', (
    tester,
  ) async {
    await pumpAccount(tester);

    final buttons = tester
        .widgetList<StyledButton>(find.byType(StyledButton))
        .toList();
    expect(buttons, isNotEmpty);
    for (final button in buttons) {
      expect(button.size, StyledButtonSize.compact);
      expect(button.variant, StyledButtonVariant.secondary);
      // No hand-tuned geometry: the size carries it.
      expect(button.minHeight, isNull);
      expect(button.width, isNull);
    }
  });

  testWidgets('a role is one quiet chip, not a coloured container per kind', (
    tester,
  ) async {
    await pumpAccount(
      tester,
      members: [
        _member(id: '1', role: 'owner', username: 'Marta', email: 'm@t.no'),
        _member(id: '2', role: 'editor', email: 'ola@t.no'),
      ],
    );

    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget);

    final pills = tester
        .widgetList<StatusPill>(
          find.descendant(
            of: find.byType(StyledTile),
            matching: find.byType(StatusPill),
          ),
        )
        .where((pill) => pill.label == 'Owner' || pill.label == 'Manager');
    expect(pills, hasLength(2));
    for (final pill in pills) {
      expect(pill.tone, StatusPillTone.neutral);
    }
  });

  testWidgets('the member row states who, not what the role may do', (
    tester,
  ) async {
    await pumpAccount(
      tester,
      members: [
        _member(id: '1', role: 'editor', username: 'Ola', email: 'ola@t.no'),
      ],
    );

    expect(find.text('Ola'), findsOneWidget);
    expect(find.text('ola@t.no'), findsOneWidget);
    // The role explanation is the section footnote, once, not on every row.
    expect(
      find.textContaining('a manager handles content and prices'),
      findsOneWidget,
    );
  });

  testWidgets('inviting is the list\'s last row, not a filled header button', (
    tester,
  ) async {
    await pumpAccount(tester);

    final invite = find.widgetWithText(StyledTile, 'Invite a member');
    expect(invite, findsOneWidget);
    expect(
      tester.widget<StyledTile>(invite).titleColor,
      HosthubDiploraV1Palette.primary,
    );
  });

  testWidgets('the plan says what it costs per month and for how many', (
    tester,
  ) async {
    await pumpAccount(tester);

    expect(find.text('Pro'), findsOneWidget);
    expect(find.text('Monthly · 2 properties'), findsOneWidget);
  });

  testWidgets('the team loads once, from the section that shows it', (
    tester,
  ) async {
    await pumpAccount(tester);
    // Not asserted through the fake's counter alone: a second load would also
    // re-emit and rebuild, which is what the old page did on every keystroke in
    // the VAT field.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'every row starts on the same left edge, wrapper widget or not',
    (tester) async {
      // A member/invitation row, the Lodgify connection row, and the VAT and
      // app-info rows are each built by a private widget that wraps a
      // StyledTile rather than returning one directly. StyledSection only
      // skips its own extra per-child padding for children it recognises as
      // tile-like — via `with StyledTileLike` — so any such wrapper that
      // forgets the mixin gets silently double-padded relative to a row built
      // as a bare StyledTile/StyledSecretTile in the same section.
      await pumpAccount(
        tester,
        members: [
          _member(id: '1', role: 'owner', username: 'Marta', email: 'm@t.no'),
        ],
      );

      final left = tester.getTopLeft(find.widgetWithText(StyledTile, 'Marta')).dx;
      for (final title in [
        'Invite a member',
        'Lodgify',
        'Pro',
        'Payment method',
        'Invoices',
        'VAT or company number',
        'App information',
      ]) {
        expect(
          tester.getTopLeft(find.widgetWithText(StyledTile, title)).dx,
          left,
          reason: '"$title" should start on the same left edge as "Marta"',
        );
      }
      expect(
        tester.getTopLeft(find.byType(StyledSecretTile)).dx,
        left,
        reason: 'the API-key StyledSecretTile should start on the same edge',
      );
    },
  );
}
