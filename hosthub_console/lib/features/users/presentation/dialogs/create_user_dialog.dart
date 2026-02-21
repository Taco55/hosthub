import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/users/data/admin_user_repository.dart';
import 'package:hosthub_console/features/auth/presentation/widgets/login_form.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

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
  bool _isBusy = false;
  String? _errorMessage;

  Future<void> _onSubmit(String email, String password) async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await context.read<AdminUserRepository>().createUser(
        email: email,
        password: password,
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
    return LoginForm(
      mode: LoginFormMode.register,
      title: context.s.createUserTitle,
      description: context.s.createUserDescription,
      primaryButtonLabel: context.s.createUserButton,
      onSubmit: _onSubmit,
      isBusy: _isBusy,
      errorMessage: _errorMessage,
      showBusyOverlay: true,
      busyOverlayBuilder: (_) => const ColoredBox(color: Colors.transparent),
    );
  }
}
