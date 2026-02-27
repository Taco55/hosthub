// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_property_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelPropertyDetails {

 String? get id; String? get name;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw;
/// Create a copy of ChannelPropertyDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelPropertyDetailsCopyWith<ChannelPropertyDetails> get copyWith => _$ChannelPropertyDetailsCopyWithImpl<ChannelPropertyDetails>(this as ChannelPropertyDetails, _$identity);

  /// Serializes this ChannelPropertyDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelPropertyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.raw, raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(raw));

@override
String toString() {
  return 'ChannelPropertyDetails(id: $id, name: $name, raw: $raw)';
}


}

/// @nodoc
abstract mixin class $ChannelPropertyDetailsCopyWith<$Res>  {
  factory $ChannelPropertyDetailsCopyWith(ChannelPropertyDetails value, $Res Function(ChannelPropertyDetails) _then) = _$ChannelPropertyDetailsCopyWithImpl;
@useResult
$Res call({
 String? id, String? name,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class _$ChannelPropertyDetailsCopyWithImpl<$Res>
    implements $ChannelPropertyDetailsCopyWith<$Res> {
  _$ChannelPropertyDetailsCopyWithImpl(this._self, this._then);

  final ChannelPropertyDetails _self;
  final $Res Function(ChannelPropertyDetails) _then;

/// Create a copy of ChannelPropertyDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? raw = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelPropertyDetails].
extension ChannelPropertyDetailsPatterns on ChannelPropertyDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelPropertyDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelPropertyDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelPropertyDetails value)  $default,){
final _that = this;
switch (_that) {
case _ChannelPropertyDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelPropertyDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelPropertyDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelPropertyDetails() when $default != null:
return $default(_that.id,_that.name,_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)  $default,) {final _that = this;
switch (_that) {
case _ChannelPropertyDetails():
return $default(_that.id,_that.name,_that.raw);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,) {final _that = this;
switch (_that) {
case _ChannelPropertyDetails() when $default != null:
return $default(_that.id,_that.name,_that.raw);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChannelPropertyDetails extends ChannelPropertyDetails {
  const _ChannelPropertyDetails({this.id, this.name, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic> raw = const <String, dynamic>{}}): _raw = raw,super._();
  factory _ChannelPropertyDetails.fromJson(Map<String, dynamic> json) => _$ChannelPropertyDetailsFromJson(json);

@override final  String? id;
@override final  String? name;
 final  Map<String, dynamic> _raw;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}


/// Create a copy of ChannelPropertyDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelPropertyDetailsCopyWith<_ChannelPropertyDetails> get copyWith => __$ChannelPropertyDetailsCopyWithImpl<_ChannelPropertyDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelPropertyDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelPropertyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._raw, _raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_raw));

@override
String toString() {
  return 'ChannelPropertyDetails(id: $id, name: $name, raw: $raw)';
}


}

/// @nodoc
abstract mixin class _$ChannelPropertyDetailsCopyWith<$Res> implements $ChannelPropertyDetailsCopyWith<$Res> {
  factory _$ChannelPropertyDetailsCopyWith(_ChannelPropertyDetails value, $Res Function(_ChannelPropertyDetails) _then) = __$ChannelPropertyDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class __$ChannelPropertyDetailsCopyWithImpl<$Res>
    implements _$ChannelPropertyDetailsCopyWith<$Res> {
  __$ChannelPropertyDetailsCopyWithImpl(this._self, this._then);

  final _ChannelPropertyDetails _self;
  final $Res Function(_ChannelPropertyDetails) _then;

/// Create a copy of ChannelPropertyDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? raw = null,}) {
  return _then(_ChannelPropertyDetails(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
