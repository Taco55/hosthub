// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {

 String? get reservationId; DateTime? get startDate; DateTime? get endDate; String? get status; String? get guestName; String? get guestEmail; String? get guestPhone; int? get guestCount; int? get adultCount; int? get childCount; int? get infantCount; String? get source; String? get notes; num? get totalAmount; String? get currency; DateTime? get createdAt; DateTime? get updatedAt;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestEmail, guestEmail) || other.guestEmail == guestEmail)&&(identical(other.guestPhone, guestPhone) || other.guestPhone == guestPhone)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.adultCount, adultCount) || other.adultCount == adultCount)&&(identical(other.childCount, childCount) || other.childCount == childCount)&&(identical(other.infantCount, infantCount) || other.infantCount == infantCount)&&(identical(other.source, source) || other.source == source)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.raw, raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reservationId,startDate,endDate,status,guestName,guestEmail,guestPhone,guestCount,adultCount,childCount,infantCount,source,notes,totalAmount,currency,createdAt,updatedAt,const DeepCollectionEquality().hash(raw));

@override
String toString() {
  return 'Reservation(reservationId: $reservationId, startDate: $startDate, endDate: $endDate, status: $status, guestName: $guestName, guestEmail: $guestEmail, guestPhone: $guestPhone, guestCount: $guestCount, adultCount: $adultCount, childCount: $childCount, infantCount: $infantCount, source: $source, notes: $notes, totalAmount: $totalAmount, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt, raw: $raw)';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 String? reservationId, DateTime? startDate, DateTime? endDate, String? status, String? guestName, String? guestEmail, String? guestPhone, int? guestCount, int? adultCount, int? childCount, int? infantCount, String? source, String? notes, num? totalAmount, String? currency, DateTime? createdAt, DateTime? updatedAt,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reservationId = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? status = freezed,Object? guestName = freezed,Object? guestEmail = freezed,Object? guestPhone = freezed,Object? guestCount = freezed,Object? adultCount = freezed,Object? childCount = freezed,Object? infantCount = freezed,Object? source = freezed,Object? notes = freezed,Object? totalAmount = freezed,Object? currency = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? raw = null,}) {
  return _then(_self.copyWith(
reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestEmail: freezed == guestEmail ? _self.guestEmail : guestEmail // ignore: cast_nullable_to_non_nullable
as String?,guestPhone: freezed == guestPhone ? _self.guestPhone : guestPhone // ignore: cast_nullable_to_non_nullable
as String?,guestCount: freezed == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int?,adultCount: freezed == adultCount ? _self.adultCount : adultCount // ignore: cast_nullable_to_non_nullable
as int?,childCount: freezed == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int?,infantCount: freezed == infantCount ? _self.infantCount : infantCount // ignore: cast_nullable_to_non_nullable
as int?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as num?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? reservationId,  DateTime? startDate,  DateTime? endDate,  String? status,  String? guestName,  String? guestEmail,  String? guestPhone,  int? guestCount,  int? adultCount,  int? childCount,  int? infantCount,  String? source,  String? notes,  num? totalAmount,  String? currency,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.reservationId,_that.startDate,_that.endDate,_that.status,_that.guestName,_that.guestEmail,_that.guestPhone,_that.guestCount,_that.adultCount,_that.childCount,_that.infantCount,_that.source,_that.notes,_that.totalAmount,_that.currency,_that.createdAt,_that.updatedAt,_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? reservationId,  DateTime? startDate,  DateTime? endDate,  String? status,  String? guestName,  String? guestEmail,  String? guestPhone,  int? guestCount,  int? adultCount,  int? childCount,  int? infantCount,  String? source,  String? notes,  num? totalAmount,  String? currency,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.reservationId,_that.startDate,_that.endDate,_that.status,_that.guestName,_that.guestEmail,_that.guestPhone,_that.guestCount,_that.adultCount,_that.childCount,_that.infantCount,_that.source,_that.notes,_that.totalAmount,_that.currency,_that.createdAt,_that.updatedAt,_that.raw);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? reservationId,  DateTime? startDate,  DateTime? endDate,  String? status,  String? guestName,  String? guestEmail,  String? guestPhone,  int? guestCount,  int? adultCount,  int? childCount,  int? infantCount,  String? source,  String? notes,  num? totalAmount,  String? currency,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.reservationId,_that.startDate,_that.endDate,_that.status,_that.guestName,_that.guestEmail,_that.guestPhone,_that.guestCount,_that.adultCount,_that.childCount,_that.infantCount,_that.source,_that.notes,_that.totalAmount,_that.currency,_that.createdAt,_that.updatedAt,_that.raw);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Reservation extends Reservation {
  const _Reservation({this.reservationId, this.startDate, this.endDate, this.status, this.guestName, this.guestEmail, this.guestPhone, this.guestCount, this.adultCount, this.childCount, this.infantCount, this.source, this.notes, this.totalAmount, this.currency, this.createdAt, this.updatedAt, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic> raw = const <String, dynamic>{}}): _raw = raw,super._();
  factory _Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);

@override final  String? reservationId;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override final  String? status;
@override final  String? guestName;
@override final  String? guestEmail;
@override final  String? guestPhone;
@override final  int? guestCount;
@override final  int? adultCount;
@override final  int? childCount;
@override final  int? infantCount;
@override final  String? source;
@override final  String? notes;
@override final  num? totalAmount;
@override final  String? currency;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
 final  Map<String, dynamic> _raw;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}


