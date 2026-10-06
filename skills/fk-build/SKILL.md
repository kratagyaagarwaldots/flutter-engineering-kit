---
name: fk-build
description: Build a ticket, spec or sketch to a reviewed, verified commit, choosing the path from what it is given: a change to existing code, a new feature from a design and an endpoint, or a screen before its API exists.
disable-model-invocation: true
---

# Build

Take a settled piece of work and drive it to a commit that has been reviewed and proven, rather than
to code that compiles.

Everything here is a call to a skill that owns its part. This skill owns the **route**, the
**order** and the **gates**, which is what goes missing when work is done ad hoc: the review happens
after the claim of doneness, or the suite is run once at the end and its failures attributed to
something else.

## 0. Route

Read what you were given, then take the first row that fits.

| The work | Path |
|---|---|
| No spec, sketch or numbered acceptance criteria, or criteria naming only the happy path | Stop. Tell the user to run `/fk-plan` first, or call the Skill tool with `grill` when only a criterion or two is missing. |
| A **new feature folder**, with a design and a real endpoint | Call the Skill tool with `flutter-create-feature-e2e`. It runs its own phases and gates; return here only for step 6. |
| A **fixture-mode feature** whose API now exists | Call the Skill tool with `flutter-create-feature-e2e`; it detects upgrade mode from the feature's README. |
| A **new screen** with a design but no API yet | Call the Skill tool with `flutter-create-screen-e2e`. |
| A change to **code that already exists** | Steps 1 to 6 below. |

Where the user wants a cheaper model to do the build, tell them to run `/spec-for-cheap-executor`,
which writes the task doc that model works from.

The step is done when you have named the path and why, in one line, before writing any code.

## 1. Orient

Call the Skill tool with `project-conventions` for the stack, and read `docs/agents/project.md` for
the commands and the known-failing-test baseline. Record the baseline **now**, before writing
anything, so a pre-existing failure is never reported later as your own breakage.

Where the work has no sketch and touches more than a couple of files, call the Skill tool with
`flutter-plan-change` before writing code.

## 2. Build, test-first

For each slice in the sequence, call the Skill tool with `flutter-tdd`. One vertical slice at a
time, each ending green.

Between slices, run the analyzer and the tests for the files you touched. Not the full suite: it is
slow enough that running it per slice is how people stop running it.

Where a slice turns out to need a shape the sketch did not have, say so and call the Skill tool with
`flutter-plan-change` again rather than working around it.

## 3. Gate

Now the full suite, and the analyzer clean:

```bash
flutter analyze
flutter test
```

Compare against the baseline from step 1. Anything worse is yours. A suite reported as green when
the baseline was never zero is the failure this step exists to prevent.

## 4. Review

Call the Skill tool with `flutter-code-review`. It reviews on two axes, and both matter here:
whether the code follows the project's conventions, and whether it does what was asked. Code can
pass every convention and implement the wrong requirement.

Act on the findings, then re-run step 3. A review whose findings are noted and not fixed is a review
that cost time and bought nothing.

## 5. Prove

Call the Skill tool with `flutter-verify`. Name the rung reached for each acceptance criterion, and
name what is not proven and what rung it would need.

Where the work touched security-sensitive surfaces, meaning secrets, storage, network or a webview,
call the Skill tool with `flutter-security-review`.

## 6. Commit

Only when steps 3 to 5 have all passed. Stage the change, write a message saying what changed and
why, and show it to the user before committing. Never push.

Where the branch is the default branch, branch first.

Where the work goes up as a pull request, call the Skill tool with `pr` for its body. The evidence
from step 5 is what fills it.

## Completion criteria

Every acceptance criterion has code, a test naming it, and a verification rung reported. The
analyzer is clean, the suite matches or beats the baseline, and the review findings are resolved
rather than acknowledged.

Report what is **not** done in the same breath as what is: criteria dropped, rungs not reached,
findings deliberately left. A completion report listing only successes is not a report, and the next
person pays for the difference.
