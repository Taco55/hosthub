import 'package:app_errors/app_errors.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widgets/styled_widgets.dart';

Future<dynamic> styledAppErrorPresenter(
  BuildContext context,
  AppErrorDialogData data,
) =>
    showStyledAlertDialog(
      context,
      title: data.title,
      message: data.message,
      content: data.showDebugDetails ? AppErrorDebugDetails(data: data) : null,
      dismissText: data.dismissText,
      actionText: data.actionText,
      onDismissed: data.onDismissed,
      onAction: data.onAction,
      isDestructiveAction: data.isDestructiveAction,
      hideDismiss: data.hideDismiss,
    );
