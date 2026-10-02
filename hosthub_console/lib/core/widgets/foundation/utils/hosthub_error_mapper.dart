import 'package:app_errors/app_errors.dart';
import 'package:flutter/widgets.dart';

import 'package:hosthub_console/core/errors/hosthub_error_reason.dart';
import 'package:hosthub_console/core/widgets/foundation/utils/context_extensions.dart';

/// The console's copy for its own [HosthubErrorReason]s; `null` for every
/// other error, which the library words.
///
/// A session that ended and a lost connection keep the library's copy, so
/// the order stays the library's: session, connection, then the cause.
AppError? hosthubErrorMapper(
  BuildContext context,
  DomainError error,
  AppErrorStrings strings,
) {
  final reason = error.projectReason;
  if (reason is! HosthubErrorReason) return null;
  if (error.endsSession || _connectionFailed(error)) return null;

  final s = context.s;
  final (title, alert) = switch (reason) {
    HosthubErrorReason.cannotDeleteAllUserData => (
      s.error,
      s.cannotDeleteAllUserData,
    ),
    HosthubErrorReason.signUpConfirmationEmailFailed => (
      s.failed,
      s.errorSignUpConfirmationEmailFailed,
    ),
    HosthubErrorReason.loginOtpEmailFailed => (
      s.failed,
      s.errorLoginOtpEmailFailed,
    ),
    HosthubErrorReason.passwordResetEmailFailed => (
      s.failed,
      s.errorPasswordResetEmailFailed,
    ),
    HosthubErrorReason.userCreatedEmailFailed => (
      s.failed,
      s.errorUserCreatedEmailFailed,
    ),
  };
  return AppError(title: title, alert: alert, domainError: error);
}

bool _connectionFailed(DomainError error) =>
    error.code == DomainErrorCode.network ||
    error.code == DomainErrorCode.timeout ||
    error.network == true;
