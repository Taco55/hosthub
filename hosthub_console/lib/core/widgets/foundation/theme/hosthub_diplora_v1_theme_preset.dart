import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'app_colors.dart';
import 'timeline_calendar_theme.dart';

abstract final class HosthubDiploraV1Palette {
  const HosthubDiploraV1Palette._();

  static const Color primary = Color(0xFF155DBE);
  static const Color secondary = Color(0xFF023550);
  static const Color persianBlue = Color(0xFF0369A0);
  static const Color azureDiplora = Color(0xFF0D9ADB);
  static const Color teal = Color(0xFF01857E);
  static const Color ice = Color(0xFFE2F2FD);
  static const Color backgroundWhite = Color(0xFFF8FAFC);
  static const Color softGrey = Color(0xFFE1E7EF);
  static const Color darkGrey = Color(0xFFB4B8BF);

  /// Design-system text roles (Just Organize): readable secondary text and
  /// the outline/footnote grey. `darkGrey` above is too light for text on
  /// light surfaces and stays for decorative use only.
  static const Color textVariant = Color(0xFF44474E);
  static const Color outlineGrey = Color(0xFF74777F);
  static const Color searchPlaceholder = Color(0xFF7794A7);

  /// Design `.btn-line{color:#33506f}`: the label on an outlined button. A
  /// slate between [secondary] and [outlineGrey] — a secondary action reads as
  /// text on a hairline, not as a second blue call to action next to the
  /// primary button.
  static const Color outlineButtonLabel = Color(0xFF33506F);
  static const Color success = Color(0xFF099773);
  static const Color warning = Color(0xFFF68F46);
  static const Color error = Color(0xFFEB5757);

  /// [success] darkened towards [secondary] for use as **small text**.
  ///
  /// `success` itself only reaches ~3.7:1 on white — enough for an icon or a
  /// bar (non-text contrast), short of AA for a 10-11px label. Derived rather
  /// than authored as a second hex so the two greens cannot drift apart.
  static final Color successText = Color.lerp(success, secondary, 0.35)!;

  /// [warning] darkened on the same principle as [successText].
  static final Color warningText = Color.lerp(warning, secondary, 0.4)!;
  static const Color errorSoft = Color(0x33EB5757);
  static const Color surfaceDark = Color(0xFF0C1B26);
  static const Color surfaceContainerDark = Color(0xFF132433);
  static const Color outlineDark = Color(0xFF2D3B45);
  static const Color onSurfaceDark = Color(0xFFE6EFF6);
  static const Color onSurfaceVariantDark = Color(0xFF8AA0AF);
}

abstract final class HosthubThemePreset {
  const HosthubThemePreset._();

