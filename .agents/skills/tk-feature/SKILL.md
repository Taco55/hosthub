---
name: tk-feature
description: >
  Cross-project convention for how a feature's code is layered and how data and
  errors flow through it: repository → state → view, live reads as the normal case,
  one generic state for a read (`Loadable`) and for a write (`Submission`) run by one
  helper instead of a status enum, a sequence counter and a try/catch per method,
  pure decisions outside the cubit, one-shot effects without flags, the models,
  DomainError handling, lifecycle, dependency injection, test seams and regression
  tests. Not the frame around the features (routes, navigation, app identity,
  account: `tk-app-shell`) and not which component draws a page (the
  `styled-widgets` skill). Brand-neutral and path-free — the API of the state types
  and their helper is the error library's `app-errors` skill; the repo's own
  `<repo>-feature` skill names the repository base, the DI container and the
  backend's specifics.
  Triggers on: Cubit, Bloc, BlocProvider, BlocBuilder, BlocListener, feature
  module, state management, state class, status enum, loading state, repository,
  stream, watch, live read, fetch sequencing, stale response, debounce, optimistic
  update, save, submit, toast after save, navigate after save, model, Freezed,
  fromMap, GetIt, DI, DomainError, Loadable, Submission, CubitSlots, test a cubit,
  fake repository, "how does data flow".
user-invocable: true
---

# Feature architecture — shared convention

Data flows one way: **repository → state layer → view**. A widget never reaches past
the state layer, and an error never reaches a widget as a raw exception. A feature's
code is mostly three kinds of thing: **reads** that keep a screen current, **writes**
the user starts, and **decisions** — filtering, sorting, deriving, validating — that
are plain functions of their inputs.

This skill holds the convention. The API of the shared state types and their helper
is the error library's skill, `app-errors`; what a page shows per state is the
`styled-widgets` skill › "Pages". The repo's own feature skill names the
repository base, the DI container and anything specific to the backend — read that
one too. A feature's routes are composed
by the app's frame: `tk-app-shell`.

It is vendored: copied unchanged from `tk-skills` into each repo that follows it.
Change it there and re-vendor; never edit a copy.

## Layering

| Layer | Owns | Never does |
|---|---|---|
| Model | the data and the rules that are only about it | know about a repository, a widget or `BuildContext` |
| Decisions | pure functions over models: filter, sort, derive, validate | read a clock, a database or a widget |
| Repository | the API or database call; a stream per read; failures as `DomainError` | know about widgets or state |
| State (cubit/bloc) | which read runs, which write starts, what the screen holds | render, or decide what a pure function can decide |
| View | rendering state, dispatching intent, one-shot reactions to outcomes | call a repository, `try/catch` a feature action, hold business logic |

A view that needs data calls a method on the state layer. A view that catches an
exception is a layering bug, not error handling.

## Models

- Immutable values with value equality and a `copyWith` (generated, or by hand for a
  small one). Two reads of the same rows give equal models: a screen that reacts to a
  change must not see one where there is none. A plain class held inside a generated
  model defines `==` and `hashCode` itself.
- Deserialization at the edge, from the wire format (`fromMap`/`fromJson`), and
  serialization back; a round-trip test pins it.
- A model the app creates may default its id and creation time; a model read from
  storage takes them from the row, never from the clock.
- A rule that is only about the data (a total, whether it is complete, the next state
  of a value) is a method or extension on the model, so every caller gets the same
  answer and a test needs no cubit.

## Pure logic

Decisions are plain functions — no Flutter, no state layer, no I/O — and the cubit
only calls them:

```dart
// A decision: testable with two lists and no cubit.
List<Entry> visibleEntries(List<Entry> entries, {required Filter filter}) =>
    [for (final entry in entries) if (filter.accepts(entry)) entry]
      ..sort(byDueDate);
```

A cubit method that grows an `if` ladder over the data is a decision in the wrong
place: move it into a function or a model method, test it there, and leave the cubit
the orchestration. What a function needs from outside (the time, an id) comes in as
a parameter.

