// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent()';
}


}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( InitializeEvent value)?  initialize,TResult Function( OnboardingStarted value)?  onboardingStarted,TResult Function( OnboardingCompleted value)?  onboardingCompleted,TResult Function( SignInRequested value)?  signInRequested,TResult Function( SignInWithOtpRequested value)?  signInWithOtpRequested,TResult Function( SignUpRequested value)?  signUpRequested,TResult Function( SignOutRequested value)?  signOutRequested,TResult Function( AuthenticationSucceeded value)?  authenticationSucceeded,TResult Function( AuthenticationCleared value)?  authenticationCleared,TResult Function( SignUpConfirmed value)?  signUpConfirmed,TResult Function( SignInWithOtpConfirmed value)?  signInWithOtpConfirmed,TResult Function( SignUpCodeResendRequested value)?  signUpCodeResendRequested,TResult Function( PasswordResetRequested value)?  passwordResetRequested,TResult Function( PasswordResetConfirmed value)?  passwordResetConfirmed,TResult Function( PasswordResetCodeResendRequested value)?  passwordResetCodeResendRequested,TResult Function( AuthRedirectReceived value)?  authRedirectReceived,TResult Function( OAuthSignInRequested value)?  oauthSignInRequested,TResult Function( MagicLinkFailed value)?  magicLinkFailed,TResult Function( AccountDeletionRequested value)?  accountDeletionRequested,TResult Function( AuthFlowReset value)?  authFlowReset,TResult Function( ProfileLoaded value)?  profileLoaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case InitializeEvent() when initialize != null:
return initialize(_that);case OnboardingStarted() when onboardingStarted != null:
return onboardingStarted(_that);case OnboardingCompleted() when onboardingCompleted != null:
return onboardingCompleted(_that);case SignInRequested() when signInRequested != null:
return signInRequested(_that);case SignInWithOtpRequested() when signInWithOtpRequested != null:
return signInWithOtpRequested(_that);case SignUpRequested() when signUpRequested != null:
return signUpRequested(_that);case SignOutRequested() when signOutRequested != null:
return signOutRequested(_that);case AuthenticationSucceeded() when authenticationSucceeded != null:
return authenticationSucceeded(_that);case AuthenticationCleared() when authenticationCleared != null:
return authenticationCleared(_that);case SignUpConfirmed() when signUpConfirmed != null:
return signUpConfirmed(_that);case SignInWithOtpConfirmed() when signInWithOtpConfirmed != null:
return signInWithOtpConfirmed(_that);case SignUpCodeResendRequested() when signUpCodeResendRequested != null:
return signUpCodeResendRequested(_that);case PasswordResetRequested() when passwordResetRequested != null:
return passwordResetRequested(_that);case PasswordResetConfirmed() when passwordResetConfirmed != null:
return passwordResetConfirmed(_that);case PasswordResetCodeResendRequested() when passwordResetCodeResendRequested != null:
return passwordResetCodeResendRequested(_that);case AuthRedirectReceived() when authRedirectReceived != null:
return authRedirectReceived(_that);case OAuthSignInRequested() when oauthSignInRequested != null:
return oauthSignInRequested(_that);case MagicLinkFailed() when magicLinkFailed != null:
return magicLinkFailed(_that);case AccountDeletionRequested() when accountDeletionRequested != null:
return accountDeletionRequested(_that);case AuthFlowReset() when authFlowReset != null:
return authFlowReset(_that);case ProfileLoaded() when profileLoaded != null:
return profileLoaded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( InitializeEvent value)  initialize,required TResult Function( OnboardingStarted value)  onboardingStarted,required TResult Function( OnboardingCompleted value)  onboardingCompleted,required TResult Function( SignInRequested value)  signInRequested,required TResult Function( SignInWithOtpRequested value)  signInWithOtpRequested,required TResult Function( SignUpRequested value)  signUpRequested,required TResult Function( SignOutRequested value)  signOutRequested,required TResult Function( AuthenticationSucceeded value)  authenticationSucceeded,required TResult Function( AuthenticationCleared value)  authenticationCleared,required TResult Function( SignUpConfirmed value)  signUpConfirmed,required TResult Function( SignInWithOtpConfirmed value)  signInWithOtpConfirmed,required TResult Function( SignUpCodeResendRequested value)  signUpCodeResendRequested,required TResult Function( PasswordResetRequested value)  passwordResetRequested,required TResult Function( PasswordResetConfirmed value)  passwordResetConfirmed,required TResult Function( PasswordResetCodeResendRequested value)  passwordResetCodeResendRequested,required TResult Function( AuthRedirectReceived value)  authRedirectReceived,required TResult Function( OAuthSignInRequested value)  oauthSignInRequested,required TResult Function( MagicLinkFailed value)  magicLinkFailed,required TResult Function( AccountDeletionRequested value)  accountDeletionRequested,required TResult Function( AuthFlowReset value)  authFlowReset,required TResult Function( ProfileLoaded value)  profileLoaded,}){
final _that = this;
switch (_that) {
case InitializeEvent():
return initialize(_that);case OnboardingStarted():
return onboardingStarted(_that);case OnboardingCompleted():
return onboardingCompleted(_that);case SignInRequested():
return signInRequested(_that);case SignInWithOtpRequested():
return signInWithOtpRequested(_that);case SignUpRequested():
return signUpRequested(_that);case SignOutRequested():
return signOutRequested(_that);case AuthenticationSucceeded():
return authenticationSucceeded(_that);case AuthenticationCleared():
return authenticationCleared(_that);case SignUpConfirmed():
return signUpConfirmed(_that);case SignInWithOtpConfirmed():
return signInWithOtpConfirmed(_that);case SignUpCodeResendRequested():
return signUpCodeResendRequested(_that);case PasswordResetRequested():
return passwordResetRequested(_that);case PasswordResetConfirmed():
return passwordResetConfirmed(_that);case PasswordResetCodeResendRequested():
return passwordResetCodeResendRequested(_that);case AuthRedirectReceived():
return authRedirectReceived(_that);case OAuthSignInRequested():
return oauthSignInRequested(_that);case MagicLinkFailed():
return magicLinkFailed(_that);case AccountDeletionRequested():
return accountDeletionRequested(_that);case AuthFlowReset():
return authFlowReset(_that);case ProfileLoaded():
return profileLoaded(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( InitializeEvent value)?  initialize,TResult? Function( OnboardingStarted value)?  onboardingStarted,TResult? Function( OnboardingCompleted value)?  onboardingCompleted,TResult? Function( SignInRequested value)?  signInRequested,TResult? Function( SignInWithOtpRequested value)?  signInWithOtpRequested,TResult? Function( SignUpRequested value)?  signUpRequested,TResult? Function( SignOutRequested value)?  signOutRequested,TResult? Function( AuthenticationSucceeded value)?  authenticationSucceeded,TResult? Function( AuthenticationCleared value)?  authenticationCleared,TResult? Function( SignUpConfirmed value)?  signUpConfirmed,TResult? Function( SignInWithOtpConfirmed value)?  signInWithOtpConfirmed,TResult? Function( SignUpCodeResendRequested value)?  signUpCodeResendRequested,TResult? Function( PasswordResetRequested value)?  passwordResetRequested,TResult? Function( PasswordResetConfirmed value)?  passwordResetConfirmed,TResult? Function( PasswordResetCodeResendRequested value)?  passwordResetCodeResendRequested,TResult? Function( AuthRedirectReceived value)?  authRedirectReceived,TResult? Function( OAuthSignInRequested value)?  oauthSignInRequested,TResult? Function( MagicLinkFailed value)?  magicLinkFailed,TResult? Function( AccountDeletionRequested value)?  accountDeletionRequested,TResult? Function( AuthFlowReset value)?  authFlowReset,TResult? Function( ProfileLoaded value)?  profileLoaded,}){
final _that = this;
switch (_that) {
case InitializeEvent() when initialize != null:
return initialize(_that);case OnboardingStarted() when onboardingStarted != null:
return onboardingStarted(_that);case OnboardingCompleted() when onboardingCompleted != null:
return onboardingCompleted(_that);case SignInRequested() when signInRequested != null:
return signInRequested(_that);case SignInWithOtpRequested() when signInWithOtpRequested != null:
return signInWithOtpRequested(_that);case SignUpRequested() when signUpRequested != null:
return signUpRequested(_that);case SignOutRequested() when signOutRequested != null:
return signOutRequested(_that);case AuthenticationSucceeded() when authenticationSucceeded != null:
return authenticationSucceeded(_that);case AuthenticationCleared() when authenticationCleared != null:
return authenticationCleared(_that);case SignUpConfirmed() when signUpConfirmed != null:
return signUpConfirmed(_that);case SignInWithOtpConfirmed() when signInWithOtpConfirmed != null:
return signInWithOtpConfirmed(_that);case SignUpCodeResendRequested() when signUpCodeResendRequested != null:
return signUpCodeResendRequested(_that);case PasswordResetRequested() when passwordResetRequested != null:
return passwordResetRequested(_that);case PasswordResetConfirmed() when passwordResetConfirmed != null:
return passwordResetConfirmed(_that);case PasswordResetCodeResendRequested() when passwordResetCodeResendRequested != null:
return passwordResetCodeResendRequested(_that);case AuthRedirectReceived() when authRedirectReceived != null:
return authRedirectReceived(_that);case OAuthSignInRequested() when oauthSignInRequested != null:
return oauthSignInRequested(_that);case MagicLinkFailed() when magicLinkFailed != null:
return magicLinkFailed(_that);case AccountDeletionRequested() when accountDeletionRequested != null:
return accountDeletionRequested(_that);case AuthFlowReset() when authFlowReset != null:
return authFlowReset(_that);case ProfileLoaded() when profileLoaded != null:
return profileLoaded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initialize,TResult Function()?  onboardingStarted,TResult Function()?  onboardingCompleted,TResult Function( String email,  String password)?  signInRequested,TResult Function( String email,  bool shouldCreateUser,  String? redirectTo)?  signInWithOtpRequested,TResult Function( String email,  String password)?  signUpRequested,TResult Function()?  signOutRequested,TResult Function( AuthUser user)?  authenticationSucceeded,TResult Function()?  authenticationCleared,TResult Function( String confirmationCode)?  signUpConfirmed,TResult Function( String confirmationCode)?  signInWithOtpConfirmed,TResult Function()?  signUpCodeResendRequested,TResult Function( String email)?  passwordResetRequested,TResult Function( String email,  String newPassword,  String confirmationCode)?  passwordResetConfirmed,TResult Function( String email)?  passwordResetCodeResendRequested,TResult Function( AuthRedirectPayload payload)?  authRedirectReceived,TResult Function( OAuthProvider provider)?  oauthSignInRequested,TResult Function( Object error,  StackTrace stackTrace)?  magicLinkFailed,TResult Function()?  accountDeletionRequested,TResult Function()?  authFlowReset,TResult Function()?  profileLoaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case InitializeEvent() when initialize != null:
return initialize();case OnboardingStarted() when onboardingStarted != null:
return onboardingStarted();case OnboardingCompleted() when onboardingCompleted != null:
return onboardingCompleted();case SignInRequested() when signInRequested != null:
return signInRequested(_that.email,_that.password);case SignInWithOtpRequested() when signInWithOtpRequested != null:
return signInWithOtpRequested(_that.email,_that.shouldCreateUser,_that.redirectTo);case SignUpRequested() when signUpRequested != null:
return signUpRequested(_that.email,_that.password);case SignOutRequested() when signOutRequested != null:
return signOutRequested();case AuthenticationSucceeded() when authenticationSucceeded != null:
return authenticationSucceeded(_that.user);case AuthenticationCleared() when authenticationCleared != null:
return authenticationCleared();case SignUpConfirmed() when signUpConfirmed != null:
return signUpConfirmed(_that.confirmationCode);case SignInWithOtpConfirmed() when signInWithOtpConfirmed != null:
return signInWithOtpConfirmed(_that.confirmationCode);case SignUpCodeResendRequested() when signUpCodeResendRequested != null:
return signUpCodeResendRequested();case PasswordResetRequested() when passwordResetRequested != null:
return passwordResetRequested(_that.email);case PasswordResetConfirmed() when passwordResetConfirmed != null:
return passwordResetConfirmed(_that.email,_that.newPassword,_that.confirmationCode);case PasswordResetCodeResendRequested() when passwordResetCodeResendRequested != null:
return passwordResetCodeResendRequested(_that.email);case AuthRedirectReceived() when authRedirectReceived != null:
return authRedirectReceived(_that.payload);case OAuthSignInRequested() when oauthSignInRequested != null:
return oauthSignInRequested(_that.provider);case MagicLinkFailed() when magicLinkFailed != null:
return magicLinkFailed(_that.error,_that.stackTrace);case AccountDeletionRequested() when accountDeletionRequested != null:
return accountDeletionRequested();case AuthFlowReset() when authFlowReset != null:
return authFlowReset();case ProfileLoaded() when profileLoaded != null:
return profileLoaded();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initialize,required TResult Function()  onboardingStarted,required TResult Function()  onboardingCompleted,required TResult Function( String email,  String password)  signInRequested,required TResult Function( String email,  bool shouldCreateUser,  String? redirectTo)  signInWithOtpRequested,required TResult Function( String email,  String password)  signUpRequested,required TResult Function()  signOutRequested,required TResult Function( AuthUser user)  authenticationSucceeded,required TResult Function()  authenticationCleared,required TResult Function( String confirmationCode)  signUpConfirmed,required TResult Function( String confirmationCode)  signInWithOtpConfirmed,required TResult Function()  signUpCodeResendRequested,required TResult Function( String email)  passwordResetRequested,required TResult Function( String email,  String newPassword,  String confirmationCode)  passwordResetConfirmed,required TResult Function( String email)  passwordResetCodeResendRequested,required TResult Function( AuthRedirectPayload payload)  authRedirectReceived,required TResult Function( OAuthProvider provider)  oauthSignInRequested,required TResult Function( Object error,  StackTrace stackTrace)  magicLinkFailed,required TResult Function()  accountDeletionRequested,required TResult Function()  authFlowReset,required TResult Function()  profileLoaded,}) {final _that = this;
switch (_that) {
case InitializeEvent():
return initialize();case OnboardingStarted():
return onboardingStarted();case OnboardingCompleted():
return onboardingCompleted();case SignInRequested():
return signInRequested(_that.email,_that.password);case SignInWithOtpRequested():
return signInWithOtpRequested(_that.email,_that.shouldCreateUser,_that.redirectTo);case SignUpRequested():
return signUpRequested(_that.email,_that.password);case SignOutRequested():
return signOutRequested();case AuthenticationSucceeded():
return authenticationSucceeded(_that.user);case AuthenticationCleared():
return authenticationCleared();case SignUpConfirmed():
return signUpConfirmed(_that.confirmationCode);case SignInWithOtpConfirmed():
return signInWithOtpConfirmed(_that.confirmationCode);case SignUpCodeResendRequested():
return signUpCodeResendRequested();case PasswordResetRequested():
return passwordResetRequested(_that.email);case PasswordResetConfirmed():
return passwordResetConfirmed(_that.email,_that.newPassword,_that.confirmationCode);case PasswordResetCodeResendRequested():
return passwordResetCodeResendRequested(_that.email);case AuthRedirectReceived():
return authRedirectReceived(_that.payload);case OAuthSignInRequested():
return oauthSignInRequested(_that.provider);case MagicLinkFailed():
return magicLinkFailed(_that.error,_that.stackTrace);case AccountDeletionRequested():
return accountDeletionRequested();case AuthFlowReset():
return authFlowReset();case ProfileLoaded():
return profileLoaded();case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initialize,TResult? Function()?  onboardingStarted,TResult? Function()?  onboardingCompleted,TResult? Function( String email,  String password)?  signInRequested,TResult? Function( String email,  bool shouldCreateUser,  String? redirectTo)?  signInWithOtpRequested,TResult? Function( String email,  String password)?  signUpRequested,TResult? Function()?  signOutRequested,TResult? Function( AuthUser user)?  authenticationSucceeded,TResult? Function()?  authenticationCleared,TResult? Function( String confirmationCode)?  signUpConfirmed,TResult? Function( String confirmationCode)?  signInWithOtpConfirmed,TResult? Function()?  signUpCodeResendRequested,TResult? Function( String email)?  passwordResetRequested,TResult? Function( String email,  String newPassword,  String confirmationCode)?  passwordResetConfirmed,TResult? Function( String email)?  passwordResetCodeResendRequested,TResult? Function( AuthRedirectPayload payload)?  authRedirectReceived,TResult? Function( OAuthProvider provider)?  oauthSignInRequested,TResult? Function( Object error,  StackTrace stackTrace)?  magicLinkFailed,TResult? Function()?  accountDeletionRequested,TResult? Function()?  authFlowReset,TResult? Function()?  profileLoaded,}) {final _that = this;
switch (_that) {
case InitializeEvent() when initialize != null:
return initialize();case OnboardingStarted() when onboardingStarted != null:
return onboardingStarted();case OnboardingCompleted() when onboardingCompleted != null:
return onboardingCompleted();case SignInRequested() when signInRequested != null:
return signInRequested(_that.email,_that.password);case SignInWithOtpRequested() when signInWithOtpRequested != null:
return signInWithOtpRequested(_that.email,_that.shouldCreateUser,_that.redirectTo);case SignUpRequested() when signUpRequested != null:
return signUpRequested(_that.email,_that.password);case SignOutRequested() when signOutRequested != null:
return signOutRequested();case AuthenticationSucceeded() when authenticationSucceeded != null:
return authenticationSucceeded(_that.user);case AuthenticationCleared() when authenticationCleared != null:
return authenticationCleared();case SignUpConfirmed() when signUpConfirmed != null:
return signUpConfirmed(_that.confirmationCode);case SignInWithOtpConfirmed() when signInWithOtpConfirmed != null:
return signInWithOtpConfirmed(_that.confirmationCode);case SignUpCodeResendRequested() when signUpCodeResendRequested != null:
return signUpCodeResendRequested();case PasswordResetRequested() when passwordResetRequested != null:
return passwordResetRequested(_that.email);case PasswordResetConfirmed() when passwordResetConfirmed != null:
return passwordResetConfirmed(_that.email,_that.newPassword,_that.confirmationCode);case PasswordResetCodeResendRequested() when passwordResetCodeResendRequested != null:
return passwordResetCodeResendRequested(_that.email);case AuthRedirectReceived() when authRedirectReceived != null:
return authRedirectReceived(_that.payload);case OAuthSignInRequested() when oauthSignInRequested != null:
return oauthSignInRequested(_that.provider);case MagicLinkFailed() when magicLinkFailed != null:
return magicLinkFailed(_that.error,_that.stackTrace);case AccountDeletionRequested() when accountDeletionRequested != null:
return accountDeletionRequested();case AuthFlowReset() when authFlowReset != null:
return authFlowReset();case ProfileLoaded() when profileLoaded != null:
return profileLoaded();case _:
  return null;

}
}

}

