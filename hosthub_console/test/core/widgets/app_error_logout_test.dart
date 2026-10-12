import 'package:app_errors/app_errors.dart';
import 'package:auth_ui_flutter/auth_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hosthub_console/core/errors/hosthub_error_reason.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/auth/auth_ui_styled_overrides.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

/// Records the events the console sends to the auth bloc.
class _RecordingAuthBloc extends Bloc<AuthEvent, AuthState>
    implements AuthBloc {
  _RecordingAuthBloc()
    : super(const AuthState(status: AuthStatus.authenticated)) {
    on<AuthEvent>((event, emit) => events.add(event));
  }

  final List<AuthEvent> events = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A session that ended signs the console out as the error is shown, through
/// the logout handler the console gives app_errors; the dialog's "Log out"
/// only acknowledges it.
void main() {
  setUp(() {
    AppErrors.configure(
      mapper: hosthubErrorMapper,
      errorPresenter: styledAppErrorPresenter,
      onLogoutRequired: handleAppErrorLogout,
    );
  });

  tearDown(AppErrors.resetForTesting);

  testWidgets('an error that ends the session signs out once', (tester) async {
    final authBloc = _RecordingAuthBloc();
    addTearDown(authBloc.close);
    late BuildContext context;
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            AppErrorLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(
            builder: (built) {
              context = built;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    final appError = AppError.fromDomain(
      context,
      DomainErrorCode.unauthorized.err(
        reason: HosthubErrorReason.cannotDeleteAllUserData,
        logout: true,
      ),
      mapper: hosthubErrorMapper,
    );
    expect(appError.requiresLogout, isTrue);

    showAppError(context, appError);
    await tester.pumpAndSettle();

    expect(authBloc.events, [const AuthEvent.logout()]);
  });
}
