// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSettings {

 String get profileId; String? get languageCode; String? get exportLanguageCode; List<String>? get exportColumns; String? get lodgifyApiKey; bool get lodgifyConnected; DateTime? get lodgifyConnectedAt; DateTime? get lodgifyLastSyncedAt;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.exportLanguageCode, exportLanguageCode) || other.exportLanguageCode == exportLanguageCode)&&const DeepCollectionEquality().equals(other.exportColumns, exportColumns)&&(identical(other.lodgifyApiKey, lodgifyApiKey) || other.lodgifyApiKey == lodgifyApiKey)&&(identical(other.lodgifyConnected, lodgifyConnected) || other.lodgifyConnected == lodgifyConnected)&&(identical(other.lodgifyConnectedAt, lodgifyConnectedAt) || other.lodgifyConnectedAt == lodgifyConnectedAt)&&(identical(other.lodgifyLastSyncedAt, lodgifyLastSyncedAt) || other.lodgifyLastSyncedAt == lodgifyLastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileId,languageCode,exportLanguageCode,const DeepCollectionEquality().hash(exportColumns),lodgifyApiKey,lodgifyConnected,lodgifyConnectedAt,lodgifyLastSyncedAt);

@override
String toString() {
  return 'UserSettings(profileId: $profileId, languageCode: $languageCode, exportLanguageCode: $exportLanguageCode, exportColumns: $exportColumns, lodgifyApiKey: $lodgifyApiKey, lodgifyConnected: $lodgifyConnected, lodgifyConnectedAt: $lodgifyConnectedAt, lodgifyLastSyncedAt: $lodgifyLastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String profileId, String? languageCode, String? exportLanguageCode, List<String>? exportColumns, String? lodgifyApiKey, bool lodgifyConnected, DateTime? lodgifyConnectedAt, DateTime? lodgifyLastSyncedAt
});




}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? languageCode = freezed,Object? exportLanguageCode = freezed,Object? exportColumns = freezed,Object? lodgifyApiKey = freezed,Object? lodgifyConnected = null,Object? lodgifyConnectedAt = freezed,Object? lodgifyLastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,exportLanguageCode: freezed == exportLanguageCode ? _self.exportLanguageCode : exportLanguageCode // ignore: cast_nullable_to_non_nullable
as String?,exportColumns: freezed == exportColumns ? _self.exportColumns : exportColumns // ignore: cast_nullable_to_non_nullable
as List<String>?,lodgifyApiKey: freezed == lodgifyApiKey ? _self.lodgifyApiKey : lodgifyApiKey // ignore: cast_nullable_to_non_nullable
as String?,lodgifyConnected: null == lodgifyConnected ? _self.lodgifyConnected : lodgifyConnected // ignore: cast_nullable_to_non_nullable
as bool,lodgifyConnectedAt: freezed == lodgifyConnectedAt ? _self.lodgifyConnectedAt : lodgifyConnectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lodgifyLastSyncedAt: freezed == lodgifyLastSyncedAt ? _self.lodgifyLastSyncedAt : lodgifyLastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String? languageCode,  String? exportLanguageCode,  List<String>? exportColumns,  String? lodgifyApiKey,  bool lodgifyConnected,  DateTime? lodgifyConnectedAt,  DateTime? lodgifyLastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.profileId,_that.languageCode,_that.exportLanguageCode,_that.exportColumns,_that.lodgifyApiKey,_that.lodgifyConnected,_that.lodgifyConnectedAt,_that.lodgifyLastSyncedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String? languageCode,  String? exportLanguageCode,  List<String>? exportColumns,  String? lodgifyApiKey,  bool lodgifyConnected,  DateTime? lodgifyConnectedAt,  DateTime? lodgifyLastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.profileId,_that.languageCode,_that.exportLanguageCode,_that.exportColumns,_that.lodgifyApiKey,_that.lodgifyConnected,_that.lodgifyConnectedAt,_that.lodgifyLastSyncedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String? languageCode,  String? exportLanguageCode,  List<String>? exportColumns,  String? lodgifyApiKey,  bool lodgifyConnected,  DateTime? lodgifyConnectedAt,  DateTime? lodgifyLastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.profileId,_that.languageCode,_that.exportLanguageCode,_that.exportColumns,_that.lodgifyApiKey,_that.lodgifyConnected,_that.lodgifyConnectedAt,_that.lodgifyLastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserSettings extends UserSettings {
  const _UserSettings({required this.profileId, this.languageCode, this.exportLanguageCode, final  List<String>? exportColumns, this.lodgifyApiKey, this.lodgifyConnected = false, this.lodgifyConnectedAt, this.lodgifyLastSyncedAt}): _exportColumns = exportColumns,super._();
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override final  String profileId;
@override final  String? languageCode;
@override final  String? exportLanguageCode;
 final  List<String>? _exportColumns;
@override List<String>? get exportColumns {
  final value = _exportColumns;
  if (value == null) return null;
  if (_exportColumns is EqualUnmodifiableListView) return _exportColumns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? lodgifyApiKey;
@override@JsonKey() final  bool lodgifyConnected;
@override final  DateTime? lodgifyConnectedAt;
@override final  DateTime? lodgifyLastSyncedAt;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.exportLanguageCode, exportLanguageCode) || other.exportLanguageCode == exportLanguageCode)&&const DeepCollectionEquality().equals(other._exportColumns, _exportColumns)&&(identical(other.lodgifyApiKey, lodgifyApiKey) || other.lodgifyApiKey == lodgifyApiKey)&&(identical(other.lodgifyConnected, lodgifyConnected) || other.lodgifyConnected == lodgifyConnected)&&(identical(other.lodgifyConnectedAt, lodgifyConnectedAt) || other.lodgifyConnectedAt == lodgifyConnectedAt)&&(identical(other.lodgifyLastSyncedAt, lodgifyLastSyncedAt) || other.lodgifyLastSyncedAt == lodgifyLastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileId,languageCode,exportLanguageCode,const DeepCollectionEquality().hash(_exportColumns),lodgifyApiKey,lodgifyConnected,lodgifyConnectedAt,lodgifyLastSyncedAt);

