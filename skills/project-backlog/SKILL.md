---
name: project-backlog
description: Break the proposal's modules into tickets with acceptance criteria, story points and blocking edges, write a note per module, and file the tickets in the tracker. Use when /fk-plan has an agreed proposal or a new module, when an approved change request needs tickets, or when the user asks for a backlog or a ticket breakdown.
---

# Project backlog

Turns modules into work that can be picked up without asking a question. A ticket is finished being
written when `/fk-build` could take it as its only input, and a backlog is finished when every
module in the proposal is covered by tickets like that.

## 1. Read

The proposal's current revision, `GLOSSARY.md`, `docs/agents/design.md` where it exists, the module
notes already in `docs/vault/modules/`, and the open tickets (call the Skill tool with
`project-tracker` for them), so nothing is filed twice.

## 2. Slice each module

Cut vertically: every ticket ends in something a person can see or do.

- The module's **first ticket is its tracer**: the thinnest path through every layer, from the
  screen to the data and back, so the module's shape is proven before it is widened. Everything
  else in the module is blocked by it.
- Then one ticket per capability or state the tracer left out.
- Work no screen shows (pipelines, environments, push setup, store accounts) is `type:chore`. Work
  only a person can do (fetching keys, signing, a store console, a client decision) is
  `ready-for-human`.
- A ticket whose backend does not exist yet is still filed, with a note that it builds on fixture
  data until the endpoint lands, plus a follow-up ticket to move it onto the real endpoint, blocked
  until then.

## 3. Write the criteria

Each ticket gets numbered acceptance criteria a person can observe, each naming its loading, empty
and failure behaviour where it has them, in the glossary's words. Where a module's behaviour is not
settled enough to write them, call the Skill tool with `grill` for that module rather than inventing
an answer.

## 4. Point

Points measure the whole job (the code, its tests, its review and its proof) relative to these
anchors:

| Points | Anchor |
|---|---|
| 1 | Copy, configuration or a constant; no new state |
| 2 | One state or one field added to an existing screen |
| 3 | One screen and its states over a data source that already exists |
| 5 | One slice across every layer: data, state, screen and tests |
| 8 | A slice with an unknown: a new integration, an unfamiliar API, platform code |

Above 8, split. An 8 names its unknown in the ticket; where the unknown is large, a 1- or 2-point
spike in front of it is usually cheaper than the surprise.

## 5. Record the edges

Write `Blocked by #N` wherever a ticket needs another's code or decision. A module whose tickets
form one long chain cannot run in parallel; where that happens, re-slice so the tracer unblocks
several tickets at once.

## 6. Confirm, then file

Show one table per module (title, type, points, blocked by, intake state) with its point total next
to the size the proposal gave it. A module that comes out more than half again over its size is a
finding: either the proposal undersized it and needs a revision, or the slicing is padded. Say which
you think it is.

On a yes, write `docs/vault/modules/<slug>.md` for each module and link it from the vault index,
then call the Skill tool with `project-tracker` to create the module label and file the tickets.

```markdown
# <Module name>

**Proposal:** M<n>, revision <r> · **Tickets:** label `module:<slug>` · **Design:** <frame links>

## Purpose

## Decisions

## Open questions
```

## Completion criteria

Every module in the proposal has a note and tickets. Every ticket has numbered criteria, at most 8
points, a type and an intake state. Every dependency is recorded, and each module's total is
reported against its proposed size.
