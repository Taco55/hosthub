import 'package:app_errors/app_errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/shared/models/models.dart';
import 'package:hosthub_console/shared/domain/channel_manager/channel_manager_repository.dart';
import 'package:hosthub_console/shared/domain/channel_manager/models/models.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/application/settings_cubit.dart';
import 'package:hosthub_console/features/user_settings/application/user_settings_state.dart';
import 'package:hosthub_console/features/user_settings/data/user_settings_repository.dart';
import 'package:hosthub_console/features/user_settings/domain/current_user_provider.dart';
import 'package:hosthub_console/features/user_settings/domain/user_settings_actions.dart';

class UserSettingsCubit extends Cubit<UserSettingsState> {
  UserSettingsCubit({
    required UserSettingsRepository userSettingsRepository,
    required ChannelManagerRepository channelManagerRepository,
    required PropertyRepository propertyRepository,
    required SettingsCubit settingsCubit,
    required CurrentUserProvider currentUserProvider,
  }) : _userSettingsRepository = userSettingsRepository,
       _channelManagerRepository = channelManagerRepository,
       _propertyRepository = propertyRepository,
       _settingsCubit = settingsCubit,
       _currentUserProvider = currentUserProvider,
       super(const UserSettingsState.initial());

  final UserSettingsRepository _userSettingsRepository;
  final ChannelManagerRepository _channelManagerRepository;
  final PropertyRepository _propertyRepository;
  final SettingsCubit _settingsCubit;
  final CurrentUserProvider _currentUserProvider;

  void reset() {
    emit(const UserSettingsState.initial());
  }

  Future<void> bootstrap({required String userId}) async {
    if (state.status == UserSettingsStatus.loading) return;
    emit(state.copyWith(status: UserSettingsStatus.loading));
    try {
      final settings = await _userSettingsRepository.loadOrCreateDefaults(
        userId,
      );
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          settings: settings,
          errorMessage: null,
          domainError: null,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: UserSettingsStatus.error,
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;
    if (settings.languageCode == languageCode) return;

    final updated = settings.copyWith(languageCode: languageCode);
    await _saveSettings(
      updated,
      toast: const UserSettingsToast(
        type: UserSettingsToastType.success,
        message: UserSettingsToastMessage.settingsSaved,
      ),
    );
  }

  Future<void> changeExportLanguage(String exportLanguageCode) async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;
    if (settings.exportLanguageCode == exportLanguageCode) return;

    final updated = settings.copyWith(exportLanguageCode: exportLanguageCode);
    await _saveSettings(
      updated,
      toast: const UserSettingsToast(
        type: UserSettingsToastType.success,
        message: UserSettingsToastMessage.settingsSaved,
      ),
    );
  }

  Future<void> changeExportSettings({
    required String exportLanguageCode,
    required List<String> exportColumns,
  }) async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;

    final langSame = settings.exportLanguageCode == exportLanguageCode;
    final colsSame = _listEquals(settings.exportColumns, exportColumns);
    if (langSame && colsSame) return;

