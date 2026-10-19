# Generated files and lockfiles

The answer to the `conventions` aspect "generated files and lockfiles" for a Flutter component. The
method is the same in any stack: regenerate what is generated, let the package manager write the
lock, merge only source by intent. This file says which files those are here and what rewrites each.

| Conflicted file | Kind | Resolve with |
|---|---|---|
| `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.mocks.dart` | Generated | `dart run build_runner build --delete-conflicting-outputs` |
| `pubspec.lock` | Lockfile | Resolve `pubspec.yaml` by intent, then `flutter pub get` |
| `ios/Podfile.lock` | Lockfile | After `flutter pub get`: `cd ios && pod install` |
| `ios/Runner.xcodeproj/project.pbxproj` | Tool-owned | Take one side, then re-add the other's changes through Xcode |
| A golden `.png` under `test/` | Snapshot | Take one side, run `flutter test --update-goldens` on that test, review the image diff |
| `lib/core/router/exports.dart` | Appended by every branch | Take both sides, keep alphabetical order within each section |

## Generated files

```bash
git checkout --ours <conflicted .g.dart>     # either side; it is about to be overwritten
dart run build_runner build --delete-conflicting-outputs
```

Resolve the source file (the class with the annotation) first, then regenerate.

## Lockfiles

```bash
# resolve pubspec.yaml by intent first, taking both sides' additions
flutter pub get                      # then regenerate pubspec.lock
cd ios && pod install                # same for Podfile.lock
```

## The barrel

`lib/core/router/exports.dart` conflicts on every parallel feature branch, because the single-barrel
convention means every new file adds a line to it. Take both sides, then restore alphabetical order
within each section. Run `flutter analyze` straight after: an unexported new file shows up as an
unresolved symbol.

## Verify

```bash
flutter analyze
flutter test
```

Only update goldens once the merged suite is otherwise green: `--update-goldens` on a red suite
turns a caught regression into an approved one.
