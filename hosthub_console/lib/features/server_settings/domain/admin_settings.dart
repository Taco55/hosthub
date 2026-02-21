class AdminSettings {
  const AdminSettings({
    required this.id,
    this.maintenanceModeEnabled = false,
    this.emailUserOnCreate = true,
    this.bookingChannelFeePercentage = 15,
    this.airbnbChannelFeePercentage = 15.5,
    this.otherChannelFeePercentage = 0,
  });

  static const String tableName = 'admin_settings';

  final String id;
  final bool maintenanceModeEnabled;
  final bool emailUserOnCreate;
  final double bookingChannelFeePercentage;
  final double airbnbChannelFeePercentage;
  final double otherChannelFeePercentage;

  factory AdminSettings.fromJson(Map<String, dynamic> json) {
    return AdminSettings(
      id: json['id'] as String,
      maintenanceModeEnabled:
          json['maintenance_mode_enabled'] as bool? ?? false,
      emailUserOnCreate: json['email_user_on_create'] as bool? ?? true,
      bookingChannelFeePercentage:
          _toDouble(json['booking_channel_fee_percentage']) ?? 15,
      airbnbChannelFeePercentage:
          _toDouble(json['airbnb_channel_fee_percentage']) ?? 15.5,
      otherChannelFeePercentage:
          _toDouble(json['other_channel_fee_percentage']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'maintenance_mode_enabled': maintenanceModeEnabled,
    'email_user_on_create': emailUserOnCreate,
    'booking_channel_fee_percentage': bookingChannelFeePercentage,
    'airbnb_channel_fee_percentage': airbnbChannelFeePercentage,
    'other_channel_fee_percentage': otherChannelFeePercentage,
  };

  AdminSettings copyWith({
    bool? maintenanceModeEnabled,
    bool? emailUserOnCreate,
    double? bookingChannelFeePercentage,
    double? airbnbChannelFeePercentage,
    double? otherChannelFeePercentage,
  }) {
    return AdminSettings(
      id: id,
      maintenanceModeEnabled:
          maintenanceModeEnabled ?? this.maintenanceModeEnabled,
      emailUserOnCreate: emailUserOnCreate ?? this.emailUserOnCreate,
      bookingChannelFeePercentage:
          bookingChannelFeePercentage ?? this.bookingChannelFeePercentage,
      airbnbChannelFeePercentage:
          airbnbChannelFeePercentage ?? this.airbnbChannelFeePercentage,
      otherChannelFeePercentage:
          otherChannelFeePercentage ?? this.otherChannelFeePercentage,
    );
  }

  static AdminSettings defaults() => const AdminSettings(
    id: 'defaults',
    maintenanceModeEnabled: false,
    emailUserOnCreate: true,
    bookingChannelFeePercentage: 15,
    airbnbChannelFeePercentage: 15.5,
    otherChannelFeePercentage: 0,
  );
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }
  return null;
}
