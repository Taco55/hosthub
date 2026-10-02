import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/core/errors/hosthub_error_reason.dart';
import 'package:hosthub_console/features/profile/data/profile_repository.dart';

import '../../support/fake_supabase.dart';

void main() {
  tearDown(DomainErrors.resetForTesting);

  test('delete_user answering a status other than 200 is reported once, '
      'naming the account data it left', () async {
    final reported = <DomainError>[];
    DomainError.onUnexpectedError = reported.add;
    final supabase = FakeSupabase(
      (request) => request.url.path == '/functions/v1/delete_user'
          ? FakeSupabase.json(const <String, Object?>{}, status: 202)
          : null,
    );
    final repository = ProfileRepository(supabase: supabase.client);

    await expectLater(
      repository.deleteUser('user-2'),
      throwsA(
        isA<DomainError>()
            .having((e) => e.code, 'code', DomainErrorCode.serverError)
            .having(
              (e) => e.reason,
              'reason',
              HosthubErrorReason.cannotDeleteAllUserData,
            ),
      ),
    );
    expect(reported, hasLength(1));
    expect(reported.single.context?['function_status'], 202);
  });
}
