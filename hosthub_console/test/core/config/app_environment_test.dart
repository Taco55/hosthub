import 'package:flutter_test/flutter_test.dart';
import 'package:hosthub_console/core/config/app_environment.dart';

void main() {
  group('showsErrorDiagnostics', () {
    test('is off on prd and on everywhere else', () {
      // The console ships one release build per environment, so this is the
      // only thing standing between a site owner and a stacktrace. It is
      // asserted per value rather than as `!isPrd` so that adding a fourth
      // environment has to make a deliberate choice here.
      expect(AppEnvironment.prd.showsErrorDiagnostics, isFalse);
      expect(AppEnvironment.stg.showsErrorDiagnostics, isTrue);
      expect(AppEnvironment.dev.showsErrorDiagnostics, isTrue);
    });

    test('an unset APP_ENVIRONMENT does not open diagnostics up', () {
      // A build without --dart-define falls back to stg, not prd: a missing
      // flag must never be the thing that hides an error's cause from us.
      expect(AppEnvironment.fromEnvironment(), AppEnvironment.stg);
    });
  });
}
