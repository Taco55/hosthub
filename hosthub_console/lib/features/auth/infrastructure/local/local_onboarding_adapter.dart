import 'package:hosthub_console/features/auth/domain/ports/onboarding_port.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';

class LocalOnboardingAdapter implements OnboardingPort {
  const LocalOnboardingAdapter();

  @override
  Future<AdminSettings> load({bool forceRefresh = false}) async {
    return AdminSettings.defaults();
  }
}
