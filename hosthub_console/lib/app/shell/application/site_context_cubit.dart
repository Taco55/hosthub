import 'dart:async';

import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';

enum SiteContextStatus { initial, loading, loaded, error }

/// Language codes a site can offer, mirroring the design handoff catalog.
/// Adding one here makes it appear in Settings → "Add language".
const List<String> kSiteLanguageCatalog = [
  'nl', 'en', 'no', 'de', 'fr', 'sv', 'da', 'es', 'it', 'pl', 'fi', //
];

/// The site belonging to the currently selected property, resolved with the
/// same name-matching the sites page uses. Owns the property-scope site
/// settings shown on the Settings page: the source language
/// (`default_locale`, strictly independent from the per-user interface
/// language), the enabled website languages, and the site-details values
/// (name, primary domain, booking link).
class SiteContextState extends Equatable {
  const SiteContextState({
    this.status = SiteContextStatus.initial,
    this.site,
    this.primaryDomain,
    this.bookingUrl,
    this.error,
  });

  final SiteContextStatus status;
  final SiteSummary? site;

  /// Primary public domain (`site_domains.is_primary`), null when unset.
  final String? primaryDomain;

  /// Booking link from the site-config content, shared across languages.
  final String? bookingUrl;

  final DomainError? error;

  /// Catalog languages the site does not offer yet (Settings → Add language).
  List<String> get addableLanguages {
    final enabled = site?.locales ?? const <String>[];
    return [
      for (final code in kSiteLanguageCatalog)
        if (!enabled.contains(code)) code,
    ];
  }

  SiteContextState copyWith({
    SiteContextStatus? status,
    SiteSummary? site,
    String? primaryDomain,
    String? bookingUrl,
    DomainError? error,
    bool clearError = false,
  }) => SiteContextState(
    status: status ?? this.status,
    site: site ?? this.site,
    primaryDomain: primaryDomain ?? this.primaryDomain,
    bookingUrl: bookingUrl ?? this.bookingUrl,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [
    status,
    site?.id,
    site?.name,
    site?.defaultLocale,
    site?.locales,
    primaryDomain,
    bookingUrl,
    error,
  ];
}

class SiteContextCubit extends Cubit<SiteContextState> {
  SiteContextCubit({
    required CmsRepository cmsRepository,
    required PropertyContextCubit propertyContext,
  }) : _cmsRepository = cmsRepository,
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
      final site = _resolvePreferredSite(sites, property?.name);

      String? primaryDomain;
      String? bookingUrl;
      try {
        final results = await Future.wait([
          _cmsRepository.fetchPrimaryDomain(site.id),
          _fetchBookingUrl(site),
        ]);
        primaryDomain = results[0];
        bookingUrl = results[1];
      } on DomainError {
        // Site details are decorative on the Settings page; the site context
        // itself (source language, locales) must survive their failure.
      }
      if (seq != _fetchSeq) return;

      emit(
        SiteContextState(
          status: SiteContextStatus.loaded,
          site: site,
          primaryDomain: primaryDomain,
          bookingUrl: bookingUrl,
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
    await _guard(() async {
      await _cmsRepository.updateSiteDefaultLocale(site.id, locale);
      await resolve();
    });
  }

  /// Adds a catalog language to the site's enabled website languages.
  Future<void> addLanguage(String code) async {
    final site = state.site;
    if (site == null || site.locales.contains(code)) return;
    await _guard(() async {
      await _cmsRepository.updateSiteLocales(site.id, [...site.locales, code]);
      await resolve();
    });
  }

  /// Removes an enabled language. The source language cannot be removed.
  /// Stored translations are kept, so re-adding the language restores them.
  Future<void> removeLanguage(String code) async {
    final site = state.site;
    if (site == null ||
        code == site.defaultLocale ||
        !site.locales.contains(code)) {
      return;
    }
    await _guard(() async {
      await _cmsRepository.updateSiteLocales(site.id, [
        for (final locale in site.locales)
          if (locale != code) locale,
      ]);
      await resolve();
    });
  }

  /// Renames the property/site (Settings → Site details).
  Future<void> setSiteName(String name) async {
    final site = state.site;
    final trimmed = name.trim();
    if (site == null || trimmed.isEmpty || site.name == trimmed) return;
    await _guard(() async {
      await _cmsRepository.updateSiteName(site.id, trimmed);
      await resolve();
    });
  }

  /// Updates the booking link in every language's site-config document — the
  /// link is shared infrastructure, not translated content.
  Future<void> setBookingUrl(String url) async {
    final site = state.site;
    final trimmed = url.trim();
    if (site == null || trimmed == (state.bookingUrl ?? '')) return;
    await _guard(() async {
      final docs = await _cmsRepository.fetchSiteDocuments(
        siteId: site.id,
        contentType: 'site_config',
      );
      for (final doc in docs) {
        await _cmsRepository.updateDocumentContent(
          documentId: doc.id,
          content: {...doc.content, 'bookingUrl': trimmed},
        );
      }
      await resolve();
    });
  }

  void clearError() => emit(state.copyWith(clearError: true));

  Future<String?> _fetchBookingUrl(SiteSummary site) async {
    final docs = await _cmsRepository.fetchSiteDocuments(
      siteId: site.id,
      locale: site.defaultLocale,
      contentType: 'site_config',
    );
    if (docs.isEmpty) return null;
    final value = docs.first.content['bookingUrl'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
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
