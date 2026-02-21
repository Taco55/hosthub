// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUserDetail {

 Profile get profile;
/// Create a copy of AdminUserDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserDetailCopyWith<AdminUserDetail> get copyWith => _$AdminUserDetailCopyWithImpl<AdminUserDetail>(this as AdminUserDetail, _$identity);

  /// Serializes this AdminUserDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserDetail&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile);

@override
String toString() {
  return 'AdminUserDetail(profile: $profile)';
}


}

/// @nodoc
abstract mixin class $AdminUserDetailCopyWith<$Res>  {
  factory $AdminUserDetailCopyWith(AdminUserDetail value, $Res Function(AdminUserDetail) _then) = _$AdminUserDetailCopyWithImpl;
@useResult
$Res call({
 Profile profile
});


$ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$AdminUserDetailCopyWithImpl<$Res>
    implements $AdminUserDetailCopyWith<$Res> {
  _$AdminUserDetailCopyWithImpl(this._self, this._then);

  final AdminUserDetail _self;
  final $Res Function(AdminUserDetail) _then;

/// Create a copy of AdminUserDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,}) {
  return _then(_self.copyWith(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}
/// Create a copy of AdminUserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminUserDetail].
extension AdminUserDetailPatterns on AdminUserDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserDetail value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Profile profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserDetail() when $default != null:
return $default(_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Profile profile)  $default,) {final _that = this;
switch (_that) {
case _AdminUserDetail():
return $default(_that.profile);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Profile profile)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserDetail() when $default != null:
return $default(_that.profile);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _AdminUserDetail extends AdminUserDetail {
  const _AdminUserDetail({required this.profile}): super._();
  factory _AdminUserDetail.fromJson(Map<String, dynamic> json) => _$AdminUserDetailFromJson(json);

@override final  Profile profile;

/// Create a copy of AdminUserDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserDetailCopyWith<_AdminUserDetail> get copyWith => __$AdminUserDetailCopyWithImpl<_AdminUserDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserDetail&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile);

@override
String toString() {
  return 'AdminUserDetail(profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$AdminUserDetailCopyWith<$Res> implements $AdminUserDetailCopyWith<$Res> {
  factory _$AdminUserDetailCopyWith(_AdminUserDetail value, $Res Function(_AdminUserDetail) _then) = __$AdminUserDetailCopyWithImpl;
@override @useResult
$Res call({
 Profile profile
});


@override $ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$AdminUserDetailCopyWithImpl<$Res>
    implements _$AdminUserDetailCopyWith<$Res> {
  __$AdminUserDetailCopyWithImpl(this._self, this._then);

  final _AdminUserDetail _self;
  final $Res Function(_AdminUserDetail) _then;

/// Create a copy of AdminUserDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,}) {
  return _then(_AdminUserDetail(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}

/// Create a copy of AdminUserDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
