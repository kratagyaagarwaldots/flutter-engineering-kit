---
name: to-spec
description: Turn the current conversation into a written spec, with an explicit out-of-scope section.
disable-model-invocation: true
---

# To spec

Synthesise what has already been discussed into a spec. Write from the conversation you have; the
interviewing was `grill`'s job, and re-asking here spends the alignment twice. When the conversation
does not contain enough to write a spec, say which sections you cannot fill, then call the Skill tool
with `grill` to settle them rather than inventing the gaps.

Write to the directory `docs/agents/project.md` names for specs (`docs/specs/` by default), as
`docs/specs/<NN>-<slug>.md`. If the project config names a real issue tracker, publish there
instead and link it from the file.

## Before writing

Read the project's glossary (`CONTEXT.md`) if it exists and use its terms exactly; a spec that
renames a domain concept teaches the codebase a second word for the same thing. Respect anything in
`docs/adr/` covering the area, and do not re-litigate a recorded decision inside a spec.

Then name the **seams under test** and confirm them with the user before writing. For a Flutter
feature that is usually the bloc's event surface and the page's widget tree; sometimes the
repository. Prefer seams that already exist. The fewer, the better.

## The document

```markdown
# <NN>: <Feature name>

**Status:** ready to build · **Source:** <the round, questionnaire, or conversation this came from>

## Problem

What the user cannot do today, from the user's side of the screen. No implementation.

## Solution

What they will be able to do, from the same side.

## Acceptance criteria

A numbered list. Every criterion is observable by a person using the app, and every one names its
states, including loading, empty and failure. This list is what `flutter-verify` maps proof onto and
what `flutter-code-review`'s spec axis reviews against, so an unobservable criterion is unverifiable.

## Implementation decisions

Modules touched, the interfaces that change, the data shape, endpoints and their request/response
association, navigation edges, and anything settled during grilling that the code must honour.

No file paths, no code snippets: they go stale within a round. One exception — a state machine,
enum, or JSON shape that encodes a decision more precisely than prose can. Inline that.

## Testing decisions

Which seams are tested and which are deliberately not. Prior art in the repo to follow. The
verification rung each criterion can actually reach, and which ones cannot be proven until a real
API or a staging environment exists.

## Assumptions

Every place we picked for the client because an answer never came back. Each one is a live risk;
this section is where a wrong guess gets caught in review instead of in a feedback round.

## Out of scope

What we are explicitly not building in this phase, in the client's own words where we have them.

On fixed-scope client work this is the most valuable section in the document. Write it even when
nobody asked, and make it specific: "no offline mode" beats "keeping it simple". A request that
arrives later and is listed here is a change request, not a bug.
```

## After writing

Show the user the **Acceptance criteria**, **Assumptions** and **Out of scope** sections and get
those three confirmed. The rest is ours to get right; those three are the contract.

With the contract confirmed the product is locked, which is the moment the app's visual language stops
being free to invent per screen. Where `docs/agents/design.md` does not exist yet, call the Skill tool
with `flutter-design` to settle it before any screen is built.

Then tell the user which scaffolder to run. Both are user-invoked, so only they can start one:
`/flutter-create-feature-e2e` when a model and endpoint exist, `/flutter-create-screen-e2e` when they
do not.
