import 'dart:async';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
  });

  final String id;
  final String? email;
}

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

abstract class AuthPort {
  AuthUser? get currentUser;

  Future<SignInResult> signIn(String username, String password);
  Future<SignUpResult> signUp(String username, String password);

  /// Sends a magic link / OTP.
  /// [shouldCreateUser] defaults to true so new accounts are provisioned automatically.
  /// Use [redirectTo] to override the default deep-link redirect when needed.
  Future<void> signInWithOtp(
    String email, {
    bool shouldCreateUser = true,
    String? redirectTo,
  });
  Future<void> confirmSignInWithOtp(String email, String code);

  Future<void> signOut();

  bool get isGuestUser;
  Future<void> signInWithOAuth(OAuthProvider provider);
  Stream<AuthSessionChange> get onAuthStateChange;

  /// This will not check whether or not those tokens are valid. To check
  /// if tokens are valid, see [isValidSession].
  bool get isLoggedIn;
  Future<bool> validateCurrentUserExists();

  Future<bool> resetPassword(String username);

  Future<void> resendSignUpEmail(String username);

  Future<SignUpResult> confirmSignUp(String username, String code);

  Future<void> deleteCurrentUser();

  /// Delete a user account by id. Only available for admin users.
  Future<void> deleteUser(String userId);

  /// Create a new user account and return the user id.
  Future<String> createUser(String email, String password, {String? name});

  Future<void> refreshSessionIfNeeded();

  /// Confirms a password reset by verifying the OTP and setting a new password.
  Future<void> confirmResetPasswordWithOtp(
    String email,
    String code,
    String newPassword,
  );

  /// Refreshes the session using a refresh token (e.g. from a deep link redirect).
  Future<void> refreshSessionFromRefreshToken(String refreshToken);
}

enum AuthSignInStep {
  /// The sign-in is not complete and must be confirmed with an SMS code.
  confirmSignInWithSmsMfaCode,

  /// The sign-in is not complete and must be confirmed with the user's new
  /// password.
  confirmSignInWithNewPassword,

  /// The sign-in is not complete and the user must reset their password before
  /// proceeding.
  resetPassword,

  /// The sign-in is not complete and the user's sign up must be confirmed
  /// before proceeding.
  confirmSignUp,

  /// The sign-in is complete.
  done,
}

enum AuthSignUpStep {
  /// The user is successfully registered but requires an additional
  /// confirmation before the sign up is considered complete.
  confirmSignUp,

  /// The user is successfully registered and sign up is complete.
  done,
}

class SignUpResult {
  const SignUpResult({
    required this.isSignUpComplete,
    required this.nextStep,
    this.userId,
  });

  final bool isSignUpComplete;
  final AuthSignUpStep nextStep;

  /// The user ID of the signed-up user.
  final String? userId;
}

class SignInResult {
  const SignInResult({required this.isSignedIn, required this.nextStep});

  final bool isSignedIn;
  final AuthSignInStep nextStep;
}
