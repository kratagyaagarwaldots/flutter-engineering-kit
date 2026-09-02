---
name: flutter-navigation
description: Wire routes, typed arguments and deep links, and test that they arrive. Use when adding a route, passing arguments between screens, handling a deep link or a notification tap, or fixing navigation that lands on the wrong screen.
---

# Flutter navigation

Route registration currently lives buried in a scaffolding phase, and the entry points that are not
a tap, meaning deep links and notification taps, have no owner at all. Those are the ones that break
in production, because nobody exercises them by hand.

Call the Skill tool with `project-conventions` for the Navigation row first. The three routers differ
enough that the wrong assumption produces code that compiles and never navigates.

## 1. Register the route

Whatever the router, three things hold:

- **The route id belongs to the page**, as a `static const String routeName`, so a caller refers to
  the screen rather than to a string literal that drifts.
- **Arguments are a typed object**, never a raw `Map`. A map moves a missing-key failure from the
  compiler to the moment the user opens the screen.
- **Every route is reachable from a named list**, so the set of screens is enumerable rather than
  discovered.

| Navigation | Registration |
|---|---|
| `onGenerateRoute` | A `switch` on `settings.name`, casting `settings.arguments` to the typed class |
| `go_router` | A `GoRoute` with a path, and arguments in `extra` or as path parameters |
| `auto_route` | An `@RoutePage()` annotation plus codegen |

## 2. Guard the arguments

The cast is where this fails. A route entered from a deep link has arguments the compiler never
checked, and `settings.arguments as ProfileArgs` throws when it arrives as null or as a map.

Handle the absent and wrong-typed cases at the boundary, and land somewhere sensible rather than
crashing:

```dart
final Object? raw = settings.arguments;
if (raw is! ProfileArgs) {
  return _errorRoute(AppStrings.routeArgumentsMissing);
}
```

This matters most for the routes a deep link can reach, which is exactly where hand testing never
happens.

## 3. Deep links and notification taps

These are the same problem: the app is asked to open a screen by something outside it. Both need
answers to four questions, and all four are usually missed.

| Question | Why it bites |
|---|---|
| Is the app cold or warm? | A cold start has no navigator yet, so a tap handled too early is dropped |
| Is the user signed in? | A link to a gated screen must route to sign-in and **resume afterwards**, not discard the destination |
| Is there a back stack? | Landing deep with no stack leaves the user with nowhere to go back to |
| Is the id still valid? | A link to a deleted record needs an empty state, not a crash |

The cold-start case is the one that produces "the notification does nothing sometimes". A tap
arriving before the first frame has no navigator to receive it, so the destination has to be held
and replayed once the app is ready rather than pushed immediately.

Where navigation happens outside the widget tree, from an interceptor, a service or a notification
handler, route through the project's navigation service rather than a captured `BuildContext`. A
context from a disposed widget is the other half of this bug class.

## 4. After an await

```dart
await doSomething();
if (!context.mounted) return;
Navigator.of(context).pushNamed(NextPage.routeName);
```

Every navigation after an `await` needs the guard. The screen can be gone by the time the future
resolves, and the resulting error names the navigator rather than the flow that caused it.

## 5. Test that it arrives

Navigation is testable, and almost never tested:

- **A widget test** asserts that a tap dispatched a navigation, using a mock observer or a stubbed
  navigation service.
- **A unit test** on the argument parsing covers the deep-link cases: valid, absent, wrong type,
  unknown id. This is the cheapest high-value test in this skill, because those are the paths no
  human tries.
- **An integration test** covers the real thing, including cold start. Where no harness exists, tell
  the user to run `/setup-integration-harness`.

Call the Skill tool with `flutter-write-tests` for the shapes.

## Completion criteria

Every new route has a `routeName`, a typed argument class, and a registration in the named list.
Every deep-linkable route handles absent and wrong-typed arguments without crashing.

State which entry points you tested and which you did not: tap, deep link cold, deep link warm,
notification tap cold, notification tap warm. An untested cold-start path is the one most likely to
be broken, so naming it is what stops it shipping unnoticed.
