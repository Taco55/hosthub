import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  Timer? _resendTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _codeController.dispose();
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
    context.read<AuthBloc>().add(
      AuthEvent.signInWithOtpConfirmed(_codeController.text.trim()),
    );
  }

  void _resendCode() {
    final email = context.read<AuthBloc>().state.email;
    if (email == null || email.isEmpty) return;
    context.read<AuthBloc>().add(
      AuthEvent.signInWithOtpRequested(email),
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
        }
      },
      child: OnboardingPageScaffold(
        title: 'Verify your identity',
        contentMaxWidth: 420,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                email == null || email.isEmpty
                    ? 'Enter the verification code from your email.'
                    : 'Enter the verification code sent to $email.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              StyledFormField(
                name: 'otpCode',
                controller: _codeController,
                placeholder: 'Verification code',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Verification code required',
                  ),
                ],
                onFieldSubmitted: (_) => _submit(),
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
            ],
          ),
        ),
        primaryButtonLabel: 'Verify',
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
