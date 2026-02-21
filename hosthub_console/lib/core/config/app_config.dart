import 'app_environment.dart';

// ------- compile-time env (literal keys only) -------
// Note: requires full restart when values change.
const kSupabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const kSupabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);
const kSupabaseKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');
const kGoogleApiKey = String.fromEnvironment(
  'GOOGLE_API_KEY',
  defaultValue: '',
);
const kPlacesGoogleApiKey = String.fromEnvironment(
  'PLACES_GOOGLE_API_KEY',
  defaultValue: '',
);
const kAdminBaseUrl = String.fromEnvironment(
  'ADMIN_BASE_URL',
  defaultValue: '',
);
const kLodgifyBaseUrl = String.fromEnvironment(
  'LODGIFY_BASE_URL',
  defaultValue: 'https://api.lodgify.com',
);
const kTestFlightUrl = String.fromEnvironment(
  'TESTFLIGHT_URL',
  defaultValue: '',
);
const kCmsPreviewDomain = String.fromEnvironment(
  'CMS_PREVIEW_DOMAIN',
  defaultValue: '',
);

const _isProductBuild = bool.fromEnvironment('dart.vm.product');

class AppConfig {
  final AppEnvironment environment;
  final String clientAppKey;
  final String deepLinkScheme;

  final Uri supabaseUrl;
  final String supabaseAnonKey;
  final String googleApiKey;
  final String placesApiKey;
  final Uri? adminBaseUrl;
  final Uri lodgifyBaseUrl;
  final Uri? testFlightUrl;

  /// Enables developer-only UI affordances (e.g. settings section, debug details in error modals).
  final bool enableDevTools;

  /// Whether Firebase is allowed to initialize; used to disable it for certain apps/envs.
  final bool enableFirebase;

  /// If false, auth errors show inline instead of modal dialogs.
  final bool authErrorsInDialog;

  /// Allows showing captured magic links locally; disabled in product builds.
  final bool enableMagicLinkPreview;

  /// Controls Bloc observer logging; typically tied to kDebugMode.
  final bool enableLogging;

  /// Controls API request/response logging for Dio clients.
  final bool enableApiLogger;

  /// Controls GoRouter debug logging; defaults to [enableLogging].
  final bool enableRouterLogging;

  final String supportEmail;
  final String themeScheme;

  AppConfig._({
    required this.environment,
    required this.clientAppKey,
    required this.deepLinkScheme,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleApiKey,
    required this.placesApiKey,
    required this.adminBaseUrl,
    required this.lodgifyBaseUrl,
    required this.testFlightUrl,
    required this.enableDevTools,
    required this.enableFirebase,
    required this.authErrorsInDialog,
    required this.enableMagicLinkPreview,
    required this.enableLogging,
    required this.enableApiLogger,
    required this.enableRouterLogging,
    required this.supportEmail,
    required this.themeScheme,
  });

  static AppConfig? _instance;
  static AppConfig get current {
    final v = _instance;
    if (v == null) {
      throw StateError('Call AppConfig.initialize first.');
    }
    return v;
  }

