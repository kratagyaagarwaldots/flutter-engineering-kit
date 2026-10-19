---
name: ask-kit
description: Ask where the project stands and which kit command or skill comes next. A router over every skill in the engineering kit.
disable-model-invocation: true
---

# Ask kit

Answer two things, in this order: where the project stands, and what the person wants next. Then
name **one** command or skill, say why in a sentence, and state what it needs before it can start.
If the request is too vague to route, ask the one question that separates the candidates.

Do not do the work, and do not run the routed skill. Where the answer is a command, tell them to
type it; only a human can start one.

## 1. Where the project stands

Check these before matching the request to anything, in order, stopping at the first that is not
done: that is where the project stands, and its command is the default answer. Stages 1, 2 and 4
are files to read; for stage 3, call the Skill tool with `project-tracker` for the current phase's
Must features.

| # | Stage | Done when | Next |
|---|---|---|---|
| 1 | Set up | `docs/agents/project.md` exists | `/fk-setup` |
| 2 | Scoped | `docs/vault/proposal.md` says agreed, and `docs/vault/features.md` gives every feature a priority and a phase | `/fk-plan` |
| 3 | Backlogged | every Must feature of the current phase has a ticket naming it | `/fk-plan` |
| 4 | Sprint planned | the vault index's **Now** line names a sprint note | `/fk-sprint plan` |
| 5 | In a sprint | (the stage the project stays in) | `/fk-build #N` for its tickets, or `kit loop run`; `/fk-sprint` for status, QA and close, picking its mode from the dates |

Say the stage in one line, with the file that decided it. Then:

- **The request fits the stage:** name its command.
- **The request is a later stage:** name the current stage's command first, and say what it leaves
  for the later one. A sprint cannot be planned from features that have no tickets.
- **The request jumps the order on purpose:** route it directly. Feedback from a client or tester
  is `/fk-feedback` at any stage, shipping is `/fk-release`, and a project not run as a delivery
  project (no `proposal.md`) skips stages 2 to 4: one change goes to `/fk-plan` or `/fk-build`.

## 2. The commands

Each calls the right skills in the right order, so the person only has to know where they are.

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
| Handing a task to another team, or a tool someone else runs, with no review before it lands | `/spec-for-cheap-executor` |
| Prose a client will read | `/unslop` |

## 3. Inside the commands

The planning skills look alike because they all deal in requirements, but each writes a different
thing. Tell them apart by what they leave behind, and route to one directly only when the person
names that thing ("revise the proposal", "add a feature", "re-point these tickets"). Otherwise name
the command, which runs them in this order.

| Order | Skill | Leaves behind | Reached through |
|---|---|---|---|
| 1 | `client-questionnaire` | Questions only the client can answer, to send | `/fk-plan` |
| 2 | `grill` | Settled answers and numbered criteria, in the conversation; no file of its own | `/fk-plan`, and any skill that finds a gap |
| 3 | `domain-glossary` | `GLOSSARY.md` and ADRs | `/fk-plan`, whenever a term is doing two jobs |
| 4 | `project-proposal` | `proposal.md` (why, for whom, modules, scope) and `features.md` (every feature, prioritised and phased) | `/fk-plan`, `/fk-feedback` |
| 5 | `project-backlog` | Tickets for the current phase's features, with criteria and points, and a note per module | `/fk-plan`, `/fk-feedback`, `/fk-sprint plan` |
| 6 | `to-spec` | A spec for one feature, in `docs/specs/`, whose criteria its tickets point to | `/fk-plan`, feature path |
| 7 | `flutter-plan-change` | A technical sketch: types, signatures, order of work | `/fk-plan`, feature path |

A project run for delivery takes rows 1 to 5, then `/fk-sprint plan`. One feature takes rows 2, 6
and 7, then `/fk-build`.

The rest run inside their command too:

| Step | Skill | Reached through |
|---|---|---|
| Audit a codebase you inherited | `takeover-audit` | `/fk-setup` |
| File, move or report on tickets, features and sprints | `project-tracker` | every command |
| What the project remembers, and where a fact goes | `project-memory` | every command |
| Which model each kind of agent work runs on, what it costs, or putting builds on a cheaper model | `configure-models` | installing, `/fk-sprint close` |
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