@override
String toString() {
  return 'UserSettings(profileId: $profileId, languageCode: $languageCode, exportLanguageCode: $exportLanguageCode, exportColumns: $exportColumns, lodgifyApiKey: $lodgifyApiKey, lodgifyConnected: $lodgifyConnected, lodgifyConnectedAt: $lodgifyConnectedAt, lodgifyLastSyncedAt: $lodgifyLastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String? languageCode, String? exportLanguageCode, List<String>? exportColumns, String? lodgifyApiKey, bool lodgifyConnected, DateTime? lodgifyConnectedAt, DateTime? lodgifyLastSyncedAt
});




}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? languageCode = freezed,Object? exportLanguageCode = freezed,Object? exportColumns = freezed,Object? lodgifyApiKey = freezed,Object? lodgifyConnected = null,Object? lodgifyConnectedAt = freezed,Object? lodgifyLastSyncedAt = freezed,}) {
  return _then(_UserSettings(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,exportLanguageCode: freezed == exportLanguageCode ? _self.exportLanguageCode : exportLanguageCode // ignore: cast_nullable_to_non_nullable
as String?,exportColumns: freezed == exportColumns ? _self._exportColumns : exportColumns // ignore: cast_nullable_to_non_nullable
as List<String>?,lodgifyApiKey: freezed == lodgifyApiKey ? _self.lodgifyApiKey : lodgifyApiKey // ignore: cast_nullable_to_non_nullable
as String?,lodgifyConnected: null == lodgifyConnected ? _self.lodgifyConnected : lodgifyConnected // ignore: cast_nullable_to_non_nullable
as bool,lodgifyConnectedAt: freezed == lodgifyConnectedAt ? _self.lodgifyConnectedAt : lodgifyConnectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lodgifyLastSyncedAt: freezed == lodgifyLastSyncedAt ? _self.lodgifyLastSyncedAt : lodgifyLastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
