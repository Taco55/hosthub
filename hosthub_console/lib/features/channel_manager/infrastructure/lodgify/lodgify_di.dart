import 'package:hosthub_console/core/config/app_config.dart';
import 'package:hosthub_console/core/di/inject.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/lodgify_channel_manager_repository.dart';
import 'package:hosthub_console/core/services/api_services/api_client.dart';
import 'package:hosthub_console/core/services/lodgify_service.dart';
import 'package:hosthub_console/features/user_settings/data/user_settings_repository.dart';
import 'package:hosthub_console/features/user_settings/domain/current_user_provider.dart';

void registerLodgifyDependencies() {
  if (!I.isRegistered<LodgifyService>()) {
    final lodgifyClient = ApiClient(
      baseUrl: AppConfig.current.lodgifyBaseUrl.toString(),
      apiVersion: 'v1',
    )..init();

    I.registerSingleton<LodgifyService>(
      LodgifyService(
        apiClient: lodgifyClient,
        apiKeyProvider: () async {
          final userId = I.get<CurrentUserProvider>().currentUserId;
          final settings = await I.get<UserSettingsRepository>()
              .loadOrCreateDefaults(userId);
          return settings.lodgifyApiKey;
        },
      ),
      dispose: (service) => service.dispose(),
    );
  }

  if (!I.isRegistered<ChannelManagerRepository>()) {
    I.registerSingleton<ChannelManagerRepository>(
      LodgifyChannelManagerRepository(
        lodgifyService: I.get<LodgifyService>(),
      ),
      signalsReady: true,
    );
  }
}
