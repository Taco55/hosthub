import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';

SiteSummary _site({
  String defaultLocale = 'nl',
  List<String> locales = const ['nl', 'en', 'no'],
  bool sourceLocaleFollowsUi = false,
  String name = 'Trysil Panorama',
}) => SiteSummary(
  id: 'site-1',
  name: name,
  defaultLocale: defaultLocale,
  locales: locales,
  timezone: 'Europe/Oslo',
  createdAt: DateTime.utc(2026, 2, 18),
  sourceLocaleFollowsUi: sourceLocaleFollowsUi,
);

ContentDocument _siteConfigDoc(String locale, Map<String, dynamic> content) =>
    ContentDocument(
      id: 'doc-$locale',
      siteId: 'site-1',
      contentType: 'site_config',
      slug: 'config',
      locale: locale,
      content: content,
      status: 'published',
      updatedAt: DateTime.utc(2026, 7, 24),
    );

/// In-memory CmsRepository: serves [site] and mutates it like the real
/// backing table would, recording every write.
class _FakeCmsRepository implements CmsRepository {
  _FakeCmsRepository({required this.site, this.siteConfigDocs = const []});

  SiteSummary site;
  List<ContentDocument> siteConfigDocs;
  String? primaryDomain = 'trysilpanorama.com';
  final List<String> writes = [];

  @override
  Future<List<SiteSummary>> fetchSites() async => [site];

  @override
  Future<String?> fetchPrimaryDomain(String siteId) async => primaryDomain;

  @override
  Future<List<ContentDocument>> fetchSiteDocuments({
    required String siteId,
    String? locale,
    String? contentType,
  }) async => [
    for (final doc in siteConfigDocs)
      if ((locale == null || doc.locale == locale) &&
          (contentType == null || doc.contentType == contentType))
        doc,
  ];

  @override
  Future<void> updateSiteDefaultLocale(String siteId, String locale) async {
    writes.add('defaultLocale=$locale');
    site = _copy(defaultLocale: locale);
  }

  @override
  Future<void> updateSiteLocales(String siteId, List<String> locales) async {
    writes.add('locales=${locales.join('+')}');
    site = _copy(locales: locales);
  }

  @override
  Future<void> updateSiteSourceFollowsUi(String siteId, bool follows) async {
    writes.add('followsUi=$follows');
    site = _copy(sourceLocaleFollowsUi: follows);
  }

  @override
  Future<void> updateSiteName(String siteId, String name) async {
    writes.add('name=$name');
    site = _copy(name: name);
  }

  @override
  Future<void> updateDocumentContent({
    required String documentId,
    required Map<String, dynamic> content,
  }) async {
    writes.add('doc:$documentId=${content['bookingUrl']}');
    siteConfigDocs = [
      for (final doc in siteConfigDocs)
        if (doc.id == documentId) _siteConfigDoc(doc.locale, content) else doc,
    ];
  }

