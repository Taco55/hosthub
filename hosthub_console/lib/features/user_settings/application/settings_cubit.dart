import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/shared/models/models.dart';

import 'package:hosthub_console/features/user_settings/data/user_settings_repository.dart';
import 'package:hosthub_console/features/user_settings/domain/current_user_provider.dart';

enum SettingsStatus { initial, loading, ready, error }

class SettingsState extends Equatable {
  const SettingsState({
    this.settings,
    this.status = SettingsStatus.initial,
    this.error,
  });

  const SettingsState.initial()
    : settings = null,
      status = SettingsStatus.initial,
      error = null;

  final UserSettings? settings;
  final SettingsStatus status;
  final DomainError? error;

  SettingsState copyWith({
    UserSettings? settings,
    SettingsStatus? status,
    DomainError? error,
  }) {
    final effectiveStatus = status ?? this.status;
    final suppliedError = error ?? this.error;
    final shouldClearError =
        status != null && status != this.status && error == null;
    final effectiveError = shouldClearError ? null : suppliedError;
    return SettingsState(
      settings: settings ?? this.settings,
      status: effectiveStatus,
      error: effectiveError,
    );
  }

  @override
  List<Object?> get props => [settings, status, error];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required UserSettingsRepository repository,
    required CurrentUserProvider currentUserProvider,
  }) : _repository = repository,
       _currentUserProvider = currentUserProvider,
      super(const SettingsState.initial());

  final UserSettingsRepository _repository;
  final CurrentUserProvider _currentUserProvider;

  Future<void> load({bool forceRefresh = false}) async {
    if (state.status == SettingsStatus.loading) return;
    emit(state.copyWith(status: SettingsStatus.loading, error: null));
    try {
      final userId = _currentUserProvider.currentUserId;
      final settings = await _repository.loadOrCreateDefaults(
        userId,
        forceRefresh: forceRefresh,
      );
      emit(state.copyWith(status: SettingsStatus.ready, settings: settings));
    } catch (error, stack) {
      final domainError = DomainError.from(error, stack: stack);
      emit(state.copyWith(status: SettingsStatus.error, error: domainError));
    }
  }

  void reset() {
    emit(const SettingsState.initial());
  }
}