## Repository

Whatever the repo's base class or helper, the contract is the same:

- **A read is a stream where the source can tell about changes.** One stream per read
  the screen shows (`watchItems(…)`), which answers at once and again whenever what it
  read changes — another device, another screen, this one's own write. The screen
  never asks for a reload after a write and never knows how the data stays current
  (a sync engine, a subscription, a poll). A one-shot `Future` read is for what has no
  change feed: a search, a server-side report.
- **A repository is an interface** the state layer depends on, with the
  implementation behind it; that is what lets a test hand the cubit a fake.
- Every failure leaves the repository as a `DomainError`, in a `Future` as a thrown
  error and in a stream as an error event. A raw driver or transport exception never
  escapes.
- One conversion handles both: a raw failure becomes a `DomainError`, and converting
  it is its one report; an **existing** `DomainError` comes through the same
  conversion with its code kept, at most with context added, and is not reported
  again. So a repository catches once and converts — no separate branch that rethrows
  a `DomainError`, no re-wrapping it by hand.
- Never swallow an error. An empty result is a valid result; a failed read is not.
- Include enough context to identify the call (the operation, the remote function).
- A write returns when its result is where the reads see it, so the state layer never
  waits on a sync engine or reloads by hand after it.
- Validate a response's shape before reading it rather than casting blindly.
- When a signature changes, update every call site in the same change. No overload
  shims, no `@Deprecated` bridges.

## State of a read: `Loadable<T>`

A screen holds what it read as one generic value with four cases — never a status
enum, a nullable `data` and a nullable `error` side by side, which allow states that
cannot exist ("loaded" without data, "loading" with a stale error): nothing asked
yet, the first read on its way, a value (maybe refreshing, maybe beside a failed
read), or a failure with nothing to show. The cases and their fields are the
`app-errors` skill › "State of a read or a write"; what a page shows in each is the
`styled-widgets` skill › "Pages".

- **Only the value case has a value**, and a `switch` over the four cases is
  exhaustive: the view handles every one, and cannot read data that is not there.
- **What was shown stays**: a value survives a refresh and a failed read.
- **A read's failure is never a dialog or a toast**, in any app: the page says it
  in place. The error presenter is for a write the user started.
- **Read again when it can succeed**: retry on the user's word, and when the
  connection returns while the last read failed.
- A state holds one `Loadable` per read, beside the other fields it needs (the
  query, a selection). Several independent reads are several `Loadable`s, not one
  status.

## Reads and writes in a cubit

The state types and the helper that runs them (`CubitSlots`, with a slot per read
and per write) ship with the error library; its skill holds the API and its exact
semantics. This section holds the rules a feature follows with it. A cubit never
writes them by hand: no status enum, no sequence counter, no
try/convert/`isClosed`/emit per method.

**Reads**

- **A stream is the normal case**; a one-shot read is for what has no change feed.
- **A read of something else** (another list, another account) starts from
  nothing: the slot is reset first, so the previous one's data never shows as
  this one's, not while it loads and not after it fails.
- **A newer read replaces an older one**: a slow first response that lands after a
  fast second one is dropped. A search typed quickly shows the answer to the last
  query, never the slowest. A read that asks something new of the same thing (a
  query) leaves no old answer standing when it fails, and what it asks lands in the
  same state as its loading.
- **The caught failure is converted first** — its one report — and only then dropped
  as stale or shown. A guard that returns early (closed, stale) protects only the
  emit, never the report. Nothing is emitted from `close` on.
- The `op` names the method that starts the read or write (`Owner.method`), so a
  report says where it came from.

**Writes** — a write the user starts and waits on (save, delete, invite) is a
`Submission<R>`, whose cases say whether it is on its way, done or failed.

- **Busy** is the write on its way: the button disables, a row spins. One write at a
  time per slot; one action at a time across several is the cubit's check before it
  starts one.
