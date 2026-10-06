---
name: takeover-audit
description: Audit an inherited Flutter codebase before committing to work on it, covering whether it builds, what its tests prove, how far it has drifted, where the risk sits, and what must be stabilised first. Use when /fk-setup finds a project this team did not write, or when the user asks to assess a codebase they are taking over.
---

# Takeover audit

An inherited app arrives with claims ("it works", "it is nearly done", "it only needs one more
feature") and nobody left to ask. The audit replaces the claims with evidence before anyone gives an
estimate. Everything here is observation: record what is broken, and leave the repair to tickets.

Read `docs/agents/project.md` first. `/fk-setup` has already recorded the stack, the platforms and
the test baseline; reuse them rather than re-deriving them.

## 1. Does it build

For each platform in `project.md` this machine can build (iOS needs macOS), build it in debug:

```bash
flutter build apk --debug
flutter build ios --debug --no-codesign
```

Where a build fails before Dart compiles, call the Skill tool with `flutter-build-failure` to find
the cause, and record the cause without fixing it. Then call the Skill tool with `flutter-verify`
for the highest rung this project can reach today, and whether the app launches there.

The step is done when every platform has a recorded result: builds, or fails with a named cause.

## 2. What is there

Call the Skill tool with `flutter-explain` for a map of the app: its features, how state and data
flow, how navigation works, what the startup sequence does. Write it as the list of modules the app
actually has, each with what works and what is stubbed, half-built or dead. This becomes the
proposal's **Existing** column.

## 3. What the tests prove

Take the counts from the baseline. Then check what they cover: do the flows that matter most
(sign-in, payment, anything that writes data) have a test at any rung? A suite of passing tests over
the wrong code proves little, so name the critical flows with no test at all.

## 4. Drift

```bash
flutter pub outdated
```

Count the packages a major version behind, and any marked discontinued. Compare the SDK constraint
with the current stable release, and the Android `targetSdk` and iOS deployment target with what
each store currently requires for a new release. A store requirement the app misses blocks the next
update, whatever else is true.

## 5. Risk

Call the Skill tool with `flutter-security-review`. Then check what it does not:

- Secrets in git history, not only in the working tree: `git log -p -S` on the obvious key prefixes.
- A signing keystore or an API key file committed to the repo.
- Who holds the developer accounts, the signing keys and the backend: if nobody on this side does,
  that is the first blocker.
- The version in `pubspec.yaml` against the version live in each store.

## 6. Write it up

Write `docs/vault/audit.md` and link it from the vault index:

```markdown
# Audit, YYYY-MM-DD

**Verdict:** <stabilise first | workable as is | rewrite candidate>, because <the deciding evidence>.

## Builds

| Platform | Result | Cause |
|---|---|---|

## Modules as found

| Module | Works | Stubbed or broken |
|---|---|---|

## Findings

| # | Severity | Area | Finding | Evidence |
|---|---|---|---|---|
```

Severity is **blocker** (cannot build, sign or ship), **high** (security, store rejection, data
loss), **medium** or **low**. Evidence is a command and its output, or a `file:line`.

A rewrite is a recommendation the user weighs, never the default. Where you make it, give the cost
of both paths in the same terms.

Then show the blockers and highs as tickets, `type:chore` or `type:bug` with points, and on a yes
call the Skill tool with `project-tracker` to file them. Stabilisation goes first in the first
sprint.

## Completion criteria

Every platform has a build result. Every finding has evidence and a severity. The verdict names the
evidence it rests on. Every blocker and high finding is filed as a ticket or explicitly waived by
the user.
