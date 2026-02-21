import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';

enum ServerSettingsStatus { initial, loading, ready, mutating, error }

class ServerSettingsState extends Equatable {
  const ServerSettingsState({
    this.settings,
    this.status = ServerSettingsStatus.initial,
    this.error,
  });

  const ServerSettingsState.initial()
    : settings = null,
      status = ServerSettingsStatus.initial,
      error = null;

  final AdminSettings? settings;
  final ServerSettingsStatus status;
  final DomainError? error;

  ServerSettingsState copyWith({
    AdminSettings? settings,
    ServerSettingsStatus? status,
    DomainError? error,
  }) {
    final effectiveStatus = status ?? this.status;
    final suppliedError = error ?? this.error;
    final shouldClearError =
        status != null && status != this.status && error == null;
    final effectiveError = shouldClearError ? null : suppliedError;
    return ServerSettingsState(
      settings: settings ?? this.settings,
      status: effectiveStatus,
      error: effectiveError,
    );
  }

  @override
  List<Object?> get props => [settings, status, error];
}

class ServerSettingsCubit extends Cubit<ServerSettingsState> {
  ServerSettingsCubit(this._repository)
    : super(const ServerSettingsState.initial());

  final AdminSettingsRepository _repository;

  Future<void> load() async {
    if (state.status == ServerSettingsStatus.loading ||
        state.status == ServerSettingsStatus.mutating) {
      return;
    }
    emit(state.copyWith(status: ServerSettingsStatus.loading, error: null));
    try {
      final settings = await _repository.load(forceRefresh: true);
      emit(
        state.copyWith(status: ServerSettingsStatus.ready, settings: settings),
      );
    } catch (error, stack) {
      final domainError = DomainError.from(error, stack: stack);
      emit(
        state.copyWith(status: ServerSettingsStatus.error, error: domainError),
      );
    }
  }

  Future<void> save(AdminSettings settings) async {
    emit(state.copyWith(status: ServerSettingsStatus.mutating, error: null));
    try {
      final saved = await _repository.save(settings);
      emit(state.copyWith(status: ServerSettingsStatus.ready, settings: saved));
    } catch (error, stack) {
      final domainError = DomainError.from(error, stack: stack);
      emit(
        state.copyWith(status: ServerSettingsStatus.error, error: domainError),
      );
    }
  }
}
