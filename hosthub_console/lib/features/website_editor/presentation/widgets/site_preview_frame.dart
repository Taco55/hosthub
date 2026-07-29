import 'package:flutter/material.dart';

import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

/// Device chrome rendered around a [SitePreviewFrame]'s content.
enum SitePreviewFrameDevice {
  /// A desktop browser window: traffic-light dots + an address bar.
  desktop,

  /// A phone: a dark bezel + rounded screen with a status bar.
  mobile,
}

/// App-local "web page preview" chrome for the website editor's live preview
/// (deliberately not a styled_widgets component: browser/phone chrome is
/// specific to this screen — see the build-loop ledger).
///
/// In [SitePreviewFrameDevice.desktop] it renders a browser window (optional
/// traffic-light dots, an address bar showing [url], an optional [toolbar]
/// beside the address bar) around [child]. In [SitePreviewFrameDevice.mobile]
/// it renders a phone bezel with a status bar (time + host derived from [url]).
///
/// Built on [StyledContainer] so radius/surfaces follow the theme; the default
/// soft drop shadow matches the design-system card-hover elevation. All colours
/// come from the [ColorScheme].
class SitePreviewFrame extends StatelessWidget {
  const SitePreviewFrame({
    super.key,
    required this.child,
    this.url,
    this.showTrafficLights = true,
    this.toolbar,
    this.device = SitePreviewFrameDevice.desktop,
    this.maxWidth = 660,
    this.boxShadow,
    this.expandContent = false,
    this.pointAtChrome = false,
  });

  /// The rendered page / content slot.
  final Widget child;

  /// URL shown in the address bar (desktop) / host in the status bar (mobile).
  final String? url;

  /// Whether to render the three traffic-light dots (desktop only).
  final bool showTrafficLights;

  /// Optional controls rendered beside the address bar (desktop) / above the
  /// bezel (mobile).
  final Widget? toolbar;

  /// Desktop window vs phone bezel.
  final SitePreviewFrameDevice device;

  /// Maximum content width for the desktop frame. Mobile clamps to a phone
  /// width regardless.
  final double maxWidth;

  /// Overrides the default card-hover drop shadow.
  final List<BoxShadow>? boxShadow;

  /// When true the content slot fills the available height (for an embedded
  /// live page); when false the frame shrink-wraps its child (the mock).
  final bool expandContent;

  /// Marks the browser chrome instead of anything on the page.
  ///
  /// Two fields are not text on the page at all — the tab title and the search
  /// description (§E). Pointing at them means pointing at the chrome, which is
  /// the console's own frame rather than the site's document, so the mark lands
  /// here. The editor's note says what the field is; this says where.
  final bool pointAtChrome;

  static const double _mobileScreenWidth = 306;
  static const double _mobileBezelPadding = 10;

  List<BoxShadow> _resolveShadow(BuildContext context) =>
      boxShadow ??
      [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return device == SitePreviewFrameDevice.mobile
        ? _buildMobile(context)
        : _buildDesktop(context);
  }

  Widget _buildDesktop(BuildContext context) {
    final chrome = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          if (showTrafficLights) ...[
            _trafficDot(context.colors.error),
            const SizedBox(width: 6),
            _trafficDot(context.colors.tertiary),
            const SizedBox(width: 6),
            _trafficDot(context.colors.primary),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Container(
              height: 28,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: pointAtChrome
                    ? context.colors.primaryContainer
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: pointAtChrome
                    ? Border.all(color: context.colors.primary, width: 1.5)
                    : null,
              ),
              child: Text(
                url ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: pointAtChrome
                      ? context.colors.onPrimaryContainer
                      : context.colors.onSurfaceVariant,
                  fontWeight: pointAtChrome ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
          if (toolbar != null) ...[const SizedBox(width: 12), toolbar!],
        ],
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: StyledContainer(
          backgroundColor: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.outlineVariant),
          boxShadow: _resolveShadow(context),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              chrome,
              Divider(
                height: 1,
                thickness: 1,
                color: context.colors.outlineVariant,
              ),
              if (expandContent)
                Expanded(child: child)
              else
                Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final host = _host(url);

    final bezelColor = Theme.of(context).brightness == Brightness.dark
        ? context.colors.surfaceContainerHighest
        : context.colors.onSurface;

    final phone = Container(
      width: _mobileScreenWidth + _mobileBezelPadding * 2,
      padding: const EdgeInsets.all(_mobileBezelPadding),
      decoration: BoxDecoration(
        color: bezelColor,
        borderRadius: BorderRadius.circular(38),
        boxShadow: _resolveShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: ColoredBox(
          color: context.colors.surface,
          child: Column(
            mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '9:41',
                      style: context.theme.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      host,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (expandContent)
                Expanded(child: child)
              else
                Flexible(child: child),
            ],
          ),
        ),
      ),
    );

    return Center(
      child: Column(
        mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (toolbar != null) ...[toolbar!, const SizedBox(height: 16)],
          if (expandContent) Expanded(child: phone) else phone,
        ],
      ),
    );
  }

  Widget _trafficDot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.55),
      shape: BoxShape.circle,
    ),
  );

  static String _host(String? url) {
    if (url == null || url.isEmpty) return '';
    final withoutScheme = url.replaceFirst(RegExp(r'^[a-zA-Z]+://'), '');
    final slash = withoutScheme.indexOf('/');
    return slash == -1 ? withoutScheme : withoutScheme.substring(0, slash);
  }
}
