---
name: ask-kit
description: Ask which kit skill fits what you are about to do. A router over every skill in the engineering kit.
disable-model-invocation: true
---

# Ask kit

Name **one** skill, say why in a sentence, and state what it needs before it can start. When two
fit, name the narrower one first and the broader as a fallback. If the request is too vague to
route, ask the one question that separates the candidates.

Do not do the work, and do not run the routed skill: a user-invoked skill is reachable only by the
human typing its name. Where the answer is a user-invoked skill, tell them to type it.

## The engineering loop

The default route for changing an app that exists. Each step's output is the next step's input.

| Where you are | Skill | Invocation |
|---|---|---|
| New repo, kit not configured | `setup-flutter-project` | type it |
| Do not yet understand the code | `flutter-explain` | either |
| Requirement is thin or arrived as prose | `grill` | either |
| Product settled, but the app has no design language | `flutter-design` | either |
| Change touches more than a couple of files | `flutter-plan-change` | either |
| Ready to build against a spec or sketch | `flutter-implement` | type it |
| Building one slice, test-first | `flutter-tdd` | either |
| About to claim it works | `flutter-verify` | either |
| Ready for CI | `setup-ci` | type it |

`flutter-implement` is the entry point for the build: it drives `flutter-tdd` per slice, then the
analyzer, the suite, `flutter-code-review` and `flutter-verify`, and stops at a commit.

## Client delivery

Everything above still applies. Route here for what a paying client adds on top.

| Where you are | Skill | Invocation |
|---|---|---|
| A decision only the client can make | `client-questionnaire` | type it |
| Terms mean different things to you and the client | `domain-glossary` | either |
| Alignment done, ready to write it down | `to-spec` | type it |
| Spec ready, model and endpoint exist | `flutter-create-feature-e2e` | type it |
| Spec ready, no API yet | `flutter-create-screen-e2e` | type it |
| About to ship to real users | `release-readiness` | type it |
| Store metadata, privacy, terms, release pack | `store-compliance` | type it |
| Round finished | `retro` | type it |
| Prose a client will read | `unslop` | type it |

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
| Feature from criteria alone, no design or API | `flutter-create-feature` |

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
| Human-only setup: keys, signing, provider dashboards | `setup-wizard` |

## Working across sessions and models

| Situation | Skill |
|---|---|
| Long branch, context about to reset | `handoff` |
| Handing work to a cheaper model | `spec-for-cheap-executor` |
| Bugs in what the cheaper model shipped | `triage-executor-bugs` |
| Editing any skill in this kit | `writing-for-agents` |

## Not covered by any skill

Say so rather than forcing a fit. A one-file change or a question answerable by reading one file
needs no skill. `flutter-core-architecture` is still worth reading before touching anything shared.
