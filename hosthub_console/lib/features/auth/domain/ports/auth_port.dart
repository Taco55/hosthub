import 'dart:async';

import 'package:auth_ui_flutter/auth_ui_flutter.dart' as auth_ui;

typedef AuthUser = auth_ui.AuthUser;
typedef SignUpResult = auth_ui.SignUpResult;
typedef SignInResult = auth_ui.SignInResult;
typedef AuthSignInStep = auth_ui.AuthSignInStep;
typedef AuthSignUpStep = auth_ui.AuthSignUpStep;

class AuthSessionChange {
  const AuthSessionChange({this.user});

  final AuthUser? user;
}

enum OAuthProvider {
  apple,
  azure,
  bitbucket,
  discord,
  facebook,
  github,
  gitlab,
  google,
  twitter,
}

abstract class AuthPort implements auth_ui.AuthServiceInterface {
  @override
  AuthUser? get currentUser;

  @override
  Future<SignInResult> signIn(String username, String password);
  @override
  Future<SignUpResult> signUp(String username, String password);

  @override
  Future<void> sendResetEmail(String email);
  @override
  Future<void> sendMagicLink(String email);
  @override
  Future<String> verifyOtp(String email, String code);
  @override
  Future<void> refreshSessionFromToken(String refreshToken);
  @override
  Future<void> confirmResetPassword(String newPassword);

  /// Sends a magic link / OTP.
  /// [shouldCreateUser] defaults to true so new accounts are provisioned automatically.
  /// Use [redirectTo] to override the default deep-link redirect when needed.
  Future<void> signInWithOtp(
    String email, {
    bool shouldCreateUser = true,
    String? redirectTo,
  });
  Future<void> confirmSignInWithOtp(String email, String code);

  @override
  Future<void> signOut();

  bool get isGuestUser;
  Future<void> signInWithOAuth(OAuthProvider provider);
  Stream<AuthSessionChange> get onAuthStateChange;

  /// This will not check whether or not those tokens are valid. To check
  /// if tokens are valid, see [isValidSession].
  @override
  bool get isLoggedIn;
  Future<bool> validateCurrentUserExists();

  Future<bool> resetPassword(String username);

  @override
  Future<void> resendSignUpCode(String username);
  Future<void> resendSignUpEmail(String username);

  @override
  Future<SignUpResult> confirmSignUp(String username, String code);

  /// Consumer-facing alias from [AuthServiceInterface].
  /// Implementations can delegate to [deleteCurrentUser].
  @override
  Future<void> deleteAccount();

  Future<void> deleteCurrentUser();

  /// Delete a user account by id. Only available for admin users.
  Future<void> deleteUser(String userId);

  /// Create a new user account and return the user id.
  Future<String> createUser(String email, String password, {String? name});

  Future<void> refreshSessionIfNeeded();

  /// Confirms a password reset by verifying the OTP and setting a new password.
  @override
  Future<void> confirmResetPasswordWithOtp(
    String email,
    String code,
    String newPassword,
  );

  /// Refreshes the session using a refresh token (e.g. from a deep link redirect).
  Future<void> refreshSessionFromRefreshToken(String refreshToken);
}
