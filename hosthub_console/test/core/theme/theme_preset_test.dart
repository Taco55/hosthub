import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/theme/theme.dart';

/// Guards the theme decisions the CMS design handoff left open, plus the preset
/// groups the Reservations / Revenue / Pricing screens read instead of
/// hardcoding values. These are global: a regression here changes every screen.
void main() {
  ThemeData themeFor(Brightness brightness) =>
      HosthubThemePreset.applyMaterialTheme(
        baseTheme: brightness == Brightness.light
            ? ThemeData.light()
            : ThemeData.dark(),
        brightness: brightness,
      );

  StyledWidgetsThemeData styledFor(Brightness brightness) =>
      HosthubThemePreset.styledTheme(
        lightMaterialTheme: themeFor(Brightness.light),
      ).resolve(themeFor(brightness));

  group('decision: tables use a light header band, not white-on-primary', () {
    test('light mode: light band, muted grey label', () {
      final tables = styledFor(Brightness.light).tables;

      expect(
        tables.headerBackgroundColor,
        HosthubDiploraV1Palette.backgroundWhite,
      );
      expect(
        tables.columnHeaderTextStyle?.color,
        HosthubDiploraV1Palette.outlineGrey,
      );
    });

    test('the header label is never onPrimary — that was the old conflict', () {
      final onPrimary = themeFor(Brightness.light).colorScheme.onPrimary;
      for (final brightness in Brightness.values) {
        final tables = styledFor(brightness).tables;
        expect(
          tables.columnHeaderTextStyle?.color,
          isNot(onPrimary),
          reason: 'white-on-primary header text in $brightness',
        );
        expect(tables.trinaColumnTextStyle?.color, isNot(onPrimary));
      }
    });

    test('dark mode swaps both the band and the label', () {
      final tables = styledFor(Brightness.dark).tables;

      expect(
        tables.headerBackgroundColor,
        HosthubDiploraV1Palette.surfaceContainerDark,
      );
      expect(
        tables.columnHeaderTextStyle?.color,
        HosthubDiploraV1Palette.onSurfaceVariantDark,
      );
    });

    test('header labels stay sentence case', () {
      expect(
        styledFor(Brightness.light).tables.uppercaseColumnHeaderLabels,
        isFalse,
      );
    });
  });

  group('decision: the palette green wins over the prototype green', () {
    const prototypeGreen = Color(0xFF1F8A4C);

    test('menu check marks use Palette.success', () {
      final dropdowns = styledFor(Brightness.light).dropdowns;

      expect(dropdowns.menuCheckedColor, HosthubDiploraV1Palette.success);
      expect(dropdowns.menuCheckedColor, isNot(prototypeGreen));
      expect(dropdowns.menuUncheckedColor, HosthubDiploraV1Palette.softGrey);
      expect(
        dropdowns.menuCheckDisabledColor,
        HosthubDiploraV1Palette.darkGrey,
      );
    });

    test('none of the old hardcoded check colours survive', () {
      // The three literals that used to live in _checkEntry.
      const oldChecked = Color(0xFF1B5E20);
      const oldUnchecked = Color(0xFFD0D0D0);
      const oldDisabled = Color(0xFFBDBDBD);
      final dropdowns = styledFor(Brightness.light).dropdowns;

      expect(dropdowns.menuCheckedColor, isNot(oldChecked));
      expect(dropdowns.menuUncheckedColor, isNot(oldUnchecked));
      expect(dropdowns.menuCheckDisabledColor, isNot(oldDisabled));
    });

    test('successText is a readable variant of success, not a second hue', () {
      final success = HosthubDiploraV1Palette.success;
      final successText = HosthubDiploraV1Palette.successText;

      expect(successText, isNot(success));
      // Darker, which is the whole point: `success` alone misses AA at 10-11px.
      expect(
        successText.computeLuminance(),
        lessThan(success.computeLuminance()),
      );
      expect(_contrastOnWhite(successText), greaterThan(4.5));
      expect(
        _contrastOnWhite(success),
        lessThan(4.5),
        reason: 'if this ever passes, successText is no longer needed',
      );
    });

    test('a positive KPI caption uses the readable green', () {
      expect(
        styledFor(Brightness.light).statTiles.positiveColor,
        HosthubDiploraV1Palette.successText,
      );
    });
  });

  group('spacing scale', () {
    test('is the design 4px scale', () {
      final spacing = styledFor(Brightness.light).spacing;

      expect(spacing.xs, 4);
      expect(spacing.sm, 8);
      expect(spacing.md, 12);
      expect(spacing.lg, 16);
      expect(spacing.xl, 24);
      expect(spacing.xxl, 32);
    });

    test('every step is on the 4px grid — no 6, 10 or 14', () {
      final spacing = styledFor(Brightness.light).spacing;
      for (final step in [
        spacing.xs,
        spacing.sm,
        spacing.md,
        spacing.lg,
        spacing.xl,
        spacing.xxl,
      ]) {
        expect(step % 4, 0, reason: '$step is off the 4px scale');
      }
    });
  });

  group('toolbar buttons', () {
    test('carry the design geometry so call sites pass none', () {
      final toolbar = styledFor(Brightness.light).toolbarButton;

      expect(toolbar.buttonWidth, 40);
      expect(toolbar.buttonHeight, 36);
      expect(toolbar.iconSize, 20);
      expect(toolbar.borderRadius, const BorderRadius.all(Radius.circular(10)));
      expect(toolbar.shape, StyledControlShape.customRadius);
    });

    test('selected means "a filter is active": ice + primary', () {
      final toolbar = styledFor(Brightness.light).toolbarButton;

      expect(toolbar.selectedBackgroundColor, HosthubDiploraV1Palette.ice);
      expect(toolbar.selectedIconColor, HosthubDiploraV1Palette.primary);
    });
  });

  group('timeline calendar', () {
    test('the day-cell hairline survives the dark surface', () {
      // Black at 8% reads as the design's grid line over a white cell and
      // vanishes over a dark one, so the dark theme carries its own outline.
      // Everything else in the extension stays brightness-independent.
      final light = themeFor(Brightness.light).timelineCalendar;
      final dark = themeFor(Brightness.dark).timelineCalendar;

      expect(light.dayCellBorderColor, const Color(0x14000000));
      expect(dark.dayCellBorderColor, HosthubDiploraV1Palette.outlineDark);
      expect(dark.comfortable, light.comfortable);
      expect(dark.pastEntryBlendColor, light.pastEntryBlendColor);
    });
  });

  group('stat tiles', () {
    test('sit on the white card surface', () {
      expect(
        styledFor(Brightness.light).statTiles.backgroundColor,
        Colors.white,
      );
      expect(
        styledFor(Brightness.dark).statTiles.backgroundColor,
        HosthubDiploraV1Palette.surfaceContainerDark,
      );
    });

    test('label / value / caption resolve to the design roles', () {
      final statTiles = styledFor(Brightness.light).statTiles;

      expect(statTiles.labelTextStyle?.fontSize, 9.5);
      expect(statTiles.labelTextStyle?.fontWeight, FontWeight.w600);
      expect(
        statTiles.labelTextStyle?.color,
        HosthubDiploraV1Palette.outlineGrey,
      );
      expect(statTiles.valueTextStyle?.fontSize, 18);
      expect(statTiles.valueTextStyle?.fontWeight, FontWeight.w700);
      expect(statTiles.captionTextStyle?.fontSize, 10.5);
      expect(statTiles.uppercaseLabel, isTrue);
    });
  });

  group('surface roles', () {
    test(
      'light surface is white — ice is primaryContainer, not the surface',
      () {
        final light = themeFor(Brightness.light).colorScheme;

        expect(light.surface, Colors.white);
        expect(light.primaryContainer, HosthubDiploraV1Palette.ice);
        expect(
          light.surface,
          isNot(HosthubDiploraV1Palette.ice),
          reason:
              'anything falling back to surface would inherit the sidebar tint',
        );
      },
    );

    test('table rows and stat tiles therefore land on white', () {
      final tables = styledFor(Brightness.light).tables;
      expect(tables.card.rowBackgroundColor, Colors.white);
    });

    test('dark surface stays dark', () {
      expect(
        themeFor(Brightness.dark).colorScheme.surface,
        HosthubDiploraV1Palette.surfaceDark,
      );
    });
  });

  group('page chrome follows the design', () {
    test('page body shares its left edge with the page header', () {
      // `.top{padding:16px 22px}`: the scaffold spends this once, on the
      // column that holds the header *and* the content, so title, toolbar and
      // content cannot land on different left edges. Vertically `lg` / `xxl`
      // off the spacing scale — the bottom keeps the last card off the
      // viewport edge.
      final spacing = styledFor(Brightness.light).spacing;
      expect(
        styledFor(Brightness.light).webPageScaffold.pagePadding,
        EdgeInsets.fromLTRB(22, spacing.lg, 22, spacing.xxl),
      );
    });

    test('wide pages cap at .set-wide max-width', () {
      expect(styledFor(Brightness.light).webPageScaffold.contentMaxWidth, 1040);
    });

    test(
      'the page title is the design 19/700 crumb-and-title, not a headline',
      () {
        final header = styledFor(Brightness.light).webPageScaffold;

        // `.top h1{font-size:19px;font-weight:700;letter-spacing:-.3px}` over
        // `.crumb{font-size:12px}`. Stated in the preset so pages pass strings.
        expect(header.titleTextStyle?.fontSize, 19);
        expect(header.titleTextStyle?.letterSpacing, -0.3);
        expect(header.overlineTextStyle?.fontSize, 12);
      },
    );

    test('the title band closes with the design hairline', () {
      // `.top{border-bottom:1px solid var(--jo-border)}` — the same grey as
      // every card border, and dark mode swaps it rather than dropping it.
      expect(
        styledFor(Brightness.light).webPageScaffold.headerDividerColor,
        HosthubDiploraV1Palette.softGrey,
      );
      expect(
        styledFor(Brightness.dark).webPageScaffold.headerDividerColor,
        HosthubDiploraV1Palette.outlineDark,
      );
    });
  });

  group('toolbar buttons match .tbtn', () {
    test('white surface, hairline border, dark icon', () {
      final toolbar = styledFor(Brightness.light).toolbarButton;

      expect(toolbar.backgroundColor, Colors.white);
      expect(toolbar.borderColor, HosthubDiploraV1Palette.softGrey);
      expect(toolbar.iconColor, HosthubDiploraV1Palette.secondary);
    });

    test('and stay readable in dark mode', () {
      final toolbar = styledFor(Brightness.dark).toolbarButton;

      expect(
        toolbar.backgroundColor,
        HosthubDiploraV1Palette.surfaceContainerDark,
      );
      expect(toolbar.iconColor, HosthubDiploraV1Palette.onSurfaceDark);
    });
  });

  group('timeline calendar theme', () {
    test('is registered on both brightnesses', () {
      for (final brightness in Brightness.values) {
        final extension = themeFor(
          brightness,
        ).extension<TimelineCalendarTheme>();
        expect(extension, isNotNull, reason: 'missing in $brightness');
      }
    });

    test('carries the density values the reservations page used to inline', () {
      final timeline = themeFor(Brightness.light).timelineCalendar;

      expect(timeline.comfortable.barHeight, 30);
      expect(timeline.comfortable.dayNumberHeight, 24);
      expect(timeline.comfortable.barTopPadding, 6);
      expect(timeline.comfortable.rowBottomPadding, 10);
      expect(timeline.comfortable.showDayLabels, isTrue);
      expect(timeline.comfortable.leadingIconSize, 18);

      expect(timeline.compact.barHeight, 22);
      expect(timeline.compact.dayNumberHeight, 18);
      expect(timeline.compact.barTopPadding, 3);
      expect(timeline.compact.rowBottomPadding, 4);
      expect(timeline.compact.showDayLabels, isFalse);
      expect(timeline.compact.leadingIconSize, 14);
    });

    test('carries the past-booking treatment', () {
      final timeline = themeFor(Brightness.light).timelineCalendar;

      expect(timeline.pastEntryBlend, 0.55);
      expect(timeline.pastEntryBlendColor, const Color(0xFFE0E0E0));
      expect(timeline.pastEntryTextColor, const Color(0xFF9E9E9E));
      expect(timeline.pastEntryLeadingOpacity, 0.45);
    });

    test('a bare ThemeData still resolves, via the standard fallback', () {
      expect(
        ThemeData.light().timelineCalendar,
        TimelineCalendarTheme.standard,
      );
    });
  });

  test('registering the timeline theme keeps other extensions intact', () {
    final base = ThemeData.light().copyWith(
      extensions: const [_ProbeExtension(1)],
    );
    final themed = HosthubThemePreset.applyMaterialTheme(
      baseTheme: base,
      brightness: Brightness.light,
    );

    expect(themed.extension<_ProbeExtension>()?.value, 1);
    expect(themed.extension<TimelineCalendarTheme>(), isNotNull);
  });

  // Padding audit against `HostHub CMS.dc.html`. Every value below is a CSS
  // rule from the prototype that used to be a literal at a call site.
  group('card geometry follows the design', () {
    test('two radii: 10 on controls, 14 on content cards', () {
      final styled = styledFor(Brightness.light);

      expect(
        styled.sharedLayout.surfaceRadius,
        const BorderRadius.all(Radius.circular(10)),
      );
      // `.card` / `.chartcard` / `.kpi` / `.tbl-wrap` / `.payout`
      expect(
        styled.sharedLayout.cardRadius,
        const BorderRadius.all(Radius.circular(14)),
      );
      // Sections, tables and stat tiles all read that one value instead of
      // restating 14 three times.
      expect(styled.sections.borderRadius, styled.sharedLayout.cardRadius);
      expect(styled.tables.borderRadius, styled.sharedLayout.cardRadius);
    });

    test('a content card is padded 18/20, rows keep hugging the card', () {
      final sections = styledFor(Brightness.light).sections;

      // `.chartcard{padding:18px 20px}` / `.payout{padding:18px 20px}` — 18 is
      // off the 4px scale, so the vertical rounds to 16 instead of being
      // reproduced with an addition at the call site.
      expect(
        sections.contentPadding,
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
      // `.chan-hd` / `.trow .tc` / `.stile` all inset rows by 16.
      expect(sections.innerPadding, const EdgeInsets.symmetric(horizontal: 16));
    });

    test('dense .dt padding applies to the plain table, not the card one', () {
      final tables = styledFor(Brightness.light).tables;

      // `.dt th` and `.dt td{padding:12px 14px}` on the design's `.tbl-wrap`
      // table. The card tables (team, listings) are a different shell and keep
      // the library's tighter dense — stating this table-wide would have made
      // them roomier by accident.
      expect(
        tables.plain.denseHeaderPadding,
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
      expect(
        tables.plain.denseRowPadding,
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
      expect(tables.plain.denseHeaderHeight, 40);
      expect(tables.card.denseRowPadding, isNull);
      expect(tables.denseRowPadding, isNull);
    });
  });

  group('modal geometry: one edge for body and footer', () {
    test('the modal grid matches the section inset', () {
      final styled = styledFor(Brightness.light);
      final content = styled.modals.contentPadding.resolve(TextDirection.ltr);
      final footer = styled.modals.footerActionsPadding.resolve(
        TextDirection.ltr,
      );

      // Inherited from the library, asserted here because it is what keeps a
      // bare-field modal body off the modal's rounded corners and on the same
      // edge as the footer — the preset must not override one of the two.
      expect(content.left, styled.sharedLayout.horizontalPadding);
      expect(content.left, footer.left);
      expect(content.right, footer.right);
      // And the primary is not glued to the last field.
      expect(content.bottom, greaterThanOrEqualTo(16));
    });

    test('commitments render below the content they confirm', () {
      expect(
        styledFor(Brightness.light).modals.actionPlacement,
        StyledModalSlotPlacement.footer,
      );
    });
  });

  group('timeline calendar geometry follows the design', () {
    test('bar, day cell, weekday strip and month heading', () {
      final calendar = themeFor(Brightness.light).timelineCalendar;

      expect(calendar.barRadius, 7); // `.cbar{border-radius:7px}`
      expect(
        calendar.barPadding,
        const EdgeInsets.symmetric(horizontal: 7),
      ); // `.cbar{padding:0 7px}`
      expect(calendar.barContentSpacing, 6); // `.cbar{gap:6px}`
      expect(calendar.dayCellHorizontalPadding, 8); // `.cal-day{padding:· 8px}`
      expect(
        calendar.weekdayHeaderPadding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ); // `.cal-dow div{padding:9px 10px}`
      expect(
        calendar.monthHeadingPadding,
        const EdgeInsets.fromLTRB(2, 14, 2, 6),
      ); // `.calmonth-hd{padding:14px 2px 6px}`
    });
  });

  group('decision: the outlined button is a hairline, not a second blue CTA', () {
    test(
      'light: design .btn-line — white, card-border hairline, slate label',
      () {
        final buttons = styledFor(Brightness.light).buttons;

        expect(buttons.secondaryBackgroundColor, Colors.white);
        expect(buttons.secondaryBorderColor, HosthubDiploraV1Palette.softGrey);
        expect(
          buttons.secondaryLabelColor,
          HosthubDiploraV1Palette.outlineButtonLabel,
        );
      },
    );

    test(
      'the outlined label is never `primary` — that is the filled button',
      () {
        for (final brightness in Brightness.values) {
          expect(
            styledFor(brightness).buttons.secondaryLabelColor,
            isNot(themeFor(brightness).colorScheme.primary),
            reason: 'outlined button label in $brightness',
          );
        }
      },
    );

    test('dark: the same button on the dark surfaces, not white-on-white', () {
      final buttons = styledFor(Brightness.dark).buttons;

      expect(
        buttons.secondaryBackgroundColor,
        HosthubDiploraV1Palette.surfaceContainerDark,
      );
      expect(buttons.secondaryBorderColor, HosthubDiploraV1Palette.outlineDark);
      expect(
        buttons.secondaryLabelColor,
        HosthubDiploraV1Palette.onSurfaceDark,
      );
    });

    test('a destructive button is filled red, not a wash with a hairline', () {
      for (final brightness in Brightness.values) {
        final buttons = styledFor(brightness).buttons;

        // The filled destructive is the confirmation dialog's primary action.
        // A soft wash there makes the dangerous button the weakest-looking one
        // in a row where its neighbour is a text `Annuleren`.
        expect(
          buttons.destructiveBackgroundColor,
          HosthubDiploraV1Palette.error,
          reason: 'destructive fill in $brightness',
        );
        expect(buttons.destructiveLabelColor, Colors.white);

        // The destructive *text* label falls back to that background and needs
        // no line of its own — which is only true while the background is a
        // solid red rather than something meant to sit behind a label.
        expect(
          buttons.destructiveTextLabelColor,
          HosthubDiploraV1Palette.error,
          reason: 'destructive text label in $brightness',
        );
      }
    });
  });
}

double _contrastOnWhite(Color color) {
  final luminance = color.computeLuminance();
  return (1.0 + 0.05) / (luminance + 0.05);
}

@immutable
class _ProbeExtension extends ThemeExtension<_ProbeExtension> {
  const _ProbeExtension(this.value);

  final int value;

  @override
  _ProbeExtension copyWith({int? value}) =>
      _ProbeExtension(value ?? this.value);

  @override
  _ProbeExtension lerp(ThemeExtension<_ProbeExtension>? other, double t) =>
      this;
}
