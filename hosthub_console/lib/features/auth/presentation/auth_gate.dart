import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/auth/application/bloc/auth_bloc.dart';
import 'package:hosthub_console/features/auth/presentation/pages/confirm_sign_up_page.dart';
import 'package:hosthub_console/features/auth/presentation/pages/login_page.dart';
import 'package:hosthub_console/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:hosthub_console/features/auth/presentation/pages/password_reset_code_page.dart';
import 'package:hosthub_console/features/auth/presentation/pages/password_reset_sent_page.dart';
import 'package:hosthub_console/features/auth/presentation/widgets/login_form.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.loading ||
            state.status == AuthStatus.initial ||
            state.step == AuthenticatorStep.loadingProfile) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status != AuthStatus.authenticated) {
          final page = _pageForStep(state.step);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );
              return SlideTransition(position: offset, child: child);
            },
            child: KeyedSubtree(
              key: ValueKey(state.step),
              child: page,
            ),
          );
        }

        return child;
      },
    );
  }

  Widget _pageForStep(AuthenticatorStep? step) {
    return switch (step) {
      AuthenticatorStep.confirmSignUp => const ConfirmSignUpPage(),
      AuthenticatorStep.confirmSignInOtp => const OtpVerificationPage(),
      AuthenticatorStep.confirmPasswordResetWithCode =>
        const PasswordResetCodePage(),
      AuthenticatorStep.confirmSignInWithNewPassword =>
        const PasswordResetSentPage(),
      AuthenticatorStep.signUp =>
        const LoginPage(initialMode: LoginFormMode.register),
      _ => const LoginPage(initialMode: LoginFormMode.login),
    };
  }
}
