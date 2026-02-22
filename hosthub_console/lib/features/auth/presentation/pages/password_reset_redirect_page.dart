import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

import 'package:hosthub_console/features/auth/presentation/utils/url_sanitizer.dart'
    as url_sanitizer;

class PasswordResetRedirectPage extends StatefulWidget {
  const PasswordResetRedirectPage({super.key, required this.payload});

  final AuthRedirectPayload payload;

  @override
  State<PasswordResetRedirectPage> createState() =>
      _PasswordResetRedirectPageState();
}

class _PasswordResetRedirectPageState extends State<PasswordResetRedirectPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _sessionReady = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    url_sanitizer.sanitizeCurrentUrl();

    if (widget.payload.isValid && widget.payload.refreshToken != null) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<AuthBloc>().add(
          AuthEvent.authRedirectReceived(widget.payload),
        );
      });
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email =
        context.read<AuthBloc>().state.email ??
        widget.payload.queryParameters['email'] ??
        '';

    context.read<AuthBloc>().add(
      AuthEvent.passwordResetConfirmed(
        email: email,
        confirmationCode: '',
        newPassword: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInvite = widget.payload.isInvite;
    final isExpired = widget.payload.isExpired;
    final hasError = widget.payload.hasError;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) async {
        if (state.status == AuthStatus.authenticated &&
            state.step == AuthenticatorStep.confirmSignInWithNewPassword) {
          if (mounted)
            setState(() {
              _sessionReady = true;
              _loading = false;
            });
        }
        if (state.status == AuthStatus.error && state.domainError != null) {
          if (mounted) setState(() => _loading = false);
          final appError = AppError.fromDomain(context, state.domainError!);
          await showAppError(context, appError);
        }
        if (state.status == AuthStatus.newPasswordConfirmed) {
          if (!mounted) return;
          showStyledToast(
            context,
            type: ToastificationType.success,
            description: 'Password updated successfully.',
          );
          context.read<AuthBloc>().add(const AuthEvent.authFlowReset());
        }
      },
      child: _buildContent(context, theme, isInvite, isExpired, hasError),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isInvite,
    bool isExpired,
    bool hasError,
  ) {
    // Expired or invalid link
    if (isExpired || hasError || (!widget.payload.isValid && !_sessionReady)) {
      return OnboardingPageScaffold(
        title: 'Link expired',
        contentMaxWidth: 420,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.payload.error ??
                  'This link has expired or is no longer valid. '
                      'Please request a new password reset.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        primaryButtonLabel: 'Back to login',
        onPrimaryPressed: () {
          context.read<AuthBloc>().add(const AuthEvent.authFlowReset());
        },
      );
    }

    // Loading while refreshing session from token
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Session ready — show new password form
    final title = isInvite ? 'Set your password' : 'Choose a new password';
    final subtitle = isInvite
        ? 'Welcome! Please set a password for your account.'
        : 'Enter your new password below.';

    return OnboardingPageScaffold(
      title: title,
      contentMaxWidth: 420,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            StyledFormField(
              name: 'newPassword',
              controller: _passwordController,
              placeholder: 'New password',
              obscureText: true,
              enablePasswordToggle: true,
              textInputAction: TextInputAction.next,
              validators: [
                FormBuilderValidators.required(errorText: 'Password required'),
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
      primaryButtonLabel: isInvite ? 'Set password' : 'Update password',
      onPrimaryPressed: _submit,
    );
  }
}
