---
name: flutter-verify
description: Prove a Flutter change actually works before calling it done. Use after implementing a feature or fixing a bug, when asked to verify or confirm something works, or when a scaffolding skill reaches its verification phase.
---

# Flutter verify

"It compiles" and "the bloc test passes" are not proof that a screen works. This skill is the ladder
from cheapest signal to real proof, plus the rule for which rung a given claim needs.

Climb only as far as the claim requires, but **name the rung you stopped on** in your reply. A claim
reported at a rung below what it needs is the failure this skill exists to prevent.

Read `docs/agents/project.md` first, for the commands, the known-failing-test baseline, the safe
flavor, and the startup gates.

## Doctor: run this first

```bash
flutter analyze          # expect: "No issues found!"
flutter test             # compare against the baseline in project.md
```

A dirty analyzer makes every higher rung ambiguous, so fix that before climbing.

**Check the baseline before reporting a failure as yours.** `docs/agents/project.md` records the
tests already failing on a clean checkout. A count matching the baseline is expected; anything worse
is new breakage. Reporting a pre-existing failure as your own wastes a round, and reporting the
suite as green when the baseline is not zero is worse.

## The ladder

### Rung 1 — Static

```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
```

Proves it compiles and matches house formatting. Proves nothing about behaviour, so never the final
rung for a behaviour claim.

### Rung 2 — Unit and bloc

```bash
flutter test test/features/<feature>/
flutter test --name '<case>'
```

Proves the state machine emits what the criteria say. The right rung for a claim about **status
transitions, repository error mapping, or a computed value**. Not enough for any claim about what
the user sees.

### Rung 3 — Widget

```bash
flutter test test/features/<feature>/widget/
```

Proves the widget tree renders the expected text and responds to taps, pumped in isolation. The
right rung for a claim about **copy, empty states, conditional visibility, or that a tap dispatches
an event**.

This rung catches most UI regressions in under a second, so reach for it before anything heavier. It
is the workhorse of the ladder. Not enough for navigation across screens, native permissions, real
network, or anything needing the app to boot.

### Rung 4 — Golden

```bash
flutter test --update-goldens        # baseline, reviewed by eye once
flutter test                         # thereafter, a pixel diff
```

Proves the rendered pixels still match an approved baseline. The right rung for **"it doesn't match
the design"**, which on design-driven client work is a recurring round.

Two rules make it honest. Establish the baseline **before** the change, never after, or you have
approved the regression. And never regenerate a golden to make a failing test pass without looking
at the diff and saying what changed and why.

### Rung 5 — Device drive

Drives the real app on a real surface. Whether this rung exists is recorded in
`docs/agents/project.md`; when the integration-harness row says `none yet`, **say so** rather than
implying you drove the app.

Standing it up has three prerequisites, none of which an agent decides alone:

1. **A safe flavor.** Driving flows that write real data against a live backend creates real
   records. Use the flavor `project.md` names as safe. If the project has no staging environment,
   this rung is unavailable, and that is a finding worth reporting to whoever owns the backend.
2. **A driver that survives startup.** `project.md` lists the gates in `main()` — crash reporting,
   remote config, force-update checks, connectivity, push registration. A driver has to tolerate or
   stub each one.
3. **A test account**, since most flows sit behind sign-in. Never write the credential into a file;
   read it from the environment.

With those in place: `integration_test` plus `flutter test integration_test/<file>` against a booted
simulator or attached device, capturing a screenshot at each asserted state.

## Evidence

State the rung, the exact command, and its real output. Paste the counts, not a paraphrase. Never
report a command you did not run in this session.

For a bug fix, evidence is the **same command twice**: red before the fix, green after. One green run
proves the code passes a test, not that it fixed anything.

Redact before pasting. A gitignored `.env`, generated secret files, and env accessors carry live
keys; write `<REDACTED>` in place of any value that appears in output.

## Reporting

Two lines, always:

```
Rung 3 (widget). flutter test test/features/<feature>/widget/ → +42 -0.
Not proven: navigation from the summary step to payment (needs rung 5, unavailable — no staging flavor).
```

An honest "not proven" is worth more than a confident claim at the wrong rung. When a criterion
cannot be proven at any available rung, say which rung it needs and what is missing; that sentence is
how the gap gets closed instead of forgotten.
