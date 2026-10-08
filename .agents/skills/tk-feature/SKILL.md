---
name: tk-feature
description: >
  Cross-project convention for building a feature: folder structure, the repository →
  state → view flow, cubit and bloc shape, state objects, DomainError handling, fetch
  sequencing, routes, dependency injection, realtime subscriptions and regression
  tests. Brand-neutral and path-free — the repo's own `<repo>-feature` skill supplies
  key files, the DI container, the route table and the actual error-mapping helper.
  Triggers on: Cubit, Bloc, BlocProvider, BlocBuilder, feature module, state
  management, repository, model, Freezed, GetIt, DI, DomainError, mapError, route,
  realtime subscription, "how does data flow".
user-invocable: true
---

# Feature architecture — shared convention

Data flows one way: **repository → state layer → view**. A widget never reaches past
the state layer, and an error never reaches a widget as a raw exception.

This skill holds the convention. Key files, the DI container, route definitions and
the repo's specific error-mapping helper live in the repo's own feature skill — read
that one too.

It is vendored: copied unchanged from `tk-skills` into each repo that follows it.
Change it there and re-vendor; never edit a copy.

## Layering

| Layer | Owns | Never does |
|---|---|---|
| Repository | the API/database call, mapping failures to `DomainError` | know about widgets or `BuildContext` |
| State (cubit/bloc) | orchestration, side effects, callbacks, holding `DomainError` in state | render |
| View | rendering state, dispatching intent | call a repository, `try/catch` a feature action, hold business logic |

A view that needs data calls a method on the state layer. A view that catches an
exception is a layering bug, not error handling.

## Repository

Whatever the repo's base class or helper, the contract is the same:

- Every failure leaves the repository as a `DomainError`. A raw driver or transport
  exception never escapes.
- An **existing** `DomainError` is rethrown unchanged, so its code and context
  survive. Don't re-wrap it.
- Never swallow an error. An empty result set is a valid result; a failed read is not.
- Include enough context to identify the call — for an edge function, its name.
- When a signature changes, update every call site in the same change. No overload
  shims, no `@Deprecated` bridges.

For edge functions: the client surfaces a non-2xx as a thrown exception, so the
failure path is `catch` + map, never an `if (ok) … else …` on the happy path. Whether
a manual status check is still needed as a belt-and-braces guard differs per client
version — follow the repo's own skill, and never let a status branch *replace* the
catch. Validate the response shape before reading it rather than casting blindly.

## State object

A state is a value object: immutable, equatable, with a `copyWith`. Model progress as
an explicit status rather than a scattering of booleans, and carry the failure in the
state so the view can present it:

```dart
class FeatureState extends Equatable {
  const FeatureState({this.status = FeatureStatus.initial, this.data, this.error});
  final FeatureStatus status;
  final List<Item>? data;
  final DomainError? error;
  ...
}
```

## Cubit

```dart
Future<void> load() async {
  emit(state.copyWith(status: FeatureStatus.loading));
  try {
    final data = await _repository.load();
    emit(state.copyWith(status: FeatureStatus.loaded, data: data));
  } catch (error, stack) {
    emit(state.copyWith(
      status: FeatureStatus.error,
      error: DomainError.from(error, stack: stack),
    ));
  }
}
```

**A cubit never silently swallows an error.** It propagates a `DomainError` through
the state so the view can surface it. Only a genuinely expected empty outcome — no
rows, nothing visible to this user — may emit an empty state; a network, server or
permission failure never may.

Reach for a bloc instead of a cubit when the feature has genuinely distinct events
with their own payloads, or needs event transformation (debounce, throttle, droppable).
Otherwise a cubit is the simpler correct choice.

## Fetch sequencing

Any method that can be invoked again before the previous call resolves — search,
filter, refresh — guards against a stale response overwriting a newer one:

```dart
int _fetchSeq = 0;

Future<void> search(String query) async {
  final seq = ++_fetchSeq;
  emit(state.copyWith(status: Status.loading, query: query));
  try {
    final results = await _repository.search(query);
    if (seq != _fetchSeq) return;            // stale — discard
    emit(state.copyWith(status: Status.loaded, results: results));
  } catch (error, stack) {
    if (seq != _fetchSeq) return;
    emit(state.copyWith(status: Status.error, error: DomainError.from(error, stack: stack)));
  }
}
```

Without it, a slow first request lands after a fast second one and the UI shows the
wrong results with no error anywhere.

## Errors reaching the user

A business error is shown through the app's error presenter, from the state's
`DomainError`. Only field-level validation — an invalid email, a wrong password —
renders inline next to the field. Server, network and permission failures always go
through the presenter, never inline and never as a bare toast.

Where a feature has expected, named failure cases, give them a code and a localized
message rather than surfacing a technical string.

## Lifecycle

- Never construct a cubit or bloc in `build()` — it is recreated on every rebuild.
  Use `initState` or a route-level provider.
- Always `close()` a page-local cubit in `dispose()`.
- Never register a page-local cubit as a DI singleton. Singletons are for
  app-lifetime state.

## Dependency injection

Two mechanisms, used deliberately:

- **Constructor injection** for a feature's own collaborators — explicit, trivially
  testable, and the default.
- **A service locator singleton** for app-lifetime services reached deep in the tree.

Register in layers — services first, then app-level state — so ordering is explicit
rather than incidental.

## Realtime subscriptions

A subscription is state-layer machinery: open it in the state layer, cancel it in
`close()`, and route its events through the same state transitions as a fetch. Never
subscribe from a widget, and never let a subscription error bypass the `DomainError`
path.

## Regression tests

A bug that reached a human means no test covered it. Before closing a fix, write the
test that fails on the current code and passes after, at the layer where the root
cause lives. New cubits, repositories and mappers warrant tests on their own.
