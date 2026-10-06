---
name: ask-kit
description: Ask which kit skill fits what you are about to do. A router over every skill in the engineering kit.
disable-model-invocation: true
---

# Ask kit

Name **one** skill, say why in a sentence, and state what it needs before it can start. When two
fit, name the narrower one first and the broader as a fallback. If the request is too vague to
route, ask the one question that separates the candidates.

Do not do the work, and do not run the routed skill. Where the answer is a command, tell them to
type it; only a human can start one.

## The commands

Most work starts with one of these. Each calls the right skills in the right order, so the person
only has to know where they are.

| Where you are | Command |
|---|---|
| New repo, inherited repo, or kit not configured for this repo yet | `/fk-setup` |
| An idea, a brief, a new phase, a client request, or criteria that are still thin | `/fk-plan` |
| A backlog to schedule, a sprint to check on, a build to gate, a sprint to close, or UAT | `/fk-sprint` |
| A spec, sketch or ticket (`#N`) ready to build, including a new feature from a design | `/fk-build` |
| Feedback has come back from a client or tester | `/fk-feedback` |
| About to ship: store submission, tester build, or a backend cutover | `/fk-release` |
| A round of work finished, and the next one should be shorter | `/retro` |

## Tools

| Situation | Command |
|---|---|
| Long branch, context about to reset | `/handoff` |
| Handing a task to a cheaper model | `/spec-for-cheap-executor` |
| Prose a client will read | `/unslop` |

## Reached through the commands

These run inside the commands above, and also fire on their own when a request clearly needs one.
Route to one directly when the person wants that single step and nothing around it.

| Step | Skill | Reached through |
|---|---|---|
| Audit a codebase you inherited | `takeover-audit` | `/fk-setup` |
| Write or revise the proposal | `project-proposal` | `/fk-plan`, `/fk-feedback` |
| Cut modules into pointed tickets | `project-backlog` | `/fk-plan`, `/fk-feedback` |
| File, move or report on tickets and sprints | `project-tracker` | every command |
| What the project remembers, and where a fact goes | `project-memory` | every command |
| Which model each kind of agent work runs on, and what it costs | `configure-models` | installing, `/fk-sprint close` |
| A decision only the client can make | `client-questionnaire` | `/fk-plan` |
| Settle requirements by interview | `grill` | `/fk-plan` |
| Terms mean different things to you and the client | `domain-glossary` | `/fk-plan` |
| Write the settled discussion as a spec | `to-spec` | `/fk-plan` |
| Design the shape of a change | `flutter-plan-change` | `/fk-plan` |
| New feature folder, with or before its API | `flutter-scaffold-feature` | `/fk-build` |
| One slice, test-first | `flutter-tdd` | `/fk-build` |
| Prove it works, and name the rung | `flutter-verify` | `/fk-build` |
| Review against conventions and spec | `flutter-code-review` | `/fk-build` |
| Opening a pull request | `pr` | `/fk-build` |
| What a release could break | `release-readiness` | `/fk-release` |
| CI pipeline | `setup-ci` | `/fk-setup`, `/fk-release` |
| Store metadata, privacy, terms, release pack | `store-compliance` | `/fk-release` |

## Build one layer

| Layer | Skill |
|---|---|
| Actions, state shape, handlers | `flutter-create-state-layer` |
| Request and response DTOs | `flutter-create-model` |
| Repository over an endpoint | `flutter-create-repository` |
| View and widgets | `flutter-create-screen` |
| Hierarchy, the states nobody drew, whether it should animate | `flutter-design` |
| Routes, typed arguments, deep links | `flutter-navigation` |
| Tests: logic, widget, golden | `flutter-write-tests` |
| Legacy screen onto current conventions | `flutter-modernize-screen` |

All model-invoked, so they also fire on their own when a request clearly names one layer. Route here
when the caller wants exactly one layer touched.

## Diagnose

| Situation | Skill |
|---|---|
| Broken, and reading the code has not helped | `flutter-diagnose-bug` |
| Slow, janky, or too large, and you need numbers | `flutter-performance` |
| Fails before Dart compiles: Gradle, pods, signing | `flutter-build-failure` |
| A merge or rebase is conflicting | `flutter-merge-conflicts` |
| Which core widget, util or constant to reuse | `flutter-core-architecture` |
| Which stack this project actually uses | `project-conventions` |
| Choosing between two shapes rather than behaviours | `engineering-principles` |

## Keep it working

| Situation | Skill |
|---|---|
| Packages or the SDK are behind | `flutter-upgrade-deps` |
| Screen reader, large text, contrast, tap targets | `flutter-accessibility` |
| Adding a language, or RTL | `flutter-localization` |
| Pre-release security and quality audit | `flutter-security-review` |
| Verification cannot reach the top rung yet | `setup-integration-harness` |
| Diagnose bugs in what a cheaper model shipped | `triage-executor-bugs` |
| Human-only setup: keys, signing, provider dashboards | `setup-wizard` |

## Editing the kit

| Situation | Skill |
|---|---|
| Editing any skill in this kit | `writing-for-agents` |

## Not covered by any skill

Say so rather than forcing a fit. A one-file change or a question answerable by reading one file
needs no skill. `flutter-core-architecture` is still worth reading before touching anything shared.
