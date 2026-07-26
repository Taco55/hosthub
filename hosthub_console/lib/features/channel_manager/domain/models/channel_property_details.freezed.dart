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

 String? get id; String? get name; String? get address; String? get zip; String? get city; String? get country; String? get imageUrl; bool? get hasAddons; bool? get hasAgreement; String? get agreementText; String? get agreementUrl; List<String>? get ownerSpokenLanguages; num? get rating; int? get priceUnitInDays; num? get minPrice; num? get originalMinPrice; num? get maxPrice; num? get originalMaxPrice; Object? get rooms; DateTime? get inOutMaxDate; Object? get inOut; Object? get currency; List<String>? get subscriptionPlans;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw;
/// Create a copy of ChannelPropertyDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelPropertyDetailsCopyWith<ChannelPropertyDetails> get copyWith => _$ChannelPropertyDetailsCopyWithImpl<ChannelPropertyDetails>(this as ChannelPropertyDetails, _$identity);

  /// Serializes this ChannelPropertyDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelPropertyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.hasAddons, hasAddons) || other.hasAddons == hasAddons)&&(identical(other.hasAgreement, hasAgreement) || other.hasAgreement == hasAgreement)&&(identical(other.agreementText, agreementText) || other.agreementText == agreementText)&&(identical(other.agreementUrl, agreementUrl) || other.agreementUrl == agreementUrl)&&const DeepCollectionEquality().equals(other.ownerSpokenLanguages, ownerSpokenLanguages)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.priceUnitInDays, priceUnitInDays) || other.priceUnitInDays == priceUnitInDays)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.originalMinPrice, originalMinPrice) || other.originalMinPrice == originalMinPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.originalMaxPrice, originalMaxPrice) || other.originalMaxPrice == originalMaxPrice)&&const DeepCollectionEquality().equals(other.rooms, rooms)&&(identical(other.inOutMaxDate, inOutMaxDate) || other.inOutMaxDate == inOutMaxDate)&&const DeepCollectionEquality().equals(other.inOut, inOut)&&const DeepCollectionEquality().equals(other.currency, currency)&&const DeepCollectionEquality().equals(other.subscriptionPlans, subscriptionPlans)&&const DeepCollectionEquality().equals(other.raw, raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,address,zip,city,country,imageUrl,hasAddons,hasAgreement,agreementText,agreementUrl,const DeepCollectionEquality().hash(ownerSpokenLanguages),rating,priceUnitInDays,minPrice,originalMinPrice,maxPrice,originalMaxPrice,const DeepCollectionEquality().hash(rooms),inOutMaxDate,const DeepCollectionEquality().hash(inOut),const DeepCollectionEquality().hash(currency),const DeepCollectionEquality().hash(subscriptionPlans),const DeepCollectionEquality().hash(raw)]);

@override
String toString() {
  return 'ChannelPropertyDetails(id: $id, name: $name, address: $address, zip: $zip, city: $city, country: $country, imageUrl: $imageUrl, hasAddons: $hasAddons, hasAgreement: $hasAgreement, agreementText: $agreementText, agreementUrl: $agreementUrl, ownerSpokenLanguages: $ownerSpokenLanguages, rating: $rating, priceUnitInDays: $priceUnitInDays, minPrice: $minPrice, originalMinPrice: $originalMinPrice, maxPrice: $maxPrice, originalMaxPrice: $originalMaxPrice, rooms: $rooms, inOutMaxDate: $inOutMaxDate, inOut: $inOut, currency: $currency, subscriptionPlans: $subscriptionPlans, raw: $raw)';
}


}

