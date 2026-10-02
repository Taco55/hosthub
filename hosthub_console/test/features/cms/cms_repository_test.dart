import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/cms/data/cms_repository.dart';

import '../../support/fake_supabase.dart';

void main() {
  tearDown(DomainErrors.resetForTesting);

  test('manage_site_domain answering without a domain is reported once, '
      'as a failed save', () async {
    final reported = <DomainError>[];
    DomainError.onUnexpectedError = reported.add;
    final supabase = FakeSupabase(
      (request) => request.url.path == '/functions/v1/manage_site_domain'
          ? FakeSupabase.json(const <String, Object?>{})
          : null,
    );
    await supabase.signIn();

    await expectLater(
      CmsRepository(
        supabase: supabase.client,
      ).setPrimaryDomain(siteId: 'site-1', domain: 'example.com'),
      throwsA(
        isA<DomainError>()
            .having((e) => e.code, 'code', DomainErrorCode.serverError)
            .having((e) => e.operation, 'operation', DomainOperation.save),
      ),
    );
    expect(reported, hasLength(1));
  });
}
