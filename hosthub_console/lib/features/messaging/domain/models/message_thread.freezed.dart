// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageThread {

/// The property this conversation belongs to — the console's own
/// `properties.id`, never the source's.
///
/// Required for the same reason [Reservation.propertyId] is: every filter
/// and every counter is `property_id IN (:selection)`, and a thread that
/// cannot say which property it is about cannot be scoped.
 int get propertyId;/// Our id for the thread (`message_threads.id`).
 String get threadId;/// The id the source knows it by. Half of the uniqueness that makes a
/// re-sync an upsert instead of a duplicate.
 String get sourceThreadId; MessageChannel get channel;/// Not every conversation hangs off a booking — an enquiry does not.
 String? get reservationId; String? get guestName; String? get guestLocale; DateTime? get lastMessageAt; String? get lastMessagePreview; int get unreadCount;/// The last word is the guest's. Derived at sync time from the direction of
/// the last message, never a flag anybody maintains — which is why the
/// `Actie` filter can be trusted.
 bool get awaitingHost;/// Our own read state. The source has no concept of one, so this is where
/// "read" exists at all.
 DateTime? get readAt; DateTime? get snoozedUntil; DateTime? get archivedAt;/// Loaded by [MessagingRepository.fetchThread]; empty in a list fetch,
/// where a preview is all the row shows.
 List<Message> get messages;@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw;
/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageThreadCopyWith<MessageThread> get copyWith => _$MessageThreadCopyWithImpl<MessageThread>(this as MessageThread, _$identity);

  /// Serializes this MessageThread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageThread&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.sourceThreadId, sourceThreadId) || other.sourceThreadId == sourceThreadId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestLocale, guestLocale) || other.guestLocale == guestLocale)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.awaitingHost, awaitingHost) || other.awaitingHost == awaitingHost)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.snoozedUntil, snoozedUntil) || other.snoozedUntil == snoozedUntil)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.raw, raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,propertyId,threadId,sourceThreadId,channel,reservationId,guestName,guestLocale,lastMessageAt,lastMessagePreview,unreadCount,awaitingHost,readAt,snoozedUntil,archivedAt,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(raw));

@override
String toString() {
  return 'MessageThread(propertyId: $propertyId, threadId: $threadId, sourceThreadId: $sourceThreadId, channel: $channel, reservationId: $reservationId, guestName: $guestName, guestLocale: $guestLocale, lastMessageAt: $lastMessageAt, lastMessagePreview: $lastMessagePreview, unreadCount: $unreadCount, awaitingHost: $awaitingHost, readAt: $readAt, snoozedUntil: $snoozedUntil, archivedAt: $archivedAt, messages: $messages, raw: $raw)';
}


}

