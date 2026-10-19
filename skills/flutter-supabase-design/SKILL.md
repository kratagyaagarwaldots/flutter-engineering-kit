---
name: flutter-supabase-design
description: The design slot for a Flutter client component: settle or recover the app's design language and write or confirm docs/agents/design.md. Use when asked for a Flutter component's design slot, or when a Flutter app is about to plan or build screens and has no design language written down.
---

# Flutter + Supabase: design

The `design` slot for a client component this kit serves. It returns `docs/agents/design.md`,
written or confirmed. The judgment itself belongs to `flutter-design`; this skill decides which
component it is for and what the request opens.

## 1. Confirm the component

Read the **Components** table in `docs/agents/project.md` and find the row named in the request.
Where it has none, take the Flutter app in the repo: the folder whose `pubspec.yaml` depends on
`flutter`.

A component whose Kind is not `client` has no design language. Say so and return.

The step is done when you have named the component, its Kind and its Path.

## 2. Read what is settled

Read `docs/agents/design.md` where it exists, then the theme and `lib/core/constants/` under the
component's Path, and decide which case this is:

| Case | What the request needs |
|---|---|
| No `design.md`, no screens built yet | Settle the language |
| No `design.md`, screens already built | Recover the language the screens already use, then settle what they disagree on |
| `design.md` exists | Add only the rows the request opens; the rest stands |

The step is done when you have named the case and, for the last one, the rows the request opens.

## 3. Settle it

Call the Skill tool with `flutter-design`, passing the component, its Path, the case and the rows
from step 2.

The step is done when `docs/agents/design.md` exists and every row the request touched is settled
or named as an open question for the user.

## Completion criterion

The answer names the component, the path of `docs/agents/design.md`, whether it was written,
recovered or confirmed, the rows added, and each open question with who answers it.
