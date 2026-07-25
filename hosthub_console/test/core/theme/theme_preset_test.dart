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
      expect(dropdowns.menuCheckDisabledColor, HosthubDiploraV1Palette.darkGrey);
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
      expect(
        toolbar.borderRadius,
        const BorderRadius.all(Radius.circular(10)),
      );
      expect(toolbar.shape, StyledControlShape.customRadius);
    });

    test('selected means "a filter is active": ice + primary', () {
      final toolbar = styledFor(Brightness.light).toolbarButton;

      expect(
        toolbar.selectedBackgroundColor,
        HosthubDiploraV1Palette.ice,
      );
      expect(toolbar.selectedIconColor, HosthubDiploraV1Palette.primary);
    });
  });

  group('stat tiles', () {
    test('sit on the card surface, not the ice page surface', () {
      final light = styledFor(Brightness.light);
      // colorScheme.surface is ice in this app's light theme — a KPI tile must
      // not inherit the sidebar tint.
      expect(
        light.statTiles.backgroundColor,
        isNot(themeFor(Brightness.light).colorScheme.surface),
      );
      expect(light.statTiles.backgroundColor, Colors.white);

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
  _ProbeExtension copyWith({int? value}) => _ProbeExtension(value ?? this.value);

  @override
  _ProbeExtension lerp(ThemeExtension<_ProbeExtension>? other, double t) => this;
}
