import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/user_settings/domain/current_user_provider.dart';

class CurrentUserProviderSupabase implements CurrentUserProvider {
  CurrentUserProviderSupabase({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  String get currentUserId {
    final user = _client.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw DomainErrorCode.unauthorized.err(
        message: 'User not logged in',
        context: const {'supabase_user': null},
      );
    }
    return user.id;
  }
}
