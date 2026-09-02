---
name: flutter-build-failure
description: Diagnose a native build failure: Gradle, AGP, Kotlin, JDK, CocoaPods, Xcode or signing. Use when the build fails before Dart compiles, when pod install or Gradle errors, when a build works on one machine but not another, or after an SDK upgrade breaks the native side.
---

# Flutter build failure

The build breaking before your Dart code compiles is a different problem from a bug, and
`flutter-diagnose-bug` cannot help: its method starts with a failing *test*, and there is no test
for a Gradle version conflict.

These failures are almost always **a version mismatch between toolchain layers**, and the error
message almost never names the layer that is wrong.

## 1. Read the real error

Build output buries the cause in noise. Get to it:

```bash
flutter run -v 2>&1 | tail -100          # verbose, then the tail
cd android && ./gradlew assembleDebug --stacktrace   # Gradle's own error, not Flutter's wrapper
cd ios && pod install --verbose
```

Read from the **first** error, not the last. The last is usually "build failed"; the first names the
task and often the version.

Discard the summary line. "Execution failed for task ':app:compileDebugKotlin'" is where the failure
surfaced, and the cause is above it.

## 2. Establish the version matrix

Most of these failures are one of these six numbers disagreeing with another. Collect all of them
before theorising:

```bash
flutter --version                        # Flutter and the Dart it bundles
java -version                            # the JDK Gradle will use
cat android/gradle/wrapper/gradle-wrapper.properties   # Gradle
grep -rn "agp\|com.android.tools.build" android/       # Android Gradle Plugin
grep -rn "kotlin" android/settings.gradle* android/build.gradle*
xcodebuild -version                      # Xcode
cat ios/Podfile | head -20               # iOS deployment target
```

The constraints that actually bind:

| Layer | Constrained by |
|---|---|
| AGP | Gradle version, and the JDK |
| Gradle | The JDK. A new JDK with an old Gradle is the single most common break |
| Kotlin | AGP, and any plugin shipping Kotlin code |
| `compileSdk` | Every plugin's requirement; the highest one wins |
| `minSdk` | Every plugin's floor; the highest one wins |
| iOS deployment target | Every pod's floor; the highest one wins |

## 3. Match the symptom

| Error says | Usually means |
|---|---|
| "Unsupported class file major version" | JDK too new for this Gradle |
| "Dependency requires at least JVM target 11" | Kotlin `jvmTarget` below what a plugin needs |
| "requires a higher minSdkVersion" | A plugin's floor is above yours; raise `minSdk` |
| "Manifest merger failed" | Two plugins declaring conflicting manifest entries |
| "CocoaPods could not find compatible versions" | `Podfile.lock` stale, or a pod needing a higher target |
| "Module not found" after adding a plugin | Pods not installed since the change |
| "No profile matching" / signing errors | Provisioning, not code |
| Works locally, fails in CI | An unpinned toolchain version somewhere |

## 4. Try the cheap resets first

Genuinely stale artefacts cause a real share of these, and ruling that out is fast:

```bash
flutter clean && flutter pub get
cd ios && rm -rf Pods Podfile.lock && pod install --repo-update
cd android && ./gradlew clean
```

`rm -rf ~/.gradle/caches` where a corrupt cache is suspected, knowing it costs a long re-download.

Where a reset fixes it, say so plainly. "It was a stale pod lockfile" is a real diagnosis. Where a
reset fixes it and it comes back, the reset was not the fix and something is regenerating the bad
state.

## 5. Change one number

Raise or pin **one** version, then rebuild. The layers constrain each other, so two changes at once
leaves you unable to tell which mattered, and version churn in the native build is expensive to
unpick.

Prefer raising the constrained layer over lowering the constraint: bump Gradle to suit the JDK
rather than installing an older JDK, because the JDK is shared with everything else on the machine.

## 6. Record it

A native build fix is invisible in Dart and will be rediscovered by the next person, so put it in
`docs/agents/project.md` under Commands or a deviations note: the versions that work together, and
any step a fresh clone needs.

Where the fix was a human-only step, meaning a certificate, a provisioning profile, a store account
or a local SDK install, call the Skill tool with `setup-wizard` to make it repeatable.

## Completion criteria

The build succeeds, and you can name **which version disagreed with which**. A build fixed by
changing several things at once with no explanation is a build that will break again the same way.

Where the fix was a reset rather than a change, say that, and say what you think regenerated the bad
state.
