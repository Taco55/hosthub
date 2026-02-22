import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/shared/services/local_storage_manager.dart';
import 'package:app_errors/app_errors.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthPort _authService;
  final LocalStorageManager _localStorage;
  late final StreamSubscription<AuthSessionChange> _authSubscription;

  AuthBloc({
    required AuthPort authService,
    required LocalStorageManager localStorage,
  }) : _authService = authService,
       _localStorage = localStorage,
       super(const AuthState(status: AuthStatus.initial)) {
    _authSubscription = _authService.onAuthStateChange.listen(
      (authState) {
        final user = authState.user;
        if (user != null) {
          add(AuthEvent.authenticationSucceeded(user));
        } else {
          add(const AuthEvent.authenticationCleared());
        }
      },
      onError: (error, stackTrace) {
        add(AuthEvent.magicLinkFailed(error, stackTrace));
      },
    );

    on<SignInRequested>(_onSignInRequested);
    on<SignInWithOtpRequested>(_onSignInWithOtpRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<OAuthSignInRequested>(_onOAuthSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordResetConfirmed>(_onPasswordResetConfirmed);
    on<SignUpConfirmed>(_onSignUpConfirmed);
    on<SignInWithOtpConfirmed>(_onSignInWithOtpConfirmed);
    on<SignUpCodeResendRequested>(_onSignUpCodeResendRequested);
    on<PasswordResetCodeResendRequested>(_onPasswordResetCodeResendRequested);
    on<AuthRedirectReceived>(_onAuthRedirectReceived);
    on<AccountDeletionRequested>(_onAccountDeletionRequested);
    on<AuthFlowReset>(_onAuthFlowReset);
    on<OnboardingStarted>(_onOnboardingStarted);
    on<OnboardingCompleted>(_onOnboardingCompleted);

    on<AuthenticationSucceeded>(_onAuthenticationSucceeded);
    on<AuthenticationCleared>(_onAuthenticationCleared);
    on<ProfileLoaded>(_onProfileLoaded);

    on<InitializeEvent>(_onInitialize);
    on<MagicLinkFailed>(_onMagicLinkFailed);
  }

  Future<void> _onInitialize(
    InitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.refreshSessionIfNeeded();

      if (_authService.isLoggedIn) {
        final userExists = await _authService.validateCurrentUserExists();
        if (!userExists) {
          await _authService.signOut();
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              step: AuthenticatorStep.signIn,
            ),
          );
          return;
        }
        // This initialize call can finish after profile load already completed.
        // In that case we must not regress to loadingProfile, otherwise AuthGate
        // shows an indefinite spinner.
        if (state.status == AuthStatus.authenticated &&
            state.step == AuthenticatorStep.done) {
          return;
        }

        if (state.status == AuthStatus.authenticated &&
            state.step == AuthenticatorStep.loadingProfile) {
          return;
        }

        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            step: AuthenticatorStep.loadingProfile,
            domainError: null,
          ),
        );
        return;
      } else if (state.status == AuthStatus.unauthenticated &&
          state.step != null) {
        return;
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            step: AuthenticatorStep.signIn,
          ),
        );
      }
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_authService.isLoggedIn) await _authService.signOut();
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final result = await _authService.signIn(event.email, event.password);
      if (result.nextStep == AuthSignInStep.done) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      } else if (result.nextStep == AuthSignInStep.confirmSignUp) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            step: AuthenticatorStep.confirmSignUp,
            email: event.email,
            password: event.password,
          ),
        );
      } else if (result.nextStep ==
          AuthSignInStep.confirmSignInWithNewPassword) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            step: AuthenticatorStep.confirmSignInWithNewPassword,
            email: event.email,
            password: event.password,
          ),
        );
      }
    } catch (error, stack) {
      if (error is DomainError &&
          error.reason == DomainErrorReason.emailNotConfirmed) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            step: AuthenticatorStep.confirmSignUp,
            email: event.email,
            password: event.password,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> _onSignInWithOtpRequested(
    SignInWithOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.signInWithOtp(
        event.email,
        shouldCreateUser: event.shouldCreateUser,
        redirectTo: event.redirectTo,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          step: AuthenticatorStep.confirmSignInOtp,
          email: event.email,
        ),
      );
    } catch (error, stack) {
      final domainError = DomainError.from(error, stack: stack);
      final errorState = state.copyWith(
        status: AuthStatus.error,
        domainError: domainError,
        step: AuthenticatorStep.confirmSignInOtp,
        email: event.email,
      );
      emit(errorState);
      emit(
        errorState.copyWith(
          status: AuthStatus.unauthenticated,
          domainError: domainError,
        ),
      );
    }
  }

  Future<void> _onOAuthSignInRequested(
    OAuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.signInWithOAuth(event.provider);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          step: state.step ?? AuthenticatorStep.signIn,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _localStorage.setIsFirstLogin(true);
      final result = await _authService.signUp(event.email, event.password);
      if (result.nextStep == AuthSignUpStep.done) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            step: AuthenticatorStep.loadingProfile,
            email: event.email,
            password: event.password,
            id: result.userId,
          ),
        );
      } else if (result.nextStep == AuthSignUpStep.confirmSignUp) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            step: AuthenticatorStep.confirmSignUp,
            email: event.email,
            password: event.password,
            id: result.userId,
          ),
        );
      }
    } catch (error, stack) {
      final domainError = DomainError.from(error, stack: stack);
      final errorState = state.copyWith(
        status: AuthStatus.error,
        domainError: domainError,
      );
      emit(errorState);
      emit(
        errorState.copyWith(
          status: AuthStatus.unauthenticated,
          domainError: domainError,
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.signOut();
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    } finally {
      // Always drive the state to unauthenticated, even if Supabase fails to emit onAuthStateChange.
      add(const AuthEvent.authenticationCleared());
    }
  }

  Future<void> _onAuthenticationSucceeded(
    AuthenticationSucceeded event,
    Emitter<AuthState> emit,
  ) async {
    // Supabase may emit signed-in events multiple times (e.g. token refresh).
    // If the app is already fully authenticated, avoid regressing to
    // loadingProfile and blocking the UI behind AuthGate.
    if (state.status == AuthStatus.authenticated &&
        state.step == AuthenticatorStep.done) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          step: AuthenticatorStep.done,
          email: event.user.email,
          domainError: null,
        ),
      );
      return;
    }

    if (state.status == AuthStatus.authenticated &&
        state.step == AuthenticatorStep.loadingProfile) {
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        email: event.user.email,
        step: AuthenticatorStep.loadingProfile,
      ),
    );
  }

  Future<void> _onProfileLoaded(
    ProfileLoaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        step: AuthenticatorStep.done,
      ),
    );
  }

  Future<void> _onAuthenticationCleared(
    AuthenticationCleared event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        step: AuthenticatorStep.signIn,
      ),
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      await _authService.resetPassword(event.email);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          step: AuthenticatorStep.confirmPasswordResetWithCode,
          email: event.email,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onPasswordResetConfirmed(
    PasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.confirmResetPasswordWithOtp(
        event.email,
        event.confirmationCode,
        event.newPassword,
      );
      emit(
        state.copyWith(
          status: AuthStatus.newPasswordConfirmed,
          step: AuthenticatorStep.signIn,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignUpConfirmed(
    SignUpConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (state.email != null && state.password != null) {
        emit(state.copyWith(status: AuthStatus.loading));
        await _authService.confirmSignUp(state.email!, event.confirmationCode);
        await _authService.signIn(state.email!, state.password!);
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            step: AuthenticatorStep.loadingProfile,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            step: AuthenticatorStep.confirmSignUp,
          ),
        );
      }
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> _onSignInWithOtpConfirmed(
    SignInWithOtpConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    final pendingEmail = state.email;
    if (pendingEmail == null || pendingEmail.isEmpty) {
      final domainError = DomainError.of(DomainErrorCode.badRequest);
      emit(state.copyWith(status: AuthStatus.error, domainError: domainError));
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          step: AuthenticatorStep.signIn,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.confirmSignInWithOtp(
        pendingEmail,
        event.confirmationCode,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          step: AuthenticatorStep.loadingProfile,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthFlowReset(
    AuthFlowReset event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _localStorage.setHasCompletedOnboarding(true);
    await _authService.signOut();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        step: AuthenticatorStep.signIn,
      ),
    );
  }

  Future<void> _onOnboardingStarted(
    OnboardingStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        step: AuthenticatorStep.signIn,
      ),
    );
  }

  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    await _localStorage.setHasCompletedOnboarding(true);
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        step: AuthenticatorStep.signIn,
      ),
    );
  }

  Future<void> _onAccountDeletionRequested(
    AccountDeletionRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      await _authService.deleteCurrentUser();
      _localStorage.setIsFirstLogin(false);
      emit(const AuthState(status: AuthStatus.accountDeleted));
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignUpCodeResendRequested(
    SignUpCodeResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = state.email;
    if (email == null || email.trim().isEmpty) {
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.resendSignUpEmail(email);
      emit(state.copyWith(status: AuthStatus.codeResent));
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onMagicLinkFailed(
    MagicLinkFailed event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.error,
        domainError: DomainError.from(event.error, stack: event.stackTrace),
      ),
    );
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        step: AuthenticatorStep.signIn,
      ),
    );
  }

  Future<void> _onPasswordResetCodeResendRequested(
    PasswordResetCodeResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.resetPassword(event.email);
      emit(state.copyWith(status: AuthStatus.codeResent));
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      return;
    }
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onAuthRedirectReceived(
    AuthRedirectReceived event,
    Emitter<AuthState> emit,
  ) async {
    final payload = event.payload;

    if (payload.hasError || payload.isExpired) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError:
              payload.domainError ??
              DomainError.of(
                DomainErrorCode.unauthorized,
                message: payload.error ?? 'The link has expired.',
              ),
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          step: AuthenticatorStep.signIn,
        ),
      );
      return;
    }

    if (!payload.isValid || payload.refreshToken == null) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          step: AuthenticatorStep.signIn,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.refreshSessionFromRefreshToken(payload.refreshToken!);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          step: AuthenticatorStep.confirmSignInWithNewPassword,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          step: AuthenticatorStep.signIn,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }
}
