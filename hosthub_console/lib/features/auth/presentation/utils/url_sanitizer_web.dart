import 'package:web/web.dart' as web;

/// Strips sensitive tokens from the browser's address bar.
void sanitizeCurrentUrl() {
  final current = web.window.location.href;
  if (!current.contains('access_token') &&
      !current.contains('refresh_token')) {
    return;
  }
  final uri = Uri.parse(current);
  final clean = uri.replace(fragment: '', query: '');
  web.window.history.replaceState(null, '', clean.toString());
}