  static ColorScheme materialColorScheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ColorScheme.fromSeed(
      seedColor: HosthubDiploraV1Palette.primary,
      brightness: brightness,
    ).copyWith(
      primary: HosthubDiploraV1Palette.primary,
      onPrimary: Colors.white,
      primaryContainer: HosthubDiploraV1Palette.ice,
      onPrimaryContainer: HosthubDiploraV1Palette.secondary,
      secondary: HosthubDiploraV1Palette.secondary,
      onSecondary: Colors.white,
      secondaryContainer: HosthubDiploraV1Palette.persianBlue,
      onSecondaryContainer: Colors.white,
      tertiary: HosthubDiploraV1Palette.teal,
      onTertiary: Colors.white,
      tertiaryContainer: HosthubDiploraV1Palette.azureDiplora,
      onTertiaryContainer: Colors.white,
      // `--jo-surface` is #FFFFFF: the card and page plane. Ice is
      // `primaryContainer` — the sidebar and active states — not the surface.
      // Anything that falls back to `surface` (table rows, stat tiles, plain
      // containers) was inheriting the sidebar tint while this said ice.
      surface: isLight ? Colors.white : HosthubDiploraV1Palette.surfaceDark,
      onSurface: isLight ? HosthubDiploraV1Palette.secondary : Colors.white,
      surfaceContainerHighest: isLight
          ? HosthubDiploraV1Palette.backgroundWhite
          : HosthubDiploraV1Palette.surfaceContainerDark,
      outlineVariant: isLight
          ? HosthubDiploraV1Palette.softGrey
          : HosthubDiploraV1Palette.outlineDark,
      onSurfaceVariant: isLight
          ? HosthubDiploraV1Palette.textVariant
          : HosthubDiploraV1Palette.onSurfaceVariantDark,
      outline: isLight
          ? HosthubDiploraV1Palette.outlineGrey
          : HosthubDiploraV1Palette.onSurfaceVariantDark,
      error: HosthubDiploraV1Palette.error,
      onError: Colors.white,
      errorContainer: HosthubDiploraV1Palette.errorSoft,
      onErrorContainer: HosthubDiploraV1Palette.error,
    );
  }

  static ThemeData applyMaterialTheme({
    required ThemeData baseTheme,
    required Brightness brightness,
  }) {
    final colorScheme = materialColorScheme(brightness);
    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? Colors.white
          : colorScheme.surface,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      iconTheme: baseTheme.iconTheme.copyWith(size: 24),
      extensions: [
        ...baseTheme.extensions.values,
        // `TimelineCalendar` is app-local, so its density and past-booking
        // treatment have no `styled_widgets` preset group to live in. Reading
        // them from here is what keeps them out of `reservations_page.dart`.
        if (brightness == Brightness.light)
          TimelineCalendarTheme.standard
        else
          TimelineCalendarTheme.standard.copyWith(
            dayCellBorderColor: HosthubDiploraV1Palette.outlineDark,
          ),
      ],
    );
  }

  static AppColors appColorsForTheme({
    required ThemeData theme,
    required bool isDark,
  }) {
    final colorScheme = theme.colorScheme;
    if (isDark) {
      return AppColors(
        settingsBackgroundColor: HosthubDiploraV1Palette.surfaceDark,
        themedBackgroundColor: colorScheme.primary,
        onThemedBackgroundColor: colorScheme.onPrimary,
        settingsSectionHeaderAndFooterColor:
            HosthubDiploraV1Palette.onSurfaceVariantDark,
        settingsTileBackgroundColor:
            HosthubDiploraV1Palette.surfaceContainerDark,
        contrastBackgroundSoft: HosthubDiploraV1Palette.surfaceContainerDark,
        contrastBackgroundMedium: HosthubDiploraV1Palette.outlineDark,
        contrastBackgroundHard: HosthubDiploraV1Palette.surfaceDark,
        onContrastBackgroundSoft: HosthubDiploraV1Palette.onSurfaceDark,
        onContrastBackgroundMedium: HosthubDiploraV1Palette.onSurfaceDark,
        onContrastBackgroundHard: HosthubDiploraV1Palette.onSurfaceDark,
        disabledTextColor: const Color(0x80E6EFF6),
        activeButtonColor: HosthubDiploraV1Palette.primary,
        neutralButtonColor: HosthubDiploraV1Palette.onSurfaceVariantDark,
        barrierColor: const Color(0x73000000),
        themedTextFieldBackgroundColor:
            HosthubDiploraV1Palette.surfaceContainerDark,
        onThemedTextFieldBackgroundColor: HosthubDiploraV1Palette.onSurfaceDark,
        bottomAppBarColor: HosthubDiploraV1Palette.surfaceContainerDark,
        itemTileBackground: HosthubDiploraV1Palette.surfaceContainerDark,
        placeholderText: HosthubDiploraV1Palette.onSurfaceVariantDark,
        systemRed: HosthubDiploraV1Palette.error,
        secondaryLabel: HosthubDiploraV1Palette.onSurfaceVariantDark,
        buttonBackground: HosthubDiploraV1Palette.surfaceContainerDark,
        deselectedButtonColor: HosthubDiploraV1Palette.outlineDark,
        buttonPrimary: colorScheme.primary,
        onButtonPrimary: colorScheme.onPrimary,
        buttonDisabled: HosthubDiploraV1Palette.outlineDark,
        onButtonDisabled: const Color(0x80E6EFF6),
      );
    }

    return AppColors(
      settingsBackgroundColor: HosthubDiploraV1Palette.ice,
      themedBackgroundColor: colorScheme.primary,
      onThemedBackgroundColor: colorScheme.onPrimary,
      settingsSectionHeaderAndFooterColor: HosthubDiploraV1Palette.darkGrey,
      settingsTileBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
      contrastBackgroundSoft: HosthubDiploraV1Palette.backgroundWhite,
      contrastBackgroundMedium: HosthubDiploraV1Palette.softGrey,
      contrastBackgroundHard: HosthubDiploraV1Palette.ice,
      onContrastBackgroundSoft: HosthubDiploraV1Palette.secondary,
      onContrastBackgroundMedium: HosthubDiploraV1Palette.secondary,
      onContrastBackgroundHard: HosthubDiploraV1Palette.secondary,
      disabledTextColor: const Color(0x61023550),
      activeButtonColor: HosthubDiploraV1Palette.primary,
      neutralButtonColor: HosthubDiploraV1Palette.darkGrey,
      barrierColor: const Color(0x26023550),
      themedTextFieldBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
      onThemedTextFieldBackgroundColor: HosthubDiploraV1Palette.secondary,
      bottomAppBarColor: HosthubDiploraV1Palette.backgroundWhite,
      itemTileBackground: HosthubDiploraV1Palette.backgroundWhite,
      placeholderText: HosthubDiploraV1Palette.searchPlaceholder,
      systemRed: HosthubDiploraV1Palette.error,
      secondaryLabel: HosthubDiploraV1Palette.darkGrey,
      buttonBackground: HosthubDiploraV1Palette.backgroundWhite,
      deselectedButtonColor: HosthubDiploraV1Palette.softGrey,
      buttonPrimary: colorScheme.primary,
      onButtonPrimary: colorScheme.onPrimary,
      buttonDisabled: HosthubDiploraV1Palette.softGrey,
      onButtonDisabled: const Color(0x61023550),
    );
  }

  static StyledWidgetsThemeData styledTheme({
    required ThemeData lightMaterialTheme,
  }) {
    final baseColumnHeaderTextStyle =
        lightMaterialTheme.textTheme.titleSmall ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    return StyledWidgetsThemeData.defaultsWith(
      sharedComponentColors: (t) =>
          t.copyWith(accent: HosthubDiploraV1Palette.primary),
      sharedLayout: (t) => t.copyWith(
        horizontalPadding: 24,
        surfaceRadius: const BorderRadius.all(Radius.circular(10)),
        // The design draws two radii: 10 on controls (`.btn-sm`, `.seg`,
        // `.tbtn`, `.inp`) and 14 on the surfaces that hold a block of content
        // (`.card`, `.chartcard`, `.kpi`, `.tbl-wrap`, `.payout`). Stating the
        // second here is what stops each component group repeating `14`.
        cardRadius: const BorderRadius.all(Radius.circular(14)),
        fieldRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      // The design's 4px scale (`--jo-space-*`). Stated explicitly even though
      // it matches the library defaults: screens read gaps from here via
      // `context.styledSpacing`, so this is the one place the rhythm is set.
      // Nothing off the scale — `6`, `10` and `14` round to a neighbouring
      // step. Widget-internal geometry tuned to something other than page
      // layout belongs in that widget's own group, not here.
      spacing: (t) => t.copyWith(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32),
      // Design (Just Organize) tile groups: a white bordered card that hugs
      // its rows — no internal vertical padding — with a compact dark-blue
      // sentence-case header and a muted footnote. Content cards (e.g. the
      // editor's Hero/Highlights) opt into their own padding per instance.
      sections: (t) => t.copyWith(
        innerPadding: const EdgeInsets.symmetric(horizontal: 16),
        // Design `.chartcard` / `.payout` / `.card`: a card that holds content
        // rather than rows is padded on all four sides. The design says 18/20;
        // 18 is off the 4px scale, so the vertical rounds to 16 rather than
        // being reproduced with an addition at the call site. Rows keep hugging
        // the card via `innerPadding`.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        topPadding: 24,
        firstTopPadding: 0,
        insetBackgroundColor: Colors.white,
        insetBackgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        borderColor: HosthubDiploraV1Palette.softGrey,
        borderColorDark: HosthubDiploraV1Palette.outlineDark,
        borderWidth: 1,
        headerTextColor: HosthubDiploraV1Palette.secondary,
        headerTextStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headerSpacing: 8,
        footerTextColor: HosthubDiploraV1Palette.outlineGrey,
        headerInsideTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15.5,
          height: 1.2,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
          color: HosthubDiploraV1Palette.secondary,
        ),
        uppercaseHeader: false,
        uppercaseInsideHeader: false,
      ),
      tiles: (t) => t.copyWith(
        minHeight: 44,
        defaultPadding: const EdgeInsets.symmetric(vertical: 10),
        // Every plain-icon tile leading (StyledIconBadge with no explicit
        // `size`) shares this width with the avatar/monogram badges beside
        // it, matching the app's established Lodgify-badge convention —
        // instead of each row picking its own leading widget's natural size.
        iconBadgeSize: 34,
      ),
      // Design `.set-card` page chrome: every page pane is a white bordered
      // card on the white page surface (`--jo-surface`, the design `.frame`
      // background — ice blue is the sidebar only); panes carry 24px inner
      // padding.
      webPageScaffold: (t) => t.copyWith(
        decoratePanes: true,
        paneBackgroundColor: Colors.white,
        paneBackgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        paneBorderColor: HosthubDiploraV1Palette.softGrey,
        paneBorderColorDark: HosthubDiploraV1Palette.outlineDark,
        paneBorderRadius: const BorderRadius.all(Radius.circular(12)),
        panePadding: const EdgeInsets.all(24),
        pageBackgroundColor: Colors.white,
        pageBackgroundColorDark: HosthubDiploraV1Palette.surfaceDark,
        // Design `.top{padding:16px 22px}`. The scaffold spends this once, on
        // the column that holds the header *and* the content, so title,
        // toolbar and content cannot end up on different left edges. The
        // design's own `.set-body{padding:26px 30px 40px}` sets the body 8px
        // further in than the header it belongs to; 22px sides (as in
        // `.body`) is the alignment the mock actually intends. Vertically:
        // `lg` on top, `xxl` at the bottom so the last card clears the
        // viewport edge when you scroll to it.
        pagePadding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        // Design `.set-wide{max-width:1040px}`: wide pages cap their content
        // instead of stretching a table across a 27" monitor. The design's
        // `margin:0 auto` is dropped on purpose — the cap applies to the whole
        // page column, header included, and that column stays flush left.
        contentMaxWidth: 1040,
        // Design `.top`: crumb at 12px in the outline grey over a 19/700 title
        // — not a Material headline. Stated here so a page passes strings and
        // nothing else; the colours come from the scaffold's defaults
        // (`outline` = `--jo-fg-outline`, `secondary` = the heading blue).
        overlineTextStyle: const TextStyle(fontSize: 12, height: 1.3),
        titleTextStyle: const TextStyle(fontSize: 19, letterSpacing: -0.3),
        // The design's page headers carry no sentence under the title — a page
        // that still passes one gets the muted footnote size, not body copy.
        descriptionTextStyle: const TextStyle(fontSize: 12.5),
        // Design `.top{border-bottom:1px solid var(--jo-border)}`: the title
        // band closes with a hairline that runs the full page width — chrome
        // under the toolbar, not a line drawn around the content. Same
        // hairline as every card border, so there is one grey.
        headerDividerColor: HosthubDiploraV1Palette.softGrey,
        headerDividerColorDark: HosthubDiploraV1Palette.outlineDark,
        // `.set-body{padding:20px 22px 32px}` — the gap under the rule. Like
        // the 22px sides it is the design's own number and off the named
        // spacing steps; the band above the rule takes `pagePadding.top`, so
        // the title sits centred in its own band.
        headerBottomSpacing: 20,
        // The 32px page bottom is spent *inside* the scrolling pane, so a list
        // runs to the window edge and only pads once you reach its end.
        bottomPaddingInsideContent: true,
      ),
      // Navigation rail (design §5 + §"Responsieve strategie"): the full menu
      // from 1100px, the pinned icon rail down to 600px — no hamburger, so
      // navigation stays visible — and only below that the hamburger drawer.
      // The design draws the rail at 96px (`.sb2.compact`), but 96 costs the
      // page content ~24px between 600 and 1100px and only buys empty space
      // around the 48px rows — a deliberate deviation, reviewed against the
      // design on 2026-07-24.
      sideMenu: (t) => t.copyWith(
        breakpoints: const StyledSideMenuBreakpoints(
          expandedMin: 1100,
          railMin: 600,
        ),
        expandedWidth: 284,
        railWidth: 72,
      ),
      // Design `.dt th` / `.dt tfoot td`: a **light** header band with a muted
      // grey label — not white-on-primary. A saturated band would become the
      // loudest element on every page and collide with the ice sidebar and ice
      // active states, which are where `primary`/`ice` earn their emphasis; a
      // light band reads as chrome, which is what a header is. Applied here so
      // all four tables in the console change together (reservations, revenue,
      // team, listings) — never per call site.
      //
      // The design uppercases at 10px; we keep sentence case (the preset and
      // every call site already do) and take the design's other header size,
      // `.trow .th` at 600 11.5px, which is legible where 10px caps are not.
      tables: (t) => t.copyWith(
        uppercaseColumnHeaderLabels: false,
        // Was passed per call site by the reservations table only; every table
        // should breathe the same.
        columnGap: 8,

        // Design `.tbl-wrap{border:1px solid var(--jo-border)}`: the table is a
        // bordered panel, not a floating block of rows. Stated on the plain
        // variant so all four console tables get it at once; the library paints
        // it in the same hairline the row separators use. The 14 radius comes
        // from `sharedLayout.cardRadius`, so it is not repeated here.
        plain: t.plain.copyWith(
          borderWidth: 1,
          // `.dt th` / `.dt td{padding:12px 14px}`. Scoped to the plain
          // variant, which is the design's `.tbl-wrap` table: the card tables
          // (team, listings) are a different shell and keep the library's
          // tighter dense. Without this the library's fallback (12/6 and 12/8)
          // silently overrode the design from inside the widget.
          denseHeaderPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          denseRowPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          // 12 + 12 around an 11.5px label. A header that wraps to two lines
          // grows past this — it is a minimum, not a fixed height, which is why
          // the revenue table no longer needs its own `headerHeight: 58`.
          denseHeaderHeight: 40,
        ),
        // `.tbl-wrap{background:#fff}` with the header band a shade darker on
        // top of it, which is what makes the band read as chrome.
        backgroundColor: Colors.white,
        backgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        headerBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
        headerBackgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        columnHeaderTextColorDark: HosthubDiploraV1Palette.onSurfaceVariantDark,
        columnHeaderTextStyle: baseColumnHeaderTextStyle.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: HosthubDiploraV1Palette.outlineGrey,
        ),
        trinaColumnTextStyle: baseColumnHeaderTextStyle.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: HosthubDiploraV1Palette.outlineGrey,
          letterSpacing: 0.1,
        ),
      ),
      // Design `.tbtn`: 40x36, radius 10, hairline border, and ice + primary
      // when the control carries an active filter/toggle (`.tbtn.on`) — the
      // same pairing the sidebar uses, and ice in both brightnesses.
      //
      toolbarButton: (t) => t.copyWith(
        buttonWidth: 40,
        buttonHeight: 36,
        iconSize: 20,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderWidth: 1,
        backgroundColor: Colors.white,
        borderColor: HosthubDiploraV1Palette.softGrey,
        iconColor: HosthubDiploraV1Palette.secondary,
        backgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        borderColorDark: HosthubDiploraV1Palette.outlineDark,
        iconColorDark: HosthubDiploraV1Palette.onSurfaceDark,
        selectedBackgroundColor: HosthubDiploraV1Palette.ice,
        selectedBorderColor: HosthubDiploraV1Palette.ice,
        selectedIconColor: HosthubDiploraV1Palette.primary,
      ),
      // Design `.kpi`. Only two values need stating: the label, value and
      // caption styles already resolve to this design's tokens
      // (`outline` / `onSurface` / `onSurfaceVariant`, at 9.5/18/10.5), the
      // surface follows the inset-section card, and the border follows
      // `dividerColor` — all of which are correct in both brightnesses.
      statTiles: (t) => t.copyWith(
        // `.kpi{border-radius:14px}` comes from `sharedLayout.cardRadius`, so
        // it is not restated here.
        // `.kpi .kl svg` #b3c2d4 — decorative, which is exactly what
        // `darkGrey` is reserved for, and it reads on light and dark alike.
        iconColor: HosthubDiploraV1Palette.darkGrey,
        // A positive caption is 10.5px text, so it takes the darkened green.
        positiveColor: HosthubDiploraV1Palette.successText,
      ),
      // Design `.inp{background:#fff;border:1px solid #D5DFEB}`: an editable
      // field is white with a visible hairline. The library default fills it
      // with `surfaceContainerHighest`, which in this palette is the same very
      // light grey read-only surfaces use — so editable and read-only fields
      // looked alike (README §11e).
      formFields: (t) => t.copyWith(
        input: t.input.copyWith(
          // `.inp{padding:11px 13px}` — `all(16)` made every field ~10px
          // taller than the design and stretched each card with it.
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          backgroundColor: Colors.white,
          backgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
          borderColor: HosthubDiploraV1Palette.softGrey,
          borderWidth: 1,
        ),
      ),
      searchFields: (t) => t.copyWith(
        placeholderColor: HosthubDiploraV1Palette.searchPlaceholder,
      ),
      // -- fase 2: the field-list pattern (mapping part C) ------------------
      // Every number the handoff states lives here, so no card, row or picker
      // in the app repeats one.
      //
      // `.repeat{border:1px solid;border-radius:12px;padding:11px 13px;
      // margin-bottom:9px}` — the same 11/13 the input fields use, so a row
      // and the field inside it share one rhythm.
      repeaters: (t) => t.copyWith(
        rowRadius: 12,
        rowBorderColor: HosthubDiploraV1Palette.softGrey,
        rowBackgroundColor: Colors.white,
        rowPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
        rowGap: 9,
        // `.repeat .grip{color:#b3c2d4}`.
        handleColor: HosthubDiploraV1Palette.darkGrey,
        // `.repeat.dragging{opacity:.5}` is the row; a blocked action is
        // dimmer still, so it reads as unavailable rather than as moving.
        disabledActionOpacity: 0.30,
      ),
      // `.lhd .lt{600 12.5px}` / `.lc{11px}`, the group header on
      // `--jo-surface-low`, and `.emptylist{border:1.5px dashed #dbe4ee;
      // background:#FBFCFE;padding:16px}`.
      fieldLists: (t) => t.copyWith(
        subheaderTextStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: HosthubDiploraV1Palette.textVariant,
        ),
        counterTextStyle: const TextStyle(
          fontSize: 11,
          color: HosthubDiploraV1Palette.outlineGrey,
        ),
        addLabelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: HosthubDiploraV1Palette.primary,
        ),
        groupHeaderBackground: HosthubDiploraV1Palette.backgroundWhite,
        groupBorderColor: HosthubDiploraV1Palette.softGrey,
        groupRadius: 12,
        indent: 16,
        emptyBorderColor: HosthubDiploraV1Palette.softGrey,
        emptyBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
        emptyBorderWidth: 1.5,
      ),
      // `88 × 64` tiles, `radius:11`, `gap:10`, and the add tile's dashed
      // primary at 35% (mapping B11).
      media: (t) => t.copyWith(
        tileSize: const Size(88, 64),
        tileRadius: 11,
        gap: 10,
        addTileBorderColor: HosthubDiploraV1Palette.primary.withValues(
          alpha: 0.35,
        ),
        badgeBackgroundColor: HosthubDiploraV1Palette.primary,
        gridCrossAxisCount: 4,
        gridTileHeight: 88,
        selectedBorderColor: HosthubDiploraV1Palette.primary,
      ),
      // A 3px progress track, and the two colours an upload row can end in
      // (mapping B13). The failure colour is the palette's, not a second red.
      uploads: (t) => t.copyWith(
        trackHeight: 3,
        trackColor: HosthubDiploraV1Palette.softGrey,
        progressColor: HosthubDiploraV1Palette.primary,
        doneColor: HosthubDiploraV1Palette.success,
        failedColor: HosthubDiploraV1Palette.error,
        dropzoneBorderColor: HosthubDiploraV1Palette.softGrey,
        dropzoneBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
        dropzoneHoverBackgroundColor: HosthubDiploraV1Palette.ice,
      ),
      // Also the home of menu-overlay styling, which dropdowns and
      // `StyledToolbarButton.menu` share — hence the check colours for the
      // Filter / Kolommen / Weergave menus living here rather than on
      // `toolbarButton`, so dropdown menus get them too.
      //
      // The green is `Palette.success`, not the prototype's #1F8A4C: it sits in
      // the same cool family as `primary`, it is already the toast success
      // colour, and `BookingSourceIcon`'s Website pastel is a tint of it. A
      // check mark is a graphic, so `success` itself is fine here; small text
      // takes `successText`. Section-header styling needs no override — it
      // resolves to 9.5/w600/0.5 in `outline`, which is the design's `.mhd`.
      dropdowns: (t) => t.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minHeight: 40,
        menuCheckedColor: HosthubDiploraV1Palette.success,
        menuUncheckedColor: HosthubDiploraV1Palette.softGrey,
        menuCheckDisabledColor: HosthubDiploraV1Palette.darkGrey,
      ),
      buttons: (t) => t.copyWith(
        cornerRadius: 12,
        // Design `.btn-line`: white, a hairline in the card-border grey, and a
        // slate label. The library's default outlined button is
        // `primary`-on-`outline`, which puts a second blue call to action in
        // every toolbar and draws the eye away from the page. Stated here so
        // all of them change together — never per call site.
        secondaryBackgroundColor: Colors.white,
        secondaryBorderColor: HosthubDiploraV1Palette.softGrey,
        secondaryLabelColor: HosthubDiploraV1Palette.outlineButtonLabel,
        secondaryBackgroundColorDark:
            HosthubDiploraV1Palette.surfaceContainerDark,
        secondaryBorderColorDark: HosthubDiploraV1Palette.outlineDark,
        secondaryLabelColorDark: HosthubDiploraV1Palette.onSurfaceDark,
        // A filled destructive button only shows up where destroying *is* the
        // primary action — the confirmation dialog itself. A 20% wash with a red
        // hairline made that button the softest-looking thing in its row, beside
        // a text `Annuleren`: the dangerous choice read as the cautious one.
        // Solid red, white label. The low-weight `Verwijderen` in a modal footer
        // is a text button, and its label falls back to this background, which is
        // now the red it wanted — so it states nothing of its own.
        destructiveBackgroundColor: HosthubDiploraV1Palette.error,
        destructiveLabelColor: Colors.white,
      ),
      segmentedControls: (t) => t.copyWith(cornerRadius: 10),
      dialogs: (t) => t.copyWith(
        backgroundColor: HosthubDiploraV1Palette.backgroundWhite,
        backgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        buttonsLayout: DialogButtonsLayout.horizontal,
        buttonAlignment: DialogButtonAlignment.right,
      ),
      // Body and footer padding come from the library: its default is the 24 the
      // sections use, so a bare-field body and a section body land on the same
      // edge without either being stated here.
      modals: (t) => t.copyWith(
        // Every modal here commits below the content it confirms; saying so once
        // keeps a new call site from inheriting the library's header default.
        actionPlacement: StyledModalSlotPlacement.footer,
      ),
      toasts: (t) => t.copyWith(
        successBackgroundColor: HosthubDiploraV1Palette.success,
        warningBackgroundColor: HosthubDiploraV1Palette.warning,
        errorBackgroundColor: HosthubDiploraV1Palette.error,
        infoBackgroundColor: HosthubDiploraV1Palette.azureDiplora,
      ),
    );
  }
}
