import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/features/users/data/admin_user_repository.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:styled_widgets/styled_widgets.dart';

Future<bool?> showCreateUserDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        title: Text(context.s.createUserTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: const _CreateUserForm(),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 20),
        actions: [
          StyledButton(
            title: context.s.cancelButton,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            minHeight: 40,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            labelColor: theme.colorScheme.onSurface,
          ),
        ],
      );
    },
  );
}

class _CreateUserForm extends StatefulWidget {
  const _CreateUserForm();

  @override
  State<_CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<_CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBusy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await context.read<AdminUserRepository>().createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        skipSeededLists: true,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error, stack) {
      final domainError = DomainError.from(error, stack: stack);
      final message = AppError.fromDomain(context, domainError).alert;
      setState(() {
        _isBusy = false;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.s.createUserDescription,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          StyledFormField(
            controller: _emailController,
            placeholder: context.s.email,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isBusy,
            validators: [
              (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return context.s.requiredField;
                if (!trimmed.contains('@') || !trimmed.contains('.')) {
                  return context.s.enterValidEmail;
                }
                return null;
              },
            ],
          ),
          const SizedBox(height: 12),
          StyledFormField(
            controller: _passwordController,
            placeholder: context.s.password,
            enabled: !_isBusy,
            obscureText: true,
            enablePasswordToggle: true,
            validators: [
              (value) {
                final input = value ?? '';
                if (input.isEmpty) return context.s.requiredField;
                if (input.length < 8) return context.s.passwordMinLength;
                return null;
              },
            ],
          ),
          const SizedBox(height: 16),
          StyledButton(
            title: context.s.createUserButton,
            enabled: !_isBusy,
            showProgressIndicatorWhenDisabled: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
