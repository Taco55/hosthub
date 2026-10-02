import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/cms/cms.dart';

void main() {
  tearDown(DomainErrors.resetForTesting);

  Future<CmsCubit> loadedCubit(_SettingsRepository repository) async {
    final cubit = CmsCubit(cmsRepository: repository);
    addTearDown(cubit.close);
    await cubit.loadSiteContent(siteId: 'site-1');
    return cubit;
  }

  group('saving the site settings', () {
    test('answers that they were saved', () async {
      final repository = _SettingsRepository();
      final cubit = await loadedCubit(repository);

      final saved = await cubit.saveSiteSettings(contactEmail: 'a@b.test');

      expect(saved, isTrue);
      expect(repository.savedContactEmails, ['a@b.test']);
      expect(cubit.state.error, isNull);
    });

    test('answers that they were not, and leaves the failure in the state '
        'as a failed save, for the page to show', () async {
      final repository = _SettingsRepository()
        ..saveFailure = Exception('offline');
      final cubit = await loadedCubit(repository);

      final saved = await cubit.saveSiteSettings(contactEmail: 'a@b.test');

      expect(saved, isFalse);
      expect(cubit.state.error?.operation, DomainOperation.save);
    });
  });
}

/// A repository for one site, whose settings write fails with [saveFailure];
/// the client is never touched.
class _SettingsRepository extends CmsRepository {
  _SettingsRepository()
    : super(
        supabase: SupabaseClient(
          'http://localhost:7011',
          'sb_publishable_test',
        ),
      );

  Object? saveFailure;
  final savedContactEmails = <String?>[];

  @override
  Future<SiteSummary?> fetchSite(String siteId) async => SiteSummary(
    id: siteId,
    name: 'Site',
    defaultLocale: 'nl',
    locales: const ['nl'],
    timezone: 'Europe/Amsterdam',
    createdAt: DateTime(2026),
  );

  @override
  Future<List<ContentDocument>> fetchSiteDocuments({
    required String siteId,
    String? locale,
    String? contentType,
  }) async => const [];

  @override
  Future<String?> fetchPrimaryDomain(String siteId) async => null;

  @override
  Future<void> updateSiteSettings(
    String siteId, {
    String? contactEmail,
    String? emailFromName,
    String? lodgifyPropertyId,
    String? lodgifyRoomTypeId,
  }) async {
    final failure = saveFailure;
    if (failure != null) throw failure;
    savedContactEmails.add(contactEmail);
  }
}
