import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Decides whether a failed `auth.getUser()` call proves the account behind the
/// stored session is gone.
///
/// `AuthBloc` destroys the session when `validateCurrentUserExists` returns
/// `false`, so only a definitive answer may do that. Everything else — expired
/// access token, offline, 5xx, a session that is still being refreshed — is
/// inconclusive: the caller must throw and keep the session, otherwise a
/// healthy user is signed out mid-boot.
class AuthUserExistenceCheck {
  const AuthUserExistenceCheck._();

  /// Supabase Auth error code for "the user in this JWT does not exist".
  static const String userNotFoundCode = 'user_not_found';

  /// Whether [error] is Supabase Auth telling us the account no longer exists.
  static bool provesUserIsGone(Object error) {
    if (error is! sb.AuthException) return false;
    if (error.code == userNotFoundCode) return true;

    // Gateways without the error code answer the same case with a rejected
    // identity plus an explicit message ("User from sub claim in JWT does not
    // exist"). Both signals must line up: a bare 403 also covers cases that
    // say nothing about the account existing.
    final statusCode = error.statusCode;
    if (statusCode != '403' && statusCode != '404') return false;

    final message = error.message.toLowerCase();
    if (!message.contains('user')) return false;
    return message.contains('does not exist') || message.contains('not found');
  }
}
