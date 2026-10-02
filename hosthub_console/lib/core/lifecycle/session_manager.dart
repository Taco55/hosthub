import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/features/auth/auth.dart';

/// Coordinates session related concerns outside of the bloc layer.
class SessionManager {
  final AuthPort _authService;

  SessionManager({required AuthPort authService}) : _authService = authService;

  /// Ensures the current session is still valid before making API calls.
  Future<void> ensureFreshSession() => _authService.refreshSessionIfNeeded();

  /// Returns the currently authenticated user, if any.
  AuthUser? get currentUser => _authService.currentUser;

  /// Signs out without surfacing errors to the caller. A sign-out that fails
  /// can leave a session behind, so the failure is reported all the same.
  Future<void> signOutSilently() async {
    try {
      await _authService.signOut();
    } catch (error, stack) {
      DomainError.report(
        error,
        stack: stack,
        context: const {'op': 'signOutSilently'},
      );
    }
  }
}
