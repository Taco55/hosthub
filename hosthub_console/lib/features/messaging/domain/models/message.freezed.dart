// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {

 String get messageId; String get threadId; MessageDirection get direction; String get body; DateTime get sentAt; String? get authorName; MessageChannel get channel; MessageDeliveryState get deliveryState;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.body, body) || other.body == body)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.deliveryState, deliveryState) || other.deliveryState == deliveryState)&&const DeepCollectionEquality().equals(other.raw, raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,threadId,direction,body,sentAt,authorName,channel,deliveryState,const DeepCollectionEquality().hash(raw));

@override
String toString() {
  return 'Message(messageId: $messageId, threadId: $threadId, direction: $direction, body: $body, sentAt: $sentAt, authorName: $authorName, channel: $channel, deliveryState: $deliveryState, raw: $raw)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String messageId, String threadId, MessageDirection direction, String body, DateTime sentAt, String? authorName, MessageChannel channel, MessageDeliveryState deliveryState,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? threadId = null,Object? direction = null,Object? body = null,Object? sentAt = null,Object? authorName = freezed,Object? channel = null,Object? deliveryState = null,Object? raw = null,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as MessageDirection,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as MessageChannel,deliveryState: null == deliveryState ? _self.deliveryState : deliveryState // ignore: cast_nullable_to_non_nullable
as MessageDeliveryState,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId,  String threadId,  MessageDirection direction,  String body,  DateTime sentAt,  String? authorName,  MessageChannel channel,  MessageDeliveryState deliveryState, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.messageId,_that.threadId,_that.direction,_that.body,_that.sentAt,_that.authorName,_that.channel,_that.deliveryState,_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId,  String threadId,  MessageDirection direction,  String body,  DateTime sentAt,  String? authorName,  MessageChannel channel,  MessageDeliveryState deliveryState, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.messageId,_that.threadId,_that.direction,_that.body,_that.sentAt,_that.authorName,_that.channel,_that.deliveryState,_that.raw);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId,  String threadId,  MessageDirection direction,  String body,  DateTime sentAt,  String? authorName,  MessageChannel channel,  MessageDeliveryState deliveryState, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.messageId,_that.threadId,_that.direction,_that.body,_that.sentAt,_that.authorName,_that.channel,_that.deliveryState,_that.raw);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Message extends Message {
  const _Message({required this.messageId, required this.threadId, required this.direction, required this.body, required this.sentAt, this.authorName, this.channel = MessageChannel.other, this.deliveryState = MessageDeliveryState.sent, @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic> raw = const <String, dynamic>{}}): _raw = raw,super._();
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  String messageId;
@override final  String threadId;
@override final  MessageDirection direction;
@override final  String body;
@override final  DateTime sentAt;
@override final  String? authorName;
@override@JsonKey() final  MessageChannel channel;
@override@JsonKey() final  MessageDeliveryState deliveryState;
 final  Map<String, dynamic> _raw;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}


/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.body, body) || other.body == body)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.deliveryState, deliveryState) || other.deliveryState == deliveryState)&&const DeepCollectionEquality().equals(other._raw, _raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,threadId,direction,body,sentAt,authorName,channel,deliveryState,const DeepCollectionEquality().hash(_raw));

@override
String toString() {
  return 'Message(messageId: $messageId, threadId: $threadId, direction: $direction, body: $body, sentAt: $sentAt, authorName: $authorName, channel: $channel, deliveryState: $deliveryState, raw: $raw)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String messageId, String threadId, MessageDirection direction, String body, DateTime sentAt, String? authorName, MessageChannel channel, MessageDeliveryState deliveryState,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? threadId = null,Object? direction = null,Object? body = null,Object? sentAt = null,Object? authorName = freezed,Object? channel = null,Object? deliveryState = null,Object? raw = null,}) {
  return _then(_Message(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as MessageDirection,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as MessageChannel,deliveryState: null == deliveryState ? _self.deliveryState : deliveryState // ignore: cast_nullable_to_non_nullable
as MessageDeliveryState,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
