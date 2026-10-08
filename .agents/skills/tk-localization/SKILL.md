---
name: tk-localization
description: >
  Cross-project convention for ARB-based localization: how keys are written and named,
  how translations are added and regenerated, how strings are read in and outside a
  widget, and which patterns are forbidden. Brand-neutral and path-free — the repo's
  own `<repo>-localization` skill supplies ARB locations, the generated class name,
  the context accessor and the regen command. Triggers on: ARB, intl, l10n,
  localization, translation, plural, ICU, placeholder, S.of, S.current, context.s,
  update_translations, intl_utils, locale switching, hardcoded string.
user-invocable: true
---

# Localization — shared convention

Every user-facing string comes from ARB. No exceptions for "just this one label", and
no branching on the active language in Dart.

This skill holds the convention. Which packages own which ARB files, what the
generated class is called, how it is reached from a `BuildContext`, and the exact
regeneration command live in the repo's own localization skill — read that one too.

It is vendored: copied unchanged from `tk-skills` into each repo that follows it.
Change it there and re-vendor; never edit a copy.

## Reading a string

Prefer the context-bound accessor: it rebuilds when the locale changes. Use the
static accessor only where there is no context — cubits, services, error mappers.

**Never assign the accessor to a local variable.** Call it inline:

```dart
// ❌
final l10n = S.of(context);
return Text(l10n.save);

// ✅
return Text(S.of(context).save);
```

The rule is about aliasing the accessor, not about reuse: a derived *value* used two
or more times may stay local (`final emailHint = S.of(context).email;`). It applies
regardless of the alias name (`l10n`, `intl`, `t`, `s`).

```bash
rg -n "final \w+ = (S|A|UiIntl)\.of\(context\)" apps packages -g "*.dart"
```

## ARB format

```json
{ "save": "Save", "@save": { "description": "Button label" } }
```

Placeholders carry a type and an example; that metadata block is the contract the
generator validates against:

```json
{
  "welcomeUser": "Welcome, {name}",
  "@welcomeUser": {
    "placeholders": { "name": { "type": "String", "example": "Alex" } }
  }
}
```

Plurals use ICU, and may be combined with a literal count:

```json
{ "daysCount": "{count, plural, one{{count} day} other{{count} days}}" }
{ "itemsFound": "{count} {count, plural, =1{item} other{items}} found" }
```

### Key naming

| Kind | Shape |
|---|---|
| Plain label | `save`, `cancel`, `add` |
| Domain noun | `patientName`, `listTitle`, `organizationTitle` |
| Action | `addPatient`, `discardChanges` |
| Counted unit | `daysCount`, `itemsFound` |
| Error | `errorDeviceNotFound`, `errorNetworkUnavailable` |

## Adding a translation

1. Add the key and value to the **source-of-truth locale** (`intl_en.arb`).
2. Add the same key to **every other locale**. A missing key in a translated locale
   silently falls back to the source language; a missing key in the source locale is
   a build failure.
3. Add the `@key` metadata in the source locale: a `description`, and `placeholders`
   with type and example where the string takes arguments.
4. Regenerate through the repo's own command.
5. Only then reference the key from Dart — referencing before regenerating does not
   compile.

**Never run the generator from a monorepo root.** `intl_utils` falls back to defaults
there and writes a stray `lib/l10n/` and `lib/generated/` at the root. Use the repo's
workspace-aware script, or run the generator inside the owning package. Delete any
stray root `lib/` that appears.

## Anti-patterns

**No hardcoded user-facing strings.** Labels, errors, button text, dialog copy, toast
titles and table column headers all come from ARB — reusable headers included.

**No inline locale branching.** The language is the localization layer's business:

```dart
// ❌
final label = isNl ? 'Patiënt' : 'Patient';
final title = switch (lang) { 'nl' => 'Apparaat', _ => 'Device' };
```

```bash
rg -n "isNl|isEn|switch \(\s*(lang|locale|languageCode)" apps packages -g "*.dart"
```

**Never hand-edit generated output.** Only ARB files are edited; the generated
classes are rebuilt by the regen command.

## Delegates

Register the per-package delegate and its supported locales on the app shell. A
shared UI package's delegate is typically registered by the shell already — check
before adding it a second time.