- **An optimistic change of a read** goes through that read, before the write, so a
  read that started earlier cannot overwrite it. A rollback puts back what the cubit
  captured before the write — never by inverting the change. With a live read it is
  often unnecessary: the write returns when the reads see it.
- **An outcome is an event, not a flag.** A done or failed write equals only itself,
  so the same save done twice is two states. The view reacts to each with a
  listener, and nothing sets the state back:

```dart
BlocListener<ItemsCubit, ItemsState>(
  listenWhen: (previous, current) => previous.save != current.save,
  listener: (context, state) => switch (state.save) {
    Submitted() => Navigator.of(context).pop(),          // or a success toast
    SubmitFailed(:final error) => showError(context, error),
    _ => null,
  },
  child: …,
)
```

  A listener that mounts later does not fire for the standing outcome, so a page
  never pops twice. Never model an effect as a `bool shouldClose` or a `message`
  field that the view clears after showing it.
- **A write that returns before its outcome is known** — a store that sends it
  later — is not a `Submission`: nobody waits on it, and how a screen shows it and
  undoes it is the rule of the library that owns that store.

**A Bloc** keeps its events and handlers and holds the same `Loadable` and
`Submission`, applying their pure transitions in its handlers (`emit.forEach` over
a stream). Reach for a Bloc instead of a cubit only for genuinely distinct events
with their own payloads, or event transformation (droppable, restartable,
throttle).

## Errors reaching the user

A write's error is shown through the app's error presenter, from the state's
`DomainError`. A read's error follows the read rule above. Only field-level
validation — an invalid email, a wrong password — renders inline next to the field.
Server, network and permission failures never render inline in a form and never as a
bare toast.

Where a feature has expected, named failure cases, give them a code and a localized
message rather than surfacing a technical string. A failure a catch had to handle
outside the helper is converted where it is caught, before any guard.

## Test seams

A feature is testable when its collaborators come in, not when its tests reach in:

- **Fakes over mocks.** The cubit takes the repository interface; a test hands it a
  small fake that holds rows in memory and a `StreamController` per watched read, so
  "another device changed it" is one `add`. Mock only what has no sensible fake.
- **Time, ids and randomness come in**: a `DateTime Function() now`, an id generator,
  a `Random` — never `DateTime.now()` or a uuid inside a decision. A debounce or
  timer is tested on a fake clock.
- **Test behaviour, not the emit sequence.** Assert the state the user would see once
  the action settles (`await cubit.rename('x'); expect(cubit.state.save, isA<Submitted>())`),
  or what the page shows. Pin a sequence only where the sequence is the behaviour (a
  loading state shows at once, a rollback follows the optimistic change).
- **Decisions get their own unit tests**, with plain values in and out; the cubit's
  tests then cover the wiring, not every branch of the decision.
- A test of a page pumps it with the real cubit over a fake repository, not a mocked
  cubit, unless the page's own logic is what is under test.

## Lifecycle

- Never construct a cubit or bloc in `build()` — it is recreated on every rebuild.
  Use `initState` or a route-level provider.
- Always `close()` a page-local cubit in `dispose()`; closing ends its reads and
  subscriptions. A cubit that overrides `close` calls `super.close()`.
- A slot is a `late final` field, made once — never a getter, which would make a new
  one on every read.
- Never register a page-local cubit as a DI singleton. Singletons are for
  app-lifetime state.

## Dependency injection

- **Constructor injection** for a feature's own collaborators — repositories, the
  clock, an id generator — explicit, trivially testable, and the default.
- **A service locator singleton** for app-lifetime services, read where the cubit is
  constructed (the route or the provider), never inside the cubit or a widget's logic.
- Register in layers — services first, then app-level state — so ordering is
  explicit rather than incidental.

## Regression tests

A bug that reached a human means no test covered it. Before closing a fix, write the
test that fails on the current code and passes after, at the layer where the root
cause lives — a decision's unit test when a decision was wrong, the cubit's test when
the wiring was. New cubits, repositories, decisions and mappers warrant tests of
their own.
