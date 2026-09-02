---
name: flutter-write-tests
description: Write the tests for a feature: logic tests at the state seam, widget tests for what the user sees, and goldens for the pixels. Use when writing tests, adding coverage to a feature, or creating tests for new code.
---

# Write tests

Write the tests that map back to acceptance criteria. `flutter-verify` owns which rung a claim
needs; this skill writes rungs 2, 3 and 4.

Where the code does not exist yet, call the Skill tool with `flutter-tdd` instead: it owns the order,
and a test written after the code tests the code rather than the requirement.

## Which test for which criterion

| The criterion is about | Write | Rung |
|---|---|---|
| A status transition, a computed value, error mapping | A logic test | 2 |
| What the user reads, taps, or does not see | A widget test | 3 |
| Matching an approved design | A golden | 4 |

Most criteria want a widget test, and most suites have none. It runs in under a second, needs no
device, and catches the regressions users actually report.

## 1. Logic tests

Call the Skill tool with `project-conventions` for the Logic test tool row, then read the template:

| Logic test tool | Template |
|---|---|
| `bloc_test` | [templates/bloc.md](templates/bloc.md) |
| `ProviderContainer` | [templates/riverpod.md](templates/riverpod.md) |
| `addListener` | [templates/provider.md](templates/provider.md) |

Minimum per action, in every stack:

| Case | Asserted outcome |
|---|---|
| Happy path | Reaches success, carrying the data |
| Null or empty response | Reaches failure, not a success with empty data |
| The call throws | Reaches failure, with the reason preserved |

The middle row is the one most often skipped, and it is the one that produces a screen stuck on a
spinner.

## 2. Widget tests

Pump the widget, assert what is on screen, tap, assert what changed. The wrapper is the only
stack-specific part, and `project-conventions` gives it as the Widget-test wrapper row.

```dart
testWidgets('shows the empty state when there are no items', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: /* the wrapper the project uses, seeded with an empty success state */
          const UserPage(),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text(AppStrings.userEmptyTitle), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsNothing);
});

testWidgets('tapping retry dispatches the action', (tester) async {
  // pump with a failure state, then:
  await tester.tap(find.text(AppStrings.retry));
  await tester.pump();

  // assert the action reached the seam, via a mock or a spy notifier
});
```

Four rules that make the difference between a useful widget test and a flaky one:

- **Find by what the user perceives.** `find.text(AppStrings.retry)` survives a refactor that
  `find.byKey(const Key('btn_2'))` does not. Reach for a key only where the text is duplicated or
  absent.
- **Assert the absence too.** A test that checks the empty state appears, without checking the
  spinner is gone, passes while both render at once.
- **`pumpAndSettle` needs a settling tree.** An infinite animation, including a
  `CircularProgressIndicator` that never leaves, makes it time out. Use `pump(duration)` there.
- **Set a surface size** where the layout depends on it, via
  `tester.view.physicalSize`, and reset it in a `tearDown`. The default test surface is 800x600,
  which is not a phone, and overflow errors that appear only in tests usually come from this.

Where the widget needs an image, use `precacheImage` or a fake asset bundle. A real network image in
a widget test renders as an error box and takes the assertion with it.

## 3. Goldens

A golden asserts the rendered pixels against an approved file. It is the right rung for "it does not
match the design".

```bash
flutter test --update-goldens    # establish the baseline, reviewed by eye once
flutter test                     # thereafter, a pixel diff
```

```dart
testWidgets('user card matches the design', (tester) async {
  await tester.pumpWidget(/* ... */);
  await expectLater(
    find.byType(UserCard),
    matchesGoldenFile('goldens/user_card.png'),
  );
});
```

Two rules keep a golden honest:

- **Establish the baseline before the change**, never after. A baseline captured after the edit has
  approved whatever the edit did, including the regression.
- **Never regenerate to clear a failure** without looking at the diff and saying what changed and
  why. `--update-goldens` on a red suite turns a caught regression into an approved one, silently.

Goldens render differently across machines, mostly through fonts. Where the suite runs in CI, the
baseline has to be generated in the same environment that checks it; `setup-ci` owns that.

## Conventions

The test file's import shape belongs to `flutter-core-architecture`; call it rather than working from
a copy. What is specific to this skill:

- Name each test for what it asserts, so a failure line is a bug report.
- Assert on the fields the criterion is about, not every property. A test asserting everything fails
  on changes it was never written to catch, and gets deleted rather than fixed.
- Derive expected values from the requirement or the design, never by running the code and pasting
  what it produced.
- Use `const` test data wherever the type allows it.
- Close the file with an `AC coverage` group mapping every acceptance criterion to the test proving
  it.

## Completion criteria

Every acceptance criterion appears in the `AC coverage` group against a named test, every action has
the three logic cases above, and `flutter test` passes against the baseline in
`docs/agents/project.md`.

Name any criterion no test here can reach and which `flutter-verify` rung it needs instead. A
criterion silently left uncovered reads as covered, which is worse than an admitted gap.
