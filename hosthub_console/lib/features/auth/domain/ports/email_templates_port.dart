abstract class EmailTemplatesPort {
  Future<void> sendLoginOtpEmail(
    String to, {
    String? actionLink,
    String? name,
    String? otp,
  });

  Future<void> sendSignUpConfirmationEmail(
    String to, {
    String? actionLink,
    String? name,
    String? otp,
  });

  Future<void> sendUserCreatedEmail(
    String to, {
    String? actionLink,
    String? name,
    String? otp,
  });

  Future<void> sendPasswordResetEmail(
    String to,
    String? actionLink, {
    String? name,
    String? otp,
  });

  Future<void> sendSiteInvitationEmail(
    String to, {
    String? actionLink,
    String? otp,
    String? siteName,
    bool isNewUser = true,
  });
}
