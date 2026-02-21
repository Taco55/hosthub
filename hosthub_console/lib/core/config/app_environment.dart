enum AppEnvironment {
  dev,
  stg,
  prd;

  String get shortName => switch (this) {
    AppEnvironment.dev => 'DEV',
    AppEnvironment.stg => 'STG',
    AppEnvironment.prd => '',
  };

  String environmentSuffix({bool includeParentheses = false}) {
    if (this == AppEnvironment.prd) return '';
    final label = shortName.isNotEmpty ? shortName : name.toUpperCase();
    return includeParentheses ? ' ($label)' : label;
  }

  String decorateAppName(String baseName) {
    final suffix = this == AppEnvironment.prd ? '' : name.toUpperCase();
    if (suffix.isEmpty) return baseName;
    return '$baseName $suffix';
  }

  static AppEnvironment fromEnvironment({
    AppEnvironment fallback = AppEnvironment.stg,
  }) {
    const env = String.fromEnvironment('APP_ENVIRONMENT');
    if (env.isEmpty) return fallback;
    switch (env.toLowerCase()) {
      case 'dev':
        return AppEnvironment.dev;
      case 'prd':
        return AppEnvironment.prd;
      case 'stg':
      case 'staging':
        return AppEnvironment.stg;
      default:
        return fallback;
    }
  }
}

extension AppEnvironmentChecks on AppEnvironment {
  bool get isDev => this == AppEnvironment.dev;
  bool get isStg => this == AppEnvironment.stg;
  bool get isPrd => this == AppEnvironment.prd;
}
