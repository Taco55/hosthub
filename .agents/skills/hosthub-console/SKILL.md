---
name: hosthub-console
description: >
  The one place for what is HostHub's own about its web console
  (`hosthub_console`): its preset, its frame (shell, menu tree, version, the way
  back), the choices it made within the console rules, and its known deviations.
  The rules themselves are the library's `styled-widgets` skill ("Pages", "Web
  console") and `tk-app-shell`; read those first. Triggers on: console page, side
  menu, SideMenu, console_nav_tree, hosthub_router, SidebarModeCubit,
  StyledSideMenuScaffold, StyledWebPageScaffold, leaveTo, onBack, version footer,
  PackageInfo, page layout, page padding.
user-invocable: true
---

# HostHub Console — the console's binding

The rules for every web console — shell, side menu, page, page types, page states,
layout versus brand, and the review checklist — are the library's `styled-widgets`
skill, sections "Pages" and "Web console"; the frame around the features (routes,
the active item, the way back, the app's name, version and environment, account) is
`tk-app-shell`. This skill is only their binding for this console: where things
are, what HostHub chose, and where it still differs. It never restates a rule or a
layout number. Colours and type are `hosthub-styling`.

## Preset

`HosthubThemePreset.styledTheme`
(`lib/core/widgets/foundation/theme/hosthub_diplora_v1_theme_preset.dart`). Brand
choices there: the palette, the section header styles, panes drawn as cards
(`webPageScaffold.decoratePanes`).

## Frame

- **Shell**: `lib/app/router/hosthub_router.dart` — the shell route with
  `StyledSideMenuScaffold`, a `SelectionArea` around it.
- **Menu tree**: `lib/app/shell/presentation/widgets/console_nav_tree.dart`; the
  menu itself is `side_menu.dart` beside it.
- **Environment**: `AppConfig.current.environment` (`lib/core/config/app_config.dart`).
- **The way back**: a sub-page passes `onBack: () => leaveTo(context, <parent
  path>)` (`lib/app/navigation/console_back.dart`: pop when there is a stack,
  otherwise go to the parent).

## Choices

- The menu starts in the mode the user pinned last (`SidebarModeCubit`); the rail
  expands on hover after `kSidebarHoverIntentDelay`.
- Panes are cards (`decoratePanes`).

## Deviations

Each because the console was built before the shared console rules.

- **The preset sets its own layout**: it does not start from
  `withConsoleLayout()` and sets the page padding, the pane padding and the
  sections' rhythm itself.
- **Card or flat is not decided once**: pages choose `inset` per section.
- **No one version widget**: the menu's footer, the sign-in page
  (`_LoginVersionInfo` in `hosthub_router.dart`, shown in debug builds only) and the
  user settings page each read `PackageInfo` and format it themselves; the menu's
  footer carries no environment marker.
- **The way back takes a path string** (`leaveTo(context, '/sites/$id')`) instead
  of the parent route's typed handle.
- **Page states**: no page uses the library's load notices
  (`StyledDataTable.loadFailure`, `StyledLoadNotice`) yet.
