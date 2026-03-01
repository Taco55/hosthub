import 'package:hosthub_console/core/di/inject.dart';
import 'package:hosthub_console/core/services/lodgify_service.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/lodgify_channel_manager_repository.dart';

void registerLodgifyDependencies() {
  if (!I.isRegistered<LodgifyService>()) {
    I.registerSingleton<LodgifyService>(
      LodgifyService(),
      dispose: (service) => service.dispose(),
    );
  }

  if (!I.isRegistered<ChannelManagerRepository>()) {
    I.registerSingleton<ChannelManagerRepository>(
      LodgifyChannelManagerRepository(lodgifyService: I.get<LodgifyService>()),
      signalsReady: true,
    );
  }
}
