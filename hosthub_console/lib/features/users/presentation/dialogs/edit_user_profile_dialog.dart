import 'package:flutter/material.dart';

import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

class EditUserProfileResult {
  const EditUserProfileResult({required this.email, this.username});

  final String email;
  final String? username;
}

Future<EditUserProfileResult?> showEditUserProfileDialog(
  BuildContext context, {
  required String currentEmail,
  String? currentUsername,
}) {
  final emailController = TextEditingController(text: currentEmail);
  final usernameController = TextEditingController(text: currentUsername ?? '');
  final formKey = GlobalKey<FormState>();

  return showDialog<EditUserProfileResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(context.s.editUserDialogTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: context.s.emailLabel),
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.s.emailRequired;
                  }
                  if (!value.contains('@')) {
                    return context.s.emailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: context.s.usernameLabel),
              ),
            ],
          ),
        ),
        actions: [
          StyledButton(
            title: context.s.cancelButton,
            onPressed: () => Navigator.of(context).pop(),
            minHeight: 40,
          ),
          StyledButton(
            title: context.s.saveButton,
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.of(context).pop(
                EditUserProfileResult(
                  email: emailController.text.trim(),
                  username: usernameController.text.trim().isEmpty
                      ? null
                      : usernameController.text.trim(),
                ),
              );
            },
            minHeight: 40,
          ),
        ],
      );
    },
  );
}
