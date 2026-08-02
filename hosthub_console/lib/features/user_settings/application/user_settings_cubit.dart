import 'package:app_errors/app_errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/features/channel_manager/domain/channel_manager_repository.dart';
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

  /// Caches the plaintext resolved by [revealChannelApiKey], so re-showing
  /// or re-copying the key after it auto-hides is instant instead of paying
  /// for another round trip to the server for a value that has not changed.
  String? _revealedApiKeyCache;

  void reset() {
    _revealedApiKeyCache = null;
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

  /// Remember which properties a portfolio screen is filtered to.
  ///
  /// Saved without a toast: a filter is a view preference, and confirming every
  /// checkbox would be noise. It is stored per page, so Boekingen and Omzet keep
  /// their own selection.
  Future<void> changePortfolioScope(Map<String, List<int>> scope) async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;
    if (_scopesEqual(settings.portfolioScope, scope)) return;

    await _saveSettings(settings.copyWith(portfolioScope: scope));
  }

  static bool _scopesEqual(
    Map<String, List<int>>? a,
    Map<String, List<int>>? b,
  ) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null || other.length != entry.value.length) return false;
      for (var index = 0; index < other.length; index++) {
        if (other[index] != entry.value[index]) return false;
      }
    }
    return true;
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
    required String exportPdfOrientation,
  }) async {
    final settings = state.settings;
    if (settings == null) return;
    if (_isBusy) return;

    final langSame = settings.exportLanguageCode == exportLanguageCode;
    final colsSame = _listEquals(settings.exportColumns, exportColumns);
    final orientationSame =
        settings.exportPdfOrientation == exportPdfOrientation;
    if (langSame && colsSame && orientationSame) return;

    final updated = settings.copyWith(
      exportLanguageCode: exportLanguageCode,
      exportColumns: exportColumns,
      exportPdfOrientation: exportPdfOrientation,
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
      _revealedApiKeyCache = null;
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

    _revealedApiKeyCache = null;
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

  /// Resolves the user's own channel API key so the settings screen can show it.
  ///
  /// Returns `null` on failure and puts the [DomainError] in state, which is the
  /// contract the secret tile expects: the tile stays masked and the page's
  /// error listener reports why.
  Future<String?> revealChannelApiKey() async {
    final settings = state.settings;
    if (settings == null) return null;

    final cached = _revealedApiKeyCache;
    if (cached != null) return cached;

    try {
      final revealed = await _channelManagerRepository.revealApiKey();
      _revealedApiKeyCache = revealed;
      return revealed;
    } catch (error, stack) {
      emit(
        state.copyWith(
          domainError: DomainError.from(
            error,
            stack: stack,
            context: const {'lodgify_action': 'reveal_api_key'},
          ),
        ),
      );
      return null;
    }
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

  /// Ask Lodgify what it has, and resolve it against the properties we hold.
  ///
  /// Writes nothing: the outcome lands in [UserSettingsState.syncPlan] so the
  /// owner sees what applying would create and what it would link before it
  /// happens.
  Future<void> syncLodgify({bool allowWhenBusy = false}) async {
    final settings = state.settings;
    if (settings == null || !settings.lodgifyConnected) return;
    if (_isBusy && !allowWhenBusy) return;

    emit(state.copyWith(status: UserSettingsStatus.syncing));
    try {
      final listings = await _channelManagerRepository.fetchProperties();
      final existing = await _propertyRepository.fetchProperties();
      final plan = LodgifySyncPlan.from(
        listings: listings,
        properties: existing,
      );
      // Lodgify answered, so this *is* the last successful sync — whether or
      // not the owner applies what it found. Stamping it only after applying
      // made a sync that found nothing look like a sync that never ran.
      final saved = await _userSettingsRepository.save(
        settings.copyWith(lodgifyLastSyncedAt: DateTime.now()),
      );
      _settingsCubit.load(forceRefresh: true);
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          settings: saved,
          syncPlan: plan,
          errorMessage: null,
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

  /// Create what the plan says is new, link what it says already exists here.
  ///
  /// Returns how many properties were added or linked, so the caller can say it
  /// and point at the list. A plan with nothing to do only stamps the sync time.
  Future<int> applySyncPlan() async {
    final settings = state.settings;
    final plan = state.syncPlan;
    if (settings == null || plan == null) return 0;
    if (_isBusy) return 0;

    emit(state.copyWith(status: UserSettingsStatus.syncing));
    try {
      for (final entry in plan.toCreate) {
        await _propertyRepository.createProperty(
          name: entry.label,
          lodgifyId: entry.listing.id,
        );
      }
      for (final entry in plan.toLink) {
        final existing = entry.existing;
        final lodgifyId = entry.listing.id;
        if (existing == null || lodgifyId == null) continue;
        await _propertyRepository.setLodgifyLink(
          propertyId: existing.id,
          lodgifyId: lodgifyId,
        );
      }
      // No toast from here: the caller knows how many properties this touched
      // and can point at them, which a fixed sentence cannot.
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          errorMessage: null,
          clearSyncPlan: true,
        ),
      );
      return plan.changeCount;
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: UserSettingsStatus.ready,
          errorMessage: error.toString(),
          domainError: DomainError.from(error, stack: stack),
        ),
      );
      return 0;
    }
  }

  /// Walk away from a plan without applying it. The sync itself already counted
  /// as successful, so the stamp stays where [syncLodgify] put it.
  void dismissSyncPlan() {
    if (state.syncPlan == null) return;
    emit(state.copyWith(status: UserSettingsStatus.ready, clearSyncPlan: true));
  }

  void clearToast() {
    if (state.toast == null) return;
    emit(state.copyWith(clearToast: true));
  }

  void clearError() {
    if (state.domainError == null) return;
    emit(state.copyWith(clearDomainError: true));
  }

  Future<void> refresh() async {
    final userId = _currentUserProvider.currentUserId;
    await bootstrap(userId: userId);
  }

  /// [toast] is optional: a preference the user did not ask to be confirmed —
  /// a view filter — saves silently.
  Future<void> _saveSettings(
    UserSettings updated, {
    UserSettingsToast? toast,
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
          clearToast: toast == null,
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

  bool get _isBusy =>
      state.status == UserSettingsStatus.saving ||
      state.status == UserSettingsStatus.connecting ||
      state.status == UserSettingsStatus.syncing;
}
