import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/core/models/models.dart';

import 'package:hosthub_console/features/users/data/admin_user_repository.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';

enum UsersStatus { initial, loading, ready, error }

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  final UsersStatus status;
  final List<Profile> users;
  final String searchQuery;
  final String? errorMessage;

  bool get isLoadingList => status == UsersStatus.loading;

  @override
  List<Object?> get props => [status, users, searchQuery, errorMessage];

  UsersState copyWith({
    UsersStatus? status,
    List<Profile>? users,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    final nextUsers = users ?? this.users;
    final effectiveError = clearError
        ? null
        : (errorMessage ?? this.errorMessage);

    return UsersState(
      status: status ?? this.status,
      users: List<Profile>.unmodifiable(nextUsers),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: effectiveError,
    );
  }
}

class UsersCubit extends Cubit<UsersState> {
  UsersCubit({required AdminUserRepository repository})
    : _repository = repository,
      super(const UsersState());

  final AdminUserRepository _repository;
  bool _hasLoadedOnce = false;
  bool _isLoading = false;

  Future<void> ensureLoaded() async {
    if (_hasLoadedOnce || _isLoading) return;
    await loadUsers();
  }

  Future<void> loadUsers({String? query}) async {
    if (_isLoading) return;
    final trimmedQuery = query?.trim();
    final effectiveQuery = trimmedQuery ?? state.searchQuery;

    _isLoading = true;
    emit(
      state.copyWith(
        status: UsersStatus.loading,
        searchQuery: effectiveQuery,
        clearError: true,
      ),
    );

    try {
      final result = await _repository.fetchProfiles(
        searchQuery: effectiveQuery.isEmpty ? null : effectiveQuery,
      );
      _hasLoadedOnce = true;
      emit(
        state.copyWith(
          status: UsersStatus.ready,
          users: List<Profile>.unmodifiable(result),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UsersStatus.error,
          errorMessage: S.current.loadUsersFailed('$error'),
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  void reset() {
    _hasLoadedOnce = false;
    _isLoading = false;
    emit(const UsersState());
  }
}
