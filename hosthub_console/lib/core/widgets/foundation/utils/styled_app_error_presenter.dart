import 'package:app_errors/app_errors.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// Shows an error dialog with [showStyledAlertDialog] and answers how it
/// closed: [AppErrorDialogOutcome.action] when its action closed it, and
/// [AppErrorDialogOutcome.dismissed] for every other way out, for which
/// `showAppError` runs the caller's `onDismissed`.
Future<AppErrorDialogOutcome> styledAppErrorPresenter(
  BuildContext context,
  AppErrorDialogData data,
) async {
  final showDebugDetails = data.showDebugDetails;
  final confirmed = await showStyledAlertDialog(
    context,
    title: data.title,
    message: data.message,
    content: showDebugDetails ? AppErrorDebugDetails(data: data) : null,
    contentFit: showDebugDetails
        ? DialogContentFit.fill
        : DialogContentFit.scroll,
    dismissText: data.dismissText,
    actionText: data.actionText,
    // A retry is awaited in place (spinner, stays open on a repeated
    // failure); a plain action closes the dialog at once.
    onAction: data.onRetry ?? data.onAction,
    asyncAction: data.onRetry != null,
    isDestructiveAction: data.isDestructiveAction,
    hideDismiss: data.hideDismiss,
  );
  return confirmed == true
      ? AppErrorDialogOutcome.action
      : AppErrorDialogOutcome.dismissed;
}