/// @nodoc
abstract mixin class $MessageThreadCopyWith<$Res>  {
  factory $MessageThreadCopyWith(MessageThread value, $Res Function(MessageThread) _then) = _$MessageThreadCopyWithImpl;
@useResult
$Res call({
 int propertyId, String threadId, String sourceThreadId, MessageChannel channel, String? reservationId, String? guestName, String? guestLocale, DateTime? lastMessageAt, String? lastMessagePreview, int unreadCount, bool awaitingHost, DateTime? readAt, DateTime? snoozedUntil, DateTime? archivedAt, List<Message> messages,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class _$MessageThreadCopyWithImpl<$Res>
    implements $MessageThreadCopyWith<$Res> {
  _$MessageThreadCopyWithImpl(this._self, this._then);

  final MessageThread _self;
  final $Res Function(MessageThread) _then;

/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? propertyId = null,Object? threadId = null,Object? sourceThreadId = null,Object? channel = null,Object? reservationId = freezed,Object? guestName = freezed,Object? guestLocale = freezed,Object? lastMessageAt = freezed,Object? lastMessagePreview = freezed,Object? unreadCount = null,Object? awaitingHost = null,Object? readAt = freezed,Object? snoozedUntil = freezed,Object? archivedAt = freezed,Object? messages = null,Object? raw = null,}) {
  return _then(_self.copyWith(
propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as int,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,sourceThreadId: null == sourceThreadId ? _self.sourceThreadId : sourceThreadId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as MessageChannel,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestLocale: freezed == guestLocale ? _self.guestLocale : guestLocale // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,awaitingHost: null == awaitingHost ? _self.awaitingHost : awaitingHost // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,snoozedUntil: freezed == snoozedUntil ? _self.snoozedUntil : snoozedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageThread].
extension MessageThreadPatterns on MessageThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageThread value)  $default,){
final _that = this;
switch (_that) {
case _MessageThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageThread value)?  $default,){
final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int propertyId,  String threadId,  String sourceThreadId,  MessageChannel channel,  String? reservationId,  String? guestName,  String? guestLocale,  DateTime? lastMessageAt,  String? lastMessagePreview,  int unreadCount,  bool awaitingHost,  DateTime? readAt,  DateTime? snoozedUntil,  DateTime? archivedAt,  List<Message> messages, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
return $default(_that.propertyId,_that.threadId,_that.sourceThreadId,_that.channel,_that.reservationId,_that.guestName,_that.guestLocale,_that.lastMessageAt,_that.lastMessagePreview,_that.unreadCount,_that.awaitingHost,_that.readAt,_that.snoozedUntil,_that.archivedAt,_that.messages,_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int propertyId,  String threadId,  String sourceThreadId,  MessageChannel channel,  String? reservationId,  String? guestName,  String? guestLocale,  DateTime? lastMessageAt,  String? lastMessagePreview,  int unreadCount,  bool awaitingHost,  DateTime? readAt,  DateTime? snoozedUntil,  DateTime? archivedAt,  List<Message> messages, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)  $default,) {final _that = this;
switch (_that) {
case _MessageThread():
return $default(_that.propertyId,_that.threadId,_that.sourceThreadId,_that.channel,_that.reservationId,_that.guestName,_that.guestLocale,_that.lastMessageAt,_that.lastMessagePreview,_that.unreadCount,_that.awaitingHost,_that.readAt,_that.snoozedUntil,_that.archivedAt,_that.messages,_that.raw);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int propertyId,  String threadId,  String sourceThreadId,  MessageChannel channel,  String? reservationId,  String? guestName,  String? guestLocale,  DateTime? lastMessageAt,  String? lastMessagePreview,  int unreadCount,  bool awaitingHost,  DateTime? readAt,  DateTime? snoozedUntil,  DateTime? archivedAt,  List<Message> messages, @JsonKey(includeFromJson: false, includeToJson: false)  Map<String, dynamic> raw)?  $default,) {final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
return $default(_that.propertyId,_that.threadId,_that.sourceThreadId,_that.channel,_that.reservationId,_that.guestName,_that.guestLocale,_that.lastMessageAt,_that.lastMessagePreview,_that.unreadCount,_that.awaitingHost,_that.readAt,_that.snoozedUntil,_that.archivedAt,_that.messages,_that.raw);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _MessageThread extends MessageThread {
  const _MessageThread({required this.propertyId, required this.threadId, required this.sourceThreadId, this.channel = MessageChannel.other, this.reservationId, this.guestName, this.guestLocale, this.lastMessageAt, this.lastMessagePreview, this.unreadCount = 0, this.awaitingHost = false, this.readAt, this.snoozedUntil, this.archivedAt, final  List<Message> messages = const <Message>[], @JsonKey(includeFromJson: false, includeToJson: false) final  Map<String, dynamic> raw = const <String, dynamic>{}}): _messages = messages,_raw = raw,super._();
  factory _MessageThread.fromJson(Map<String, dynamic> json) => _$MessageThreadFromJson(json);

/// The property this conversation belongs to — the console's own
/// `properties.id`, never the source's.
///
/// Required for the same reason [Reservation.propertyId] is: every filter
/// and every counter is `property_id IN (:selection)`, and a thread that
/// cannot say which property it is about cannot be scoped.
@override final  int propertyId;
/// Our id for the thread (`message_threads.id`).
@override final  String threadId;
/// The id the source knows it by. Half of the uniqueness that makes a
/// re-sync an upsert instead of a duplicate.
@override final  String sourceThreadId;
@override@JsonKey() final  MessageChannel channel;
/// Not every conversation hangs off a booking — an enquiry does not.
@override final  String? reservationId;
@override final  String? guestName;
@override final  String? guestLocale;
@override final  DateTime? lastMessageAt;
@override final  String? lastMessagePreview;
@override@JsonKey() final  int unreadCount;
/// The last word is the guest's. Derived at sync time from the direction of
/// the last message, never a flag anybody maintains — which is why the
/// `Actie` filter can be trusted.
@override@JsonKey() final  bool awaitingHost;
/// Our own read state. The source has no concept of one, so this is where
/// "read" exists at all.
@override final  DateTime? readAt;
@override final  DateTime? snoozedUntil;
@override final  DateTime? archivedAt;
/// Loaded by [MessagingRepository.fetchThread]; empty in a list fetch,
/// where a preview is all the row shows.
 final  List<Message> _messages;
/// Loaded by [MessagingRepository.fetchThread]; empty in a list fetch,
/// where a preview is all the row shows.
@override@JsonKey() List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  Map<String, dynamic> _raw;
@override@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}


/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageThreadCopyWith<_MessageThread> get copyWith => __$MessageThreadCopyWithImpl<_MessageThread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageThreadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageThread&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.sourceThreadId, sourceThreadId) || other.sourceThreadId == sourceThreadId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestLocale, guestLocale) || other.guestLocale == guestLocale)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.awaitingHost, awaitingHost) || other.awaitingHost == awaitingHost)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.snoozedUntil, snoozedUntil) || other.snoozedUntil == snoozedUntil)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._raw, _raw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,propertyId,threadId,sourceThreadId,channel,reservationId,guestName,guestLocale,lastMessageAt,lastMessagePreview,unreadCount,awaitingHost,readAt,snoozedUntil,archivedAt,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_raw));

