import 'package:flutter/material.dart';

import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

Future<bool> showDeleteUserConfirmationDialog(
  BuildContext context, {
  required String email,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(context.s.deleteUserTitle),
        content: Text(context.s.deleteUserConfirmation(email)),
        actions: [
          StyledButton(
            title: context.s.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
            minHeight: 40,
          ),
          StyledButton(
            title: context.s.deleteButton,
            onPressed: () => Navigator.of(context).pop(true),
            minHeight: 40,
            backgroundColor: Theme.of(context).colorScheme.error,
            labelColor: Theme.of(context).colorScheme.onError,
          ),
        ],
      );
    },
  );

  return result ?? false;
}
