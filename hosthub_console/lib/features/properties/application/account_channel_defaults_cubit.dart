import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/properties/data/account_channel_defaults_repository.dart';
import 'package:hosthub_console/features/properties/domain/account_channel_defaults.dart';
import 'package:hosthub_console/features/properties/domain/account_settings.dart';

enum AccountChannelDefaultsStatus { initial, loading, loaded, saving, error }

class AccountChannelDefaultsState extends Equatable {
  const AccountChannelDefaultsState({
    this.status = AccountChannelDefaultsStatus.initial,
    this.defaults = AccountChannelDefaults.empty,
    this.settings = AccountSettings.defaults,
    this.ownerProfileId,
    this.error,
  });

  final AccountChannelDefaultsStatus status;

  /// What every property inherits unless it says otherwise. Zeroes until the
  /// first load, which reads as "no fee" — briefly wrong is better than a
  /// number from another account.
  final AccountChannelDefaults defaults;

  /// The account's non-channel settings — the languages a new property starts
  /// with, and the number on the invoice.
  final AccountSettings settings;

  final String? ownerProfileId;
  final DomainError? error;

  /// Whether this user may change the account tier at all.
  ///
  /// Only the owner can; a `beheerder` reads the defaults (every payout figure
  /// resolves through them) but deviates per property instead.
  bool get canEdit => ownerProfileId != null;

  bool get isBusy =>
      status == AccountChannelDefaultsStatus.loading ||
      status == AccountChannelDefaultsStatus.saving;

  AccountChannelDefaultsState copyWith({
    AccountChannelDefaultsStatus? status,
    AccountChannelDefaults? defaults,
    AccountSettings? settings,
    String? ownerProfileId,
    DomainError? error,
    bool clearError = false,
  }) {
    return AccountChannelDefaultsState(
      status: status ?? this.status,
      defaults: defaults ?? this.defaults,
      settings: settings ?? this.settings,
      ownerProfileId: ownerProfileId ?? this.ownerProfileId,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    defaults.toMap(),
    settings,
    ownerProfileId,
    error,
  ];
}

/// The account tier, held once for the whole shell.
///
/// The rail's override badges, the properties list, Prijzen and Standaardwaarden
/// all resolve through the same defaults; loading them per screen is how two
/// screens end up disagreeing about what a property inherits.
class AccountChannelDefaultsCubit extends Cubit<AccountChannelDefaultsState> {
  AccountChannelDefaultsCubit({
    required AccountChannelDefaultsRepository repository,
    required AuthPort authPort,
  }) : _repository = repository,
       super(const AccountChannelDefaultsState()) {
    // This cubit loads the moment the shell is entered, which can land inside
    // the same beat as a Supabase token refresh (app start, another tab
    // rotating the refresh token). That read fails with a transient
    // unauthorized DomainError — see SupabaseRepository.currentUserId — that
    // self-heals as soon as a session is back. Re-priming on every session
    // event, the same way SessionBlocListeners does for the app-root cubits,
    // closes that gap instead of leaving the tier stuck on an error card.
    _authSubscription = authPort.onAuthStateChange.listen((change) {
      if (change.user == null) return;
      if (state.status == AccountChannelDefaultsStatus.error) load();
    });
  }

  final AccountChannelDefaultsRepository _repository;
  late final StreamSubscription<AuthSessionChange> _authSubscription;

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  Future<void> load() async {
    if (state.status == AccountChannelDefaultsStatus.loading) return;
    emit(
      state.copyWith(
        status: AccountChannelDefaultsStatus.loading,
        clearError: true,
      ),
    );
    try {
      final ownerProfileId = await _repository.currentAccountOwnerId();
      if (isClosed) return;
      if (ownerProfileId == null) {
        // No account resolved yet — a user who has neither a site nor an
        // invitation. Empty defaults, not an error.
        emit(state.copyWith(status: AccountChannelDefaultsStatus.loaded));
        return;
      }
      final defaults = await _repository.fetch(ownerProfileId);
      final settings = await _repository.fetchAccountSettings(ownerProfileId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AccountChannelDefaultsStatus.loaded,
          defaults: defaults,
          settings: settings,
          ownerProfileId: ownerProfileId,
        ),
      );
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AccountChannelDefaultsStatus.error,
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// Apply a draft. One write, and every property that follows sees it.
  Future<bool> save(AccountChannelDefaults defaults) async {
    final ownerProfileId = state.ownerProfileId;
    if (ownerProfileId == null) return false;

    emit(
      state.copyWith(
        status: AccountChannelDefaultsStatus.saving,
        clearError: true,
      ),
    );
    try {
      final saved = await _repository.save(
        ownerProfileId: ownerProfileId,
        defaults: defaults,
      );
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: AccountChannelDefaultsStatus.loaded,
          defaults: saved,
        ),
      );
      return true;
    } catch (error, stack) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: AccountChannelDefaultsStatus.loaded,
          error: DomainError.from(error, stack: stack),
        ),
      );
      return false;
    }
  }

  /// Apply a change to the account's non-channel settings.
  Future<bool> saveSettings(AccountSettings settings) async {
    final ownerProfileId = state.ownerProfileId;
    if (ownerProfileId == null) return false;

    emit(
      state.copyWith(
        status: AccountChannelDefaultsStatus.saving,
        clearError: true,
      ),
    );
    try {
      final saved = await _repository.saveAccountSettings(
        ownerProfileId: ownerProfileId,
        settings: settings,
      );
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: AccountChannelDefaultsStatus.loaded,
          settings: saved,
        ),
      );
      return true;
    } catch (error, stack) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: AccountChannelDefaultsStatus.loaded,
          error: DomainError.from(error, stack: stack),
        ),
      );
      return false;
    }
  }

  void clearError() {
    if (state.error == null) return;
    emit(state.copyWith(clearError: true));
  }
}
