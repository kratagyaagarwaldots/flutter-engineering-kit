---
name: flutter-supabase-build
description: Build one ticket's slice in a Flutter app and its Supabase backend, test-first, with the backend change landing first, a new feature folder going through the scaffold, a change to existing code through the layer skills, and mechanical slices handed to the layer agents. Use when project-stack asks this kit for its build slot, or when building a slice of a Flutter and Supabase project.
---

# Flutter and Supabase build

The `build` slot for the components this kit serves. The caller owns the route, the order and the
gates: the full suite, the review, the commit. This skill owns how one slice becomes code in this
stack, and hands back the proof for each of its criteria.

## What arrives

The components the slice touches, the slice's acceptance criteria, and a brief of four parts:

| The brief carries | Because the builder otherwise |
|---|---|
| The files to create and modify, and the near-duplicates to leave alone | Tidies code it was not asked to touch |
| Each thing the slice makes obsolete, and an `rg` command that must print nothing once it is gone | Adds the new code and leaves the old in place |
| The test that fails now and passes after the slice, with its current failure message | Reports a no-op as done |
| Which outcomes are normal and which mean failure, such as an empty list or zero rows written | Treats a silent early return as success |

Where a part is missing, write it yourself from the criteria and the code before writing anything
else, and say you did. The step is done when all four parts are in hand.

## 1. Read the stack

Call the Skill tool with `flutter-supabase-conventions` for the rows the slice needs: the Logic
seam, the Logic test tool, the Widget-test wrapper, Serialization and the Data return contract.

The step is done when each of those rows is answered with a file that shows it.

## 2. The backend first

Where the slice touches the Supabase backend, it lands server-side before the app reads it, in this
order:

1. **Migration**: the schema change, as a new file from `supabase migration new <name>`.
2. **Row level security**: a policy for every table the migration creates or the slice newly reads
   or writes, so each user reaches only the rows the criteria give them.
3. **Generated types**: whatever the app derives from the schema, regenerated or updated to match,
   in the Serialization shape step 1 named.
4. **Then the app**, in step 3.

These steps get their own skills soon. Until then, write each one by hand, test-first:

- A database test under `supabase/tests/` that fails before the migration: the table or column
  exists, and a policy lets the owner read a row that a second signed-in user cannot.
- `supabase test db` shows it failing for that reason, before the migration exists.
- `supabase db reset` applies every migration from clean, and `supabase test db` then passes.

The step is done when each backend criterion has a database test that was seen to fail and now
passes from a clean reset, and the app's generated types match the new schema.

## 3. The app

Take the first row that fits:

| The slice | Build it with |
|---|---|
| A **new feature folder**, with or without its API yet, or a **fixture-mode feature** whose API now exists | Call the Skill tool with `flutter-scaffold-feature`. It picks real, fixture or upgrade mode from what exists and runs its own phases. Hand it the criteria and the brief. |
| A change to **code that already exists** | The test-first loop below, with the layer skills. |

For a change to existing code, each criterion goes round the same loop:

1. **Red.** Call the Skill tool with `flutter-write-tests` for the test, at the cheapest seam that
   can express the criterion. Run it, and read the failure: it must name the assertion you meant,
   matching the brief's failure message, not a missing import or a null fixture.
2. **Green.** The smallest change that passes it, through the skill that owns the layer it lands in:

   | Layer | Skill | Agent, for a mechanical slice |
   |---|---|---|
   | Model | `flutter-create-model` | `flutter-repo-engineer` |
   | Repository | `flutter-create-repository` | `flutter-repo-engineer` |
   | State layer | `flutter-create-state-layer` | `flutter-state-engineer` |
   | Screen and widgets | `flutter-create-screen` | `flutter-ui-engineer` |
   | Tests | `flutter-write-tests` | `flutter-test-engineer` |

   Call the Skill tool with the layer's skill; a change spanning two layers is two calls.
3. **Between slices**, run `flutter analyze` and the tests for the files you touched.

The step is done when every criterion has a test that was seen to fail before its code existed and
passes now.

## Delegating a mechanical slice

Once a slice's shape is settled and the rest is typing, hand it to the agent the table names for its
layer. Its brief is the four-part brief you received, unchanged, plus the one skill it calls. In
fixture mode the scaffold keeps the model and repository itself.

When it returns, read its diff, run the brief's `rg` command and the slice's tests yourself, before
the next slice starts. Your check catches what the brief did not.

## 4. Prove

Call the Skill tool with `flutter-supabase-verify` for each criterion, and take the rung it reached.

## Completion criteria

Hand back to the caller:

- The files changed, in each component.
- For each acceptance criterion, the test that proves it, seen failing first, and the rung
  `flutter-supabase-verify` reached.
- The brief's `rg` command and its empty output.
- For a backend change, the migration, the policies and their database tests, and the regenerated
  types.
- What you inferred rather than were given, and each criterion not proven with the rung it needs.

A slice reported done with a criterion missing from that list is not done.