/// @nodoc
abstract mixin class $ChannelPropertyDetailsCopyWith<$Res>  {
  factory $ChannelPropertyDetailsCopyWith(ChannelPropertyDetails value, $Res Function(ChannelPropertyDetails) _then) = _$ChannelPropertyDetailsCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? address, String? zip, String? city, String? country, String? imageUrl, bool? hasAddons, bool? hasAgreement, String? agreementText, String? agreementUrl, List<String>? ownerSpokenLanguages, num? rating, int? priceUnitInDays, num? minPrice, num? originalMinPrice, num? maxPrice, num? originalMaxPrice, Object? rooms, DateTime? inOutMaxDate, Object? inOut, Object? currency, List<String>? subscriptionPlans,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? address = freezed,Object? zip = freezed,Object? city = freezed,Object? country = freezed,Object? imageUrl = freezed,Object? hasAddons = freezed,Object? hasAgreement = freezed,Object? agreementText = freezed,Object? agreementUrl = freezed,Object? ownerSpokenLanguages = freezed,Object? rating = freezed,Object? priceUnitInDays = freezed,Object? minPrice = freezed,Object? originalMinPrice = freezed,Object? maxPrice = freezed,Object? originalMaxPrice = freezed,Object? rooms = freezed,Object? inOutMaxDate = freezed,Object? inOut = freezed,Object? currency = freezed,Object? subscriptionPlans = freezed,Object? raw = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,hasAddons: freezed == hasAddons ? _self.hasAddons : hasAddons // ignore: cast_nullable_to_non_nullable
as bool?,hasAgreement: freezed == hasAgreement ? _self.hasAgreement : hasAgreement // ignore: cast_nullable_to_non_nullable
as bool?,agreementText: freezed == agreementText ? _self.agreementText : agreementText // ignore: cast_nullable_to_non_nullable
as String?,agreementUrl: freezed == agreementUrl ? _self.agreementUrl : agreementUrl // ignore: cast_nullable_to_non_nullable
as String?,ownerSpokenLanguages: freezed == ownerSpokenLanguages ? _self.ownerSpokenLanguages : ownerSpokenLanguages // ignore: cast_nullable_to_non_nullable
as List<String>?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as num?,priceUnitInDays: freezed == priceUnitInDays ? _self.priceUnitInDays : priceUnitInDays // ignore: cast_nullable_to_non_nullable
as int?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as num?,originalMinPrice: freezed == originalMinPrice ? _self.originalMinPrice : originalMinPrice // ignore: cast_nullable_to_non_nullable
as num?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as num?,originalMaxPrice: freezed == originalMaxPrice ? _self.originalMaxPrice : originalMaxPrice // ignore: cast_nullable_to_non_nullable
as num?,rooms: freezed == rooms ? _self.rooms : rooms ,inOutMaxDate: freezed == inOutMaxDate ? _self.inOutMaxDate : inOutMaxDate // ignore: cast_nullable_to_non_nullable
as DateTime?,inOut: freezed == inOut ? _self.inOut : inOut ,currency: freezed == currency ? _self.currency : currency ,subscriptionPlans: freezed == subscriptionPlans ? _self.subscriptionPlans : subscriptionPlans // ignore: cast_nullable_to_non_nullable
as List<String>?,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? address,  String? zip,  String? city,  String? country,  String? imageUrl,  bool? hasAddons,  bool? hasAgreement,  String? agreementText,  String? agreementUrl,  List<String>? ownerSpokenLanguages,  num? rating,  int? priceUnitInDays,  num? minPrice,  num? originalMinPrice,  num? maxPrice,  num? originalMaxPrice,  Object? rooms,  DateTime? inOutMaxDate,  Object? inOut,  Object? currency,  List<String>? subscriptionPlans, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelPropertyDetails() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.zip,_that.city,_that.country,_that.imageUrl,_that.hasAddons,_that.hasAgreement,_that.agreementText,_that.agreementUrl,_that.ownerSpokenLanguages,_that.rating,_that.priceUnitInDays,_that.minPrice,_that.originalMinPrice,_that.maxPrice,_that.originalMaxPrice,_that.rooms,_that.inOutMaxDate,_that.inOut,_that.currency,_that.subscriptionPlans,_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? address,  String? zip,  String? city,  String? country,  String? imageUrl,  bool? hasAddons,  bool? hasAgreement,  String? agreementText,  String? agreementUrl,  List<String>? ownerSpokenLanguages,  num? rating,  int? priceUnitInDays,  num? minPrice,  num? originalMinPrice,  num? maxPrice,  num? originalMaxPrice,  Object? rooms,  DateTime? inOutMaxDate,  Object? inOut,  Object? currency,  List<String>? subscriptionPlans, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)  $default,) {final _that = this;
switch (_that) {
case _ChannelPropertyDetails():
return $default(_that.id,_that.name,_that.address,_that.zip,_that.city,_that.country,_that.imageUrl,_that.hasAddons,_that.hasAgreement,_that.agreementText,_that.agreementUrl,_that.ownerSpokenLanguages,_that.rating,_that.priceUnitInDays,_that.minPrice,_that.originalMinPrice,_that.maxPrice,_that.originalMaxPrice,_that.rooms,_that.inOutMaxDate,_that.inOut,_that.currency,_that.subscriptionPlans,_that.raw);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? address,  String? zip,  String? city,  String? country,  String? imageUrl,  bool? hasAddons,  bool? hasAgreement,  String? agreementText,  String? agreementUrl,  List<String>? ownerSpokenLanguages,  num? rating,  int? priceUnitInDays,  num? minPrice,  num? originalMinPrice,  num? maxPrice,  num? originalMaxPrice,  Object? rooms,  DateTime? inOutMaxDate,  Object? inOut,  Object? currency,  List<String>? subscriptionPlans, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,) {final _that = this;
switch (_that) {
case _ChannelPropertyDetails() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.zip,_that.city,_that.country,_that.imageUrl,_that.hasAddons,_that.hasAgreement,_that.agreementText,_that.agreementUrl,_that.ownerSpokenLanguages,_that.rating,_that.priceUnitInDays,_that.minPrice,_that.originalMinPrice,_that.maxPrice,_that.originalMaxPrice,_that.rooms,_that.inOutMaxDate,_that.inOut,_that.currency,_that.subscriptionPlans,_that.raw);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChannelPropertyDetails extends ChannelPropertyDetails {
  const _ChannelPropertyDetails({this.id, this.name, this.address, this.zip, this.city, this.country, this.imageUrl, this.hasAddons, this.hasAgreement, this.agreementText, this.agreementUrl, final  List<String>? ownerSpokenLanguages, this.rating, this.priceUnitInDays, this.minPrice, this.originalMinPrice, this.maxPrice, this.originalMaxPrice, this.rooms, this.inOutMaxDate, this.inOut, this.currency, final  List<String>? subscriptionPlans, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic> raw = const <String, dynamic>{}}): _ownerSpokenLanguages = ownerSpokenLanguages,_subscriptionPlans = subscriptionPlans,_raw = raw,super._();
  factory _ChannelPropertyDetails.fromJson(Map<String, dynamic> json) => _$ChannelPropertyDetailsFromJson(json);

@override final  String? id;
@override final  String? name;
@override final  String? address;
@override final  String? zip;
@override final  String? city;
@override final  String? country;
@override final  String? imageUrl;
@override final  bool? hasAddons;
@override final  bool? hasAgreement;
@override final  String? agreementText;
@override final  String? agreementUrl;
 final  List<String>? _ownerSpokenLanguages;
@override List<String>? get ownerSpokenLanguages {
  final value = _ownerSpokenLanguages;
  if (value == null) return null;
  if (_ownerSpokenLanguages is EqualUnmodifiableListView) return _ownerSpokenLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  num? rating;
@override final  int? priceUnitInDays;
@override final  num? minPrice;
@override final  num? originalMinPrice;
@override final  num? maxPrice;
@override final  num? originalMaxPrice;
@override final  Object? rooms;
@override final  DateTime? inOutMaxDate;
@override final  Object? inOut;
@override final  Object? currency;
 final  List<String>? _subscriptionPlans;
@override List<String>? get subscriptionPlans {
  final value = _subscriptionPlans;
  if (value == null) return null;
  if (_subscriptionPlans is EqualUnmodifiableListView) return _subscriptionPlans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelPropertyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.hasAddons, hasAddons) || other.hasAddons == hasAddons)&&(identical(other.hasAgreement, hasAgreement) || other.hasAgreement == hasAgreement)&&(identical(other.agreementText, agreementText) || other.agreementText == agreementText)&&(identical(other.agreementUrl, agreementUrl) || other.agreementUrl == agreementUrl)&&const DeepCollectionEquality().equals(other._ownerSpokenLanguages, _ownerSpokenLanguages)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.priceUnitInDays, priceUnitInDays) || other.priceUnitInDays == priceUnitInDays)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.originalMinPrice, originalMinPrice) || other.originalMinPrice == originalMinPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.originalMaxPrice, originalMaxPrice) || other.originalMaxPrice == originalMaxPrice)&&const DeepCollectionEquality().equals(other.rooms, rooms)&&(identical(other.inOutMaxDate, inOutMaxDate) || other.inOutMaxDate == inOutMaxDate)&&const DeepCollectionEquality().equals(other.inOut, inOut)&&const DeepCollectionEquality().equals(other.currency, currency)&&const DeepCollectionEquality().equals(other._subscriptionPlans, _subscriptionPlans)&&const DeepCollectionEquality().equals(other._raw, _raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,address,zip,city,country,imageUrl,hasAddons,hasAgreement,agreementText,agreementUrl,const DeepCollectionEquality().hash(_ownerSpokenLanguages),rating,priceUnitInDays,minPrice,originalMinPrice,maxPrice,originalMaxPrice,const DeepCollectionEquality().hash(rooms),inOutMaxDate,const DeepCollectionEquality().hash(inOut),const DeepCollectionEquality().hash(currency),const DeepCollectionEquality().hash(_subscriptionPlans),const DeepCollectionEquality().hash(_raw)]);

