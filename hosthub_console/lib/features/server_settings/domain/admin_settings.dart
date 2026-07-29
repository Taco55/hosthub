/// Environment-wide platform settings — the whole installation, not one
/// account.
///
/// The channel commissions that used to live here moved to
/// `account_channel_defaults`: they are an account's own money, and one row for
/// every customer was never the right shape. The columns stay in the table
/// because the migration that seeded the accounts reads them; nothing in the
/// app does.
class AdminSettings {
  const AdminSettings({
    required this.id,
    this.maintenanceModeEnabled = false,
    this.emailUserOnCreate = true,
  });

  static const String tableName = 'admin_settings';

  final String id;
  final bool maintenanceModeEnabled;
  final bool emailUserOnCreate;

  factory AdminSettings.fromJson(Map<String, dynamic> json) {
    return AdminSettings(
      id: json['id'] as String,
      maintenanceModeEnabled:
          json['maintenance_mode_enabled'] as bool? ?? false,
      emailUserOnCreate: json['email_user_on_create'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'maintenance_mode_enabled': maintenanceModeEnabled,
    'email_user_on_create': emailUserOnCreate,
  };

  AdminSettings copyWith({
    bool? maintenanceModeEnabled,
    bool? emailUserOnCreate,
  }) {
    return AdminSettings(
      id: id,
      maintenanceModeEnabled:
          maintenanceModeEnabled ?? this.maintenanceModeEnabled,
      emailUserOnCreate: emailUserOnCreate ?? this.emailUserOnCreate,
    );
  }

  static AdminSettings defaults() => const AdminSettings(
    id: 'defaults',
    maintenanceModeEnabled: false,
    emailUserOnCreate: true,
  );
}
