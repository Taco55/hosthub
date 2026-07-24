import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';

enum SiteContextStatus { initial, loading, loaded, error }

/// The site belonging to the currently selected property, resolved with the
/// same name-matching the sites page uses. Exposes the site's source language
/// (`default_locale`) for the rail's source-language switcher.
class SiteContextState extends Equatable {
  const SiteContextState({
    this.status = SiteContextStatus.initial,
    this.site,
    this.error,
  });

  final SiteContextStatus status;
  final SiteSummary? site;
  final DomainError? error;

  SiteContextState copyWith({
    SiteContextStatus? status,
    SiteSummary? site,
    DomainError? error,
    bool clearError = false,
  }) =>
      SiteContextState(
        status: status ?? this.status,
        site: site ?? this.site,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [status, site?.id, site?.defaultLocale, error];
}

class SiteContextCubit extends Cubit<SiteContextState> {
  SiteContextCubit({
    required CmsRepository cmsRepository,
    required PropertyContextCubit propertyContext,
  })  : _cmsRepository = cmsRepository,
        _propertyContext = propertyContext,
        super(const SiteContextState()) {
    _propertySub = _propertyContext.stream.listen((_) => resolve());
    resolve();
  }

  final CmsRepository _cmsRepository;
  final PropertyContextCubit _propertyContext;
  late final StreamSubscription<PropertyContextState> _propertySub;
  int _fetchSeq = 0;

  Future<void> resolve() async {
    final seq = ++_fetchSeq;
    emit(state.copyWith(status: SiteContextStatus.loading, clearError: true));
    try {
      final sites = await _cmsRepository.fetchSites();
      if (seq != _fetchSeq) return; // Stale — a newer resolve superseded us.
      if (sites.isEmpty) {
        emit(const SiteContextState(status: SiteContextStatus.loaded));
        return;
      }
      final property = _propertyContext.state.currentProperty;
      emit(
        SiteContextState(
          status: SiteContextStatus.loaded,
          site: _resolvePreferredSite(sites, property?.name),
        ),
      );
    } catch (error, stack) {
      if (seq != _fetchSeq) return;
      emit(
        state.copyWith(
          status: SiteContextStatus.error,
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// Changes the site's source language (`sites.default_locale`).
  Future<void> setSourceLanguage(String locale) async {
    final site = state.site;
    if (site == null || site.defaultLocale == locale) return;
    try {
      await _cmsRepository.updateSiteDefaultLocale(site.id, locale);
      await resolve();
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: SiteContextStatus.error,
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// Same matching as SitesPage._resolvePreferredSite: exact normalized name,
  /// then substring overlap, then the first site.
  static SiteSummary _resolvePreferredSite(
    List<SiteSummary> sites,
    String? propertyName,
  ) {
    final normalizedProperty = _normalize(propertyName ?? '');
    if (normalizedProperty.isEmpty) return sites.first;

    for (final site in sites) {
      if (_normalize(site.name) == normalizedProperty) return site;
    }
    for (final site in sites) {
      final normalizedSite = _normalize(site.name);
      if (normalizedSite.contains(normalizedProperty) ||
          normalizedProperty.contains(normalizedSite)) {
        return site;
      }
    }
    return sites.first;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  @override
  Future<void> close() async {
    await _propertySub.cancel();
    return super.close();
  }
}
