// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Settings {

 String get id; bool get maintenanceModeEnabled; bool get emailUserOnCreate; String? get lodgifyApiKey; bool get lodgifyConnected; DateTime? get lodgifyConnectedAt; DateTime? get lodgifyLastSyncedAt;
/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsCopyWith<Settings> get copyWith => _$SettingsCopyWithImpl<Settings>(this as Settings, _$identity);

  /// Serializes this Settings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settings&&(identical(other.id, id) || other.id == id)&&(identical(other.maintenanceModeEnabled, maintenanceModeEnabled) || other.maintenanceModeEnabled == maintenanceModeEnabled)&&(identical(other.emailUserOnCreate, emailUserOnCreate) || other.emailUserOnCreate == emailUserOnCreate)&&(identical(other.lodgifyApiKey, lodgifyApiKey) || other.lodgifyApiKey == lodgifyApiKey)&&(identical(other.lodgifyConnected, lodgifyConnected) || other.lodgifyConnected == lodgifyConnected)&&(identical(other.lodgifyConnectedAt, lodgifyConnectedAt) || other.lodgifyConnectedAt == lodgifyConnectedAt)&&(identical(other.lodgifyLastSyncedAt, lodgifyLastSyncedAt) || other.lodgifyLastSyncedAt == lodgifyLastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,maintenanceModeEnabled,emailUserOnCreate,lodgifyApiKey,lodgifyConnected,lodgifyConnectedAt,lodgifyLastSyncedAt);

