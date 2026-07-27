import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/app/session/session_bloc_listeners.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

/// The Supabase session can surface a beat after AuthBloc reports
/// authenticated — a token refresh landing during app start. Loads that fire
/// inside that gap fail with an unauthorized DomainError, and before this was
/// fixed they were never retried: the shell kept showing "loading profile" and
/// an empty property list while the data was there all along.
void main() {
  late _FakeAuthPort authPort;

  setUp(() {
    authPort = _FakeAuthPort();
    I.registerSingleton<AuthPort>(authPort);
  });

  tearDown(() async {
    await authPort.close();
    await I.reset();
  });

  testWidgets('does not prime session data before a session is readable', (
    tester,
  ) async {
    final harness = await _pumpListeners(tester, userId: null);

    expect(harness.profileCubit.loadCalls, 0);
    expect(harness.settingsCubit.loadCalls, 0);
    expect(harness.propertyCubit.loadCalls, 0);
    expect(harness.userSettingsCubit.bootstrapCalls, isEmpty);
  });

  testWidgets('primes session data once the session surfaces', (tester) async {
    final harness = await _pumpListeners(tester, userId: null);

    harness.userProvider.userId = 'user-1';
    authPort.emitSession(const AuthUser(id: 'user-1', email: 'a@b.test'));
    await tester.pump();

    expect(harness.profileCubit.loadCalls, 1);
    expect(harness.settingsCubit.loadCalls, 1);
    expect(harness.propertyCubit.loadCalls, 1);
    expect(harness.userSettingsCubit.bootstrapCalls, ['user-1']);
  });

  testWidgets('retries cubits left in error by an earlier session gap', (
    tester,
  ) async {
    final unauthorized = DomainErrorCode.unauthorized.err(
      message: 'User not logged in',
      logout: false,
    );
    final harness = await _pumpListeners(
      tester,
      userId: 'user-1',
      profileState: ProfileState(
        status: ProfileStatus.error,
        error: unauthorized,
      ),
      propertyState: PropertyContextState(
        status: PropertyContextStatus.error,
        properties: const [],
        error: unauthorized,
      ),
    );
    // Primed on mount, because the session is readable from the start.
    expect(harness.profileCubit.loadCalls, 1);
    expect(harness.propertyCubit.loadCalls, 1);

    // A later session event (a token refresh) re-primes what is still empty.
    authPort.emitSession(const AuthUser(id: 'user-1', email: 'a@b.test'));
    await tester.pump();

    expect(harness.profileCubit.loadCalls, 2);
    expect(harness.propertyCubit.loadCalls, 2);
  });

  testWidgets('leaves cubits that already hold data alone', (tester) async {
    final harness = await _pumpListeners(
      tester,
      userId: 'user-1',
      profileState: const ProfileState(
        status: ProfileStatus.loaded,
        profile: Profile(id: 'user-1', email: 'a@b.test'),
      ),
    );

    expect(harness.profileCubit.loadCalls, 0);

    authPort.emitSession(const AuthUser(id: 'user-1', email: 'a@b.test'));
    await tester.pump();

    expect(harness.profileCubit.loadCalls, 0);
  });

  testWidgets('reloads everything on a fresh sign-in', (tester) async {
    final harness = await _pumpListeners(
      tester,
      userId: 'user-1',
      authStatus: AuthStatus.unauthenticated,
      profileState: const ProfileState(
        status: ProfileStatus.loaded,
        profile: Profile(id: 'user-1', email: 'a@b.test'),
      ),
    );
    expect(harness.profileCubit.loadCalls, 0);

    harness.authBloc.emitStatus(AuthStatus.authenticated);
    await tester.pump();

    expect(harness.profileCubit.loadCalls, 1);
    expect(harness.userSettingsCubit.bootstrapCalls, ['user-1']);
  });
}

class _Harness {
  _Harness({
    required this.authBloc,
    required this.userProvider,
    required this.profileCubit,
    required this.settingsCubit,
    required this.propertyCubit,
    required this.userSettingsCubit,
  });

  final _FakeAuthBloc authBloc;
  final _FakeCurrentUserProvider userProvider;
  final _FakeProfileCubit profileCubit;
  final _FakeSettingsCubit settingsCubit;
  final _FakePropertyContextCubit propertyCubit;
  final _FakeUserSettingsCubit userSettingsCubit;
}

Future<_Harness> _pumpListeners(
  WidgetTester tester, {
  required String? userId,
  AuthStatus authStatus = AuthStatus.authenticated,
  ProfileState profileState = const ProfileState(),
  PropertyContextState propertyState = const PropertyContextState.initial(),
}) async {
  final authBloc = _FakeAuthBloc(authStatus);
  final userProvider = _FakeCurrentUserProvider(userId);
  final profileCubit = _FakeProfileCubit(profileState);
  final settingsCubit = _FakeSettingsCubit();
  final propertyCubit = _FakePropertyContextCubit(propertyState);
  final userSettingsCubit = _FakeUserSettingsCubit();
  addTearDown(authBloc.close);
  addTearDown(profileCubit.close);
  addTearDown(settingsCubit.close);
  addTearDown(propertyCubit.close);
  addTearDown(userSettingsCubit.close);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        RepositoryProvider<CurrentUserProvider>.value(value: userProvider),
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<PropertyContextCubit>.value(value: propertyCubit),
        BlocProvider<UserSettingsCubit>.value(value: userSettingsCubit),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: const SessionBlocListeners(child: SizedBox.shrink()),
      ),
    ),
  );
  // The initial prime runs in a microtask.
  await tester.pump();

  return _Harness(
    authBloc: authBloc,
    userProvider: userProvider,
    profileCubit: profileCubit,
    settingsCubit: settingsCubit,
    propertyCubit: propertyCubit,
    userSettingsCubit: userSettingsCubit,
  );
}

class _FakeAuthPort implements AuthPort {
  final _sessions = StreamController<AuthSessionChange>.broadcast();

  void emitSession(AuthUser? user) =>
      _sessions.add(AuthSessionChange(user: user));

  Future<void> close() => _sessions.close();

  @override
  Stream<AuthSessionChange> get onAuthStateChange => _sessions.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCurrentUserProvider implements CurrentUserProvider {
  _FakeCurrentUserProvider(this.userId);

  String? userId;

  @override
  String get currentUserId =>
      currentUserIdOrNull ??
      (throw DomainErrorCode.unauthorized.err(message: 'User not logged in'));

  @override
  String? get currentUserIdOrNull => userId;
}

class _FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  _FakeAuthBloc(AuthStatus status) : super(AuthState(status: status));

  void emitStatus(AuthStatus status) => emit(AuthState(status: status));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _FakeProfileCubit(super.initialState);

  int loadCalls = 0;

  @override
  Future<void> loadProfile() async => loadCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettingsCubit extends Cubit<SettingsState> implements SettingsCubit {
  _FakeSettingsCubit() : super(const SettingsState.initial());

  int loadCalls = 0;

  @override
  Future<void> load({bool forceRefresh = false}) async => loadCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePropertyContextCubit extends Cubit<PropertyContextState>
    implements PropertyContextCubit {
  _FakePropertyContextCubit(super.initialState);

  int loadCalls = 0;

  @override
  Future<void> loadProperties() async => loadCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserSettingsCubit extends Cubit<UserSettingsState>
    implements UserSettingsCubit {
  _FakeUserSettingsCubit() : super(const UserSettingsState.initial());

  final List<String> bootstrapCalls = [];

  @override
  Future<void> bootstrap({required String userId}) async =>
      bootstrapCalls.add(userId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
