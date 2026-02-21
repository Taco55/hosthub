import 'package:hosthub_console/features/auth/auth.dart';

/// Coordinates session related concerns outside of the bloc layer.
class SessionManager {
  final AuthPort _authService;

  SessionManager({required AuthPort authService})
    : _authService = authService;

  /// Ensures the current session is still valid before making API calls.
  Future<void> ensureFreshSession() => _authService.refreshSessionIfNeeded();

  /// Returns the currently authenticated user, if any.
  AuthUser? get currentUser => _authService.currentUser;

  /// Signs out without surfacing errors to the caller.
  Future<void> signOutSilently() async {
    try {
      await _authService.signOut();
    } catch (_) {
      // Ignore failures during best-effort sign-out.
    }
  }
}
