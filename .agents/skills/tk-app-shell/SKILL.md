---
name: tk-app-shell
description: >
  Cross-project convention for the frame every app hangs its features in, on the
  web and on a phone alike: the shell route and navigation (side menu or tab bar),
  the active item derived from the location, deep links and the way back, the leave
  guard, the navigation tree built from the user's permissions, the app's identity
  (its name per environment, version and build, the environment marker outside
  production) and where each comes from, the account row and sign-out, and the
  app-wide error and toast presenters. Brand-neutral and path-free — the repo's own
  skill names the build manifest, the config, the route table and the menu tree.
  Which StyledWidgets component draws each piece is the library's `styled-widgets`
  skill; how a feature's own code is layered is `tk-feature`.
  Triggers on: app shell, ShellRoute, StatefulShellRoute, GoRouter, redirect, deep
  link, navigation, side menu, tab bar, active menu item, back button, leave guard,
  version number, build number, environment badge, app name, PackageInfo, flavor,
  sign out, account menu, permissions, hidden menu item.
user-invocable: true
---

# App shell — shared convention

Every app has a frame around its features: the routes and the navigation that
reach them, the app's own identity, the signed-in account, and the presenters that
show errors and notices. A feature never builds a piece of that frame, and the frame
holds no feature logic.

This skill holds the convention. The repo's own skill names its build manifest, its
config, its route table, its menu tree and its account actions — read that one too.
Which component draws each piece (`StyledSideMenu`, the tab bar, the page scaffold)
and how a page is composed is the `styled-widgets` skill, sections *Pages* and *Web
console*. How a feature's own code is layered is `tk-feature`.

It is vendored: copied unchanged from `tk-skills` into each repo that follows it.
Change it there and re-vendor; never edit a copy.

## Routes and navigation

- **One router, one route table.** Each feature declares its own routes; the app
  composes them into one table. Features navigate through a route's typed handle,
  never a path string built by hand.
- **One shell route around every signed-in route** (a `ShellRoute`, or a
  `StatefulShellRoute` for tabs that keep their own stack), so the navigation is
  built once and survives navigation. Signed-out pages (sign-in, onboarding,
  callbacks) stand outside it.
- **One redirect** decides between signed-out, onboarding and signed-in, from the
  session's state; it refreshes only when the inputs it reads change, not on every
  auth event, so a refresh never rebuilds open pages for nothing.
- **The active item is derived from the location**: one parse function from a path
  to its navigation item, where a nested path selects its parent item. A tab bar
  reads its branch index from the shell. Never keep the selection as state of its
  own: it drifts from the URL on a deep link, a back or a reload.
- **Every page has its own URL** and opens from it directly, signed in or after the
  sign-in it redirects through. A detail opened beside a list is a route of its own
  or restores from a query parameter.
- **The way back does not rely on history.** A sub-page goes back to its parent:
  pop when the route can, otherwise go to the parent's route, so a deep link still
  has a way up. The back control names the parent.
- **Leaving with unsaved work** goes through one leave guard the navigation asks
  before it moves; a page registers whether it has work to lose, and only while it
  has.
- **Selecting the item that is already active does nothing.**

## The navigation tree

- **Built in one place**: one function or list returns the groups and items, from
  the signed-in user's permissions and the app's configuration. Pages never add
  themselves to it.
- **Hidden, not disabled**: an item the user may not use is not in the tree. An item
  that waits on a choice the user can make (no organization picked yet) leads to
  that choice instead of being dimmed.
- **One word per place**: an item's label is the page's title, from the same
  localized key.
- **An item that leaves the app** (an external console, a help site) says so and
  opens in a new tab or the browser.
- **Context switchers** (organization, project, location) belong to the frame: they
  change what every page shows, so their state lives at app level and the pages read
  it.

## The app's identity

The name, the environment and the version each have **one source**, read at
runtime; no screen writes them as literals.

- **Name per environment**: the app's name comes from its build identity (a build
  manifest or flavor config); outside production it carries the environment
  (`… Staging`), from the same source, so a screenshot or a report says which
  environment it shows.
- **Environment**: from the configuration the build was started with, never guessed
  from a URL or a host name at runtime.
- **Version and build**: from the platform's package info (or a build-time define
  the build sets), shown as `version (build)`; never a string kept in the code.
- **Where it shows**:
  - on the web: the side menu's footer, and the sign-in page, so a support question
    can name the build;
  - on a phone: the settings' about row;
  - outside production also an environment marker (a badge or suffix in the
    environment's colour) on the same spots; production shows the version only
    where a user looks for it.
- **One widget** draws the version line with its environment marker, used in each of
  those spots; never a second formatting of the same values.

## Account

- **The account row** (avatar and name) sits in the frame — the side menu's account
  slot, or the settings root on a phone — and opens the account actions (profile,
  password, sign out).
- **Signing out** goes through the auth state layer, which ends the session and lets
  the redirect move the user out; never a navigation call from the row itself.
- Account changes report success with a toast and failures through the error
  presenter, like any feature action.

## App-wide presenters

- **One error presenter** (`showAppError` where the app uses app_errors) and **one
  toast presenter** are wired once, at the frame, for the whole app; libraries with
  a presenter slot (auth screens, error dialogs) get theirs filled there. A raw
  Material notice on screen means a slot was not filled.
- Load errors on a page follow the page states of the `styled-widgets` skill; the
  frame itself never shows an error inline.

## The binding

A repo's own skill names, and does not restate this one:

- the build identity and config — where the name, environment and version come from;
- the route table and the shell — where the shell route, the redirect, the location
  parse function and the leave guard live;
- the navigation tree — the function or list that builds it;
- the version widget and the account actions;
- its deviations from this convention, each with its reason.

## Review checklist

- [ ] No page adds itself to the navigation; the tree is built in one place from
      permissions.
- [ ] The active item (and a branch's `expanded`) comes from the location.
- [ ] A new page has its own URL and a way back to its parent after a deep link.
- [ ] Unsaved work goes through the leave guard.
- [ ] No literal app name, environment or version string on a screen; the version
      line is the one shared widget.
- [ ] Sign-out goes through the auth state layer.
- [ ] No raw Material notice; errors through the one error presenter.
