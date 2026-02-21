import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.model.freezed.dart';
part 'profile.model.g.dart';

@freezed
sealed class Profile with _$Profile {
  const Profile._();

  static const String tableName = 'profiles';

  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory Profile({
    required String id,
    @JsonKey(includeToJson: false, includeFromJson: false) String? createdBy,
    required String email,
    String? username,
    String? fcmToken,
    @Default(false) bool isDevelopment,
    @Default(false) bool isAdmin,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  static Profile empty() => const Profile(id: '123', email: 'unknown');

  @override
  Map<String, dynamic> toJson() => _$ProfileToJson(this as _Profile);

  @override
  String toString() {
    return 'Profile(id: $id, email: $email, username: $username, '
        'isAdmin: $isAdmin';
  }
}
