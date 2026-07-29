import 'package:flutter/foundation.dart';

/// What a messaging source can actually do.
///
/// The UI asks this instead of asking "is this Lodgify?". That is the whole
/// point of the port: adding a source that can send is one implementation and
/// one flag, not a sweep through the presentation layer.
///
/// **Every `false` owes the reader an explained degradation** — a visible reason
/// and, where one exists, a way to do it elsewhere. A button that silently does
/// nothing is worse than no button.
@immutable
class MessagingCapabilities {
  const MessagingCapabilities({
    required this.sourceName,
    this.canSend = false,
    this.canMarkRead = false,
    this.canArchive = false,
    this.canListThreads = false,
    this.supportsWebhook = false,
    this.sourceDeepLinkTemplate,
  });

  /// The source's name, as the owner knows it. Goes straight into the copy
  /// ("Antwoorden gaat nog via Lodgify."), so it is never a brand name baked
  /// into a widget.
  final String sourceName;

  /// Whether a reply can leave through this source.
  final bool canSend;

  /// Whether "read" means anything at the source. When false the console's own
  /// read state is the only one there is — which is fine as long as it is
  /// consistent, and is why the console stores it.
  final bool canMarkRead;

  /// Whether archiving reaches the source.
  final bool canArchive;

  /// Whether the source can enumerate threads. When false they are discovered
  /// another way (through bookings, for Lodgify); a property of the source,
  /// deliberately not surfaced in the UI.
  final bool canListThreads;

  /// Whether the source can push a new message instead of being polled.
  final bool supportsWebhook;

  /// Where to send the owner when the console cannot do something itself.
  /// `{threadId}` is replaced with the source's own thread id.
  final String? sourceDeepLinkTemplate;

  /// The source link for one thread, or null when the source has no address for
  /// it — in which case the UI offers no dead link.
  String? deepLinkFor(String sourceThreadId) {
    final template = sourceDeepLinkTemplate;
    if (template == null || template.trim().isEmpty) return null;
    return template.replaceAll('{threadId}', sourceThreadId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagingCapabilities &&
          runtimeType == other.runtimeType &&
          sourceName == other.sourceName &&
          canSend == other.canSend &&
          canMarkRead == other.canMarkRead &&
          canArchive == other.canArchive &&
          canListThreads == other.canListThreads &&
          supportsWebhook == other.supportsWebhook &&
          sourceDeepLinkTemplate == other.sourceDeepLinkTemplate;

  @override
  int get hashCode => Object.hash(
    sourceName,
    canSend,
    canMarkRead,
    canArchive,
    canListThreads,
    supportsWebhook,
    sourceDeepLinkTemplate,
  );

  @override
  String toString() =>
      'MessagingCapabilities($sourceName, send=$canSend, markRead=$canMarkRead, '
      'archive=$canArchive, list=$canListThreads, webhook=$supportsWebhook)';
}