  static void initialize({
    required String clientAppKey,
    String? deepLinkScheme,
    AppEnvironment? environment,
    bool? enableDevTools,
    bool? enableFirebase,
    bool? authErrorsInDialog,
    bool? enableMagicLinkPreview,
    bool? enableLogging,
    bool? enableApiLogger,
    bool? enableRouterLogging,
  }) {
    if (_instance != null) throw StateError('AppConfig already initialized.');

    final env = environment ?? AppEnvironment.fromEnvironment();
    final defaults = switch (env) {
      AppEnvironment.dev => (
        enableDevTools: true,
        enableFirebase: false,
        authErrorsInDialog: true,
        enableMagicLinkPreview: true,
        enableLogging: true,
        enableApiLogger: true,
        enableRouterLogging: true,
      ),
      AppEnvironment.stg => (
        enableDevTools: true,
        enableFirebase: true,
        authErrorsInDialog: true,
        enableMagicLinkPreview: true,
        enableLogging: true,
        enableApiLogger: true,
        enableRouterLogging: true,
      ),
      AppEnvironment.prd => (
        enableDevTools: false,
        enableFirebase: true,
        authErrorsInDialog: true,
        enableMagicLinkPreview: false,
        enableLogging: false,
        enableApiLogger: false,
        enableRouterLogging: false,
      ),
    };

    final resolvedEnableLogging = enableLogging ?? defaults.enableLogging;
    final resolvedEnableApiLogger = enableApiLogger ?? defaults.enableApiLogger;
    final resolvedEnableRouterLogging =
        enableRouterLogging ?? resolvedEnableLogging;

    // Pick anon key from ANON or legacy KEY
    final anonKey = _pickNonEmpty([kSupabaseAnonKey, kSupabaseKey]);

    final resolvedDeepLinkScheme = _firstNonEmpty([
      deepLinkScheme ?? '',
      clientAppKey,
    ]);

    final cfg = AppConfig._(
      environment: env,
      clientAppKey: clientAppKey,
      deepLinkScheme: resolvedDeepLinkScheme,
      supabaseUrl: _parseRequiredUri('SUPABASE_URL', kSupabaseUrl),
      supabaseAnonKey: anonKey,
      googleApiKey: kGoogleApiKey,
      placesApiKey: kPlacesGoogleApiKey,
      adminBaseUrl: _parseOptionalUri('ADMIN_BASE_URL', kAdminBaseUrl),
      lodgifyBaseUrl: _ensureTrailingSlash(
        _parseRequiredUri('LODGIFY_BASE_URL', kLodgifyBaseUrl),
      ),
      testFlightUrl: _parseOptionalUri('TESTFLIGHT_URL', kTestFlightUrl),
      enableDevTools: enableDevTools ?? defaults.enableDevTools,
      enableFirebase: enableFirebase ?? defaults.enableFirebase,
      authErrorsInDialog: authErrorsInDialog ?? defaults.authErrorsInDialog,
      enableMagicLinkPreview:
          enableMagicLinkPreview ?? defaults.enableMagicLinkPreview,
      enableLogging: resolvedEnableLogging,
      enableApiLogger: resolvedEnableApiLogger,
      enableRouterLogging: resolvedEnableRouterLogging,
      supportEmail: 'support@melioris.com',
      themeScheme: 'blue',
    );
    _validate(cfg);
    _instance = cfg;

    assert(() {
      // Debug-only presence check. Do not print secrets.
      // ignore: avoid_print
      print('AppConfig OK. SUPABASE_URL set: ${kSupabaseUrl.isNotEmpty}');
      return true;
    }());
  }

  bool get isDev => environment.isDev;
  bool get isStg => environment.isStg;
  bool get isPrd => environment.isPrd;

  bool get isFirebaseEnabled => enableFirebase;

  bool get isMagicLinkPreviewSupported {
    if (_isProductBuild) return false;
    return enableMagicLinkPreview;
  }

  String authRedirectUri({String path = '/login'}) =>
      '$deepLinkScheme://auth$path';

  String toSafeString() =>
      '[AppConfig env=${environment.name} app=$clientAppKey '
      'supabaseUrl=$supabaseUrl admin=${adminBaseUrl ?? '-'} '
      'lodgify=$lodgifyBaseUrl '
      'flags=[dev=$enableDevTools fb=$enableFirebase modal=$authErrorsInDialog '
      'magicLinkPreview=$enableMagicLinkPreview log=$enableLogging apiLog=$enableApiLogger '
      'routerLog=$enableRouterLogging]]';

  @override
  String toString() => toSafeString();
}

// ---------- helpers ----------

String _firstNonEmpty(List<String> values) =>
    values.firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');

String _pickNonEmpty(List<String> values) {
  final v = _firstNonEmpty(values);
  if (v.trim().isEmpty) {
    throw StateError('Missing required env value for ${values.join(" or ")}.');
  }
  return v;
}

Uri _parseRequiredUri(String key, String raw) {
  // Validate presence and shape of required URL.
  final v = raw.trim();
  if (v.isEmpty) {
    throw StateError(
      'Missing required URL for $key. Provide it via --dart-define $key=<value>.',
    );
  }
  final uri = Uri.tryParse(v);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw FormatException('Invalid URL for $key: $v');
  }
  return uri;
}

Uri? _parseOptionalUri(String key, String raw) {
  // Normalize trailing slashes and parse optional URLs.
  final t = raw.trim().replaceAll(RegExp(r'/+$'), '');
  if (t.isEmpty) return null;
  final uri = Uri.tryParse(t);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw FormatException('Invalid URL for $key: $t');
  }
  return uri;
}

Uri _ensureTrailingSlash(Uri uri) {
  final path = uri.path;
  if (path.endsWith('/')) return uri;
  if (path.isEmpty) return uri.replace(path: '/');
  return uri.replace(path: '$path/');
}

void _validate(AppConfig c) {
  // Validate required keys.
  if (c.clientAppKey.trim().isEmpty) {
    throw StateError(
      'clientAppKey is required. Provide a build-time key per app.',
    );
  }
  if (c.deepLinkScheme.trim().isEmpty) {
    throw StateError(
      'deepLinkScheme is required. Provide a build-time scheme per app.',
    );
  }
  if (c.supabaseAnonKey.trim().isEmpty) {
    throw StateError('SUPABASE_ANON_KEY is required.');
  }
}
