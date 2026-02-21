class EmailTemplateConfig {
  /// Optional TestFlight URL for user-facing emails.
  final String? testflightUrl;

  /// Optional environment label, e.g. 'STAGING'.
  /// When provided, templates can render a banner and subjects can be prefixed.
  final String? envLabel;

  const EmailTemplateConfig({this.testflightUrl, this.envLabel});
}
