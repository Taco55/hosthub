import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/users/data/admin_user_repository.dart';

import '../../support/fake_supabase.dart';

/// A write the server accepted without handing back what it wrote is an
/// anomaly: reported once, as a failed save.
void main() {
  tearDown(DomainErrors.resetForTesting);

  late List<DomainError> reported;
  setUp(() {
    reported = [];
    DomainError.onUnexpectedError = reported.add;
  });

  // What PostgREST answers a write asked to return one row that matched none.
  final noRow = FakeSupabase.json(const {
    'code': 'PGRST116',
    'details':
        'Results contain 0 rows, '
        'application/vnd.pgrst.object+json requires 1 row',
    'message': 'JSON object requested, multiple (or no) rows returned',
  }, status: 406);
  const userId = '00000000-0000-4000-8000-000000000002';

  Matcher failedSave(String op) => throwsA(
    isA<DomainError>()
        .having((e) => e.code, 'code', DomainErrorCode.serverError)
        .having((e) => e.operation, 'operation', DomainOperation.save)
        .having((e) => e.context?['op'], 'op', op),
  );

  test('an admin flag update that returns no profile', () async {
    final supabase = FakeSupabase(
      (request) => request.url.path == '/rest/v1/profiles' ? noRow : null,
    );

    await expectLater(
      AdminUserRepository(supabase.client).updateAdminFlag(userId, true),
      failedSave('updateAdminFlag'),
    );
    expect(reported, hasLength(1));
  });

  test('a profile update that returns no profile', () async {
    final supabase = FakeSupabase(
      (request) => switch (request.url.path) {
        '/rest/v1/profiles' => noRow,
        '/auth/v1/admin/users/$userId' => FakeSupabase.json(const {
          'id': userId,
          'aud': 'authenticated',
          'app_metadata': <String, Object?>{},
          'user_metadata': <String, Object?>{},
          'created_at': '2026-09-26T10:00:00Z',
        }),
        _ => null,
      },
    );

    await expectLater(
      AdminUserRepository(
        supabase.client,
      ).updateProfileDetails(userId, email: 'guest@example.com'),
      failedSave('updateProfileDetails'),
    );
    expect(reported, hasLength(1));
  });

  test('admin_create_user answering without a user_id', () async {
    final supabase = FakeSupabase(
      (request) => request.url.path == '/functions/v1/admin_create_user'
          ? FakeSupabase.json(const <String, Object?>{})
          : null,
    );
    await supabase.signIn();

    await expectLater(
      AdminUserRepository(
        supabase.client,
      ).createUser(email: 'guest@example.com', password: 'secret-pass'),
      failedSave('createUser'),
    );
    expect(reported, hasLength(1));
  });
}
