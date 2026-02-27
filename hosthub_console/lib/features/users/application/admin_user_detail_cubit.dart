import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';

import 'package:hosthub_console/features/users/data/admin_user_repository.dart';
import 'package:hosthub_console/features/users/domain/models/admin_user_detail.dart';
import 'package:app_errors/app_errors.dart';

const _copyWithSentinel = Object();

class AdminUserDetailState extends Equatable {
  const AdminUserDetailState({
    this.detail,
    this.isLoading = false,
    this.isToggling = false,
    this.isMutating = false,
    this.appError,
  });

  const AdminUserDetailState.initial()
    : detail = null,
      isLoading = false,
      isToggling = false,
      isMutating = false,
      appError = null;

  final AdminUserDetail? detail;
  final bool isLoading;
  final bool isToggling;
  final bool isMutating;
  final AppError? appError;

  AdminUserDetailState copyWith({
    Object? detail = _copyWithSentinel,
    bool? isLoading,
    bool? isToggling,
    bool? isMutating,
    Object? appError = _copyWithSentinel,
  }) {
    return AdminUserDetailState(
      detail: identical(detail, _copyWithSentinel)
          ? this.detail
          : detail as AdminUserDetail?,
      isLoading: isLoading ?? this.isLoading,
      isToggling: isToggling ?? this.isToggling,
      isMutating: isMutating ?? this.isMutating,
      appError: identical(appError, _copyWithSentinel)
          ? this.appError
          : appError as AppError?,
    );
  }

  @override
  List<Object?> get props => [
    detail,
    isLoading,
    isToggling,
    isMutating,
    appError,
  ];
}

class AdminUserDetailCubit extends Cubit<AdminUserDetailState> {
  AdminUserDetailCubit({
    required AdminUserRepository repository,
    required String userId,
  }) : _repository = repository,
       _userId = userId,
       super(const AdminUserDetailState.initial());

  final AdminUserRepository _repository;
  final String _userId;

  Future<void> load() async {
    if (state.isLoading) {
      return;
    }
    emit(state.copyWith(isLoading: true, appError: null));
    try {
      final detail = await _repository.fetchUserDetail(_userId);
      emit(state.copyWith(detail: detail, isLoading: false));
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          isLoading: false,
          appError: _buildAppError(
            error: error,
            stackTrace: stackTrace,
            alert: S.current.loadUserFailedMessage,
          ),
        ),
      );
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(detail: null));
    await load();
  }

  Future<bool> toggleAdmin(bool value) async {
    final detail = state.detail;
    if (detail == null || state.isToggling) return false;
    emit(state.copyWith(isToggling: true, appError: null));
    try {
      final updated = await _repository.updateAdminFlag(
        detail.profile.id,
        value,
      );
      emit(
        state.copyWith(
          isToggling: false,
          detail: detail.copyWith(profile: updated),
        ),
      );
      return true;
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          isToggling: false,
          appError: _buildAppError(
            error: error,
            stackTrace: stackTrace,
            alert: S.current.toggleAdminFailed('$error'),
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> updateProfile({required String email, String? username}) async {
    final detail = state.detail;
    if (detail == null || state.isMutating) return false;
    emit(state.copyWith(isMutating: true, appError: null));
    try {
      final updated = await _repository.updateProfileDetails(
        detail.profile.id,
        email: email,
        username: username,
      );
      emit(
        state.copyWith(
          isMutating: false,
          detail: detail.copyWith(profile: updated),
        ),
      );
      return true;
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          isMutating: false,
          appError: _buildAppError(
            error: error,
            stackTrace: stackTrace,
            alert: S.current.updateProfileFailed('$error'),
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    final detail = state.detail;
    if (detail == null || state.isMutating) return false;
    emit(state.copyWith(isMutating: true, appError: null));
    try {
      await _repository.updatePassword(detail.profile.id, newPassword);
      emit(state.copyWith(isMutating: false));
      return true;
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          isMutating: false,
          appError: _buildAppError(
            error: error,
            stackTrace: stackTrace,
            alert: S.current.passwordChangeFailedWithReason('$error'),
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> deleteUser() async {
    final detail = state.detail;
    if (detail == null || state.isMutating) return false;
    emit(state.copyWith(isMutating: true, appError: null));
    try {
      await _repository.deleteUser(detail.profile.id);
      emit(state.copyWith(isMutating: false, detail: null));
      return true;
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          isMutating: false,
          appError: _buildAppError(
            error: error,
            stackTrace: stackTrace,
            alert: S.current.userDeleteFailedWithReason('$error'),
          ),
        ),
      );
      return false;
    }
  }

  AppError _buildAppError({
    required Object error,
    required StackTrace stackTrace,
    required String alert,
  }) {
    final domainError = error is DomainError
        ? error
        : DomainError.from(error, stack: stackTrace);
    return AppError(
      title: S.current.error,
      alert: alert,
      domainError: domainError,
      requiresLogout: domainError.logout == true,
    );
  }
}
