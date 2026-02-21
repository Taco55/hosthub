import 'package:hosthub_console/core/core.dart';

import 'package:hosthub_console/features/auth/domain/ports/auth_port.dart';

/// Returns the currently authenticated user id.
String get currentUserId {
  final id = maybeCurrentUserId;
  if (id == null || id.isEmpty) {
    throw StateError('No user is currently logged in');
  }
  return id;
}

/// Returns the current user id if available, otherwise null.
String? get maybeCurrentUserId {
  final user = I.get<AuthPort>().currentUser;
  if (user == null || user.id.isEmpty) return null;
  return user.id;
}

/// Stable placeholder id for pre-auth flows (e.g. preview lists).
String get previewUserId => 'preview-user';

/// Returns the current user id or a preview placeholder when unauthenticated.
String get currentOrPreviewUserId => maybeCurrentUserId ?? previewUserId;
