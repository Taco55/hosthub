import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/core/widgets/layout/status_pill.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';

/// Properties owns the list (handoff §8.5): one action to add, and per row the
/// **origin**, because origin decides whether the destructive action unlinks or
/// deletes.
class _FakePropertyContextCubit extends Cubit<PropertyContextState>
    implements PropertyContextCubit {
  _FakePropertyContextCubit(super.initialState);

  final unlinked = <int>[];
  final deleted = <int>[];

  @override
  Future<bool> unlinkProperty(PropertySummary property) async {
    unlinked.add(property.id);
    return true;
  }

  @override
  Future<bool> deleteProperty(PropertySummary property) async {
    deleted.add(property.id);
    return true;
  }

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAccountDefaultsCubit extends Cubit<AccountChannelDefaultsState>
    implements AccountChannelDefaultsCubit {
  _FakeAccountDefaultsCubit()
    : super(
        const AccountChannelDefaultsState(
          status: AccountChannelDefaultsStatus.loaded,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SilentChannelManager implements ChannelManagerRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _fromLodgify = PropertySummary(
  id: 1,
  name: 'Trysil Panorama',
  lodgifyId: '428193',
);
const _manual = PropertySummary(id: 2, name: 'Vestfjord Cabin');

Future<_FakePropertyContextCubit> pumpProperties(
  WidgetTester tester, {
  List<PropertySummary> properties = const [_fromLodgify, _manual],
  Size surface = const Size(1180, 900),
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final propertyContext = _FakePropertyContextCubit(
    PropertyContextState(
      status: PropertyContextStatus.loaded,
      properties: properties,
      currentProperty: properties.isEmpty ? null : properties.first,
    ),
  );
  final accountDefaults = _FakeAccountDefaultsCubit();
  final reservations = ReservationsCubit(
    channelManagerRepository: _SilentChannelManager(),
  );
  addTearDown(propertyContext.close);
  addTearDown(accountDefaults.close);
  addTearDown(reservations.close);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<PropertyContextCubit>.value(value: propertyContext),
        BlocProvider<AccountChannelDefaultsCubit>.value(value: accountDefaults),
        BlocProvider<ReservationsCubit>.value(value: reservations),
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
        home: const PropertiesPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return propertyContext;
}

void main() {
  testWidgets('every row states where it came from', (tester) async {
    await pumpProperties(tester);

    expect(find.text('Trysil Panorama'), findsOneWidget);
    expect(find.text('Vestfjord Cabin'), findsOneWidget);

    final origins = tester
        .widgetList<StatusPill>(find.byType(StatusPill))
        .map((pill) => pill.label)
        .toList();
    expect(origins, containsAll(['From Lodgify', 'Manual']));
  });

  testWidgets('a synced property is unlinked, never deleted', (tester) async {
    final cubit = await pumpProperties(tester);

    await tester.tap(
      find.byTooltip('Unlink from Lodgify'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    // The dialog says which promise it keeps: the listing stays in Lodgify.
    expect(find.text('Unlink Trysil Panorama?'), findsOneWidget);
    expect(find.textContaining('stays in Lodgify'), findsOneWidget);

    await tester.tap(find.text('Unlink'));
    await tester.pumpAndSettle();

    expect(cubit.unlinked, [_fromLodgify.id]);
    expect(cubit.deleted, isEmpty);
  });

  testWidgets('a property made by hand is really deleted', (tester) async {
    final cubit = await pumpProperties(tester);

    await tester.tap(find.byTooltip('Delete property'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Delete Vestfjord Cabin?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(cubit.deleted, [_manual.id]);
    expect(cubit.unlinked, isEmpty);
  });

  testWidgets('adding is the list\'s last row, and internal keys stay out', (
    tester,
  ) async {
    await pumpProperties(tester);

    final add = find.widgetWithText(StyledTile, 'Add property');
    expect(add, findsOneWidget);
    expect(
      tester.widget<StyledTile>(add).titleColor,
      HosthubDiploraV1Palette.primary,
    );

    // The listings table's `ID` / `Lodgify ID` columns did not come along.
    expect(find.text('Lodgify ID'), findsNothing);
    expect(find.text('428193'), findsNothing);
    expect(find.byType(StyledDataTable), findsNothing);
  });

  testWidgets('the list can be left the way it was entered', (tester) async {
    await pumpProperties(tester);

    // No sidebar row leads here — Account · Koppelingen does — so the header
    // carries the way back, and names it rather than saying just "Back".
    expect(find.byType(StyledWebBackButton), findsOneWidget);
    expect(
      tester.widget<StyledWebPageScaffold>(
        find.byType(StyledWebPageScaffold),
      ).backLabel,
      'Account',
    );
  });

  testWidgets('an empty account is offered the same two routes', (
    tester,
  ) async {
    await pumpProperties(tester, properties: const []);

    expect(find.byType(StyledEmptyState), findsOneWidget);
    expect(find.text('No properties in this account yet.'), findsOneWidget);
    expect(find.text('Add property'), findsOneWidget);
  });
}
