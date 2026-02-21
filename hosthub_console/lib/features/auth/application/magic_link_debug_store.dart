import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class MagicLinkDebugData {
  const MagicLinkDebugData({required this.link, this.email, this.otp});

  final String link;
  final String? email;
  final String? otp;
}

/// Global store to keep track of the latest magic link for debug previews.
class MagicLinkDebugStore extends ValueNotifier<MagicLinkDebugData?> {
  MagicLinkDebugStore._() : super(null);

  static final MagicLinkDebugStore instance = MagicLinkDebugStore._();

  /// Save a new link for preview. Empty values clear the preview.
  void setLink(String? link, {String? email, String? otp}) {
    final trimmedLink = link?.trim();
    if (trimmedLink == null || trimmedLink.isEmpty) {
      clear();
      return;
    }

    final trimmedEmail = email?.trim();
    final trimmedOtp = otp?.trim();

    final current = value;
    if (current != null &&
        current.link == trimmedLink &&
        current.email == trimmedEmail &&
        current.otp == trimmedOtp) {
      return;
    }

    developer.log(
      'Magic link email sent: $trimmedLink',
      name: 'MagicLinkDebugStore',
    );
    value = MagicLinkDebugData(
      link: trimmedLink,
      email: trimmedEmail?.isNotEmpty == true ? trimmedEmail : null,
      otp: trimmedOtp?.isNotEmpty == true ? trimmedOtp : null,
    );
  }

  void clear() {
    if (value == null) return;
    value = null;
  }
}