@override
String toString() {
  return 'Settings(id: $id, maintenanceModeEnabled: $maintenanceModeEnabled, emailUserOnCreate: $emailUserOnCreate, lodgifyApiKey: $lodgifyApiKey, lodgifyConnected: $lodgifyConnected, lodgifyConnectedAt: $lodgifyConnectedAt, lodgifyLastSyncedAt: $lodgifyLastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res>  {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) = _$SettingsCopyWithImpl;
@useResult
$Res call({
 String id, bool maintenanceModeEnabled, bool emailUserOnCreate, String? lodgifyApiKey, bool lodgifyConnected, DateTime? lodgifyConnectedAt, DateTime? lodgifyLastSyncedAt
});




}
/// @nodoc
class _$SettingsCopyWithImpl<$Res>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? maintenanceModeEnabled = null,Object? emailUserOnCreate = null,Object? lodgifyApiKey = freezed,Object? lodgifyConnected = null,Object? lodgifyConnectedAt = freezed,Object? lodgifyLastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,maintenanceModeEnabled: null == maintenanceModeEnabled ? _self.maintenanceModeEnabled : maintenanceModeEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailUserOnCreate: null == emailUserOnCreate ? _self.emailUserOnCreate : emailUserOnCreate // ignore: cast_nullable_to_non_nullable
as bool,lodgifyApiKey: freezed == lodgifyApiKey ? _self.lodgifyApiKey : lodgifyApiKey // ignore: cast_nullable_to_non_nullable
as String?,lodgifyConnected: null == lodgifyConnected ? _self.lodgifyConnected : lodgifyConnected // ignore: cast_nullable_to_non_nullable
as bool,lodgifyConnectedAt: freezed == lodgifyConnectedAt ? _self.lodgifyConnectedAt : lodgifyConnectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lodgifyLastSyncedAt: freezed == lodgifyLastSyncedAt ? _self.lodgifyLastSyncedAt : lodgifyLastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Settings].
extension SettingsPatterns on Settings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Settings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Settings value)  $default,){
final _that = this;
switch (_that) {
case _Settings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Settings value)?  $default,){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool maintenanceModeEnabled,  bool emailUserOnCreate,  String? lodgifyApiKey,  bool lodgifyConnected,  DateTime? lodgifyConnectedAt,  DateTime? lodgifyLastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.id,_that.maintenanceModeEnabled,_that.emailUserOnCreate,_that.lodgifyApiKey,_that.lodgifyConnected,_that.lodgifyConnectedAt,_that.lodgifyLastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool maintenanceModeEnabled,  bool emailUserOnCreate,  String? lodgifyApiKey,  bool lodgifyConnected,  DateTime? lodgifyConnectedAt,  DateTime? lodgifyLastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _Settings():
return $default(_that.id,_that.maintenanceModeEnabled,_that.emailUserOnCreate,_that.lodgifyApiKey,_that.lodgifyConnected,_that.lodgifyConnectedAt,_that.lodgifyLastSyncedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool maintenanceModeEnabled,  bool emailUserOnCreate,  String? lodgifyApiKey,  bool lodgifyConnected,  DateTime? lodgifyConnectedAt,  DateTime? lodgifyLastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.id,_that.maintenanceModeEnabled,_that.emailUserOnCreate,_that.lodgifyApiKey,_that.lodgifyConnected,_that.lodgifyConnectedAt,_that.lodgifyLastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Settings extends Settings {
  const _Settings({required this.id, this.maintenanceModeEnabled = false, this.emailUserOnCreate = true, this.lodgifyApiKey, this.lodgifyConnected = false, this.lodgifyConnectedAt, this.lodgifyLastSyncedAt}): super._();
  factory _Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

@override final  String id;
@override@JsonKey() final  bool maintenanceModeEnabled;
@override@JsonKey() final  bool emailUserOnCreate;
@override final  String? lodgifyApiKey;
@override@JsonKey() final  bool lodgifyConnected;
@override final  DateTime? lodgifyConnectedAt;
@override final  DateTime? lodgifyLastSyncedAt;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsCopyWith<_Settings> get copyWith => __$SettingsCopyWithImpl<_Settings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settings&&(identical(other.id, id) || other.id == id)&&(identical(other.maintenanceModeEnabled, maintenanceModeEnabled) || other.maintenanceModeEnabled == maintenanceModeEnabled)&&(identical(other.emailUserOnCreate, emailUserOnCreate) || other.emailUserOnCreate == emailUserOnCreate)&&(identical(other.lodgifyApiKey, lodgifyApiKey) || other.lodgifyApiKey == lodgifyApiKey)&&(identical(other.lodgifyConnected, lodgifyConnected) || other.lodgifyConnected == lodgifyConnected)&&(identical(other.lodgifyConnectedAt, lodgifyConnectedAt) || other.lodgifyConnectedAt == lodgifyConnectedAt)&&(identical(other.lodgifyLastSyncedAt, lodgifyLastSyncedAt) || other.lodgifyLastSyncedAt == lodgifyLastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,maintenanceModeEnabled,emailUserOnCreate,lodgifyApiKey,lodgifyConnected,lodgifyConnectedAt,lodgifyLastSyncedAt);

@override
String toString() {
  return 'Settings(id: $id, maintenanceModeEnabled: $maintenanceModeEnabled, emailUserOnCreate: $emailUserOnCreate, lodgifyApiKey: $lodgifyApiKey, lodgifyConnected: $lodgifyConnected, lodgifyConnectedAt: $lodgifyConnectedAt, lodgifyLastSyncedAt: $lodgifyLastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res> implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) = __$SettingsCopyWithImpl;
@override @useResult
$Res call({
 String id, bool maintenanceModeEnabled, bool emailUserOnCreate, String? lodgifyApiKey, bool lodgifyConnected, DateTime? lodgifyConnectedAt, DateTime? lodgifyLastSyncedAt
});




}
/// @nodoc
class __$SettingsCopyWithImpl<$Res>
    implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? maintenanceModeEnabled = null,Object? emailUserOnCreate = null,Object? lodgifyApiKey = freezed,Object? lodgifyConnected = null,Object? lodgifyConnectedAt = freezed,Object? lodgifyLastSyncedAt = freezed,}) {
  return _then(_Settings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,maintenanceModeEnabled: null == maintenanceModeEnabled ? _self.maintenanceModeEnabled : maintenanceModeEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailUserOnCreate: null == emailUserOnCreate ? _self.emailUserOnCreate : emailUserOnCreate // ignore: cast_nullable_to_non_nullable
as bool,lodgifyApiKey: freezed == lodgifyApiKey ? _self.lodgifyApiKey : lodgifyApiKey // ignore: cast_nullable_to_non_nullable
as String?,lodgifyConnected: null == lodgifyConnected ? _self.lodgifyConnected : lodgifyConnected // ignore: cast_nullable_to_non_nullable
as bool,lodgifyConnectedAt: freezed == lodgifyConnectedAt ? _self.lodgifyConnectedAt : lodgifyConnectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lodgifyLastSyncedAt: freezed == lodgifyLastSyncedAt ? _self.lodgifyLastSyncedAt : lodgifyLastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
