---
name: setup-integration-harness
description: Stand up an integration test harness that boots the real app, prove it runs once, and record it so verification can reach the top rung.
disable-model-invocation: true
---

# Setup integration harness

`flutter-verify`'s top rung drives the real app on a real surface. On most projects that rung reads
"unavailable, no integration harness", and it stays that way because nothing in the kit builds one.
This skill builds it.

Run once per project. The output is a harness in the repo plus a filled-in
`Integration harness` row in `docs/agents/project.md`, which is what makes the rung available to
every later verification.

## 1. Check the three prerequisites

`flutter-verify` names these, and none is an agent's decision. Establish each before writing code,
because a harness missing any of them produces confident output about nothing.

**A safe flavor.** Driving real flows against a live backend creates real records: orders, payments,
messages, push sends. Read the Flavors table in `docs/agents/project.md` for the flavor named safe.

Where the project has no staging environment, stop and say so. That is a finding for whoever owns
the backend, not a problem to work around, and building a harness that hits production is worse than
having none.

**A test account.** Most flows sit behind sign-in. Read where the credential is kept from
`docs/agents/project.md`. Read it from the environment at run time and never write it into a file.

**Startup gates.** Read `lib/main.dart` and list every `await` before `runApp`: crash reporting,
remote config, force-update checks, connectivity, push registration. Each one is something the
driver has to survive. A force-update gate that fails closed will block the app before a single test
runs, and that is the usual reason a first harness never boots.

## 2. Stand it up

```
integration_test/
  app_test.dart          # the first real flow
  helpers/
    boot.dart            # launches the app with the safe flavor and stubbed gates
    finders.dart         # named finders for the surfaces the tests touch
```

`boot.dart` is the part worth care. It calls
`IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, starts the app in the safe flavor, and
neutralises each gate from step 1. Detect readiness by waiting for a widget that only appears once
the app is usable, rather than by sleeping: a fixed delay is the single biggest source of flakiness
in this kind of test, because it is always either too short on CI or wasted locally.

`finders.dart` keeps the selectors in one place, so a renamed label is one edit rather than a hunt
across every test.

Write **one** flow first, end to end, and prefer the one users do most rather than the one that is
easiest to automate.

## 3. Add a doctor

A read-only check answering "could this harness run right now" without running the suite: the safe
flavor resolves, the credential is present in the environment, a device or simulator is attached.

This earns its place the second time someone gets an opaque failure that turns out to be an
unbooted simulator.

## 4. Prove it

Run it. Not "the code looks right", not "it compiles":

```bash
flutter test integration_test/app_test.dart
```

Capture a screenshot at each asserted state, so a failure later has something to compare against.

Where it fails, fix it before handing over. A harness delivered unrun is a harness that does not
work, and the next person will assume the failure is their change rather than the harness.

## 5. Record it

Update `docs/agents/project.md`:

- **Integration harness** row: what it is and how to run it, replacing `none yet`.
- **Drivable surface** row: what it was proven on.
- **Test account** row: where the credential lives, never the credential.

This step is the point of the skill. The harness only helps if `flutter-verify` can find it.

## Completion criteria

The suite runs green in this session, with the command and its real output shown, and the
`Integration harness` row names it. Where a prerequisite was missing, the row says so explicitly and
names what is needed, so the gap is recorded rather than rediscovered.

Say which flows the harness covers and which it does not. A one-flow harness is worth having, and
worth being honest about.
