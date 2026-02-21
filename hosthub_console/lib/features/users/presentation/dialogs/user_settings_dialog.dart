import 'package:flutter/material.dart';

import 'package:hosthub_console/shared/models/models.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

Future<void> showUserSettingsDialog(
  BuildContext context, {
  required Profile profile,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.s.userSettingsAction),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
           
           
          ],
        ),
        actions: [
          StyledButton(
            title: context.s.closeButton,
            onPressed: () => Navigator.of(context).pop(),
            minHeight: 40,
          ),
        ],
      );
    },
  );
}
