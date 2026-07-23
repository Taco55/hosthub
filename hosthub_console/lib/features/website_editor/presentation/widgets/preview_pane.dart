import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/site_content_cubit.dart';
import '../website_editor_status_colors.dart';
import '../website_editor_strings.dart';

/// The right-hand live preview: a status pill + device toggle + locale
/// switcher above a [StyledBrowserFrame] (web or phone) rendering the chalet
/// site in the selected language, with a stale/draft ribbon underneath.
class PreviewPane extends StatelessWidget {
  const PreviewPane({super.key, required this.state});

  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lang = state.previewLanguage;
    final url = 'trysilpanorama.com/$lang';

    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PreviewToolbar(state: state),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StyledBrowserFrame(
                      url: url,
                      device: state.previewDevice == PreviewDevice.mobile
                          ? StyledBrowserFrameDevice.mobile
                          : StyledBrowserFrameDevice.desktop,
                      child: _SitePreview(state: state),
                    ),
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
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final s = context.s;
    final isSource = state.isSourceMode;
    final autoTokens = WebsiteStatusColors.auto(brightness);

    final statusPill = StyledChip(
      label: isSource ? s.weLivePreview : s.weAiTranslation,
      size: StyledChipSize.display,
      leading: Icon(
        isSource ? Icons.visibility_outlined : Icons.auto_awesome,
        size: 13,
        color: isSource ? scheme.primary : autoTokens.foreground,
      ),
      backgroundColor:
          isSource ? scheme.primaryContainer : autoTokens.background,
      labelColor: isSource ? scheme.primary : autoTokens.foreground,
    );

    final locales = state.orderedLocales;
    final localeSwitcher = StyledSegmentedControl.compact(
      segments: [
        for (final code in locales)
          StyledSegment(
            label: languageShort(code),
            badge: code == state.sourceLanguage ? null : 'AI',
            statusDotColor: code != state.sourceLanguage &&
                    state.isLanguageStale(code)
                ? autoTokens.foreground
                : null,
          ),
      ],
      selectedIndex: locales.indexOf(state.previewLanguage),
      onChanged: (i) => cubit.setPreviewLanguage(locales[i]),
    );

    final deviceToggle = StyledSegmentedControl.compact(
      segments: [
        StyledSegment(label: s.weDeviceWeb, icon: Icons.desktop_windows_outlined),
        StyledSegment(label: s.weDeviceMobile, icon: Icons.smartphone_outlined),
      ],
      selectedIndex: state.previewDevice == PreviewDevice.web ? 0 : 1,
      onChanged: (i) => cubit.setPreviewDevice(
        i == 0 ? PreviewDevice.web : PreviewDevice.mobile,
      ),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        statusPill,
        Text(
          s.wePreviewLabel(languageName(context, state.previewLanguage)),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        deviceToggle,
        localeSwitcher,
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
    final scheme = Theme.of(context).colorScheme;

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
            scheme.primary.withValues(alpha: 0.55),
            scheme.onSurface.withValues(alpha: 0.75),
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
                  color: scheme.surface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.surface.withValues(alpha: 0.9)),
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
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
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
                backgroundColor: scheme.surfaceContainerHighest,
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
    final brightness = Theme.of(context).brightness;

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

    final tokens = WebsiteStatusColors.locked(brightness);
    return StyledNotice(
      icon: Icons.check_circle_outline,
      message: context.s.weRibbonDraft,
      backgroundColor: tokens.background,
      foregroundColor: tokens.foreground,
    );
  }
}
