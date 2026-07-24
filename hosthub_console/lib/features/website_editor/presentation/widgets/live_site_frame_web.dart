import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Embeds the real website (its draft-preview route) in an iframe. Each unique
/// [url] registers its own platform-view factory once; changing the url swaps
/// to a fresh iframe (which is also how saves force a reload via a cache-bust
/// query parameter).
class LiveSiteFrame extends StatelessWidget {
  const LiveSiteFrame({super.key, required this.url});

  final String url;

  static final Set<String> _registered = <String>{};

  String get _viewType => 'live-site-frame:$url';

  void _ensureRegistered() {
    if (_registered.contains(_viewType)) return;
    _registered.add(_viewType);
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    _ensureRegistered();
    return HtmlElementView(viewType: _viewType);
  }
}
