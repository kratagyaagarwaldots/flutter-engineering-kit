---
name: flutter-implement
description: Drive a spec or sketch to a reviewed, verified commit: test-first at the agreed seams, then analyze, test, review and prove.
disable-model-invocation: true
---

# Implement

Take a settled piece of work and drive it to a commit that has been reviewed and proven, rather than
to code that compiles.

Everything here is a call to a skill that owns its part. This skill owns the **order** and the
**gates**, which is the thing that goes missing when work is done ad hoc: the review happens after
the claim of doneness, or the suite is run once at the end and its failures attributed to something
else.

## What this needs

A spec from `/to-spec`, a sketch from `flutter-plan-change`, or an acceptance-criteria list. Where
none exists and the criteria are thin, stop and tell the user to run `/to-spec`, or call the Skill
tool with `grill` to settle them first.

**Where this is a new feature folder with a design and an endpoint**, this is the wrong skill. Tell
the user to run `/flutter-create-feature-e2e`, which scaffolds all five layers from a Figma node and
an API contract. This skill is for changing code that already exists.

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

## Completion criteria

Every acceptance criterion has code, a test naming it, and a verification rung reported. The
analyzer is clean, the suite matches or beats the baseline, and the review findings are resolved
rather than acknowledged.

Report what is **not** done in the same breath as what is: criteria dropped, rungs not reached,
findings deliberately left. A completion report listing only successes is not a report, and the next
person pays for the difference.