    final updated = settings.copyWith(
      exportLanguageCode: exportLanguageCode,
      exportColumns: exportColumns,
    );
    await _saveSettings(
      updated,
      toast: const UserSettingsToast(
        type: UserSettingsToastType.success,
        message: UserSettingsToastMessage.settingsSaved,
      ),
    );
  }

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> updateLodgifyApiKey(
    String? apiKey, {
    required bool remove,
  }) async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;

    if (remove) {
      final updated = settings.copyWith(
        lodgifyApiKey: null,
        lodgifyConnected: false,
        lodgifyConnectedAt: null,
        lodgifyLastSyncedAt: null,
      );
      await _saveSettings(
        updated,
        toast: const UserSettingsToast(
          type: UserSettingsToastType.success,
          message: UserSettingsToastMessage.settingsSaved,
        ),
      );
      return;
    }

    final trimmed = apiKey?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == settings.lodgifyApiKey) {
      return;
    }

    final updated = settings.copyWith(
      lodgifyApiKey: trimmed,
      lodgifyConnected: false,
      lodgifyConnectedAt: null,
      lodgifyLastSyncedAt: null,
    );
    await _saveSettings(
      updated,
      toast: const UserSettingsToast(
        type: UserSettingsToastType.success,
        message: UserSettingsToastMessage.settingsSaved,
      ),
    );
  }

  Future<void> connectLodgify() async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;

    final apiKey = settings.lodgifyApiKey?.trim() ?? '';
    if (apiKey.isEmpty) {
      emit(
        state.copyWith(
          toast: const UserSettingsToast(
            type: UserSettingsToastType.error,
            message: UserSettingsToastMessage.lodgifyApiKeyRequired,
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(status: UserSettingsStatus.connecting));
    try {
      await _channelManagerRepository.testConnection();
      final updated = settings.copyWith(
        lodgifyConnected: true,
        lodgifyConnectedAt: DateTime.now(),
      );
      final saved = await _userSettingsRepository.save(updated);
      _settingsCubit.load(forceRefresh: true);
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          settings: saved,
          errorMessage: null,
          toast: const UserSettingsToast(
            type: UserSettingsToastType.success,
            message: UserSettingsToastMessage.lodgifyConnectSuccess,
          ),
        ),
      );
      await syncLodgify(allowWhenBusy: true);
    } catch (error, stack) {
      final domainError = DomainError.from(
        error,
        stack: stack,
        context: const {'lodgify_action': 'connect'},
      );
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          errorMessage: error.toString(),
          domainError: domainError,
        ),
      );
    }
  }

  Future<void> syncLodgify({bool allowWhenBusy = false}) async {
    final settings = state.settings;
    if (settings == null || !settings.lodgifyConnected) return;
    if (_isBusy && !allowWhenBusy) return;

    emit(state.copyWith(status: UserSettingsStatus.syncing));
    try {
      final channelProperties = await _channelManagerRepository
          .fetchProperties();
      final existing = await _propertyRepository.fetchProperties();
      final existingNames = existing
          .map((property) => property.name.trim().toLowerCase())
          .toSet();
      final existingLodgifyIds = existing
          .map((property) => property.lodgifyId?.trim())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();
      final missing = channelProperties.where((property) {
        final channelId = property.id?.trim();
        if (channelId != null && channelId.isNotEmpty) {
          return !existingLodgifyIds.contains(channelId);
        }
        final name = property.name?.trim();
        if (name == null || name.isEmpty) return false;
        return !existingNames.contains(name.toLowerCase());
      }).toList();

      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          missingPropertiesToConfirm: missing,
          channelPropertiesToReview: channelProperties,
        ),
      );
      return;
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          errorMessage: error.toString(),
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> addMissingProperties(List<ChannelProperty> missing) async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;

    emit(state.copyWith(status: UserSettingsStatus.syncing));
    try {
      for (final property in missing) {
        final name = property.name?.trim();
        if (name == null || name.isEmpty) continue;
        await _propertyRepository.createProperty(
          name: name,
          lodgifyId: property.id,
        );
      }
      await _completeSync(settings);
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          errorMessage: error.toString(),
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  Future<void> skipMissingProperties() async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;
    emit(
      state.copyWith(
        status: UserSettingsStatus.ready,
        clearMissingProperties: true,
      ),
    );
  }

  Future<void> confirmLodgifySync() async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;

    emit(state.copyWith(status: UserSettingsStatus.syncing));

    await _completeSync(settings);
  }

  void clearToast() {
    if (state.toast == null) return;
    emit(state.copyWith(clearToast: true));
  }

  void clearError() {
    if (state.domainError == null) return;
    emit(state.copyWith(clearDomainError: true));
  }

  void clearMissingProperties() {
    if (state.missingPropertiesToConfirm == null &&
        state.channelPropertiesToReview == null) {
      return;
    }
    emit(state.copyWith(clearMissingProperties: true));
  }

  Future<void> refresh() async {
    final userId = _currentUserProvider.currentUserId;
    await bootstrap(userId: userId);
  }

  Future<void> _saveSettings(
    UserSettings updated, {
    required UserSettingsToast toast,
  }) async {
    emit(state.copyWith(status: UserSettingsStatus.saving));
    try {
      final saved = await _userSettingsRepository.save(updated);
      _settingsCubit.load(forceRefresh: true);
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          settings: saved,
          toast: toast,
          errorMessage: null,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          errorMessage: error.toString(),
          domainError: DomainError.from(error, stack: stack),
          clearToast: true,
        ),
      );
    }
  }

  Future<void> _completeSync(UserSettings settings) async {
    final updated = settings.copyWith(lodgifyLastSyncedAt: DateTime.now());
    try {
      final saved = await _userSettingsRepository.save(updated);
      _settingsCubit.load(forceRefresh: true);
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          settings: saved,
          toast: const UserSettingsToast(
            type: UserSettingsToastType.success,
            message: UserSettingsToastMessage.lodgifySyncCompleted,
          ),
          errorMessage: null,
          clearMissingProperties: true,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          errorMessage: error.toString(),
          domainError: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  bool get _isBusy =>
      state.status == UserSettingsStatus.saving ||
      state.status == UserSettingsStatus.connecting ||
      state.status == UserSettingsStatus.syncing;
}
