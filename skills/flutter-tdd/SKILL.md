---
name: flutter-tdd
description: Build a change test-first: a failing test at a named seam, then the smallest code that passes it. Use when the user asks for test-driven development, red-green-refactor, a failing test first, or a regression test before a fix.
---

# Flutter TDD

Write the test before the code, so the test is shaped by what the feature must do rather than by
what the code happens to do. A test written afterwards passes because it was written against the
implementation in front of you, which is why it so rarely catches the bug you feared.

This skill owns the loop and the seam choice. It owns no templates and no evidence rules: call the
Skill tool with `flutter-write-tests` for the test shape, and with `flutter-verify` to report what
was proven. Where the target is an existing bug rather than new behaviour, call the Skill tool with
`flutter-diagnose-bug` instead. Its Phase 1 is this same red loop, built for a symptom nobody can
yet explain.

## 1. Pick the seam

Call the Skill tool with `project-conventions` for the Logic seam and Widget-test wrapper rows, then
choose the cheapest seam that can actually express the requirement:

| The requirement is about | Test at |
|---|---|
| A status transition, a computed value, an error mapping | The logic seam |
| Parsing, defaults, a shape change | The model's `fromJson` |
| Which call is made, and what a failure becomes | The repository, with a mocked client |
| Copy, an empty state, a tap dispatching an action | A widget test |
| Pixels against an approved design | A golden |

One requirement, one seam. A requirement that seems to need two is usually two requirements, and
splitting it is the cheaper move.

## 2. Red

Write the test and **run it**. It must fail for the intended reason, which is not the same as
failing. A test that fails on a missing import, a null in the fixture, or a typo in a finder proves
nothing about the behaviour, and it will pass later for reasons equally unrelated.

Read the failure message and confirm it names the assertion you meant to make.

Derive the expected value from the requirement, the design, or the API sample. A value copied from
what the code currently returns tests that the code does what it does.

## 3. Green

Write the smallest change that makes the test pass. Not the general version, not the version
handling the next three cases, and not the refactor you can already see. Those come after, and they
come with the test already protecting them.

## 4. Refactor

With the test green, improve the shape. Run the test after each step. The green bar is what makes
this safe, and it is the only part of the cycle that gets skipped without immediately hurting.

## 5. Next slice

Take the next thin vertical slice, not the next layer. One behaviour end to end beats every model
followed by every repository followed by every bloc: a vertical slice can be demonstrated and gets
feedback, while a horizontal one is only testable once the last layer lands.

Repeat until every acceptance criterion has a test naming it.

## Completion criteria

Every acceptance criterion maps to a test that **was seen to fail before the code existed**, and the
suite is green against the baseline in `docs/agents/project.md`.

Name any criterion you could not drive from a test, the seam it would need, and what was missing.
That sentence is how the gap gets closed rather than quietly reclassified as covered.
