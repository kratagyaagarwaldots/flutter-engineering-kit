---
name: fk-plan
description: Turn an idea, a brief or a client's request into an agreed proposal and a pointed backlog, or a single requirement into a spec and a sketch, settling it before any code exists.
disable-model-invocation: true
---

# Plan

The expensive failure is the right code for the wrong requirement. This command settles the
requirement while it is still a conversation, writes it down including what is *not* being built,
and sketches the shape of the change, so `/fk-build` starts from something it cannot misread.

Each step calls the skill that owns it. This one owns the order, and the rule that no step is
skipped because the answer "seems obvious".

Keep the whole plan in one unbroken session where you can: the interview, the spec and the sketch
build on the same thinking, and a compaction between them loses the reasons behind the decisions.

## 1. Orient

Read `docs/agents/project.md`. Where it is missing, stop and tell the user to run `/fk-setup` first:
every later step reads it. Call the Skill tool with `project-memory` to load the vault, and read
`GLOSSARY.md` and the specs folder `project.md` names, so the plan uses the project's words and does
not re-decide something already settled.

Then pick the path, and say which in one line:

| The work | Path |
|---|---|
| A new product, or a new phase of one, that no agreed proposal in `docs/vault/proposal.md` covers | **Product**: step 2, then P1 to P4 below |
| An approved change request, or a module the proposal has and the backlog does not | Call the Skill tool with `project-backlog`, then hand off as in P4 |
| One feature, ticket or change | **Feature**: steps 2 to 6 |

The step is done when you can say, in a sentence, what is being planned, what already exists around
it, and which path it takes.

## 2. Questions only someone else can answer

Where the plan depends on a decision nobody in this conversation can make (a client's business
rule, a third party's API, a policy), call the Skill tool with `client-questionnaire`. Then stop:
tell the user to send it and run `/fk-plan` again with the answers. Planning past an unanswered
client question is how a feature gets built twice.

Skip this step when every open question is one the user can answer.

## 3. Settle the requirement

Call the Skill tool with `grill`. It interviews until every acceptance criterion is numbered and
every state the happy path skips (loading, empty, failure, first run, offline) has an answer. Terms
that turn out to mean different things to different people go to `GLOSSARY.md` as they settle.

Where the change has a screen and the app has no `docs/agents/design.md` yet, call the Skill tool
with `flutter-design` before moving on, so the screen is planned against a design language rather
than invented during the build.

## 4. Write it down

Call the Skill tool with `to-spec`. The spec carries the numbered criteria from step 3 and an
explicit out-of-scope section.

## 5. Sketch the change

Where the work touches more than a couple of files, call the Skill tool with `flutter-plan-change`
for the types, signatures, boundaries and the order the slices land in. A single-file change needs
no sketch.

## 6. Hand off

Tell the user to run `/fk-build` with the spec path (and the sketch path, if step 5 wrote one).

## Product path

**P1. Proposal.** Call the Skill tool with `project-proposal`. On an inherited codebase it builds
on `docs/vault/audit.md`; where that is missing, tell the user to run `/fk-setup`, which runs the
audit.

**P2. Agreement.** The proposal is agreed before anything is cut from it. On client work that means
the client: stop here, and tell the user to run `/fk-plan` again once it is agreed.

**P3. Design.** Where the app has no `docs/agents/design.md`, call the Skill tool with
`flutter-design` to settle the design language against the proposal's modules. Where screen designs
exist, record their frame links on the proposal's modules; where they do not yet, the tickets say
so, and `/fk-build` designs from the language instead.

**P4. Backlog.** Call the Skill tool with `project-backlog`. Then tell the user to run
`/fk-sprint plan`.

## Completion criteria

**Product path:** the proposal is agreed and its revision recorded, the design language exists, and
every module has tickets with criteria and points in the tracker.

**Feature path:** a spec file exists with numbered acceptance criteria, each naming its loading, empty and failure
behaviour where it has one, and an out-of-scope section. Either a sketch exists or you have said why
the change needs none. Every question that could not be settled is listed, with who owns it.
