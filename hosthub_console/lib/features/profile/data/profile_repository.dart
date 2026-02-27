import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/core/models/models.dart';

class ProfileRepository extends SupabaseRepository {
  ProfileRepository({required SupabaseClient supabase}) : super(supabase);

  Future<Profile?> getProfile() async {
    try {
      final row = await maybeSingle(
        Profile.tableName,
        eq: {'id': currentUserId},
      );
      return row == null ? null : Profile.fromJson(row);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: const {'op': 'getProfile'},
      );
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      await upsert(Profile.tableName, profile.toJson(), ensureCreatedBy: false);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'updateProfile', 'profile_id': profile.id},
      );
    }
  }

  Future<List<Profile>> getAllProfiles() async {
    try {
      final rows = await selectList(
        Profile.tableName,
        columns: 'id, email, username',
      );
      return rows.map(Profile.fromJson).toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: const {'op': 'getAllProfiles'},
      );
    }
  }

  Future<Profile> changeAccount(
    Profile profile, {
    String? email,
    String? currentPassword,
    String? newPassword,
    String? username,
  }) async {
    final updatedProfile = profile.copyWith(
      username: username ?? profile.username,
      email: email ?? profile.email,
    );

    try {
      await upsert(
        Profile.tableName,
        updatedProfile.toJson(),
        ensureCreatedBy: false,
      );

      if (newPassword != null && currentPassword != null) {
        await supabase.auth.updateUser(UserAttributes(password: newPassword));

        if (email != null) {
          await supabase.auth.updateUser(UserAttributes(email: email));
        }
      }

      return updatedProfile;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {
          'op': 'changeAccount',
          'profile_id': profile.id,
          'update_email': email != null,
          'update_password': newPassword != null,
        },
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await supabase.functions.invoke(
        'delete_user',
        body: jsonEncode({'user_id': userId}),
        headers: const {'Content-Type': 'application/json'},
      );

      if (response.status != 200) {
        throw DomainErrorCode.serverError.err(
          reason: DomainErrorReason.cannotDeleteAllUserData,
          context: {'function_status': response.status},
        );
      }
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotDeleteAllUserData,
        context: {'op': 'deleteUser', 'user_id': userId},
      );
    }
  }
}
