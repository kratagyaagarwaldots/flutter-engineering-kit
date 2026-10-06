---
name: fk-release
description: Get a build ready to ship: find what it could break and prove the fact its safety rests on, confirm CI gates it, and produce or refresh the store submission pack.
disable-model-invocation: true
---

# Release

Everything between "it works on my machine" and "it is live". A release goes wrong in three
ways: a change breaks something nobody looked at, nothing stopped a broken build, or the store
rejects the submission. Each step below closes one of them, and each calls the skill that owns it.

## 1. Orient

Read `docs/agents/project.md` for the flavors, the safe flavor, and the release commands. Name what
is being released: the version, the commits since the last release, and the target (store, a tester
group, a backend cutover).

## 2. Find what it could break

Call the Skill tool with `release-readiness`. It traces the blast radius past the diff and proves,
by running code, the one fact the release's safety depends on.

Where it finds a failure, stop here. Report it, and leave the fix to `/fk-build`.

## 3. Confirm a gate exists

Look for a CI workflow that runs `flutter analyze` and `flutter test` on every push. Where there is
none, say so and offer to set one up; on a yes, call the Skill tool with `setup-ci`. A release with no
gate is a finding to report even when this one is clean.

## 4. The store pack

Call the Skill tool with `store-compliance` when this is the app's first store submission, or when
the release adds a permission, an SDK, a data type collected, a subscription, or a new market. For
any other release, check that the existing pack under `docs/store/` still matches the app, and name
anything that drifted.

## Completion criteria

Report, in this order:

- The release-readiness result: what was proven, by which command, and anything not proven.
- Whether CI gates the build, and what it runs.
- The store pack: written, refreshed, or confirmed unchanged, with every `TODO (client input
  needed)` item and who owns it.

A release with any of these unknown is not ready, and the report says so in its first line.
