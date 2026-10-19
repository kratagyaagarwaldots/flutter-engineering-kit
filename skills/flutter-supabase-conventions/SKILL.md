---
name: flutter-supabase-conventions
description: The conventions slot for a Flutter + Supabase component: which state management, serialization, navigation, sizing and test tooling this project actually uses, plus its test layout, review baseline, generated files and lockfiles, and debugging tools, each shown by a file. Use before writing Dart that has to match the code already there, when a component's conventions are asked for, or when a skill needs the logic seam, test tool, or widget-test wrapper.
---

# Project conventions

This is the kit's `conventions` slot: asked how code is written in a Flutter + Supabase component,
it answers for the rows and aspects asked, one line each, with a file that shows it.

The kit's defaults are one stack. Real projects are many. This skill answers which one the project in
front of you uses, so generated code matches the code already there instead of the code the kit
happens to prefer.

Answer only the rows and aspects the caller asked for. A caller writing a DTO needs the
serialization row and nothing else.

## Resolve from the table

Read the **Architecture** table in `docs/agents/project.md`. Each row decides one thing:

| Row | What it decides |
|---|---|
| Logic seam | Where behaviour lives, and what a unit is for testing |
| Logic test tool | How that seam is driven in a test |
| Widget-test wrapper | What a widget is wrapped in to pump it |
| Dependency injection | How a repository reaches the seam |
| Serialization | Whether a DTO is hand-written or generated |
| Navigation | How a route is registered and its arguments typed |
| Data return contract | What a repository method returns on success and on failure |
| Sizing strategy | Whether sizes are fixed tokens or scaled at the callsite |

## Resolve from the repo

When `docs/agents/project.md` is absent, or a row is blank, read the repo and say that is what you
did. Three sources, in increasing authority:

1. **`pubspec.yaml`** names what is available: `flutter_bloc`, `flutter_riverpod`, `provider`, `get`,
   `go_router`, `auto_route`, `freezed`, `json_serializable`, `flutter_screenutil`.
2. **An existing feature** under `lib/features/` shows the shape in use. Prefer this over
   `pubspec.yaml`, because a project keeps depending on packages it has stopped writing against.
3. **`test/`** shows the test tooling actually in play, which is the row most often stale in the
   table.

Where the table and the code disagree, **the code wins**. Report the mismatch and offer to correct
the row, so the next skill reads something true.

## Aspects

A caller may ask for an aspect rather than a row. Answer each the same way: one line per item, each
naming the file in this repo that shows it, with the kit default named where the repo has none yet.

### Test tooling and layout

The Logic test tool and Widget-test wrapper rows, plus:

| Item | Kit default | Confirm from |
|---|---|---|
| Test command | `flutter test`, one file with `flutter test <path>` | The component's Test column in `docs/agents/project.md`'s Components table; single-file runs in its Flutter section's Commands |
| Test file | `test/` mirrors `lib/`; `lib/features/x/y.dart` is tested in `test/features/x/y_test.dart` | An existing `_test.dart` beside the feature |
| Test imports | The barrel, then the dev-only test packages directly; `flutter-core-architecture` owns this | An existing test's imports |
| Mocking | Whichever of `mocktail` or `mockito` is in `dev_dependencies` | `pubspec.yaml` and an existing test |
| Logic seam | Driven by the Logic test tool, one test per action | An existing state-layer test |
| Widget | `pumpWidget` inside the Widget-test wrapper, seeded with a state | An existing widget test |
| Repository | The Supabase client, or the data source the repository wraps, mocked | An existing repository test |
| Model | `fromJson` fed a literal payload saved from a real response | An existing model test |
| Goldens | `goldens/` beside the test; the baseline set by `flutter test --update-goldens` | A `.png` under `test/` |
| Integration | `integration_test/`, run on a simulator or device | The Integration harness row |

Call the Skill tool with `flutter-write-tests` for the shape of each test.

### Review baseline

What a review checks in a Flutter component, on top of the project's documented rules. Each reads
*what it is* → *why it matters here*, and each is a judgement call. Where a row or a file decides
the item, name it beside the item.

- **Widget-helper methods.** A private method returning a `Widget` instead of a `StatelessWidget`
  class. → Breaks `const` construction and rebuild scoping; the whole parent rebuilds.
- **Business logic in `build`.** Computation, formatting, or branching that belongs in the logic
  seam or a model. → Untestable without pumping a widget.
- **`BuildContext`, navigation, or snackbars in the state layer.** → Couples state to presentation
  and breaks its tests.
- **A sizing strategy other than the Sizing strategy row.** → Two competing scale systems in one
  tree.
