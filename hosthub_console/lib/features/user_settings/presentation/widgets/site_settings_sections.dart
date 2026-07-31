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

/// Dimmed placeholder for an empty value on a read-only/value tile.
Widget notSetPlaceholder(BuildContext context) {
  return Text(
    context.s.notSet,
    style: context.theme.textTheme.bodyMedium?.copyWith(
      color: context.colors.onSurface.withValues(alpha: 0.45),
    ),
  );
}

// ---------------------------------------------------------------------------
// Site details
// ---------------------------------------------------------------------------

class _SiteDetailsSection extends StatelessWidget {
  const _SiteDetailsSection({required this.state});

  final SiteContextState state;

  @override
  Widget build(BuildContext context) {
    final site = state.site!;

    return StyledSection(
      isFirstSection: true,
      header: context.s.siteDetailsSectionTitle,
      inset: true,
      horizontalPadding: 0,
      children: [
        StyledTile(
          leading: const Icon(Icons.home_outlined),
          title: context.s.propertyNameLabel,
          value: site.name,
          showChevron: true,
          onTap: () async {
            final name = await _promptTextValue(
              context,
              title: context.s.propertyNameLabel,
              initialValue: site.name,
            );
            if (name == null || !context.mounted) return;
            await context.read<SiteContextCubit>().setSiteName(name);
          },
        ),
        // Read-only (domains are infrastructure): no chevron, and an empty
        // value renders as the dimmed "Not set" placeholder — one consistent
        // trailing pattern across these rows.
        StyledTile(
          leading: const Icon(Icons.language_outlined),
          title: context.s.publicDomainLabel,
          value: state.primaryDomain ?? notSetPlaceholder(context),
        ),
        StyledTile(
          leading: const Icon(Icons.link_outlined),
          title: context.s.bookingLinkLabel,
          value: state.bookingUrl ?? notSetPlaceholder(context),
          valueMaxWidthFraction: 0.5,
          showChevron: true,
          onTap: () async {
            final url = await _promptTextValue(
              context,
              title: context.s.bookingLinkLabel,
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
    sheet: const StyledModalSheet(presentation: StyledModalPresentation.dialog),
    sizing: const StyledModalSizing(dialogMinWidth: 420, dialogMaxWidth: 480),
    // The body collects the value, so the primary confirms it and the entered
    // text is the modal's result — no callback to route it through.
    actions: StyledModalActions.pick(
      label: context.s.saveButton,
      cancelLabel: context.s.cancelButton,
    ),
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
    final site = state.site!;

    return StyledSection(
      header: context.s.websiteLanguagesSectionTitle,
      footer: context.s.websiteLanguagesFooter,
      inset: true,
      horizontalPadding: 0,
      children: [
        for (final code in site.locales)
          StyledTile(
            leading: _LanguageTag(code: code),
            title: languageDisplayName(context, code),
            trailing: code == site.defaultLocale
                ? StyledChip(
                    label: context.s.sourceBadgeLabel.toUpperCase(),
                    size: StyledChipSize.display,
                    backgroundColor: context.colors.surface,
                    borderColor: context.colors.primaryContainer,
                    labelColor: context.colors.primary,
                  )
                : StyledToolbarButton(
                    iconData: Icons.delete_outline,
                    destructive: true,
                    tooltip: context.s.removeLanguageTooltip,
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
              leading: Icon(Icons.add, color: context.colors.primary),
              title: context.s.addLanguageAction,
              titleColor: context.colors.primary,
              // The enclosing StyledMenuOverlay owns the tap; a selectable
              // tile would wrap itself in a SelectionArea that claims it.
              selectable: false,
            ),
          ),
      ],
    );
  }

  void _confirmRemove(BuildContext context, String code) {
    showStyledAlertDialog(
      context,
      title: context.s.removeLanguageConfirmTitle(
        languageDisplayName(context, code),
      ),
      message: context.s.removeLanguageConfirmMessage,
      actionText: context.s.remove,
      dismissText: context.s.cancelButton,
      isDestructiveAction: true,
      onAction: () => context.read<SiteContextCubit>().removeLanguage(code),
    );
  }
}

/// The small uppercase language tag from the design (`.flagmini`), built on
/// [StyledChip] so it needs no bespoke chrome. labelStyle keeps labelSmall's
/// own dark colour: this theme's onSurfaceVariant is too light to read on
/// surfaceContainerHighest.
class _LanguageTag extends StatelessWidget {
  const _LanguageTag({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return StyledChip(
      label: code.toUpperCase(),
      backgroundColor: context.colors.surfaceContainerHighest,
      cornerRadius: 8,
      minHeight: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelStyle: context.theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
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
    final site = state.site!;
    final interfaceLanguage = context.watch<LanguageCubit>().state.languageCode;
    // The one-time adopt action only makes sense when it would change
    // something and the website actually offers the interface language.
    final canAdopt =
        site.locales.contains(interfaceLanguage) &&
        site.defaultLocale != interfaceLanguage;

    return StyledSection(
      header: context.s.sourceLanguageLabel,
      footer: context.s.sourceLanguageFooter,
      inset: true,
      horizontalPadding: 0,
      children: [
        // Always directly editable — deliberately independent from the
        // interface language (user scope). Every change is confirmed: it
        // re-bases what all other languages are translated from.
        StyledSelectionTile<String>.dropdown(
          title: context.s.sourceLanguageLabel,
          subtitle: context.s.sourceLanguageDescription,
          leading: const Icon(Icons.translate),
          currentValue: site.defaultLocale,
          options: site.locales,
          optionLabelBuilder: (code) => languageDisplayName(context, code),
          fieldAutoSize: true,
          onChanged: (code) {
            if (code == null || code == site.defaultLocale) return;
            _confirmSourceLanguageChange(context, code);
          },
        ),
        // Variant (a) of the design note: a one-time action instead of a
        // stateful "follows interface language" toggle — a toggle that only
        // acts once would suggest a live binding that intentionally does
        // not exist.
        StyledTile(
          leading: Icon(
            Icons.sync_alt,
            color: canAdopt ? context.colors.primary : null,
          ),
          title: context.s.adoptInterfaceLanguageTitle,
          titleColor: canAdopt ? context.colors.primary : null,
          subtitle: context.s.adoptInterfaceLanguageSubtitle(
            languageDisplayName(context, interfaceLanguage),
          ),
          enabled: canAdopt,
          // Disabled = dimmed row, not the theme'context.s dark disabled surface —
          // inside an inset group that slab reads as a rendering glitch.
          disabledBackgroundColor: Colors.transparent,
          onTap: canAdopt
              ? () => _confirmSourceLanguageChange(context, interfaceLanguage)
              : null,
        ),
      ],
    );
  }

  void _confirmSourceLanguageChange(BuildContext context, String code) {
    final language = languageDisplayName(context, code);
    showStyledAlertDialog(
      context,
      title: context.s.changeSourceLanguageConfirmTitle(language),
      message: context.s.changeSourceLanguageConfirmMessage(language),
      actionText: context.s.changeButton,
      dismissText: context.s.cancelButton,
      onAction: () => context.read<SiteContextCubit>().setSourceLanguage(code),
    );
  }
}