  SiteSummary _copy({
    String? defaultLocale,
    List<String>? locales,
    bool? sourceLocaleFollowsUi,
    String? name,
  }) => SiteSummary(
    id: site.id,
    name: name ?? site.name,
    defaultLocale: defaultLocale ?? site.defaultLocale,
    locales: locales ?? site.locales,
    timezone: site.timezone,
    createdAt: site.createdAt,
    sourceLocaleFollowsUi: sourceLocaleFollowsUi ?? site.sourceLocaleFollowsUi,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePropertyContextCubit extends Cubit<PropertyContextState>
    implements PropertyContextCubit {
  _FakePropertyContextCubit() : super(const PropertyContextState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeCmsRepository repository;
  late _FakePropertyContextCubit propertyContext;

  Future<SiteContextCubit> makeCubit({
    SiteSummary? site,
    List<ContentDocument> docs = const [],
  }) async {
    repository = _FakeCmsRepository(
      site: site ?? _site(),
      siteConfigDocs: docs,
    );
    propertyContext = _FakePropertyContextCubit();
    addTearDown(propertyContext.close);
    final cubit = SiteContextCubit(
      cmsRepository: repository,
      propertyContext: propertyContext,
    );
    addTearDown(cubit.close);
    await pumpEventQueue();
    return cubit;
  }

  test(
    'resolve exposes the site with its primary domain and booking link',
    () async {
      final cubit = await makeCubit(
        docs: [
          _siteConfigDoc('nl', {'bookingUrl': 'https://book.example.com'}),
        ],
      );

      expect(cubit.state.status, SiteContextStatus.loaded);
      expect(cubit.state.site?.id, 'site-1');
      expect(cubit.state.primaryDomain, 'trysilpanorama.com');
      expect(cubit.state.bookingUrl, 'https://book.example.com');
      expect(cubit.state.addableLanguages, isNot(contains('nl')));
      expect(cubit.state.addableLanguages, contains('de'));
    },
  );

  test('addLanguage appends to the enabled locales', () async {
    final cubit = await makeCubit();

    await cubit.addLanguage('de');

    expect(repository.writes, contains('locales=nl+en+no+de'));
    expect(cubit.state.site?.locales, ['nl', 'en', 'no', 'de']);
  });

  test('removeLanguage drops a target language but never the source', () async {
    final cubit = await makeCubit();

    await cubit.removeLanguage('no');
    expect(cubit.state.site?.locales, ['nl', 'en']);

    await cubit.removeLanguage('nl'); // source — must be a no-op
    expect(repository.writes, isNot(contains('locales=en')));
    expect(cubit.state.site?.locales, ['nl', 'en']);
  });

  test('setSourceFollowsUi(true) aligns the source language with the '
      'interface language when the site offers it', () async {
    final cubit = await makeCubit();

    await cubit.setSourceFollowsUi(true, interfaceLanguage: 'en');

    expect(repository.writes, contains('followsUi=true'));
    expect(repository.writes, contains('defaultLocale=en'));
    expect(cubit.state.site?.defaultLocale, 'en');
    expect(cubit.state.site?.sourceLocaleFollowsUi, isTrue);
  });

  test('setSourceFollowsUi(true) keeps the source language when the interface '
      'language is not an enabled website language', () async {
    final cubit = await makeCubit();

    await cubit.setSourceFollowsUi(true, interfaceLanguage: 'fi');

    expect(repository.writes, contains('followsUi=true'));
    expect(
      repository.writes.where((w) => w.startsWith('defaultLocale=')),
      isEmpty,
    );
    expect(cubit.state.site?.defaultLocale, 'nl');
  });

  test(
    'followInterfaceLanguage syncs only when the follow switch is on',
    () async {
      final cubit = await makeCubit();

      // Switch off → explicit interface-language change must not touch it.
      await cubit.followInterfaceLanguage('en');
      expect(repository.writes, isEmpty);

      await cubit.setSourceFollowsUi(true, interfaceLanguage: 'nl');
      repository.writes.clear();

      await cubit.followInterfaceLanguage('en');
      expect(repository.writes, contains('defaultLocale=en'));

      repository.writes.clear();
      await cubit.followInterfaceLanguage('fi'); // not an enabled language
      expect(repository.writes, isEmpty);
    },
  );

  test('setSiteName and setBookingUrl persist the site details', () async {
    final cubit = await makeCubit(
      docs: [
        _siteConfigDoc('nl', {'bookingUrl': 'old'}),
        _siteConfigDoc('en', {'bookingUrl': 'old'}),
      ],
    );

    await cubit.setSiteName('Trysil Panorama Lodge');
    expect(cubit.state.site?.name, 'Trysil Panorama Lodge');

    await cubit.setBookingUrl('https://book.new.example');
    expect(repository.writes, contains('doc:doc-nl=https://book.new.example'));
    expect(repository.writes, contains('doc:doc-en=https://book.new.example'));
    expect(cubit.state.bookingUrl, 'https://book.new.example');
  });
}
