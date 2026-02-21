import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';

abstract class OnboardingPort {
  Future<AdminSettings> load({bool forceRefresh = false});
}
