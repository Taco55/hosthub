import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

class PasswordResetSentPage extends StatelessWidget {
  const PasswordResetSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageScaffold(
      title: 'Check your email',
      contentMaxWidth: 420,
      body: const Text(
        'We sent a password reset link. Open the email to continue.',
        textAlign: TextAlign.center,
      ),
      primaryButtonLabel: 'Back to login',
      onPrimaryPressed: () {
        context.read<AuthBloc>().add(const AuthEvent.authFlowReset());
      },
    );
  }
}
