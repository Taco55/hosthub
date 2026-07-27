import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Embeds the real website (its draft-preview route) in an iframe, and keeps
/// that frame showing what is in the editor's fields right now.
///
/// The preview route renders the site's *saved* content, so without this the
/// pane would lag a whole save behind the form while calling itself live.
/// [fields] carries the values the owner sees, keyed by CMS address, and travels
/// over `postMessage`: nothing is written, and no draft reaches the published
/// site by typing.
///
/// One platform-view factory per instance, holding one iframe whose `src` is
/// updated in place — a save changes the url (cache-busting marker) and reloads
/// the frame without registering anything new.
class LiveSiteFrame extends StatefulWidget {
  const LiveSiteFrame({
    super.key,
    required this.url,
    required this.locale,
    required this.fields,
  });

  final String url;

  /// The language on screen; the preview ignores a draft for another one.
  final String locale;

  /// `cms address -> value`, e.g. `cabin/main:hero.title`.
  final Map<String, String> fields;

  @override
  State<LiveSiteFrame> createState() => _LiveSiteFrameState();
}

class _LiveSiteFrameState extends State<LiveSiteFrame> {
  static const String _draftMessage = 'hosthub-preview-draft';
  static const String _readyMessage = 'hosthub-preview-ready';

  late final String _viewType;
  late final web.HTMLIFrameElement _iframe;
  late final JSFunction _messageListener;

  @override
  void initState() {
    super.initState();
    _viewType = 'live-site-frame:${identityHashCode(this)}';
    _iframe = web.HTMLIFrameElement()
      ..src = widget.url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );

    // The preview announces itself after every load. That is the moment to
    // (re)send the draft: a freshly loaded document only has the saved copy.
    _messageListener = _onMessage.toJS;
    web.window.addEventListener('message', _messageListener);
  }

  @override
  void didUpdateWidget(covariant LiveSiteFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _iframe.src = widget.url;
      // The reload announces itself; the draft goes out then.
      return;
    }
    // Value comparison, not identity: the map is rebuilt from state on every
    // rebuild, so identity would post on every frame.
    if (widget.locale != oldWidget.locale ||
        !mapEquals(widget.fields, oldWidget.fields)) {
      _sendDraft();
    }
  }

  @override
  void dispose() {
    web.window.removeEventListener('message', _messageListener);
    super.dispose();
  }

  void _onMessage(web.Event event) {
    if (event is! web.MessageEvent) return;
    if (event.origin != _previewOrigin) return;
    final data = event.data?.dartify();
    if (data is! Map || data['type'] != _readyMessage) return;
    _sendDraft();
  }

  /// The origin of the embedded preview — the only window this talks to.
  String get _previewOrigin {
    final uri = Uri.parse(widget.url);
    return uri.hasPort
        ? '${uri.scheme}://${uri.host}:${uri.port}'
        : '${uri.scheme}://${uri.host}';
  }

  void _sendDraft() {
    final payload = <String, Object?>{
      'type': _draftMessage,
      'locale': widget.locale,
      'fields': widget.fields,
    };
    _iframe.contentWindow?.postMessage(payload.jsify(), _previewOrigin.toJS);
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
