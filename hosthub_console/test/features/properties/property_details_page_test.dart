import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/properties/properties.dart';

/// The property record is a **read-only** page (design "PROPERTY DETAILS"):
/// Lodgify owns these fields, so the page states them — it never offers a field
/// to fill in. These tests hold that promise, and the reading order the design
/// draws: connection → source note → Address → Rental → raw payload.
class _FakePropertyRepository implements PropertyRepository {
  _FakePropertyRepository(this._details);

  PropertyDetails _details;
  int fetchCount = 0;
  int saveCount = 0;
  ChannelPropertyDetails? savedDetails;

  set details(PropertyDetails value) => _details = value;

  @override
  Future<PropertyDetails> fetchPropertyDetails(int id) async {
    fetchCount++;
    return _details;
  }

  @override
  Future<PropertyDetails> saveChannelDetails({
    required int propertyId,
    required ChannelPropertyDetails details,
    DateTime? syncedAt,
  }) async {
    saveCount++;
    savedDetails = details;
    // The real update returns the stored row, so the page shows what was saved.
    _details = _stored(details, syncedAt ?? DateTime(2026, 7, 26, 9, 30));
    return _details;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// What the row looks like after [PropertyRepository.saveChannelDetails] wrote
/// the channel record onto it — only the fields these tests read back.
PropertyDetails _stored(ChannelPropertyDetails details, DateTime syncedAt) =>
    PropertyDetails(
      id: 7,
      name: details.name ?? 'Trysil Panorama',
      lodgifyId: '428193',
      address: details.address,
      zip: details.zip,
      city: details.city,
      country: details.country,
      rating: details.rating,
      minPrice: details.minPrice,
      maxPrice: details.maxPrice,
      currency: details.currency,
      rooms: details.rooms,
      lodgifySyncedAt: syncedAt,
    );

/// Stands in for Lodgify: hands back one record, or throws the way a rejected
/// API key does.
class _FakeChannelManagerRepository implements ChannelManagerRepository {
  _FakeChannelManagerRepository({this.record, this.failure});

  final ChannelPropertyDetails? record;
  final Object? failure;

  int fetchCount = 0;
  String? requestedPropertyId;

  @override
  Future<ChannelPropertyDetails> fetchPropertyDetails(
    String propertyId,
  ) async {
    fetchCount++;
    requestedPropertyId = propertyId;
    final error = failure;
    if (error != null) throw error;
    return record ?? const ChannelPropertyDetails();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePropertyContextCubit extends Cubit<PropertyContextState>
    implements PropertyContextCubit {
  _FakePropertyContextCubit(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PropertyDetails _details({
  String? address = 'Fageråsvegen 22',
  String? zip = '2420',
  String? city = 'Trysil',
  String? country = 'Norway',
  String? lodgifyId = '428193',
  num? rating = 4.8,
  num? minPrice = 2400,
  num? maxPrice = 4100,
  int? priceUnitInDays = 1,
  bool? hasAddons = true,
  bool? hasAgreement = false,
  Object? rooms = const [
    {'name': 'Main bedroom', 'max_people': 2},
    {'name': 'Bedroom 2', 'max_people': 4},
  ],
  Object? inOut = const {'checkIn': '16:00'},
  DateTime? lodgifySyncedAt,
}) => PropertyDetails(
  id: 7,
  name: 'Trysil Panorama',
  lodgifyId: lodgifyId,
  lodgifySyncedAt: lodgifySyncedAt,
  address: address,
  zip: zip,
  city: city,
  country: country,
  rating: rating,
  minPrice: minPrice,
  maxPrice: maxPrice,
  priceUnitInDays: priceUnitInDays,
  hasAddons: hasAddons,
  hasAgreement: hasAgreement,
  ownerSpokenLanguages: const ['Norwegian', 'English'],
  rooms: rooms,
  inOut: inOut,
  currency: 'NOK',
);

class _Harness {
  _Harness({required this.repository, required this.channelManager});

  final _FakePropertyRepository repository;
  final _FakeChannelManagerRepository channelManager;
}

Future<_Harness> pumpPage(
  WidgetTester tester, {
  PropertyDetails? details,
  ChannelPropertyDetails? channelRecord,
  Object? channelFailure,
  Size surface = const Size(1280, 1600),
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final repository = _FakePropertyRepository(details ?? _details());
  final channelManager = _FakeChannelManagerRepository(
    record: channelRecord,
    failure: channelFailure,
  );
  final propertyContext = _FakePropertyContextCubit(
    const PropertyContextState(
      status: PropertyContextStatus.loaded,
      properties: [PropertySummary(id: 7, name: 'Trysil Panorama')],
      currentProperty: PropertySummary(id: 7, name: 'Trysil Panorama'),
    ),
  );
  addTearDown(propertyContext.close);

  final lightTheme = HosthubThemePreset.applyMaterialTheme(
    baseTheme: ThemeData.light(),
    brightness: Brightness.light,
  );

  await tester.pumpWidget(
    _PageHost(
      repository: repository,
      channelManager: channelManager,
      propertyContext: propertyContext,
      lightTheme: lightTheme,
    ),
  );
  await tester.pumpAndSettle();

  return _Harness(repository: repository, channelManager: channelManager);
}

/// The page reads its two repositories from the widget tree and the selected
/// property from a bloc, so the harness supplies exactly those three. It no
/// longer needs the settings cubit: the sync stamp it shows is a column on the
/// property row, not an account-wide setting.
class _PageHost extends StatelessWidget {
  const _PageHost({
    required this.repository,
    required this.channelManager,
    required this.propertyContext,
    required this.lightTheme,
  });

  final PropertyRepository repository;
  final ChannelManagerRepository channelManager;
  final PropertyContextCubit propertyContext;
  final ThemeData lightTheme;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PropertyContextCubit>.value(value: propertyContext),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PropertyRepository>.value(value: repository),
          RepositoryProvider<ChannelManagerRepository>.value(
            value: channelManager,
          ),
        ],
        child: MaterialApp(
          theme: lightTheme,
          // A failed sync is reported through app_errors, which brings its own
          // localizations.
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
          home: const PropertyDetailsPage(),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('states the record instead of offering fields to fill in', (
    tester,
  ) async {
    await pumpPage(tester);

    // The whole point of the page: nothing here is an input.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(StyledTextFormField), findsNothing);

    // Design `.top`: crumb over a title that names the property.
    expect(find.text('Property'), findsOneWidget);
    expect(find.text('Trysil Panorama'), findsOneWidget);

    // Two cards of definition rows, in the design's order.
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Rental'), findsOneWidget);
    expect(find.byType(StyledDefinitionList), findsNWidgets(2));

    expect(find.text('Street'), findsOneWidget);
    expect(find.text('Fageråsvegen 22'), findsOneWidget);
    expect(find.text('Trysil'), findsOneWidget);
    expect(find.text('Norway'), findsOneWidget);

    // The footnote that explains why the page is read-only.
    expect(
      find.textContaining('comes from Lodgify', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('the connection row names the Lodgify property and its state', (
    tester,
  ) async {
    await pumpPage(
      tester,
      details: _details(
        lodgifySyncedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    );

    expect(find.text('Lodgify'), findsOneWidget);
    expect(find.textContaining('ID 428193'), findsOneWidget);
    expect(find.textContaining('last sync'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('a linked property that was never synced says so', (
    tester,
  ) async {
    // The state every property starts in: linked, but holding column defaults
    // rather than anything Lodgify said. Saying "last sync yesterday" here —
    // which is what the account-wide stamp would claim — would be a lie about
    // the empty cards below.
    await pumpPage(tester);

    expect(find.textContaining('never synced'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
  });

  testWidgets('an unlinked property says so instead of showing an ID', (
    tester,
  ) async {
    await pumpPage(tester, details: _details(lodgifyId: null));

    expect(find.text('Not linked'), findsOneWidget);
    expect(find.textContaining('ID'), findsNothing);
  });

  testWidgets('derived values read as sentences, not as raw columns', (
    tester,
  ) async {
    await pumpPage(tester);

    // rooms → count + summed capacity; rating → out of five; prices → a band.
    expect(find.text('2 rooms · 6 guests'), findsOneWidget);
    expect(find.text('4.8 out of 5'), findsOneWidget);
    expect(find.text('2400 NOK – 4100 NOK'), findsOneWidget);
    expect(find.text('Per night'), findsOneWidget);
    // Flags become presence, in the design's vocabulary.
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('a field Lodgify did not send shows a placeholder, not a gap', (
    tester,
  ) async {
    await pumpPage(
      tester,
      details: _details(country: null, zip: '  ', rating: null),
    );

    // Country, ZIP and rating: three dashes, and the labels still there.
    expect(find.text('—'), findsNWidgets(3));
    expect(find.text('Country'), findsOneWidget);
  });

  testWidgets('the raw payload stays folded until asked for', (tester) async {
    await pumpPage(tester);

    expect(find.text('Raw data from Lodgify'), findsOneWidget);
    expect(
      find.text('Check-in/out rules, rooms, subscriptions'),
      findsOneWidget,
    );
    // Folded: the blocks are built but have no height and take no input.
    expect(find.byType(StyledCodeBlock).hitTestable(), findsNothing);

    await tester.tap(find.text('Raw data from Lodgify'));
    await tester.pumpAndSettle();

    expect(find.byType(StyledCodeBlock).hitTestable(), findsNWidgets(2));
    expect(find.textContaining('checkIn'), findsOneWidget);
  });

  testWidgets('sync pulls this property from Lodgify and stores what it sent', (
    tester,
  ) async {
    // Where the empty page came from: nothing in the console wrote these
    // columns. This is the press that does.
    final harness = await pumpPage(
      tester,
      details: _details(
        address: null,
        zip: null,
        city: null,
        country: null,
        rating: null,
        minPrice: null,
        maxPrice: null,
        rooms: null,
      ),
      channelRecord: const ChannelPropertyDetails(
        id: '428193',
        name: 'Trysil Panorama',
        address: 'Fageråsvegen 22',
        zip: '2420',
        city: 'Innbygda',
        country: 'Norway',
        rating: 4.8,
        minPrice: 2400,
        maxPrice: 4100,
        currency: 'NOK',
      ),
    );

    expect(find.text('Sync now'), findsOneWidget);
    await tester.tap(find.text('Sync now'));
    await tester.pumpAndSettle();

    // Asked Lodgify for this property, wrote the answer, and shows it — without
    // reading the row back a second time.
    expect(harness.channelManager.fetchCount, 1);
    expect(harness.channelManager.requestedPropertyId, '428193');
    expect(harness.repository.saveCount, 1);
    expect(harness.repository.savedDetails?.city, 'Innbygda');
    expect(harness.repository.fetchCount, 1);

    expect(find.text('Innbygda'), findsOneWidget);
    expect(find.text('Fageråsvegen 22'), findsOneWidget);
    expect(find.text('2400 NOK – 4100 NOK'), findsOneWidget);

    // The success toast dismisses itself on a timer; let it run out so the test
    // does not end with it still pending.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a failed sync reports it and keeps the record on screen', (
    tester,
  ) async {
    final harness = await pumpPage(
      tester,
      channelFailure: Exception('Missing Lodgify API key. Add one in Settings.'),
    );

    await tester.tap(find.text('Sync now'));
    await tester.pumpAndSettle();

    expect(harness.repository.saveCount, 0);
    // Old fields are old, not gone.
    expect(find.text('Fageråsvegen 22'), findsOneWidget);
    // And the button is available again rather than stuck in its busy state.
    expect(find.text('Sync now'), findsOneWidget);
  });

  testWidgets('without a Lodgify link the action only reads the row again', (
    tester,
  ) async {
    final harness = await pumpPage(tester, details: _details(lodgifyId: null));
    expect(harness.repository.fetchCount, 1);

    // Nothing to sync from, so the button says what it can do — and does that.
    expect(find.text('Sync now'), findsNothing);
    harness.repository.details = _details(lodgifyId: null, city: 'Innbygda');
    await tester.tap(find.text('Refresh data'));
    await tester.pumpAndSettle();

    expect(harness.channelManager.fetchCount, 0);
    expect(harness.repository.fetchCount, 2);
    expect(find.text('Innbygda'), findsOneWidget);
  });
}
