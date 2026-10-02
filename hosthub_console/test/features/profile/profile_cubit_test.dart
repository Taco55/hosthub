import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/app/bootstrap/domain_errors_setup.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/application/profile_cubit.dart';
import 'package:hosthub_console/features/profile/data/profile_repository.dart';

/// A profile row whose auth user is gone fails on `profiles_id_fkey`: the
/// session belongs to no user any more, so the cubit signs out. The
/// Postgres failure reaches it through the Supabase adapter, which keeps the
/// constraint in the error's message and its `PostgrestDetail`.
void main() {
  late _FakeAuthPort authPort;

  setUp(() {
    configureDomainErrors();
    authPort = _FakeAuthPort();
  });

  tearDown(DomainErrors.resetForTesting);

  Future<ProfileCubit> updateFailingWith(PostgrestException failure) async {
    final cubit = ProfileCubit(
      sessionManager: SessionManager(authService: authPort),
      profileRepository: _FailingProfileRepository(failure),
    );
    addTearDown(cubit.close);
    await cubit.updateProfile(
      const Profile(id: 'user-1', email: 'a@b.test', createdBy: 'user-1'),
    );
    return cubit;
  }

  test('a missing auth user named by the message signs out', () async {
    final cubit = await updateFailingWith(
      const PostgrestException(
        message:
            'insert or update on table "profiles" violates foreign key '
            'constraint "profiles_id_fkey"',
        code: '23503',
        details: 'Key (id)=(user-1) is not present in table "users".',
      ),
    );

    expect(cubit.state.status, ProfileStatus.requiresSignOut);
    expect(authPort.signOuts, 1);
  });

  test('a missing auth user named by the details signs out', () async {
    final cubit = await updateFailingWith(
      const PostgrestException(
        message: 'violates foreign key constraint',
        code: '23503',
        details: 'constraint "profiles_id_fkey"',
      ),
    );

    expect(cubit.state.status, ProfileStatus.requiresSignOut);
    expect(authPort.signOuts, 1);
  });

  test('another foreign key keeps the session', () async {
    final cubit = await updateFailingWith(
      const PostgrestException(
        message:
            'insert or update on table "profiles" violates foreign key '
            'constraint "profiles_site_id_fkey"',
        code: '23503',
        details: 'Key (site_id)=(site-1) is not present in table "sites".',
      ),
    );

    expect(cubit.state.status, ProfileStatus.error);
    expect(authPort.signOuts, 0);
  });

  test('a failure that is no foreign-key violation keeps the session, '
      'whatever its text names', () async {
    final cubit = await updateFailingWith(
      const PostgrestException(
        message: 'new row violates row-level security policy for "profiles"',
        code: '42501',
        details: 'policy guards profiles_id_fkey',
      ),
    );

    expect(cubit.state.status, ProfileStatus.error);
    expect(authPort.signOuts, 0);
  });
}

/// A repository whose writes fail with [failure], converted by the real
/// repository code; the client is never touched.
class _FailingProfileRepository extends ProfileRepository {
  _FailingProfileRepository(this.failure)
    : super(
        supabase: SupabaseClient(
          'http://localhost:7011',
          'sb_publishable_test',
        ),
      );

  final PostgrestException failure;

  @override
  Future<void> upsert(
    String table,
    Map<String, dynamic> json, {
    bool ensureCreatedBy = true,
    String? onConflict,
  }) async => throw failure;
}

class _FakeAuthPort implements AuthPort {
  int signOuts = 0;

  @override
  Future<void> refreshSessionIfNeeded() async {}

  @override
  Future<void> signOut() async => signOuts++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