/// @nodoc


class InitializeEvent implements AuthEvent {
  const InitializeEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitializeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.initialize()';
}


}




/// @nodoc


class OnboardingStarted implements AuthEvent {
  const OnboardingStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.onboardingStarted()';
}


}




/// @nodoc


class OnboardingCompleted implements AuthEvent {
  const OnboardingCompleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.onboardingCompleted()';
}


}




/// @nodoc


class SignInRequested implements AuthEvent {
  const SignInRequested(this.email, this.password);
  

 final  String email;
 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInRequestedCopyWith<SignInRequested> get copyWith => _$SignInRequestedCopyWithImpl<SignInRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInRequested&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'AuthEvent.signInRequested(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $SignInRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $SignInRequestedCopyWith(SignInRequested value, $Res Function(SignInRequested) _then) = _$SignInRequestedCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$SignInRequestedCopyWithImpl<$Res>
    implements $SignInRequestedCopyWith<$Res> {
  _$SignInRequestedCopyWithImpl(this._self, this._then);

  final SignInRequested _self;
  final $Res Function(SignInRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(SignInRequested(
null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SignInWithOtpRequested implements AuthEvent {
  const SignInWithOtpRequested(this.email, {this.shouldCreateUser = true, this.redirectTo});
  

 final  String email;
@JsonKey() final  bool shouldCreateUser;
 final  String? redirectTo;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInWithOtpRequestedCopyWith<SignInWithOtpRequested> get copyWith => _$SignInWithOtpRequestedCopyWithImpl<SignInWithOtpRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInWithOtpRequested&&(identical(other.email, email) || other.email == email)&&(identical(other.shouldCreateUser, shouldCreateUser) || other.shouldCreateUser == shouldCreateUser)&&(identical(other.redirectTo, redirectTo) || other.redirectTo == redirectTo));
}


@override
int get hashCode => Object.hash(runtimeType,email,shouldCreateUser,redirectTo);

@override
String toString() {
  return 'AuthEvent.signInWithOtpRequested(email: $email, shouldCreateUser: $shouldCreateUser, redirectTo: $redirectTo)';
}


}

/// @nodoc
abstract mixin class $SignInWithOtpRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $SignInWithOtpRequestedCopyWith(SignInWithOtpRequested value, $Res Function(SignInWithOtpRequested) _then) = _$SignInWithOtpRequestedCopyWithImpl;
@useResult
$Res call({
 String email, bool shouldCreateUser, String? redirectTo
});




}
/// @nodoc
class _$SignInWithOtpRequestedCopyWithImpl<$Res>
    implements $SignInWithOtpRequestedCopyWith<$Res> {
  _$SignInWithOtpRequestedCopyWithImpl(this._self, this._then);

  final SignInWithOtpRequested _self;
  final $Res Function(SignInWithOtpRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? shouldCreateUser = null,Object? redirectTo = freezed,}) {
  return _then(SignInWithOtpRequested(
null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,shouldCreateUser: null == shouldCreateUser ? _self.shouldCreateUser : shouldCreateUser // ignore: cast_nullable_to_non_nullable
as bool,redirectTo: freezed == redirectTo ? _self.redirectTo : redirectTo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SignUpRequested implements AuthEvent {
  const SignUpRequested(this.email, this.password);
  

 final  String email;
 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpRequestedCopyWith<SignUpRequested> get copyWith => _$SignUpRequestedCopyWithImpl<SignUpRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpRequested&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'AuthEvent.signUpRequested(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $SignUpRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $SignUpRequestedCopyWith(SignUpRequested value, $Res Function(SignUpRequested) _then) = _$SignUpRequestedCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$SignUpRequestedCopyWithImpl<$Res>
    implements $SignUpRequestedCopyWith<$Res> {
  _$SignUpRequestedCopyWithImpl(this._self, this._then);

  final SignUpRequested _self;
  final $Res Function(SignUpRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(SignUpRequested(
null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SignOutRequested implements AuthEvent {
  const SignOutRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignOutRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.signOutRequested()';
}


}




/// @nodoc


class AuthenticationSucceeded implements AuthEvent {
  const AuthenticationSucceeded(this.user);
  

 final  AuthUser user;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationSucceededCopyWith<AuthenticationSucceeded> get copyWith => _$AuthenticationSucceededCopyWithImpl<AuthenticationSucceeded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationSucceeded&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'AuthEvent.authenticationSucceeded(user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthenticationSucceededCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthenticationSucceededCopyWith(AuthenticationSucceeded value, $Res Function(AuthenticationSucceeded) _then) = _$AuthenticationSucceededCopyWithImpl;
@useResult
$Res call({
 AuthUser user
});




}
/// @nodoc
class _$AuthenticationSucceededCopyWithImpl<$Res>
    implements $AuthenticationSucceededCopyWith<$Res> {
  _$AuthenticationSucceededCopyWithImpl(this._self, this._then);

  final AuthenticationSucceeded _self;
  final $Res Function(AuthenticationSucceeded) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(AuthenticationSucceeded(
null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser,
  ));
}


}

/// @nodoc


class AuthenticationCleared implements AuthEvent {
  const AuthenticationCleared();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationCleared);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.authenticationCleared()';
}


}




/// @nodoc


class SignUpConfirmed implements AuthEvent {
  const SignUpConfirmed(this.confirmationCode);
  

 final  String confirmationCode;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpConfirmedCopyWith<SignUpConfirmed> get copyWith => _$SignUpConfirmedCopyWithImpl<SignUpConfirmed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpConfirmed&&(identical(other.confirmationCode, confirmationCode) || other.confirmationCode == confirmationCode));
}


@override
int get hashCode => Object.hash(runtimeType,confirmationCode);

@override
String toString() {
  return 'AuthEvent.signUpConfirmed(confirmationCode: $confirmationCode)';
}


}

/// @nodoc
abstract mixin class $SignUpConfirmedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $SignUpConfirmedCopyWith(SignUpConfirmed value, $Res Function(SignUpConfirmed) _then) = _$SignUpConfirmedCopyWithImpl;
@useResult
$Res call({
 String confirmationCode
});




}
/// @nodoc
class _$SignUpConfirmedCopyWithImpl<$Res>
    implements $SignUpConfirmedCopyWith<$Res> {
  _$SignUpConfirmedCopyWithImpl(this._self, this._then);

  final SignUpConfirmed _self;
  final $Res Function(SignUpConfirmed) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? confirmationCode = null,}) {
  return _then(SignUpConfirmed(
null == confirmationCode ? _self.confirmationCode : confirmationCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SignInWithOtpConfirmed implements AuthEvent {
  const SignInWithOtpConfirmed(this.confirmationCode);
  

 final  String confirmationCode;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInWithOtpConfirmedCopyWith<SignInWithOtpConfirmed> get copyWith => _$SignInWithOtpConfirmedCopyWithImpl<SignInWithOtpConfirmed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInWithOtpConfirmed&&(identical(other.confirmationCode, confirmationCode) || other.confirmationCode == confirmationCode));
}


@override
int get hashCode => Object.hash(runtimeType,confirmationCode);

@override
String toString() {
  return 'AuthEvent.signInWithOtpConfirmed(confirmationCode: $confirmationCode)';
}


}

/// @nodoc
abstract mixin class $SignInWithOtpConfirmedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $SignInWithOtpConfirmedCopyWith(SignInWithOtpConfirmed value, $Res Function(SignInWithOtpConfirmed) _then) = _$SignInWithOtpConfirmedCopyWithImpl;
@useResult
$Res call({
 String confirmationCode
});




}
/// @nodoc
class _$SignInWithOtpConfirmedCopyWithImpl<$Res>
    implements $SignInWithOtpConfirmedCopyWith<$Res> {
  _$SignInWithOtpConfirmedCopyWithImpl(this._self, this._then);

  final SignInWithOtpConfirmed _self;
  final $Res Function(SignInWithOtpConfirmed) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? confirmationCode = null,}) {
  return _then(SignInWithOtpConfirmed(
null == confirmationCode ? _self.confirmationCode : confirmationCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SignUpCodeResendRequested implements AuthEvent {
  const SignUpCodeResendRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpCodeResendRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.signUpCodeResendRequested()';
}


}




/// @nodoc


class PasswordResetRequested implements AuthEvent {
  const PasswordResetRequested(this.email);
  

 final  String email;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetRequestedCopyWith<PasswordResetRequested> get copyWith => _$PasswordResetRequestedCopyWithImpl<PasswordResetRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetRequested&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'AuthEvent.passwordResetRequested(email: $email)';
}


}

/// @nodoc
abstract mixin class $PasswordResetRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $PasswordResetRequestedCopyWith(PasswordResetRequested value, $Res Function(PasswordResetRequested) _then) = _$PasswordResetRequestedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$PasswordResetRequestedCopyWithImpl<$Res>
    implements $PasswordResetRequestedCopyWith<$Res> {
  _$PasswordResetRequestedCopyWithImpl(this._self, this._then);

  final PasswordResetRequested _self;
  final $Res Function(PasswordResetRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(PasswordResetRequested(
null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PasswordResetConfirmed implements AuthEvent {
  const PasswordResetConfirmed({required this.email, required this.newPassword, required this.confirmationCode});
  

 final  String email;
 final  String newPassword;
 final  String confirmationCode;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetConfirmedCopyWith<PasswordResetConfirmed> get copyWith => _$PasswordResetConfirmedCopyWithImpl<PasswordResetConfirmed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetConfirmed&&(identical(other.email, email) || other.email == email)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmationCode, confirmationCode) || other.confirmationCode == confirmationCode));
}


@override
int get hashCode => Object.hash(runtimeType,email,newPassword,confirmationCode);

@override
String toString() {
  return 'AuthEvent.passwordResetConfirmed(email: $email, newPassword: $newPassword, confirmationCode: $confirmationCode)';
}


}

/// @nodoc
abstract mixin class $PasswordResetConfirmedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $PasswordResetConfirmedCopyWith(PasswordResetConfirmed value, $Res Function(PasswordResetConfirmed) _then) = _$PasswordResetConfirmedCopyWithImpl;
@useResult
$Res call({
 String email, String newPassword, String confirmationCode
});




}
/// @nodoc
class _$PasswordResetConfirmedCopyWithImpl<$Res>
    implements $PasswordResetConfirmedCopyWith<$Res> {
  _$PasswordResetConfirmedCopyWithImpl(this._self, this._then);

  final PasswordResetConfirmed _self;
  final $Res Function(PasswordResetConfirmed) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? newPassword = null,Object? confirmationCode = null,}) {
  return _then(PasswordResetConfirmed(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmationCode: null == confirmationCode ? _self.confirmationCode : confirmationCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PasswordResetCodeResendRequested implements AuthEvent {
  const PasswordResetCodeResendRequested(this.email);
  

 final  String email;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetCodeResendRequestedCopyWith<PasswordResetCodeResendRequested> get copyWith => _$PasswordResetCodeResendRequestedCopyWithImpl<PasswordResetCodeResendRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetCodeResendRequested&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'AuthEvent.passwordResetCodeResendRequested(email: $email)';
}


}

/// @nodoc
abstract mixin class $PasswordResetCodeResendRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $PasswordResetCodeResendRequestedCopyWith(PasswordResetCodeResendRequested value, $Res Function(PasswordResetCodeResendRequested) _then) = _$PasswordResetCodeResendRequestedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$PasswordResetCodeResendRequestedCopyWithImpl<$Res>
    implements $PasswordResetCodeResendRequestedCopyWith<$Res> {
  _$PasswordResetCodeResendRequestedCopyWithImpl(this._self, this._then);

  final PasswordResetCodeResendRequested _self;
  final $Res Function(PasswordResetCodeResendRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(PasswordResetCodeResendRequested(
null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthRedirectReceived implements AuthEvent {
  const AuthRedirectReceived(this.payload);
  

 final  AuthRedirectPayload payload;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthRedirectReceivedCopyWith<AuthRedirectReceived> get copyWith => _$AuthRedirectReceivedCopyWithImpl<AuthRedirectReceived>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthRedirectReceived&&(identical(other.payload, payload) || other.payload == payload));
}


@override
int get hashCode => Object.hash(runtimeType,payload);

@override
String toString() {
  return 'AuthEvent.authRedirectReceived(payload: $payload)';
}


}

/// @nodoc
abstract mixin class $AuthRedirectReceivedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthRedirectReceivedCopyWith(AuthRedirectReceived value, $Res Function(AuthRedirectReceived) _then) = _$AuthRedirectReceivedCopyWithImpl;
@useResult
$Res call({
 AuthRedirectPayload payload
});




}
/// @nodoc
class _$AuthRedirectReceivedCopyWithImpl<$Res>
    implements $AuthRedirectReceivedCopyWith<$Res> {
  _$AuthRedirectReceivedCopyWithImpl(this._self, this._then);

  final AuthRedirectReceived _self;
  final $Res Function(AuthRedirectReceived) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payload = null,}) {
  return _then(AuthRedirectReceived(
null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as AuthRedirectPayload,
  ));
}


}

/// @nodoc


class OAuthSignInRequested implements AuthEvent {
  const OAuthSignInRequested(this.provider);
  

 final  OAuthProvider provider;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OAuthSignInRequestedCopyWith<OAuthSignInRequested> get copyWith => _$OAuthSignInRequestedCopyWithImpl<OAuthSignInRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OAuthSignInRequested&&(identical(other.provider, provider) || other.provider == provider));
}


