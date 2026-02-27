import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:auth_ui_flutter/auth_ui_flutter.dart';

/// Maps [AuthUiButtonConfig] to a [StyledButton].
Widget _buildStyledButton(BuildContext context, AuthUiButtonConfig config) {
  return StyledButton(
    title: config.title,
    onPressed: config.onPressed,
    enabled: config.enabled,
    showProgressIndicatorWhenDisabled: config.showProgressIndicatorWhenDisabled,
    variant: config.variant == AuthUiButtonVariant.text
        ? StyledButtonVariant.text
        : StyledButtonVariant.filled,
    height: config.height,
    minHeight: config.minHeight,
    width: config.width,
    expand: config.expand,
    leftIconData: config.leftIconData,
    showLeftIcon: config.showLeftIcon ? true : null,
    textStyle: config.textStyle,
    labelColor: config.labelColor,
    backgroundColor: config.backgroundColor,
    enableShadow: config.enableShadow,
  );
}

/// Maps [AuthUiFormFieldConfig] to a [StyledFormField].
Widget _buildStyledFormField(
  BuildContext context,
  AuthUiFormFieldConfig config,
) {
  return StyledFormField(
    controller: config.controller,
    placeholder: config.placeholder,
    keyboardType: config.keyboardType,
    textInputAction: config.textInputAction,
    autofillHints: config.autofillHints,
    prefixIcon: config.prefixIcon,
    suffixIcon: config.suffixIcon,
    obscureText: config.obscureText,
    onFieldSubmitted: config.onFieldSubmitted,
    validators: config.validators,
    autovalidateMode: AutovalidateMode.onUserInteraction,
  );
}

/// Maps [AuthError] to an [AppError]-based dialog.
Future<void> _showStyledAuthErrorDialog(
  BuildContext context,
  AuthError error,
  String message,
) async {
  final cause = error.cause;
  if (cause is DomainError) {
    await showAppError(context, AppError.fromDomain(context, cause));
    return;
  }

  await showStyledAlertDialog(
    context,
    title: AuthUiIntl.of(context).errorDialogTitle,
    message: message,
    dismissText: AuthUiIntl.of(context).errorDialogDismiss,
  );
}

String? _buildAuthErrorMessage(BuildContext context, AuthError error) {
  final cause = error.cause;
  if (cause is! DomainError) return null;
  return AppError.fromDomain(context, cause).alert;
}

/// Builds an inline error widget using the app's styled error container.
Widget _buildStyledInlineError(BuildContext context, String message) {
  final theme = Theme.of(context);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onErrorContainer,
      ),
    ),
  );
}

/// Pre-built [AuthUiOverridesData] that delegates to styled_widgets.
const styledAuthUiOverrides = AuthUiOverridesData(
  buttonBuilder: _buildStyledButton,
  formFieldBuilder: _buildStyledFormField,
  errorMessageBuilder: _buildAuthErrorMessage,
  errorDialogBuilder: _showStyledAuthErrorDialog,
  inlineErrorBuilder: _buildStyledInlineError,
  minPasswordLength: 8,
);

/// Handles app error logout by dispatching [AuthEvent.logout] on the
/// nearest [AuthBloc].
void handleAppErrorLogout(BuildContext context, AppError appError) {
  try {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final status = authBloc.state.status;
    if (status == AuthStatus.loading || status == AuthStatus.unauthenticated) {
      return;
    }
    authBloc.add(const AuthEvent.logout());
  } catch (_) {
    // AuthBloc not available in widget tree.
  }
}
