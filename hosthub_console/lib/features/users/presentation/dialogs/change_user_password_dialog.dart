import 'package:flutter/material.dart';

import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

Future<String?> showChangeUserPasswordDialog(BuildContext context) {
  final controller = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(context.s.changePasswordTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.s.newPasswordLabel,
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return context.s.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.s.confirmPasswordLabel,
                ),
                validator: (value) {
                  if (value != controller.text) {
                    return context.s.passwordsDoNotMatch;
                  }
                  return null;
                },
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
            title: context.s.updateButton,
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.of(context).pop(controller.text);
            },
            minHeight: 40,
          ),
        ],
      );
    },
  );
}
