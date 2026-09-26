import 'dart:async';

import 'package:auth_ui_flutter/auth_ui_flutter.dart' as auth_ui;

typedef AuthUser = auth_ui.AuthUser;
typedef SignUpResult = auth_ui.SignUpResult;
typedef SignInResult = auth_ui.SignInResult;
typedef AuthSignInStep = auth_ui.AuthSignInStep;
typedef AuthSignUpStep = auth_ui.AuthSignUpStep;
typedef AccountDeletionResult = auth_ui.AccountDeletionResult;

class AuthSessionChange {
  const AuthSessionChange({this.user});

  final AuthUser? user;
}

/// The console's auth: `auth_ui_flutter`'s service contract, plus the session
/// stream the console's own listeners follow.
///
/// The implementation extends a class that already implements the contract
/// (`SupabaseAuthService`), so a member the contract gains with a default
/// reaches it without a change here.
abstract class AuthPort implements auth_ui.AuthServiceInterface {
  /// The signed-in user on every session change, `null` when signed out.
  ///
  /// Unlike [authStateChanges] it carries no refused sign-in links: those are
  /// `AuthBloc`'s to show, not the concern of a listener that only follows who
  /// is signed in.
  Stream<AuthSessionChange> get onAuthStateChange;
}