/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestEmail, guestEmail) || other.guestEmail == guestEmail)&&(identical(other.guestPhone, guestPhone) || other.guestPhone == guestPhone)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.adultCount, adultCount) || other.adultCount == adultCount)&&(identical(other.childCount, childCount) || other.childCount == childCount)&&(identical(other.infantCount, infantCount) || other.infantCount == infantCount)&&(identical(other.source, source) || other.source == source)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._raw, _raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reservationId,startDate,endDate,status,guestName,guestEmail,guestPhone,guestCount,adultCount,childCount,infantCount,source,notes,totalAmount,currency,createdAt,updatedAt,const DeepCollectionEquality().hash(_raw));

@override
String toString() {
  return 'Reservation(reservationId: $reservationId, startDate: $startDate, endDate: $endDate, status: $status, guestName: $guestName, guestEmail: $guestEmail, guestPhone: $guestPhone, guestCount: $guestCount, adultCount: $adultCount, childCount: $childCount, infantCount: $infantCount, source: $source, notes: $notes, totalAmount: $totalAmount, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt, raw: $raw)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 String? reservationId, DateTime? startDate, DateTime? endDate, String? status, String? guestName, String? guestEmail, String? guestPhone, int? guestCount, int? adultCount, int? childCount, int? infantCount, String? source, String? notes, num? totalAmount, String? currency, DateTime? createdAt, DateTime? updatedAt,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reservationId = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? status = freezed,Object? guestName = freezed,Object? guestEmail = freezed,Object? guestPhone = freezed,Object? guestCount = freezed,Object? adultCount = freezed,Object? childCount = freezed,Object? infantCount = freezed,Object? source = freezed,Object? notes = freezed,Object? totalAmount = freezed,Object? currency = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? raw = null,}) {
  return _then(_Reservation(
reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestEmail: freezed == guestEmail ? _self.guestEmail : guestEmail // ignore: cast_nullable_to_non_nullable
as String?,guestPhone: freezed == guestPhone ? _self.guestPhone : guestPhone // ignore: cast_nullable_to_non_nullable
as String?,guestCount: freezed == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int?,adultCount: freezed == adultCount ? _self.adultCount : adultCount // ignore: cast_nullable_to_non_nullable
as int?,childCount: freezed == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int?,infantCount: freezed == infantCount ? _self.infantCount : infantCount // ignore: cast_nullable_to_non_nullable
as int?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as num?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