- **A font size scaled at the callsite.** → Overrides the OS text-scale setting a user chose for
  legibility, so the app ignores an accessibility preference.
- **`dynamic`, or an unchecked cast off JSON.** → Moves a parse failure from the boundary to a
  random later frame.
- **A repository that swallows an error into a bare `null`** where the Data return contract row
  returns a typed failure. → The UI cannot tell "empty" from "broken".
- **Missing state coverage.** A status enum whose `loading`, `failure`, or empty case has no branch
  in the UI. → The single most common source of a feedback round.
- **`setState` in a screen whose state the Logic seam already owns.** → Two sources of truth for one
  screen.
- **An unbounded `ListView` or a rebuild over an unkeyed list.** → Jank and lost scroll position.
- **A `dispose` that does not cancel** a subscription, controller, timer, or Supabase realtime
  channel it created. → Leaks, and a channel left open keeps delivering to a dead screen.
- **A new file outside the barrel** the Barrel path row names, or not exported from it. → Compiles
  locally, breaks the next importer.
- **A hand-edited generated file.** → The next codegen run overwrites it; see Generated files and
  lockfiles below.
- **A test that cannot fail**, in its Flutter shapes: only `findsWidgets`, `isNotNull` or
  `verify(...).called(1)`, an expected value computed by the code under test, or a restated
  constant. → Costs CI time and catches nothing.

Skip anything `flutter analyze` already enforces.

### Generated files and lockfiles

Which files are generated here and what rewrites each:
[references/merging.md](references/merging.md). In short: `*.g.dart`, `*.freezed.dart`,
`*.gr.dart` and `*.mocks.dart` are regenerated by `build_runner`, never merged by hand;
`pubspec.lock` is rewritten by `flutter pub get` once `pubspec.yaml` is resolved; `Podfile.lock` by
`pod install`.

On the Supabase side, generated database types (a `database.types.ts` for Edge Functions from
`supabase gen types typescript`, or Dart models from a schema generator) are regenerated from the
migrated schema, never merged. A migration under `supabase/migrations/` that has run anywhere is
never edited; a change to it is a new migration with a later timestamp.

Confirm from the repo: `build.yaml`, `l10n.yaml`, `dev_dependencies` in `pubspec.yaml`, and any
`linguist-generated` lines in `.gitattributes`.

### Debugging tools

What runs each rung of a debugging loop here, the instruments, and the causes worth listing:
[references/debugging.md](references/debugging.md). For the Supabase side:

- **A select blocked by row-level security returns an empty list, not an error.** "No data" can be a
  policy; check it before suspecting the query.
- The dashboard's Logs Explorer covers API, Postgres, Auth and Edge Functions; locally,
  `supabase status` and `supabase functions serve` show the same.
- A build or toolchain failure: call the Skill tool with `flutter-build-failure`.
- Jank or a rebuild storm: call the Skill tool with `flutter-performance`.

### Security

The platform checks for a Flutter app and its Supabase backend: secure storage, transport, deep
links, webviews, and row-level security, keys and Edge Function auth on the backend. Call the Skill
tool with `flutter-security-review`, which answers each with a file and line, or runs as a full audit
on its own.

### Dependencies

What is behind, and where each version is pinned: `flutter pub outdated` for packages, the Flutter
and Dart constraints in `pubspec.yaml`'s `environment:`, `minSdk`/`targetSdk` in
`android/app/build.gradle.kts`, the iOS deployment target in `ios/Podfile`, and `supabase --version`
against the CLI version the project's scripts expect. Moving any of them is `flutter-upgrade-deps`.

### Planning tables

The tables a feature is planned in before any layer is built, one per layer with every row filled,
are `flutter-scaffold-feature`'s planning phase. Call the Skill tool with `flutter-scaffold-feature`
and stop once its tables are written and agreed.

## Report

One line per row or aspect item, each naming the file that proves it:

```
Logic seam:          Notifier            lib/features/cart/cart_notifier.dart
Logic test tool:     ProviderContainer   test/features/cart/cart_notifier_test.dart
Widget-test wrapper: ProviderScope       test/features/cart/widget/cart_page_test.dart
Serialization:       freezed             lib/features/cart/model/cart_item.freezed.dart
Mocking:             mocktail            test/features/cart/cart_repository_test.dart
```

Where a row is genuinely unresolved, say so and name the one question that would settle it. A
greenfield repo with no features yet resolves to the kit's defaults, which
`flutter-core-architecture` owns; say that is where the answer came from.

## Completion criterion

Every requested row and aspect item is answered with **a file that demonstrates it**, or reported
unresolved with the question that settles it. A row answered from `pubspec.yaml` alone, when a
feature existed that could have confirmed it, is not resolved: the dependency proves availability,
not use.
