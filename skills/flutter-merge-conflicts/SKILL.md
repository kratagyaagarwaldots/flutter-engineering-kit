---
name: flutter-merge-conflicts
description: Resolve conflicts in a Flutter repo by intent, including the generated files and lockfiles that must be regenerated rather than merged. Use when a merge or rebase conflicts, or when resolving conflicts in .g.dart, pubspec.lock, Podfile.lock, a barrel file or a golden image.
---

# Flutter merge conflicts

Resolve by **intent**: what was each side trying to do. A conflict resolved by picking whichever
hunk looks tidier produces code that compiles and does neither thing.

Work hunk by hunk. Never `--abort` to escape a hard conflict: the work does not get easier later,
and aborting loses the resolution decisions already made.

## 1. Sort the conflicts by kind first

Flutter repos conflict in four distinct ways, and three of them are not merges at all:

| Conflicted file | How to resolve |
|---|---|
| `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.mocks.dart` | **Regenerate**, never merge |
| `pubspec.lock`, `Podfile.lock` | **Regenerate** from the resolved manifest |
| `ios/Runner.xcodeproj/project.pbxproj` | Take one side, then re-add the other's changes through Xcode |
| A golden `.png` | Take one side, then re-run the golden test and review the diff |
| Ordinary Dart | Merge by intent, below |

Doing the mechanical ones first shrinks the real work, and often removes conflicts that only looked
like conflicts.

### Generated files

```bash
git checkout --ours <conflicted .g.dart>     # either side; it is about to be overwritten
dart run build_runner build --delete-conflicting-outputs
```

Resolve the **source** file first, then regenerate. A hand-merged `.g.dart` is wrong the moment
anyone runs codegen, and reviewing one is wasted effort.

### Lockfiles

```bash
git checkout --theirs pubspec.yaml   # resolve the MANIFEST by intent first
flutter pub get                      # then regenerate the lock
cd ios && pod install                # same for Podfile.lock
```

Resolve `pubspec.yaml` properly, taking both sides' dependency additions unless they genuinely
conflict on a version. Then let the tool write the lock.

## 2. The barrel file

`lib/core/router/exports.dart` conflicts on **every** parallel feature branch, because the
single-barrel convention means every new file adds a line to one file. This is the kit's own
recurring tax, and it has a fixed recipe:

**Take both sides.** Export lines are additive; two branches adding different files are not in
conflict, they only touched adjacent lines. Keep every line from both, then restore alphabetical
order within each section.

Then check nothing was lost:

```bash
flutter analyze     # an unexported new file shows up as an unresolved symbol
```

The failure to avoid is resolving with `--ours` and silently dropping the other branch's exports.
The analyzer catches it, which is why it runs immediately after.

## 3. Ordinary Dart, resolved by intent

For each hunk, establish what each side wanted before writing anything:

```bash
git log --merge -p -- <path>    # the commits from both sides touching this file
git log --oneline HEAD..MERGE_HEAD -- <path>
```

Read the commit messages. Where a side's intent is still unclear, read the spec or the issue it
references rather than inferring from the diff.

Then, in order of how often it applies:

- **Both changes belong** and touch different things. Keep both.
- **Both changed the same behaviour** differently. This is a real decision, not a merge: pick one,
  say why, and tell whoever wrote the other side.
- **One side deleted what the other edited.** Deletion usually wins, since it was deliberate, but
  confirm the edit was not the reason to keep it.
- **A rename against an edit.** Take the rename, then reapply the edit to the new name. Git often
  cannot see this, and it surfaces as a whole file conflicting.

## 4. Verify, do not assume

A resolved merge compiles far more easily than it is correct, because both sides individually
compiled.

```bash
flutter analyze
flutter test
```

Then, specifically: run the tests **from both sides** of the merge. A conflict resolved by dropping
one side's logic leaves that side's tests failing, and that is the fastest signal that intent was
lost. Where either side changed a screen, call the Skill tool with `flutter-verify` and reach a
widget or golden rung rather than trusting the analyzer.

## Completion criteria

Every conflicted file is resolved, generated files and lockfiles are regenerated rather than merged,
the analyzer is clean, and the suites from **both** sides pass.

Name every hunk where you chose one side's behaviour over the other, and why. That list is what the
other author needs to see, and it is the part a silent resolution loses.
