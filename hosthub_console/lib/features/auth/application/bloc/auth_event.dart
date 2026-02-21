part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  // Lifecycle
  const factory AuthEvent.initialize() = InitializeEvent;

  // Onboarding
  const factory AuthEvent.onboardingStarted() = OnboardingStarted;
  const factory AuthEvent.onboardingCompleted() = OnboardingCompleted;

  // Email/password auth flow
  const factory AuthEvent.signInRequested(String email, String password) =
      SignInRequested;
  const factory AuthEvent.signInWithOtpRequested(
    String email, {
    @Default(true) bool shouldCreateUser,
    String? redirectTo,
  }) = SignInWithOtpRequested;
  const factory AuthEvent.signUpRequested(String email, String password) =
      SignUpRequested;
  const factory AuthEvent.signOutRequested() = SignOutRequested;

  // Session outcome (used in onAuthStateChange listener)
  const factory AuthEvent.authenticationSucceeded(AuthUser user) =
      AuthenticationSucceeded;
  const factory AuthEvent.authenticationCleared() = AuthenticationCleared;

  // Sign-up flow
  const factory AuthEvent.signUpConfirmed(String confirmationCode) =
      SignUpConfirmed;
  const factory AuthEvent.signInWithOtpConfirmed(String confirmationCode) =
      SignInWithOtpConfirmed;
  const factory AuthEvent.signUpCodeResendRequested() =
      SignUpCodeResendRequested;

  // Password reset flow
  const factory AuthEvent.passwordResetRequested(String email) =
      PasswordResetRequested;
  const factory AuthEvent.passwordResetConfirmed({
    required String email,
    required String newPassword,
    required String confirmationCode,
  }) = PasswordResetConfirmed;
  const factory AuthEvent.passwordResetCodeResendRequested(String email) =
      PasswordResetCodeResendRequested;

  // Redirect deep link handling
  const factory AuthEvent.authRedirectReceived(
    AuthRedirectPayload payload,
  ) = AuthRedirectReceived;

  // OAuth login
  const factory AuthEvent.oauthSignInRequested(
    OAuthProvider provider,
  ) = OAuthSignInRequested;
  const factory AuthEvent.magicLinkFailed(Object error, StackTrace stackTrace) =
      MagicLinkFailed;

  // Account management
  const factory AuthEvent.accountDeletionRequested() = AccountDeletionRequested;

  // Reset complete flow (e.g. back to onboarding)
  const factory AuthEvent.authFlowReset() = AuthFlowReset;
  const factory AuthEvent.profileLoaded() = ProfileLoaded;

  //   @override
  // String toString() {
  //   return runtimeType.toString();
  // }
}