@override
int get hashCode => Object.hash(runtimeType,provider);

@override
String toString() {
  return 'AuthEvent.oauthSignInRequested(provider: $provider)';
}


}

/// @nodoc
abstract mixin class $OAuthSignInRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $OAuthSignInRequestedCopyWith(OAuthSignInRequested value, $Res Function(OAuthSignInRequested) _then) = _$OAuthSignInRequestedCopyWithImpl;
@useResult
$Res call({
 OAuthProvider provider
});




}
/// @nodoc
class _$OAuthSignInRequestedCopyWithImpl<$Res>
    implements $OAuthSignInRequestedCopyWith<$Res> {
  _$OAuthSignInRequestedCopyWithImpl(this._self, this._then);

  final OAuthSignInRequested _self;
  final $Res Function(OAuthSignInRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? provider = null,}) {
  return _then(OAuthSignInRequested(
null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as OAuthProvider,
  ));
}


}

/// @nodoc


class MagicLinkFailed implements AuthEvent {
  const MagicLinkFailed(this.error, this.stackTrace);
  

 final  Object error;
 final  StackTrace stackTrace;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MagicLinkFailedCopyWith<MagicLinkFailed> get copyWith => _$MagicLinkFailedCopyWithImpl<MagicLinkFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MagicLinkFailed&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'AuthEvent.magicLinkFailed(error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $MagicLinkFailedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $MagicLinkFailedCopyWith(MagicLinkFailed value, $Res Function(MagicLinkFailed) _then) = _$MagicLinkFailedCopyWithImpl;
@useResult
$Res call({
 Object error, StackTrace stackTrace
});




}
/// @nodoc
class _$MagicLinkFailedCopyWithImpl<$Res>
    implements $MagicLinkFailedCopyWith<$Res> {
  _$MagicLinkFailedCopyWithImpl(this._self, this._then);

  final MagicLinkFailed _self;
  final $Res Function(MagicLinkFailed) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? stackTrace = null,}) {
  return _then(MagicLinkFailed(
null == error ? _self.error : error ,null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,
  ));
}


}

/// @nodoc


class AccountDeletionRequested implements AuthEvent {
  const AccountDeletionRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDeletionRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.accountDeletionRequested()';
}


}




/// @nodoc


class AuthFlowReset implements AuthEvent {
  const AuthFlowReset();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFlowReset);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.authFlowReset()';
}


}




/// @nodoc


class ProfileLoaded implements AuthEvent {
  const ProfileLoaded();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoaded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.profileLoaded()';
}


}




// dart format on
