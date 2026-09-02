---
name: flutter-upgrade-deps
description: Upgrade Flutter and Dart dependencies one at a time, with the breaking changes read first and the suite green between each. Use when bumping packages, running pub outdated, upgrading the Flutter SDK, or resolving a version conflict.
---

# Flutter upgrade deps

Upgrade in small steps that each leave the suite green, so a break has exactly one candidate cause.

The failure this prevents: bumping fifteen packages at once, finding the app broken, and having no
way to tell which bump did it. Unpicking that costs more than the upgrades did.

## 1. Start clean

The suite must be green, or matching the baseline in `docs/agents/project.md`, **before** you begin.
Upgrading on top of an existing failure means every later failure is ambiguous.

```bash
flutter analyze && flutter test
git status --short     # a clean tree, so each bump is its own diff
```

## 2. See what is available

```bash
flutter pub outdated
```

Three columns matter: **Current**, **Upgradable** (within your constraints), **Resolvable** (if
constraints change). The gap between Upgradable and Resolvable is where the major versions hide.

Sort the work into three groups, and do them in this order:

1. **Patch and minor within constraints.** Usually safe, and doing them first shrinks the list.
2. **Major versions.** One at a time, changelog first.
3. **The Flutter or Dart SDK itself.** Last, because it can force majors on everything else.

## 3. Read before you bump

For each major version, read the changelog **before** changing the constraint. Not after it breaks:

- The package's `CHANGELOG.md`, at the version you are moving to and every version in between
- Its migration guide, where one exists
- Its GitHub issues, when the changelog is thin, for what other people hit

Where the changelog is unclear on something load-bearing, check the package's source for the symbol
you use rather than assuming. Ten minutes of reading routinely saves an afternoon of compiler
errors whose cause is a renamed parameter.

State what you learned before making the change: which APIs you use are affected, and what has to
change. A bump made without that reading is a guess with a build step.

## 4. One at a time

```bash
flutter pub upgrade --major-versions <package>
dart fix --apply          # mechanical migrations, where the package ships them
flutter analyze
flutter test
```

Then commit that one package on its own, with the version change and anything you had to migrate.
One package per commit gives every future bisect a clean bound.

Where the analyzer breaks in ways `dart fix` cannot handle, migrate by hand and keep the change
confined to that package's API. Bundling an unrelated tidy-up into an upgrade commit destroys the
property that makes this worth doing.

## 5. The SDK

```bash
flutter upgrade
flutter analyze && flutter test
```

An SDK bump also moves the Android and iOS toolchains: Gradle, AGP, Kotlin, the minimum Xcode. Those
failures do not look like Dart failures and are not fixed like them. Call the Skill tool with
`flutter-build-failure` when the break is in the native build rather than in Dart.

## 6. Verify beyond the suite

Some upgrades pass every test and break the app, because the change is in a platform channel, a
push token, a webview, or an image decoder that no unit test touches.

Call the Skill tool with `flutter-verify` and reach the highest rung available. Where the project
has an integration harness, run it; the harness exists exactly for this. Where an upgrade touched a
permission, a notification path or a payment SDK, drive that flow on a device.

## Completion criteria

Every upgraded package is its own commit with the analyzer clean and the suite green at that commit.
For each major version, state what the changelog said and what you migrated.

Name every package you deliberately did **not** upgrade and why: a pinned constraint, a breaking
change too large for now, an abandoned package needing replacement. That list is the value of the
exercise, because the packages you skipped are the ones that will hurt later.
