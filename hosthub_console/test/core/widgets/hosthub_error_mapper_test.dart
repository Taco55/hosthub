import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/core/errors/hosthub_error_reason.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

/// The console words its own reasons; everything else, and a failure the
/// library words first (a session that ended, a lost connection), is the
/// library's.
void main() {
  late BuildContext context;

  Future<void> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
    );
  }

  AppError read(DomainError error) =>
      AppError.fromDomain(context, error, mapper: hosthubErrorMapper);

  testWidgets('each reason of the console reads its own copy', (tester) async {
    await pumpContext(tester);
    final s = S.of(context);

    final expected = {
      HosthubErrorReason.cannotDeleteAllUserData: s.cannotDeleteAllUserData,
      HosthubErrorReason.signUpConfirmationEmailFailed:
          s.errorSignUpConfirmationEmailFailed,
      HosthubErrorReason.loginOtpEmailFailed: s.errorLoginOtpEmailFailed,
      HosthubErrorReason.passwordResetEmailFailed:
          s.errorPasswordResetEmailFailed,
      HosthubErrorReason.userCreatedEmailFailed: s.errorUserCreatedEmailFailed,
    };
    for (final MapEntry(key: reason, value: alert) in expected.entries) {
      final error = DomainErrorCode.serverError.err(reason: reason);
      expect(read(error).alert, alert, reason: reason.name);
    }
  });

  testWidgets('a lost connection reads as one, whatever the reason', (
    tester,
  ) async {
    await pumpContext(tester);

    final error = DomainErrorCode.network.err(
      reason: HosthubErrorReason.loginOtpEmailFailed,
    );

    expect(read(error).alert, AppErrorLocalizations.of(context).networkError);
  });

  testWidgets('a session that ended signs out, whatever the reason', (
    tester,
  ) async {
    await pumpContext(tester);

    final appError = read(
      DomainErrorCode.unauthorized.err(
        reason: HosthubErrorReason.cannotDeleteAllUserData,
        logout: true,
      ),
    );

    expect(appError.alert, AppErrorLocalizations.of(context).sessionExpired);
    expect(appError.requiresLogout, isTrue);
  });

  testWidgets('an error without a reason of the console is the library\'s', (
    tester,
  ) async {
    await pumpContext(tester);

    final error = DomainErrorCode.unknown.err(operation: DomainOperation.save);

    expect(
      hosthubErrorMapper(context, error, AppErrorLocalizations.of(context)),
      isNull,
    );
    expect(read(error).alert, AppErrorLocalizations.of(context).saveFailed);
  });
}
