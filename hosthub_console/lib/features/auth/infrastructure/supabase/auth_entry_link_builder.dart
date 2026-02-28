class AuthEntryLinkBuilder {
  const AuthEntryLinkBuilder._();

  static String build({
    required String actionLink,
    required String email,
    String? otp,
    String? otpType,
  }) {
    final trimmedActionLink = actionLink.trim();
    final trimmedEmail = email.trim();
    if (trimmedActionLink.isEmpty || trimmedEmail.isEmpty) {
      return trimmedActionLink;
    }

    final verifyUri = Uri.tryParse(trimmedActionLink);
    if (verifyUri == null) return trimmedActionLink;

    final redirectToRaw = verifyUri.queryParameters['redirect_to']?.trim();
    if (redirectToRaw == null || redirectToRaw.isEmpty) {
      return trimmedActionLink;
    }

    final redirectUri = Uri.tryParse(redirectToRaw);
    if (redirectUri == null ||
        (redirectUri.scheme.isEmpty && redirectUri.host.isEmpty)) {
      return trimmedActionLink;
    }

    final resolvedOtpType =
        _normalizeOtpType(otpType) ??
        _normalizeOtpType(verifyUri.queryParameters['type']);

    final query = <String, String>{
      'email': trimmedEmail,
      if (resolvedOtpType != null) 'otp_type': resolvedOtpType,
    };

    final trimmedOtp = otp?.trim();
    if (trimmedOtp != null && trimmedOtp.isNotEmpty) {
      query['otp'] = trimmedOtp;
    }

    return redirectUri
        .replace(
          path: _deriveSetPasswordPath(redirectUri.path),
          queryParameters: query,
          fragment: '',
        )
        .toString();
  }

  static String _deriveSetPasswordPath(String originalPath) {
    final path = originalPath.trim();
    if (path.isEmpty || path == '/') return '/set-password';

    final normalized = path.replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty || normalized == '/') return '/set-password';

    const authSuffixes = <String>{
      '/reset-password',
      '/set-password',
      '/verify-otp',
      '/reset-password-code',
    };

    for (final suffix in authSuffixes) {
      if (normalized.endsWith(suffix)) {
        final prefix = normalized.substring(
          0,
          normalized.length - suffix.length,
        );
        final rootedPrefix = prefix.startsWith('/') ? prefix : '/$prefix';
        final cleanPrefix = rootedPrefix == '/' ? '' : rootedPrefix;
        return '$cleanPrefix/set-password';
      }
    }

    final rooted = normalized.startsWith('/') ? normalized : '/$normalized';
    return '$rooted/set-password';
  }

  static String? _normalizeOtpType(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    const allowed = <String>{
      'signup',
      'invite',
      'magiclink',
      'recovery',
      'email',
      'email_change',
      'phone_change',
    };
    return allowed.contains(normalized) ? normalized : null;
  }
}
