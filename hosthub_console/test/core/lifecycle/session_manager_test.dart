import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/auth/auth.dart';

void main() {
  tearDown(DomainErrors.resetForTesting);

  test('a sign-out that fails stays silent to the caller, '
      'and is reported once', () async {
    final reported = <DomainError>[];
    DomainError.onUnexpectedError = reported.add;
    final manager = SessionManager(authService: _FailingSignOut());

    await manager.signOutSilently();

    expect(reported, hasLength(1));
    expect(reported.single.cause, isA<StateError>());
  });
}

class _FailingSignOut implements AuthPort {
  @override
  Future<void> signOut() async => throw StateError('sign-out failed');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
