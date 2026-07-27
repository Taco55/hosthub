import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:hosthub_console/features/auth/infrastructure/supabase/auth_user_existence_check.dart';

void main() {
  group('AuthUserExistenceCheck', () {
    test('recognises the user_not_found error code', () {
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          const sb.AuthException(
            'User from sub claim in JWT does not exist',
            statusCode: '403',
            code: 'user_not_found',
          ),
        ),
        isTrue,
      );
    });

    test('recognises a rejected identity without an error code', () {
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          const sb.AuthException(
            'User from sub claim in JWT does not exist',
            statusCode: '403',
          ),
        ),
        isTrue,
      );
    });

    test('treats an expired access token as inconclusive', () {
      // Regression: this used to sign a healthy session out during app start,
      // while the parallel token refresh was still running.
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          const sb.AuthException(
            'invalid JWT: unable to parse or verify signature, token is expired',
            statusCode: '401',
            code: 'bad_jwt',
          ),
        ),
        isFalse,
      );
    });

    test('treats a missing session as inconclusive', () {
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          sb.AuthSessionMissingException(),
        ),
        isFalse,
      );
    });

    test('treats a network failure as inconclusive', () {
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          sb.AuthRetryableFetchException(),
        ),
        isFalse,
      );
    });

    test('treats a server error as inconclusive', () {
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          const sb.AuthException('Internal server error', statusCode: '500'),
        ),
        isFalse,
      );
    });

    test('treats a forbidden answer about something else as inconclusive', () {
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          const sb.AuthException('User is banned', statusCode: '403'),
        ),
        isFalse,
      );
    });

    test('ignores errors that are not auth errors', () {
      expect(
        AuthUserExistenceCheck.provesUserIsGone(
          StateError('user does not exist'),
        ),
        isFalse,
      );
    });
  });
}
