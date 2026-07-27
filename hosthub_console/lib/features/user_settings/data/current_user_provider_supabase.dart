import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/user_settings/domain/current_user_provider.dart';

class CurrentUserProviderSupabase implements CurrentUserProvider {
  CurrentUserProviderSupabase({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  @override
  String get currentUserId {
    final userId = currentUserIdOrNull;
    if (userId == null) {
      // logout: false — this is a local precondition, not a server verdict on
      // the session. Without it the message trips the "expired session"
      // heuristic in app_errors and a client-side read that raced the session
      // (app start, token refresh) would force a real sign-out.
      throw DomainErrorCode.unauthorized.err(
        message: 'User not logged in',
        logout: false,
        context: const {'supabase_user': null},
      );
    }
    return userId;
  }

  @override
  String? get currentUserIdOrNull {
    final user = _client.auth.currentUser;
    if (user == null || user.id.isEmpty) return null;
    return user.id;
  }
}
