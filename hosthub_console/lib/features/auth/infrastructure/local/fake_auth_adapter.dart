import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/features/auth/domain/ports/auth_port.dart';

class FakeAuthAdapter implements AuthPort {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthSessionChange>.broadcast();

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  bool get isGuestUser => _currentUser == null;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  Stream<AuthSessionChange> get onAuthStateChange => _controller.stream;

  @override
  Future<SignInResult> signIn(String username, String password) async {
    _currentUser = AuthUser(id: 'local-user', email: username);
    _controller.add(AuthSessionChange(user: _currentUser));
    return const SignInResult(
      isSignedIn: true,
      nextStep: AuthSignInStep.done,
    );
  }

  @override
  Future<SignUpResult> signUp(String username, String password) async {
    _currentUser = AuthUser(id: 'local-user', email: username);
    _controller.add(AuthSessionChange(user: _currentUser));
    return const SignUpResult(
      isSignUpComplete: true,
      nextStep: AuthSignUpStep.done,
      userId: 'local-user',
    );
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(const AuthSessionChange(user: null));
  }

  @override
  Future<void> signInWithOtp(
    String email, {
    bool shouldCreateUser = true,
    String? redirectTo,
  }) async {
    throw _notSupported('signInWithOtp');
  }

  @override
  Future<void> confirmSignInWithOtp(String email, String code) async {
    throw _notSupported('confirmSignInWithOtp');
  }

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    throw _notSupported('signInWithOAuth');
  }

  @override
  Future<bool> validateCurrentUserExists() async => _currentUser != null;

  @override
  Future<bool> resetPassword(String username) async {
    throw _notSupported('resetPassword');
  }

  @override
  Future<void> resendSignUpEmail(String username) async {
    throw _notSupported('resendSignUpEmail');
  }

  @override
  Future<SignUpResult> confirmSignUp(String username, String code) async {
    throw _notSupported('confirmSignUp');
  }

  @override
  Future<void> deleteCurrentUser() async {
    await signOut();
  }

  @override
  Future<void> deleteUser(String userId) async {
    throw _notSupported('deleteUser');
  }

  @override
  Future<String> createUser(String email, String password, {String? name}) async {
    _currentUser = AuthUser(id: 'local-user', email: email);
    _controller.add(AuthSessionChange(user: _currentUser));
    return 'local-user';
  }

  @override
  Future<void> refreshSessionIfNeeded() async {
    return;
  }

  @override
  Future<void> confirmResetPasswordWithOtp(
    String email,
    String code,
    String newPassword,
  ) async {
    _currentUser = AuthUser(id: 'local-user', email: email);
    _controller.add(AuthSessionChange(user: _currentUser));
  }

  @override
  Future<void> refreshSessionFromRefreshToken(String refreshToken) async {
    _currentUser = AuthUser(id: 'local-user', email: 'fake@local');
    _controller.add(AuthSessionChange(user: _currentUser));
  }

  DomainError _notSupported(String action) {
    return DomainError.of(
      DomainErrorCode.serviceUnavailable,
      message: 'FakeAuthAdapter does not support $action.',
    );
  }
}
