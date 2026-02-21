import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/shared/models/models.dart';
import 'package:hosthub_console/core/lifecycle/session_manager.dart';
import 'package:hosthub_console/features/profile/data/profile_repository.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  requiresSignOut,
  error,
}

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.error,
  });

  final ProfileStatus status;
  final Profile? profile;
  final DomainError? error;

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    DomainError? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, profile, error];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required SessionManager sessionManager,
    required ProfileRepository profileRepository,
  }) : _sessionManager = sessionManager,
       _profileRepository = profileRepository,
       super(const ProfileState());

  final SessionManager _sessionManager;
  final ProfileRepository _profileRepository;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, error: null));
    await _sessionManager.ensureFreshSession();

    try {
      var profile = await _profileRepository.getProfile();

      if (profile == null) {
        final user = _sessionManager.currentUser;
        if (user == null) {
          throw DomainErrorCode.unauthorized.err(
            reason: DomainErrorReason.cannotLoadData,
            message: 'No authenticated user available for profile creation.',
          );
        }

        final newProfile = Profile(
          id: user.id,
          email: user.email ?? '',
          createdBy: user.id,
        );

        await _profileRepository.updateProfile(newProfile);
        profile = newProfile;
      }

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          error: null,
        ),
      );
    } on DomainError catch (error) {
      if (await _handleAuthConstraint(error)) {
        emit(
          state.copyWith(status: ProfileStatus.requiresSignOut, error: error),
        );
        return;
      }
      emit(state.copyWith(status: ProfileStatus.error, error: error));
    }
  }

  Future<void> updateProfile(Profile profile) async {
    emit(state.copyWith(status: ProfileStatus.updating, error: null));
    await _sessionManager.ensureFreshSession();

    try {
      await _profileRepository.updateProfile(profile);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          error: null,
        ),
      );
    } on DomainError catch (error) {
      if (await _handleAuthConstraint(error)) {
        emit(
          state.copyWith(status: ProfileStatus.requiresSignOut, error: error),
        );
        return;
      }
      emit(state.copyWith(status: ProfileStatus.error, error: error));
    }
  }

  void reset() {
    emit(const ProfileState());
  }

  Future<bool> _handleAuthConstraint(DomainError error) async {
    if (!_isMissingAuthUserForeignKey(error)) {
      return false;
    }

    await _sessionManager.signOutSilently();
    return true;
  }

  bool _isMissingAuthUserForeignKey(DomainError error) {
    bool containsProfileFk(String? value) {
      if (value == null || value.isEmpty) return false;
      final normalized = value.toLowerCase();
      return normalized.contains('profiles_id_fkey') ||
          (normalized.contains('auth.users') &&
              normalized.contains('not present'));
    }

    final context = error.context;
    final postgrestCode = context?['postgrest_code']?.toString();
    if (postgrestCode != null && postgrestCode != '23503') {
      return false;
    }

    if (containsProfileFk(error.message)) return true;

    if (context != null) {
      for (final entry in context.entries) {
        final value = entry.value;
        if (value == null) continue;
        if (containsProfileFk(value.toString())) return true;
      }
    }

    if (containsProfileFk(error.cause?.toString())) return true;
    if (containsProfileFk(error.rootCause?.toString())) return true;

    return false;
  }
}
