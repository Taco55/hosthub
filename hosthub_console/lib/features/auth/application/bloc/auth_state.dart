// part of 'auth_bloc.dart';

// @freezed
// class AuthState with _$AuthState {
//   const factory AuthState.initial() = InitialAuth;
//   const factory AuthState.loading() = LoadingAuth;
//   const factory AuthState.unauthenticated() = Unauthenticated;
//   const factory AuthState.error(AppError appError) = AuthError;
//   const factory AuthState.userAuthorized() = UserAuthorized;
//   const factory AuthState.deletingAccount() = DeletingAccount;
//   const factory AuthState.passwordReset() = PasswordReset;
//   const factory AuthState.authenticated() = Authenticated;
//   const factory AuthState.authenticatedLocalDev() = AuthenticatedLocalDev;

//   const factory AuthState.accountDeleted() = AccountDeleted;
// }

part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  passwordReset,
  newPasswordConfirmed,
  signUpConfirmed,
  codeResent,
  authenticated,
  error,
  accountDeleted,
  userAuthorized,
}

/// The current step of the authentication flow.
enum AuthenticatorStep {
  loading,

  /// The user is on the Onboarding step.
  done,
  onboarding,
  signUp,
  signIn,
  confirmSignUp,
  confirmSignInOtp,

  /// When a user has been invited, the password should be reset before login.
  confirmSignInWithNewPassword,

  /// The user must enter the OTP code and new password to complete password reset.
  confirmPasswordResetWithCode,

  /// The user has successfully signed in and their account is confirmed,
  /// however they do not have any means of account recovery (email, phone)
  /// that is confirmed.
  verifyUser,

  /// The user is on the Confirm Verify User step.
  ///
  /// The user has initiated verification of an account recovery means
  /// (email, phone), and needs to provide a verification code.
  confirmVerifyUser,

  loadingProfile,
}

@immutable
class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.domainError,
    this.step,
    this.id,
    this.email,
    this.password,
    this.code,
  });

  final AuthStatus status;
  final AuthenticatorStep? step;

  final DomainError? domainError;

  final String? id;
  final String? email;
  final String? password;
  final String? code;

  AuthState copyWith({
    required AuthStatus status,
    AuthenticatorStep? step,
    DomainError? domainError,
    String? email,
    String? password,
    String? code,
    String? id,
  }) {
    return AuthState(
      status: status,
      domainError: domainError,
      step: step ?? this.step,
      email: email ?? this.email,
      password: password ?? this.password,
      code: code ?? this.code,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    if (status == AuthStatus.error) {
      return "${runtimeType.toString()}.$status: ${domainError?.toString()}";
    } else {
      if (status == AuthStatus.unauthenticated ||
          status == AuthStatus.authenticated) {
        return "${status.name}.Step: ${step?.name}";
      } else {
        return "${runtimeType.toString()}.$status";
      }
    }
  }

  @override
  List<Object?> get props => [
    status,
    step,
    domainError,
    id,
    email,
    password,
    code,
  ];
}
