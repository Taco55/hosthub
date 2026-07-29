import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/properties/domain/account_channel_defaults.dart';
import 'package:hosthub_console/features/properties/domain/account_settings.dart';

/// The account tier of the channel settings.
///
/// One row per channel, all columns filled. Writing here reaches every property
/// that has not stated its own value — because inheritance is resolution, not a
/// copy — so a change is one write, never a backfill of N properties that can
/// fail halfway.
class AccountChannelDefaultsRepository extends SupabaseRepository {
  AccountChannelDefaultsRepository({required SupabaseClient supabase})
    : super(supabase);

  static const String tableName = 'account_channel_defaults';
  static const String accountSettingsTable = 'account_settings';

  static const String _columns =
      'owner_profile_id, channel, commission_percentage, '
      'rate_markup_percentage, cleaning_amount, cleaning_type, linen_amount, '
      'linen_type, service_amount, service_type, other_amount, other_type';

  /// The defaults of the account [ownerProfileId] acts for.
  ///
  /// An account with no rows yet resolves to zeroes rather than to an error:
  /// the tier exists conceptually before anyone has typed in it.
  Future<AccountChannelDefaults> fetch(String ownerProfileId) async {
    try {
      final rows = await supabase
          .from(tableName)
          .select(_columns)
          .eq('owner_profile_id', ownerProfileId);
      return AccountChannelDefaults.fromRows(
        rows.map(Map<String, dynamic>.from),
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchAccountChannelDefaults'},
      );
    }
  }

  /// Write the whole tier for one account.
  ///
  /// An upsert of three rows rather than a diff: the tier is small, complete by
  /// definition, and a partial write is the one way the two tiers could end up
  /// describing different worlds.
  Future<AccountChannelDefaults> save({
    required String ownerProfileId,
    required AccountChannelDefaults defaults,
  }) async {
    try {
      final rows = await supabase
          .from(tableName)
          .upsert(
            defaults.toRows(ownerProfileId),
            onConflict: 'owner_profile_id,channel',
          )
          .select(_columns);
      return AccountChannelDefaults.fromRows(
        rows.map(Map<String, dynamic>.from),
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'saveAccountChannelDefaults'},
      );
    }
  }

  /// The account-level settings that are not per channel.
  Future<AccountSettings> fetchAccountSettings(String ownerProfileId) async {
    try {
      final row = await supabase
          .from(accountSettingsTable)
          .select('default_source_language, default_languages, vat_number')
          .eq('owner_profile_id', ownerProfileId)
          .maybeSingle();
      // No row is not an error: an account that has never opened
      // Standaardwaarden simply has the defaults.
      return AccountSettings.fromMap(
        row == null ? null : Map<String, dynamic>.from(row),
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchAccountSettings'},
      );
    }
  }

  Future<AccountSettings> saveAccountSettings({
    required String ownerProfileId,
    required AccountSettings settings,
  }) async {
    try {
      final row = await supabase
          .from(accountSettingsTable)
          .upsert(
            settings.toMap(ownerProfileId),
            onConflict: 'owner_profile_id',
          )
          .select('default_source_language, default_languages, vat_number')
          .single();
      return AccountSettings.fromMap(Map<String, dynamic>.from(row));
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'saveAccountSettings'},
      );
    }
  }

  /// The account this user acts for — their own, or the one that invited them.
  ///
  /// Resolved server-side by `public.account_owner_for`, the same function the
  /// `properties` row default and its policies use, so the console can never
  /// read one account's defaults while writing another's.
  Future<String?> currentAccountOwnerId() async {
    try {
      final result = await supabase.rpc(
        'account_owner_for',
        params: {'check_user_id': currentUserId},
      );
      final id = result?.toString().trim();
      return (id == null || id.isEmpty) ? null : id;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'currentAccountOwnerId'},
      );
    }
  }
}
