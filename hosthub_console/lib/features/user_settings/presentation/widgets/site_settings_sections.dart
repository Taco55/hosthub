import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/core/l10n/application/language_cubit.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

/// The property-scope website settings from the design handoff (§5): site
/// details, the dynamic website-languages list, and the source-language
/// choice. Everything autosaves; navigation is the sidebar's job, so there
/// are no action buttons here.
///
/// Returns nothing when no site is linked to the selected property — the
/// sections are omitted rather than rendered empty.
List<Widget> buildSiteSettingsSections(
  BuildContext context,
  SiteContextState state,
) {
  final site = state.site;
  if (site == null) return const [];
  return [
    _SiteDetailsSection(state: state),
    _WebsiteLanguagesSection(state: state),
    _SourceLanguageSection(state: state),
  ];
}

String languageDisplayName(BuildContext context, String code) {
  final resolved = LocaleNames.of(context)?.nameOf(code);
  if (resolved == null || resolved.isEmpty) return code.toUpperCase();
  return resolved[0].toUpperCase() + resolved.substring(1);
}

// ---------------------------------------------------------------------------
// Site details
// ---------------------------------------------------------------------------

class _SiteDetailsSection extends StatelessWidget {
  const _SiteDetailsSection({required this.state});

  final SiteContextState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final site = state.site!;

    return StyledSection(
      isFirstSection: true,
      header: s.siteDetailsSectionTitle,
      inset: false,
      children: [
        StyledTile(
          leading: const Icon(Icons.home_outlined),
          title: s.propertyNameLabel,
          value: site.name,
          showChevron: true,
          onTap: () async {
            final name = await _promptTextValue(
              context,
              title: s.propertyNameLabel,
              initialValue: site.name,
            );
            if (name == null || !context.mounted) return;
            await context.read<SiteContextCubit>().setSiteName(name);
          },
        ),
        StyledTile(
          leading: const Icon(Icons.language_outlined),
          title: s.publicDomainLabel,
          value: state.primaryDomain ?? '—',
        ),
        StyledTile(
          leading: const Icon(Icons.link_outlined),
          title: s.bookingLinkLabel,
          value: state.bookingUrl ?? '—',
          valueMaxWidthFraction: 0.5,
          showChevron: true,
          onTap: () async {
            final url = await _promptTextValue(
              context,
              title: s.bookingLinkLabel,
              initialValue: state.bookingUrl ?? '',
            );
            if (url == null || !context.mounted) return;
            await context.read<SiteContextCubit>().setBookingUrl(url);
          },
        ),
      ],
    );
  }
}

/// Single-field edit dialog. Returns the entered text, or null on cancel.
Future<String?> _promptTextValue(
  BuildContext context, {
  required String title,
  required String initialValue,
}) {
  return showStyledModal<String>(
    context,
    title: title,
    presentation: StyledModalPresentation.dialog,
    dialogMinWidth: 420,
    dialogMaxWidth: 480,
    showAction: true,
    actionLabel: context.s.saveButton,
    leadingLabel: context.s.cancelButton,
    initialValue: initialValue,
    dataBuilder: (ctx, onChanged) => StyledTextFormField(
      initialValue: initialValue,
      autofocus: true,
      onChanged: onChanged,
    ),
  );
}

// ---------------------------------------------------------------------------
// Website languages
// ---------------------------------------------------------------------------

class _WebsiteLanguagesSection extends StatelessWidget {
  const _WebsiteLanguagesSection({required this.state});

  final SiteContextState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final site = state.site!;
    final colorScheme = Theme.of(context).colorScheme;

    return StyledSection(
      header: s.websiteLanguagesSectionTitle,
      footer: s.websiteLanguagesFooter,
      inset: false,
      children: [
        for (final code in site.locales)
          StyledTile(
            leading: _LanguageTag(code: code),
            title: languageDisplayName(context, code),
            trailing: code == site.defaultLocale
                ? StyledChip(
                    label: s.sourceBadgeLabel.toUpperCase(),
                    size: StyledChipSize.display,
                    backgroundColor: colorScheme.surface,
                    borderColor: colorScheme.primaryContainer,
                    labelColor: colorScheme.primary,
                  )
                : StyledToolbarButton(
                    iconData: Icons.delete_outline,
                    destructive: true,
                    tooltip: s.removeLanguageTooltip,
                    onPressed: () => _confirmRemove(context, code),
                  ),
          ),
        if (state.addableLanguages.isNotEmpty)
          StyledMenuOverlay<String>(
            entries: [
              for (final code in state.addableLanguages)
                StyledMenuOverlayEntry(
                  value: code,
                  label: languageDisplayName(context, code),
                  leading: _LanguageTag(code: code),
                ),
            ],
            placement: MenuOverlayPlacement.belowTrigger,
            onSelected: (code) =>
                context.read<SiteContextCubit>().addLanguage(code),
            child: StyledTile(
              leading: Icon(Icons.add, color: colorScheme.primary),
              title: s.addLanguageAction,
              titleColor: colorScheme.primary,
              // The enclosing StyledMenuOverlay owns the tap; a selectable
              // tile would wrap itself in a SelectionArea that claims it.
              selectable: false,
            ),
          ),
      ],
    );
  }

  void _confirmRemove(BuildContext context, String code) {
    final s = context.s;
    showStyledAlertDialog(
      context,
      title: s.removeLanguageConfirmTitle(languageDisplayName(context, code)),
      message: s.removeLanguageConfirmMessage,
      actionText: s.remove,
      dismissText: s.cancelButton,
      isDestructiveAction: true,
      onAction: () => context.read<SiteContextCubit>().removeLanguage(code),
    );
  }
}

/// The small uppercase language tag from the design (`.flagmini`).
class _LanguageTag extends StatelessWidget {
  const _LanguageTag({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 32,
      height: 32,
      child: StyledContainer(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            code.toUpperCase(),
            // labelSmall's own (dark) colour: this theme's onSurfaceVariant
            // is too light to read on surfaceContainerHighest.
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Source language
// ---------------------------------------------------------------------------

class _SourceLanguageSection extends StatelessWidget {
  const _SourceLanguageSection({required this.state});

  final SiteContextState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final site = state.site!;
    final interfaceLanguage = context.watch<LanguageCubit>().state.languageCode;

    return StyledSection(
      header: s.sourceLanguageLabel,
      footer: s.sourceLanguageFooter,
      inset: false,
      children: [
        StyledSwitchTile(
          leading: const Icon(Icons.translate),
          title: s.sameAsInterfaceLanguageTitle,
          subtitle: s.sameAsInterfaceLanguageSubtitle(
            languageDisplayName(context, interfaceLanguage),
          ),
          value: site.sourceLocaleFollowsUi,
          onChanged: (follows) =>
              context.read<SiteContextCubit>().setSourceFollowsUi(
                follows,
                interfaceLanguage: interfaceLanguage,
              ),
        ),
        if (!site.sourceLocaleFollowsUi)
          StyledSelectionTile<String>.dropdown(
            title: s.chooseDifferentLanguageTitle,
            subtitle: s.chooseDifferentLanguageSubtitle,
            leading: const Icon(Icons.language_outlined),
            currentValue: site.defaultLocale,
            options: site.locales,
            optionLabelBuilder: (code) => languageDisplayName(context, code),
            fieldAutoSize: true,
            onChanged: (code) {
              if (code == null || code == site.defaultLocale) return;
              context.read<SiteContextCubit>().setSourceLanguage(code);
            },
          ),
      ],
    );
  }
}
