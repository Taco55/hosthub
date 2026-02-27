import 'package:flutter/material.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';


enum UserManagementAction { editProfile, changePassword, deleteUser }

Future<UserManagementAction?> showUserManagementActionsDialog(
  BuildContext context,
) {
  return showDialog<UserManagementAction>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(context.s.manageUserAction),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(context).pop(UserManagementAction.editProfile),
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text(context.s.editDetailsAction),
              subtitle: Text(context.s.editDetailsDescription),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(context).pop(UserManagementAction.changePassword),
            child: ListTile(
              leading: Icon(Icons.key_outlined),
              title: Text(context.s.changePasswordTitle),
              subtitle: Text(context.s.changePasswordDescription),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(context).pop(UserManagementAction.deleteUser),
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text(context.s.deleteUserTitle),
              subtitle: Text(context.s.deleteUserDescription),
            ),
          ),
        ],
      );
    },
  );
}
