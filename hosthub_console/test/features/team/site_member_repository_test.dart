import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/team/data/site_member_repository.dart';
import 'package:hosthub_console/features/team/domain/site_invitation.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';

import '../../support/fake_supabase.dart';

/// invite_site_member answering a status other than 200 is the function's
/// failure: reported once, as a failed save, with the function's own words.
void main() {
  tearDown(DomainErrors.resetForTesting);

  late List<DomainError> reported;
  late SiteMemberRepository repository;

  setUp(() async {
    reported = [];
    DomainError.onUnexpectedError = reported.add;
    final supabase = FakeSupabase(
      (request) => request.url.path == '/functions/v1/invite_site_member'
          ? FakeSupabase.json(const {'error': 'mail not sent'}, status: 202)
          : null,
    );
    await supabase.signIn();
    repository = SiteMemberRepository(
      supabase: supabase.client,
      setPasswordRedirectUri: 'https://console.test/set-password',
    );
  });

  Matcher failedSave(String op) => throwsA(
    isA<DomainError>()
        .having((e) => e.code, 'code', DomainErrorCode.serverError)
        .having((e) => e.operation, 'operation', DomainOperation.save)
        .having((e) => e.message, 'message', 'mail not sent')
        .having((e) => e.context?['op'], 'op', op),
  );

  test('an invitation', () async {
    await expectLater(
      repository.inviteMember(
        siteId: 'site-1',
        email: 'guest@example.com',
        role: SiteMemberRole.values.first,
        siteName: 'Site',
      ),
      failedSave('inviteMember'),
    );
    expect(reported, hasLength(1));
  });

  test('a resent invitation', () async {
    await expectLater(
      repository.resendInvitation(
        invitation: SiteInvitation(
          id: 'invitation-1',
          siteId: 'site-1',
          email: 'guest@example.com',
          role: SiteMemberRole.values.first.name,
          status: 'pending',
          expiresAt: DateTime(2026, 10, 9),
          createdAt: DateTime(2026, 10, 2),
        ),
        siteName: 'Site',
      ),
      failedSave('resendInvitation'),
    );
    expect(reported, hasLength(1));
  });
}
