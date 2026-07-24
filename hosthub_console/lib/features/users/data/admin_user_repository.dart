import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/core/models/models.dart';

import 'package:hosthub_console/features/users/domain/models/admin_user_detail.dart';

const _profileSelectColumns = '''
  id, email, username, is_admin, subscription_status,
  is_development, is_seeded, show_calendar_tab, show_start_tab,
  default_home_tab, notification_settings
''';

class AdminUserRepository {
  AdminUserRepository(this._client);

  final SupabaseClient _client;

  Future<List<Profile>> fetchProfiles({
    String? searchQuery,
    int limit = 200,
  }) async {
    final trimmedQuery = searchQuery?.trim();
    try {
      var request = _client
          .from(Profile.tableName)
          .select(_profileSelectColumns)
          .order('email');

      if (limit > 0) {
        request = request.limit(limit);
      }

      if (trimmedQuery?.isNotEmpty == true) {
        final pattern = '%$trimmedQuery%';
        final url = request.appendSearchParams(
          'or',
          '(email.ilike.$pattern,username.ilike.$pattern)',
        );
        request = request.copyWithUrl(url);
      }

      final response = await request;
      final data = (response as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Profile.fromJson)
          .toList(growable: false);

      return data;
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchProfiles', 'query': trimmedQuery, 'limit': limit},
      );
    }
  }

  Future<Profile> fetchProfile(String userId) async {
    try {
      final response = await _client
          .from(Profile.tableName)
          .select(_profileSelectColumns)
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        throw DomainErrorCode.notFound.err(
          reason: DomainErrorReason.cannotLoadData,
          message: 'User not found for id: $userId',
          context: {'op': 'fetchProfile', 'user_id': userId},
        );
      }

      return Profile.fromJson(Map<String, dynamic>.from(response));
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchProfile', 'user_id': userId},
      );
    }
  }

  Future<AdminUserDetail> fetchUserDetail(String userId) async {
    final profile = await fetchProfile(userId);

    return AdminUserDetail(profile: profile);
  }

  Future<Profile> updateAdminFlag(String userId, bool isAdmin) async {
    try {
      final response = await _client
          .from(Profile.tableName)
          .update({'is_admin': isAdmin})
          .eq('id', userId)
          .select(
            'id, email, username, is_admin, subscription_status, '
            'is_development, is_seeded, show_calendar_tab, show_start_tab, '
            'default_home_tab, notification_settings',
          )
          .maybeSingle();

      if (response == null) {
        throw DomainErrorCode.serverError.err(
          reason: DomainErrorReason.cannotSaveData,
          message: 'Could not update admin status for $userId',
          context: {'op': 'updateAdminFlag', 'user_id': userId},
        );
      }

      return Profile.fromJson(Map<String, dynamic>.from(response));
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateAdminFlag', 'user_id': userId},
      );
    }
  }

  Future<Profile> updateProfileDetails(
    String userId, {
    required String email,
    String? username,
  }) async {
    try {
      if (_client.auth.currentUser?.id == userId) {
        await _client.auth.updateUser(UserAttributes(email: email));
      } else {
        await _client.auth.admin.updateUserById(
          userId,
          attributes: AdminUserAttributes(email: email),
        );
      }

      final response = await _client
          .from(Profile.tableName)
          .update({'email': email, 'username': username})
          .eq('id', userId)
          .select(
            'id, email, username, is_admin, subscription_status, '
            'is_development, is_seeded, show_calendar_tab, show_start_tab, '
            'default_home_tab, notification_settings',
          )
          .maybeSingle();

      if (response == null) {
        throw DomainErrorCode.serverError.err(
          reason: DomainErrorReason.cannotSaveData,
          message: 'Could not update profile for $userId',
          context: {'op': 'updateProfileDetails', 'user_id': userId},
        );
      }

      return Profile.fromJson(Map<String, dynamic>.from(response));
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateProfileDetails', 'user_id': userId},
      );
    }
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    try {
      if (_client.auth.currentUser?.id == userId) {
        await _client.auth.updateUser(UserAttributes(password: newPassword));
      } else {
        await _client.auth.admin.updateUserById(
          userId,
          attributes: AdminUserAttributes(password: newPassword),
        );
      }
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updatePassword', 'user_id': userId},
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _client.from('list_access').delete().eq('profile_id', userId);
      await _client.from('lists').delete().eq('created_by', userId);
      await _client.from(Profile.tableName).delete().eq('id', userId);
      await _client.auth.admin.deleteUser(userId);
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotDeleteAllUserData,
        context: {'op': 'deleteUser', 'user_id': userId},
      );
    }
  }

  /// Creates a password-based account through the `admin_create_user` Edge
  /// Function.
  ///
  /// This cannot run client-side: the console holds the publishable (anon) key
  /// and `auth.admin.*` answers 403 `not_admin` for it. The function keeps the
  /// service-role key server-side, verifies the caller is a platform admin, and
  /// provisions both the auth user and the `profiles` row.
  Future<String> createUser({
    required String email,
    required String password,
    String? username,
  }) async {
    final trimmedEmail = email.trim();
    final normalizedUsername = username?.trim();
    try {
      final accessToken = _client.auth.currentSession?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw DomainErrorCode.unauthorized.err(
          reason: DomainErrorReason.cannotSaveData,
          message: 'No access token available for createUser call',
          context: const {'op': 'createUser', 'auth_session': 'missing'},
        );
      }

      final response = await _client.functions.invoke(
        'admin_create_user',
        body: {
          'email': trimmedEmail,
          'password': password,
          if (normalizedUsername != null && normalizedUsername.isNotEmpty)
            'username': normalizedUsername,
        },
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final data = response.data;
      final userId = data is Map ? data['user_id'] as String? : null;
      if (userId == null || userId.isEmpty) {
        throw DomainErrorCode.serverError.err(
          reason: DomainErrorReason.cannotSaveData,
          message: 'admin_create_user returned no user_id',
          context: {'op': 'createUser', 'email': trimmedEmail},
        );
      }

      return userId;
    } on FunctionException catch (error, stack) {
      // 409 is the function's signal that the address is already taken. Use the
      // email-specific reason, not usernameExists — this form only asks for an
      // email, and app_errors renders that one as "Gebruikersnaam bestaat al."
      if (error.status == 409) {
        throw DomainErrorCode.dataConflict.err(
          reason: DomainErrorReason.emailAlreadyRegistered,
          context: {'op': 'createUser', 'email': trimmedEmail},
        );
      }
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {
          'op': 'createUser',
          'email': trimmedEmail,
          'status': error.status,
        },
      );
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'createUser', 'email': trimmedEmail},
      );
    }
  }

  DomainError _mapError(
    Object error,
    StackTrace stack, {
    DomainErrorReason? reason,
    Map<String, Object?> context = const {},
  }) {
    final base = DomainError.from(error, stack: stack);
    final mergedContext = <String, Object?>{
      'repository': runtimeType.toString(),
      if (base.context != null) ...base.context!,
      ...context,
    };
    final resolvedReason = base.reason ?? reason;
    return base.copyWith(
      reason: resolvedReason,
      context: mergedContext.isEmpty ? base.context : mergedContext,
    );
  }
}
