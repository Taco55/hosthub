abstract class CurrentUserProvider {
  /// Id of the signed-in user.
  ///
  /// Throws an unauthorized `DomainError` when there is no session — the right
  /// behaviour for feature actions, which cannot run without one.
  String get currentUserId;

  /// Id of the signed-in user, or `null` when no session is readable (yet).
  ///
  /// For callers that must tolerate a session that is still settling — app
  /// start, or a token refresh landing — instead of turning it into an error.
  String? get currentUserIdOrNull;
}
