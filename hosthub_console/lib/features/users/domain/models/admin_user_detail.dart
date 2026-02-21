import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hosthub_console/shared/models/models.dart';

part 'admin_user_detail.freezed.dart';
part 'admin_user_detail.g.dart';

@freezed
sealed class AdminUserDetail with _$AdminUserDetail {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory AdminUserDetail({required Profile profile}) = _AdminUserDetail;

  const AdminUserDetail._();

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) =>
      _$AdminUserDetailFromJson(json);
}
