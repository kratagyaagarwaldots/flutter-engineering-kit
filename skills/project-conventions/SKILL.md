---
name: project-conventions
description: Resolve which state management, serialization, navigation, sizing and test tooling this project actually uses, before generating code. Use before writing Dart that has to match the code already there, or when a skill needs the logic seam, test tool, or widget-test wrapper.
---

# Project conventions

The kit's defaults are one stack. Real projects are many. This skill answers which one the project in
front of you uses, so generated code matches the code already there instead of the code the kit
happens to prefer.

Answer only the rows the caller asked for. A caller writing a DTO needs the serialization row and
nothing else.

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

## Report

One line per row, each naming the file that proves it:

```
Logic seam:          Notifier            lib/features/cart/cart_notifier.dart
Logic test tool:     ProviderContainer   test/features/cart/cart_notifier_test.dart
Widget-test wrapper: ProviderScope       test/features/cart/widget/cart_page_test.dart
Serialization:       freezed             lib/features/cart/model/cart_item.freezed.dart
```

Where a row is genuinely unresolved, say so and name the one question that would settle it. A
greenfield repo with no features yet resolves to the kit's defaults, which
`flutter-core-architecture` owns; say that is where the answer came from.

## Completion criterion

Every requested row is answered with **a file that demonstrates it**, or reported unresolved with
the question that settles it. A row answered from `pubspec.yaml` alone, when a feature existed that
could have confirmed it, is not resolved: the dependency proves availability, not use.
