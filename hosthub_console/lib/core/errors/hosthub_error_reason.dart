import 'package:app_errors/app_errors.dart';

/// What went wrong in a flow of the console's own, beyond the library's
/// generic causes. Set as `projectReason:`; `hosthubErrorMapper` words it.
enum HosthubErrorReason implements ErrorReason {
  /// The account was not removed with all of its data.
  cannotDeleteAllUserData,

  /// The mail that confirms a sign-up was not sent.
  signUpConfirmationEmailFailed,

  /// The mail with a sign-in code was not sent.
  loginOtpEmailFailed,

  /// The mail to reset a password was not sent.
  passwordResetEmailFailed,

  /// The welcome mail of an account an admin created was not sent.
  userCreatedEmailFailed;

  @override
  String get key => name;
}
