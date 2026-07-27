import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import 'package:hosthub_console/core/config/app_config.dart';

import '../../application/site_content_cubit.dart';
import '../website_editor_status_colors.dart';
import 'live_site_frame.dart';
import 'site_preview_frame.dart';

/// The right-hand live preview: a status pill + device toggle + locale
/// switcher above a [SitePreviewFrame] (web or phone) rendering the chalet
/// site in the selected language, with a stale/draft ribbon underneath.
class PreviewPane extends StatelessWidget {
  const PreviewPane({super.key, required this.state});

  final SiteContentState state;

  /// The real website's draft-preview URL for the selected language, with a
  /// cache-busting save marker so a save reloads the frame. Null in demo
  /// mode (no linked site) — the schematic mock renders instead.
  String? get _liveUrl {
    final domain = kCmsPreviewDomain.trim().isNotEmpty
        ? kCmsPreviewDomain.trim()
        : state.previewDomain;
    if (domain == null || domain.isEmpty) return null;
    final normalized = domain
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
    final scheme =
        normalized.contains('localhost') || normalized.startsWith('127.0.0.1')
        ? 'http'
        : 'https';
    final marker = state.lastSavedAt?.millisecondsSinceEpoch ?? 0;
    return '$scheme://$normalized/preview/${state.previewLanguage}?_r=$marker';
  }

  @override
  Widget build(BuildContext context) {
    final lang = state.previewLanguage;
    final liveUrl = _liveUrl;
    final displayHost =
        (kCmsPreviewDomain.trim().isNotEmpty
            ? kCmsPreviewDomain.trim()
            : state.previewDomain) ??
        'trysilpanorama.com';
    final url = '$displayHost/$lang';

    // The real site needs room: give the embedded frame the full pane height
    // instead of the mock's intrinsic column.
    final isLive = liveUrl != null;
    final frame = SitePreviewFrame(
      url: url,
      device: state.previewDevice == PreviewDevice.mobile
          ? SitePreviewFrameDevice.mobile
          : SitePreviewFrameDevice.desktop,
      expandContent: isLive,
      child: isLive ? LiveSiteFrame(url: liveUrl) : _SitePreview(state: state),
    );

    return ColoredBox(
      color: context.colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PreviewToolbar(state: state),
            const SizedBox(height: 14),
            Expanded(
              child: isLive
                  ? Column(
                      children: [
                        Expanded(child: frame),
                        if (!state.isSourceMode) ...[
                          const SizedBox(height: 12),
                          _PreviewRibbon(state: state),
                        ],
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          frame,
                          const SizedBox(height: 12),
                          if (!state.isSourceMode) _PreviewRibbon(state: state),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();

    // §11g: the preview header keeps `Live preview` and the Web/Mobile
    // toggle. The AI pill, the `<Language> preview` caption and the locale
    // switcher all moved out — the switcher to the editor header, the other
    // two because they restate what the switcher and the per-field chips
    // already say (and the pill was false for a hand-corrected language).
    final deviceToggle = StyledSegmentedControl.compact(
      segments: [
        StyledSegment(
          label: context.s.weDeviceWeb,
          icon: Icons.desktop_windows_outlined,
        ),
        StyledSegment(
          label: context.s.weDeviceMobile,
          icon: Icons.smartphone_outlined,
        ),
      ],
      selectedIndex: state.previewDevice == PreviewDevice.web ? 0 : 1,
      onChanged: (i) => cubit.setPreviewDevice(
        i == 0 ? PreviewDevice.web : PreviewDevice.mobile,
      ),
    );

    // The caption sits left, the toggle right — flush with the preview toggle
    // in the editor header above it. Side by side they read as one group, and
    // the caption looks like the first (unstyled) tab of the switcher.
    // `spaceBetween` on a Wrap, not a Row: when the pane is too narrow for
    // both, the toggle drops to its own line instead of squeezing the caption
    // out of existence.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(
          context.s.weLivePreview,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        deviceToggle,
      ],
    );
  }
}

/// The rendered chalet page (content, not console chrome): hero with headline +
/// subtitle over a gradient, a highlights row, and a gallery grid — bound to
/// the currently selected language's values.
class _SitePreview extends StatelessWidget {
  const _SitePreview({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final lang = state.previewLanguage;
    final isMobile = state.previewDevice == PreviewDevice.mobile;

    final headline = state.valueFor(lang, 'hero.headline');
    final subtitle = state.valueFor(lang, 'hero.subtitle');
    final highlights = [
      state.valueFor(lang, 'highlights.0'),
      state.valueFor(lang, 'highlights.1'),
    ];

    final hero = Container(
      height: isMobile ? 186 : 250,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.primary.withValues(alpha: 0.55),
            context.colors.onSurface.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: context.colors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.surface.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );

    final highlightCells = [
      for (final text in highlights)
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
    ];

    final gallery = Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: [
          for (var i = 0; i < (isMobile ? 2 : 3); i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: StyledContainer(
                borderRadius: BorderRadius.circular(8),
                backgroundColor: context.colors.surfaceContainerHighest,
                padding: EdgeInsets.zero,
                child: const SizedBox(height: 64),
              ),
            ),
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hero,
        if (isMobile)
          Column(children: highlightCells)
        else
          Row(
            children: [
              for (final cell in highlightCells) Expanded(child: cell),
            ],
          ),
        gallery,
      ],
    );
  }
}

class _PreviewRibbon extends StatelessWidget {
  const _PreviewRibbon({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final lang = state.previewLanguage;
    final stale = state.isLanguageStale(lang);

    if (stale) {
      return StyledNotice(
        tone: StyledNoticeTone.warning,
        icon: Icons.schedule,
        message: context.s.weRibbonStale,
        trailing: StyledButton(
          title: context.s.wePreviewLatest,
          showLeftIcon: true,
          leftIconData: Icons.auto_awesome,
          showProgressIndicatorWhenDisabled: true,
          enabled: !state.translating.contains(lang),
          onPressed: () => cubit.previewTranslation(lang),
        ),
      );
    }

    final tokens = WebsiteStatusColors.locked(context.theme.brightness);
    return StyledNotice(
      icon: Icons.check_circle_outline,
      message: context.s.weRibbonDraft,
      backgroundColor: tokens.background,
      foregroundColor: tokens.foreground,
    );
  }
}
