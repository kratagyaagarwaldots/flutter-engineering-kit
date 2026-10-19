---
name: flutter-supabase-verify
description: The verification rungs and exact commands for a Flutter app or Supabase backend component, and a claim driven up them to the highest rung it needs, with the rung reached named. Use when proving a change in a Flutter + Supabase project works, or when asked for the verify slot of a component this kit serves.
---

# Flutter + Supabase verify

The `verify` slot for every component whose Kit is `flutter-supabase`. It turns the generic ladder
(static, unit, component in isolation, visual baseline, integration, real device, a person) into
the commands this stack runs, and drives a claim up it.

Climb only as far as the claim requires, but **name the rung you stopped on** for each criterion.
A claim reported at a rung below what it needs is the failure this skill exists to prevent.

Read `docs/agents/project.md` first: the component's row of the Components table (its Check and
Test commands), the test account and known failing tests under Verification, and in the
component's own Flutter section the safe flavor under Flavors and the integration harness and
startup gates under Verification surfaces.

## Doctor: run this first

```bash
flutter analyze          # expect: "No issues found!"
flutter test             # compare against the baseline in project.md
```

A dirty analyzer makes every higher rung ambiguous, so fix that before climbing. A failure count
matching the **Known failing tests** row is expected; anything worse is new breakage. Done when the
analyzer is clean and the suite is at or better than the baseline.

## A Flutter app component

### Rung 1 — Static

```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
```

Proves it compiles and matches house formatting. Proves nothing about behaviour.

### Rung 2 — Unit and state layer

```bash
flutter test test/features/<feature>/
flutter test --name '<case>'
```

Proves the state layer emits what the criteria say, and the repository maps errors as the data
return contract requires. Not enough for any claim about what the user sees.

### Rung 3 — Widget

```bash
flutter test test/features/<feature>/widget/
```

Proves the widget tree renders the expected text and responds to taps, pumped in isolation. The
right rung for **copy, empty states, conditional visibility, or that a tap dispatches the right
call**. The workhorse: it catches most UI regressions in under a second. Not enough for navigation
across screens, native permissions, real network, or anything needing the app to boot.

### Rung 4 — Golden

```bash
flutter test --update-goldens        # baseline, reviewed by eye once
flutter test                         # thereafter, a pixel diff
```

Proves the rendered pixels still match an approved baseline. Two rules make it honest. Establish the
baseline **before** the change, never after, or you have approved the regression. And regenerate a
golden only after looking at the diff and saying what changed and why.

### Rung 5 — Integration on a booted simulator

Drives the real app. Whether this rung exists is the **Integration harness** row; when it says
`none yet`, **say so** rather than implying you drove the app. Where a claim needs this rung and the
user wants it built, call the Skill tool with `setup-integration-harness`.

The rung has three prerequisites, none of which an agent decides alone:

1. **A safe flavor.** Driving flows that write real data against a live backend creates real
   records. Use the flavor `project.md` names as safe. With no staging environment this rung is
   unavailable, and that is a finding worth reporting to whoever owns the backend.
2. **A driver that survives startup.** The **Startup gates** row lists every `await` in `main()`
   before `runApp`: crash reporting, remote config, force-update checks, connectivity, push
   registration. A driver tolerates or stubs each one.
3. **A test account**, since most flows sit behind sign-in. Read the credential from the environment
   at run time; keep it out of every file.

With those in place, on the safe flavor:

```bash
flutter test integration_test/<file>
```

against a booted simulator, capturing a screenshot at each asserted state.

### Rung 6 — Real device

The same integration run on an attached physical device. The right rung for anything a simulator
fakes: a permission prompt, a push notification, a payment SDK, a webview, the camera, an image
decoder. Where an upgrade or change touched one of those, drive that flow here.

### Rung 7 — A person

A build on a tester's device, judged by whoever owns the criterion. Name what they must check and
leave the verdict to them.

## A Supabase backend component

Its rungs (migrations applied to a local stack, row-level security policies, edge functions) arrive
with the kit's Supabase skills. Until then, run the component's **Test** command from the Components
table and report that as the rung reached, naming every criterion that needs more.

## Report

For each criterion: the rung, the exact command, and its real output, with the counts pasted rather
than paraphrased. For a bug fix, the same command twice: red before the fix, green after. Write
`<REDACTED>` in place of any secret value that appears in output.

```
Rung 3 (widget). flutter test test/features/<feature>/widget/ → +42 -0.
Not proven: summary step to payment (needs rung 5, unavailable: no staging flavor).
```

## Completion criterion

Every criterion has a rung, a command and its output, or a "not proven" line naming the rung it
needs and what is missing to reach it.
