/// Asks the backend to send one of the transactional auth mails.
///
/// None of these take an action link or a one-time code, and that is the point:
/// the `send_auth_email` Edge Function mints the credential, renders the mail and
/// hands it to Resend without it ever passing through the client. The console
/// used to fetch `action_link` and `email_otp` itself, which meant anything able
/// to call the generator held a working sign-in link for an address it did not
/// own.
///
/// Site invitations are not here: `invite_site_member` mints that link while
/// creating the invitation and sends the mail itself, for the same reason.
abstract class EmailTemplatesPort {
  Future<void> sendLoginOtpEmail(String to, {String? redirectTo});

  Future<void> sendSignUpConfirmationEmail(
    String to, {
    String? name,
    String? redirectTo,
  });

  Future<void> sendUserCreatedEmail(
    String to, {
    String? name,
    String? redirectTo,
  });

  Future<void> sendPasswordResetEmail(
    String to, {
    String? name,
    String? redirectTo,
  });
}
