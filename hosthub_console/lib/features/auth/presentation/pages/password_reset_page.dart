import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    context.read<AuthBloc>().add(
      AuthEvent.passwordResetRequested(_emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.step != current.step || previous.status != current.status,
      listener: (context, state) async {
        if (state.status == AuthStatus.error && state.domainError != null) {
          final appError = AppError.fromDomain(context, state.domainError!);
          await showAppError(context, appError);
          return;
        }
        if (state.step == AuthenticatorStep.confirmSignInWithNewPassword) {
          Navigator.of(context).maybePop();
        }
      },
      child: OnboardingPageScaffold(
        title: context.s.forgotPassword,
        contentMaxWidth: 420,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'We will email you a link to reset your password.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              StyledFormField(
                name: 'email',
                controller: _emailController,
                placeholder: context.s.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validators: [
                  FormBuilderValidators.required(
                    errorText: context.s.requiredField,
                  ),
                  FormBuilderValidators.email(
                    errorText: context.s.enterValidEmail,
                  ),
                ],
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        primaryButtonLabel: 'Send reset link',
        onPrimaryPressed: _submit,
        bottomActions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }
}