@override
String toString() {
  return 'MessageThread(propertyId: $propertyId, threadId: $threadId, sourceThreadId: $sourceThreadId, channel: $channel, reservationId: $reservationId, guestName: $guestName, guestLocale: $guestLocale, lastMessageAt: $lastMessageAt, lastMessagePreview: $lastMessagePreview, unreadCount: $unreadCount, awaitingHost: $awaitingHost, readAt: $readAt, snoozedUntil: $snoozedUntil, archivedAt: $archivedAt, messages: $messages, raw: $raw)';
}


}

/// @nodoc
abstract mixin class _$MessageThreadCopyWith<$Res> implements $MessageThreadCopyWith<$Res> {
  factory _$MessageThreadCopyWith(_MessageThread value, $Res Function(_MessageThread) _then) = __$MessageThreadCopyWithImpl;
@override @useResult
$Res call({
 int propertyId, String threadId, String sourceThreadId, MessageChannel channel, String? reservationId, String? guestName, String? guestLocale, DateTime? lastMessageAt, String? lastMessagePreview, int unreadCount, bool awaitingHost, DateTime? readAt, DateTime? snoozedUntil, DateTime? archivedAt, List<Message> messages,@JsonKey(includeFromJson: false, includeToJson: false) Map<String, dynamic> raw
});




}
/// @nodoc
class __$MessageThreadCopyWithImpl<$Res>
    implements _$MessageThreadCopyWith<$Res> {
  __$MessageThreadCopyWithImpl(this._self, this._then);

  final _MessageThread _self;
  final $Res Function(_MessageThread) _then;

/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? propertyId = null,Object? threadId = null,Object? sourceThreadId = null,Object? channel = null,Object? reservationId = freezed,Object? guestName = freezed,Object? guestLocale = freezed,Object? lastMessageAt = freezed,Object? lastMessagePreview = freezed,Object? unreadCount = null,Object? awaitingHost = null,Object? readAt = freezed,Object? snoozedUntil = freezed,Object? archivedAt = freezed,Object? messages = null,Object? raw = null,}) {
  return _then(_MessageThread(
propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as int,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,sourceThreadId: null == sourceThreadId ? _self.sourceThreadId : sourceThreadId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as MessageChannel,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String?,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestLocale: freezed == guestLocale ? _self.guestLocale : guestLocale // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,awaitingHost: null == awaitingHost ? _self.awaitingHost : awaitingHost // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,snoozedUntil: freezed == snoozedUntil ? _self.snoozedUntil : snoozedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
