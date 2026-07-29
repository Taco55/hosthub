import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/application/account_channel_defaults_cubit.dart';
import 'package:hosthub_console/features/user_settings/presentation/widgets/site_settings_sections.dart';

/// The languages a **new** property starts with.
///
/// Exactly the list pattern from Site-instellingen — row per language, `Bron`
/// badge, remove, `Taal toevoegen` — so nobody has to learn how languages work
/// twice. What differs is only what it means, and the section footer says it:
/// this touches no existing website, it is the starting point of the next
/// property.
class AccountLanguagesSection extends StatelessWidget {
  const AccountLanguagesSection({super.key});

  /// The languages the console can publish a site in.
  static const List<String> supportedLanguages = ['nl', 'en', 'de', 'no', 'fr'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountChannelDefaultsCubit>().state;
    final settings = state.settings;
    final cubit = context.read<AccountChannelDefaultsCubit>();
    final addable = settings.addableFrom(supportedLanguages);

    return StyledSection(
      header: context.s.accountDefaultsLanguagesHeader,
      footer: context.s.accountDefaultsLanguagesFooter,
      horizontalPadding: 0,
      children: [
        for (final code in settings.languages)
          StyledTile(
            leading: _LanguageTag(code: code),
            title: languageDisplayName(context, code),
            trailing: code == settings.sourceLanguage
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
                    onPressed: state.canEdit
                        ? () => cubit.saveSettings(
                            settings.copyWith(
                              languages: [
                                for (final language in settings.languages)
                                  if (language != code) language,
                              ],
                            ),
                          )
                        : null,
                  ),
          ),
        if (addable.isNotEmpty && state.canEdit)
          StyledMenuOverlay<String>(
            entries: [
              for (final code in addable)
                StyledMenuOverlayEntry(
                  value: code,
                  label: languageDisplayName(context, code),
                  leading: _LanguageTag(code: code),
                ),
            ],
            placement: MenuOverlayPlacement.belowTrigger,
            onSelected: (code) => cubit.saveSettings(
              settings.copyWith(languages: [...settings.languages, code]),
            ),
            child: StyledTile(
              leading: Icon(Icons.add, color: context.colors.primary),
              title: context.s.addLanguageAction,
              titleColor: context.colors.primary,
              // The overlay owns the tap; a selectable tile would wrap itself
              // in a SelectionArea that claims it.
              selectable: false,
            ),
          ),
        StyledSelectionTile<String>.dropdown(
          title: context.s.sourceLanguageLabel,
          subtitle: context.s.sourceLanguageDescription,
          leading: const Icon(Icons.translate),
          currentValue: settings.sourceLanguage,
          options: settings.languages,
          optionLabelBuilder: (code) => languageDisplayName(context, code),
          fieldAutoSize: true,
          enabled: state.canEdit,
          onChanged: (code) {
            if (code == null || code == settings.sourceLanguage) return;
            cubit.saveSettings(settings.copyWith(sourceLanguage: code));
          },
        ),
      ],
    );
  }
}

/// The small uppercase language tag, same as Site-instellingen'.
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
