---
name: project-proposal
description: Write or revise the project's proposal in docs/vault/proposal.md, covering objective, users, deliverables, modules, technical approach, assumptions, what the client provides, out of scope and timeline, under a revision history. Use when /fk-plan starts a new product or a new phase, when a change request is approved, or when the user asks for a proposal or a scope document.
---

# Project proposal

The proposal is the project's bible. Every later artifact is measured against it: the modules and
tickets are cut from it, a sprint's goal serves it, and a feedback item is a bug or a change request
depending on what it says. That is why it carries revisions. Once agreed, it changes only by adding
one, so "was this in scope?" always has an answer with a date on it.

## 1. Gather

Read `docs/agents/project.md` for the stack and integrations, `GLOSSARY.md` for the project's words,
and `docs/vault/audit.md` where the codebase was inherited. Take the brief from whatever exists: the
conversation, a written brief, a filled questionnaire.

Where a section cannot be written because a decision is missing, settle it before writing around
it. The user can decide it → call the Skill tool with `grill`. Only the client can → call the Skill
tool with `client-questionnaire`, and stop until the answers are back.

The step is done when every section in the template has either an answer or a named owner for the
missing one.

## 2. Write the first revision

Fill [template.md](references/template.md) into `docs/vault/proposal.md`.

**Modules** carry the most weight, because the backlog is cut from them. A module is one capability
a user can name (signing in, onboarding, browsing, paying, settings, an admin panel) or one piece of
work no screen shows (the backend integration, notifications, the release itself). Each gets:

- **Problem**: what the user cannot do today.
- **Existing**: what is there now. "Nothing" on a new project; the audit's finding on an inherited
  one; on the user's own app, what the code does today, read from the code.
- **Proposed**: what will be built, as capabilities a user sees, never as code.
- **Size**: S (up to 13 points), M (14 to 34) or L (35 to 60). Anything larger is two modules.

**Out of scope** is never empty, and never vague. "No offline mode" commits to something; "keeping
it simple" does not. Write the things the user mentioned and decided against, and the things a
client of this kind of app usually assumes are included.

**Timeline** is points over capacity. Until a sprint has closed, capacity is a guess: write it as
one, and mark the timeline provisional. It firms up in the revision after the second sprint closes.

Sections marked *Client work* exist for an agency building for someone else. On the user's own
product, delete them and say so in the revision note.

## 3. Agree it

Show the user the objective, the module list with sizes, out of scope, the assumptions and the
timeline. On client work the proposal is the document the client approves, so the user sends it
and comes back with the answer; record who agreed and when in the revision table, and set the
status to agreed.

## 4. Revise

An agreed proposal changes only through a new revision:

1. Add a row to the revision table: the number, the date, what changed, why (the change request,
   feedback round or audit finding that caused it), and who agreed it.
2. Edit the affected sections in place, and bump the revision at the top.
3. A module moving in from out of scope, or growing, carries its points and the effect on the
   timeline in the same revision. A change with no cost attached reads as free.

## Completion criteria

Every template section is filled or deliberately removed. Every module has a problem, an existing
state, a proposal and a size. Out of scope lists specific items. Every assumption names who confirms
it. The revision table's last row matches the status line.
