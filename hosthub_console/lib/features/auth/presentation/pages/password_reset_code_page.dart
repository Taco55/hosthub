import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

class PasswordResetCodePage extends StatefulWidget {
  const PasswordResetCodePage({super.key});

  @override
  State<PasswordResetCodePage> createState() => _PasswordResetCodePageState();
}

class _PasswordResetCodePageState extends State<PasswordResetCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Timer? _resendTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 30);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        if (mounted) setState(() => _cooldownSeconds--);
      }
    });
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = context.read<AuthBloc>().state.email;
    if (email == null || email.isEmpty) return;

    context.read<AuthBloc>().add(
      AuthEvent.passwordResetConfirmed(
        email: email,
        confirmationCode: _codeController.text.trim(),
        newPassword: _passwordController.text,
      ),
    );
  }

  void _resendCode() {
    final email = context.read<AuthBloc>().state.email;
    if (email == null || email.isEmpty) return;
    context.read<AuthBloc>().add(
      AuthEvent.passwordResetCodeResendRequested(email),
    );
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = context.select<AuthBloc, String?>((bloc) => bloc.state.email);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.domainError != current.domainError,
      listener: (context, state) async {
        if (state.status == AuthStatus.error && state.domainError != null) {
          final appError = AppError.fromDomain(context, state.domainError!);
          await showAppError(context, appError);
          return;
        }
        if (state.status == AuthStatus.codeResent) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A new code has been sent to your email.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
        if (state.status == AuthStatus.newPasswordConfirmed) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          context.read<AuthBloc>().add(const AuthEvent.authFlowReset());
        }
      },
      child: OnboardingPageScaffold(
        title: 'Reset your password',
        contentMaxWidth: 420,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                email != null && email.isNotEmpty
                    ? 'Enter the 6-digit code sent to $email and choose a new password.'
                    : 'Enter the code from your email and choose a new password.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              StyledFormField(
                name: 'resetCode',
                controller: _codeController,
                placeholder: 'Verification code',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Verification code required',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _cooldownSeconds > 0 ? null : _resendCode,
                  child: Text(
                    _cooldownSeconds > 0
                        ? 'Resend code ($_cooldownSeconds)'
                        : 'Resend code',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StyledFormField(
                name: 'newPassword',
                controller: _passwordController,
                placeholder: 'New password',
                obscureText: true,
                enablePasswordToggle: true,
                textInputAction: TextInputAction.next,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Password required',
                  ),
                  FormBuilderValidators.minLength(
                    6,
                    errorText: 'Password must be at least 6 characters',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StyledFormField(
                name: 'confirmPassword',
                controller: _confirmPasswordController,
                placeholder: 'Confirm password',
                obscureText: true,
                enablePasswordToggle: true,
                textInputAction: TextInputAction.done,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please confirm your password',
                  ),
                  (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ],
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        primaryButtonLabel: 'Reset password',
        onPrimaryPressed: _submit,
        bottomActions: [
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEvent.authFlowReset());
            },
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }
}
