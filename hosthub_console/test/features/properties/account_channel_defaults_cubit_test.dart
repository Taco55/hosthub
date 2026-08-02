import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/properties/domain/account_settings.dart';
import 'package:hosthub_console/features/properties/properties.dart';

/// The tier cubit loads the moment the shell is entered, which can land
/// inside the same beat as a Supabase token refresh (app start, another tab
/// rotating the refresh token). Before this was fixed, that race left the
/// cubit stuck on an error card forever: nothing ever retried it.
void main() {
  late _FakeAuthPort authPort;

  setUp(() {
    authPort = _FakeAuthPort();
  });

  tearDown(() => authPort.close());

  test('a session event re-primes a load stuck on the boot-time auth race', () async {
    final repository = _RacyRepository(failFirstCalls: 1);
    final cubit = AccountChannelDefaultsCubit(
      repository: repository,
      authPort: authPort,
    );
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state.status, AccountChannelDefaultsStatus.error);
    expect(repository.calls, 1);

    authPort.emitSession(const AuthUser(id: 'user-1', email: 'a@b.test'));
    await pumpEventQueue();

    expect(cubit.state.status, AccountChannelDefaultsStatus.loaded);
    expect(repository.calls, 2);
  });

  test('a session event is a no-op once the tier already loaded', () async {
    final repository = _RacyRepository(failFirstCalls: 0);
    final cubit = AccountChannelDefaultsCubit(
      repository: repository,
      authPort: authPort,
    );
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state.status, AccountChannelDefaultsStatus.loaded);
    expect(repository.calls, 1);

    authPort.emitSession(const AuthUser(id: 'user-1', email: 'a@b.test'));
    await pumpEventQueue();

    expect(repository.calls, 1);
  });
}

/// Repository whose first [failFirstCalls] reads throw the same transient,
/// `logout: false` unauthorized error the real one throws when
/// `currentUserId` races a session refresh. The client is never touched.
class _RacyRepository extends AccountChannelDefaultsRepository {
  _RacyRepository({required this.failFirstCalls})
    : super(
        supabase: SupabaseClient(
          'http://localhost:7011',
          'sb_publishable_test',
        ),
      );

  final int failFirstCalls;
  int calls = 0;

  @override
  Future<String?> currentAccountOwnerId() async {
    calls++;
    if (calls <= failFirstCalls) {
      throw DomainErrorCode.unauthorized.err(
        reason: DomainErrorReason.cannotLoadData,
        message: 'User not logged in',
        logout: false,
      );
    }
    return 'owner-1';
  }

  @override
  Future<AccountChannelDefaults> fetch(String ownerProfileId) async =>
      AccountChannelDefaults.empty;

  @override
  Future<AccountSettings> fetchAccountSettings(String ownerProfileId) async =>
      AccountSettings.defaults;
}

class _FakeAuthPort implements AuthPort {
  final _sessions = StreamController<AuthSessionChange>.broadcast();

  void emitSession(AuthUser? user) =>
      _sessions.add(AuthSessionChange(user: user));

  Future<void> close() => _sessions.close();

  @override
  Stream<AuthSessionChange> get onAuthStateChange => _sessions.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
