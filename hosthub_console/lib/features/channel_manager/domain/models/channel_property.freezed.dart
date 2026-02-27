// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_property.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelProperty {

 String? get id; String? get name;
/// Create a copy of ChannelProperty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelPropertyCopyWith<ChannelProperty> get copyWith => _$ChannelPropertyCopyWithImpl<ChannelProperty>(this as ChannelProperty, _$identity);

  /// Serializes this ChannelProperty to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelProperty&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ChannelProperty(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ChannelPropertyCopyWith<$Res>  {
  factory $ChannelPropertyCopyWith(ChannelProperty value, $Res Function(ChannelProperty) _then) = _$ChannelPropertyCopyWithImpl;
@useResult
$Res call({
 String? id, String? name
});




}
/// @nodoc
class _$ChannelPropertyCopyWithImpl<$Res>
    implements $ChannelPropertyCopyWith<$Res> {
  _$ChannelPropertyCopyWithImpl(this._self, this._then);

  final ChannelProperty _self;
  final $Res Function(ChannelProperty) _then;

/// Create a copy of ChannelProperty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelProperty].
extension ChannelPropertyPatterns on ChannelProperty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelProperty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelProperty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelProperty value)  $default,){
final _that = this;
switch (_that) {
case _ChannelProperty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelProperty value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelProperty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelProperty() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name)  $default,) {final _that = this;
switch (_that) {
case _ChannelProperty():
return $default(_that.id,_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _ChannelProperty() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChannelProperty extends ChannelProperty {
  const _ChannelProperty({this.id, this.name}): super._();
  factory _ChannelProperty.fromJson(Map<String, dynamic> json) => _$ChannelPropertyFromJson(json);

@override final  String? id;
@override final  String? name;

/// Create a copy of ChannelProperty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelPropertyCopyWith<_ChannelProperty> get copyWith => __$ChannelPropertyCopyWithImpl<_ChannelProperty>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelPropertyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelProperty&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ChannelProperty(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ChannelPropertyCopyWith<$Res> implements $ChannelPropertyCopyWith<$Res> {
  factory _$ChannelPropertyCopyWith(_ChannelProperty value, $Res Function(_ChannelProperty) _then) = __$ChannelPropertyCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name
});




}
/// @nodoc
class __$ChannelPropertyCopyWithImpl<$Res>
    implements _$ChannelPropertyCopyWith<$Res> {
  __$ChannelPropertyCopyWithImpl(this._self, this._then);

  final _ChannelProperty _self;
  final $Res Function(_ChannelProperty) _then;

/// Create a copy of ChannelProperty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_ChannelProperty(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
