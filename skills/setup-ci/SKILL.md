---
name: setup-ci
description: Generate a CI pipeline that runs the verification ladder on every push, and builds per flavor.
disable-model-invocation: true
---

# Setup CI

CI is **the automation of `flutter-verify` rungs 1 to 4**. That framing is the whole scope: the
pipeline runs what a person would run to prove a change works, on every push, so nobody has to
remember to.

What CI does not own is the human-only setup: creating store accounts, generating certificates,
fetching provider keys. `setup-wizard` owns those, and this skill consumes their output as secrets.

Run once per project, then edit the generated config directly.

## 1. Read what the project already does

Everything here comes from `docs/agents/project.md` rather than from a guess:

- **Commands**: install, lint, format, test, codegen
- **Flavors** and how one is selected
- **Secret layers**: a gitignored `.env`, an envied codegen step, a native secrets file
- **Known failing tests**, the baseline the pipeline compares against
- **Platforms** that actually exist

Where the Commands table has a codegen row, the pipeline runs it **before** the analyzer. A build
that analyzes generated code that was never generated fails on missing symbols and looks like a real
error.

## 2. The stages, in ladder order

| Stage | Command | Rung |
|---|---|---|
| Install | The project's install command | — |
| Codegen | The project's codegen command, if any | — |
| Format | `dart format --output=none --set-exit-if-changed .` | 1 |
| Analyze | `flutter analyze` | 1 |
| Test | `flutter test --coverage` | 2, 3, 4 |
| Build | `flutter build apk` / `ipa` per flavor | — |

Fail fast on the cheap stages. A pipeline that runs a fifteen-minute build before a two-second
format check wastes the majority of its failures' feedback time.

## 3. The golden problem

This is the thing that will actually bite, and it lands the moment goldens and CI coexist.

Goldens are pixel comparisons, and pixels differ between machines: font rendering and available font
faces differ between macOS and Linux most of all. A baseline generated on a developer's Mac fails on
a Linux runner while nothing is wrong.

Three workable answers, in order of preference:

1. **Generate goldens in the same environment that checks them.** Run golden tests only on one
   runner OS, and generate the baseline there.
2. **Bundle the font.** Load a project font explicitly in the test harness rather than relying on the
   platform's, so text renders identically everywhere.
3. **Tag them out.** Mark golden tests with a tag and skip them in CI, keeping them a local gate.
   The honest but weakest option, and the pipeline should say the coverage is reduced rather than
   implying rungs 1 to 4 all ran.

Pick one and write down which, next to the golden stage, so the next person does not "fix" the
failures by regenerating the baseline.

## 4. Secrets

Every value from `setup-wizard` becomes a CI secret, referenced by name. Never a literal in the
config, and never echoed in a log: a printed secret is a leaked secret, because build logs are
retained and frequently readable more widely than the repo.

Where the project generates a native secrets file at build time, that generation step runs in the
pipeline from the secrets, rather than the file being committed.

## 5. Signing and upload

Only after the ladder passes. Signing needs the certificate and provisioning profile as secrets, and
the upload needs a store credential.

Where those do not exist yet, stop before this stage and tell the user to run `/setup-wizard`. A
pipeline that builds and verifies is worth having on its own; half-configured signing that fails
every run teaches the team to ignore red builds, which costs more than not having it.

## 6. Prove it

Push a branch and watch a real run. A pipeline that has never run is a configuration file.

Where it fails, fix it before handing over, and where the failure is in the native build rather than
in Dart, call the Skill tool with `flutter-build-failure`.

## Completion criteria

The pipeline has run green at least once on a real push, with the run shown. Every stage maps to a
named rung or is explicitly out of the ladder, and the golden strategy is written down next to the
stage.

Say which rungs CI now covers and which still need a human, so `flutter-verify` claims can be made
against what the pipeline actually proves.