@override
String toString() {
  return 'ChannelPropertyDetails(id: $id, name: $name, address: $address, zip: $zip, city: $city, country: $country, imageUrl: $imageUrl, hasAddons: $hasAddons, hasAgreement: $hasAgreement, agreementText: $agreementText, agreementUrl: $agreementUrl, ownerSpokenLanguages: $ownerSpokenLanguages, rating: $rating, priceUnitInDays: $priceUnitInDays, minPrice: $minPrice, originalMinPrice: $originalMinPrice, maxPrice: $maxPrice, originalMaxPrice: $originalMaxPrice, rooms: $rooms, inOutMaxDate: $inOutMaxDate, inOut: $inOut, currency: $currency, subscriptionPlans: $subscriptionPlans, raw: $raw)';
}


}

/// @nodoc
abstract mixin class _$ChannelPropertyDetailsCopyWith<$Res> implements $ChannelPropertyDetailsCopyWith<$Res> {
  factory _$ChannelPropertyDetailsCopyWith(_ChannelPropertyDetails value, $Res Function(_ChannelPropertyDetails) _then) = __$ChannelPropertyDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? address, String? zip, String? city, String? country, String? imageUrl, bool? hasAddons, bool? hasAgreement, String? agreementText, String? agreementUrl, List<String>? ownerSpokenLanguages, num? rating, int? priceUnitInDays, num? minPrice, num? originalMinPrice, num? maxPrice, num? originalMaxPrice, Object? rooms, DateTime? inOutMaxDate, Object? inOut, Object? currency, List<String>? subscriptionPlans,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? address = freezed,Object? zip = freezed,Object? city = freezed,Object? country = freezed,Object? imageUrl = freezed,Object? hasAddons = freezed,Object? hasAgreement = freezed,Object? agreementText = freezed,Object? agreementUrl = freezed,Object? ownerSpokenLanguages = freezed,Object? rating = freezed,Object? priceUnitInDays = freezed,Object? minPrice = freezed,Object? originalMinPrice = freezed,Object? maxPrice = freezed,Object? originalMaxPrice = freezed,Object? rooms = freezed,Object? inOutMaxDate = freezed,Object? inOut = freezed,Object? currency = freezed,Object? subscriptionPlans = freezed,Object? raw = null,}) {
  return _then(_ChannelPropertyDetails(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,hasAddons: freezed == hasAddons ? _self.hasAddons : hasAddons // ignore: cast_nullable_to_non_nullable
as bool?,hasAgreement: freezed == hasAgreement ? _self.hasAgreement : hasAgreement // ignore: cast_nullable_to_non_nullable
as bool?,agreementText: freezed == agreementText ? _self.agreementText : agreementText // ignore: cast_nullable_to_non_nullable
as String?,agreementUrl: freezed == agreementUrl ? _self.agreementUrl : agreementUrl // ignore: cast_nullable_to_non_nullable
as String?,ownerSpokenLanguages: freezed == ownerSpokenLanguages ? _self._ownerSpokenLanguages : ownerSpokenLanguages // ignore: cast_nullable_to_non_nullable
as List<String>?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as num?,priceUnitInDays: freezed == priceUnitInDays ? _self.priceUnitInDays : priceUnitInDays // ignore: cast_nullable_to_non_nullable
as int?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as num?,originalMinPrice: freezed == originalMinPrice ? _self.originalMinPrice : originalMinPrice // ignore: cast_nullable_to_non_nullable
as num?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as num?,originalMaxPrice: freezed == originalMaxPrice ? _self.originalMaxPrice : originalMaxPrice // ignore: cast_nullable_to_non_nullable
as num?,rooms: freezed == rooms ? _self.rooms : rooms ,inOutMaxDate: freezed == inOutMaxDate ? _self.inOutMaxDate : inOutMaxDate // ignore: cast_nullable_to_non_nullable
as DateTime?,inOut: freezed == inOut ? _self.inOut : inOut ,currency: freezed == currency ? _self.currency : currency ,subscriptionPlans: freezed == subscriptionPlans ? _self._subscriptionPlans : subscriptionPlans // ignore: cast_nullable_to_non_nullable
as List<String>?,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
