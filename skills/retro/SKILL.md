---
name: retro
description: After a round of work, propose improvements to the kit and the project's agent environment so the next round is shorter.
disable-model-invocation: true
---

# Retro

An agency ships the same shapes of work over and over. That is the whole opportunity: every round
should make the next one shorter. This skill turns a finished round into concrete edits, not
reflections.

You are improving the **environment the agent works in**, not the code it wrote.

## Process

1. Call the Skill tool with `writing-for-agents` for the writing standard before proposing any prose
   edit.

2. Read the primary sources for the round: the diff, the spec, the acceptance criteria, the review
   findings, and what the client came back with. If the round produced a feedback round, that is the
   most valuable input on the page.

3. Look for candidates in these categories, in roughly this order of value.

   - **Alignment gaps.** Did a rebuild happen because a criterion was never pinned down? Which
     question, and where should it have been asked: `client-questionnaire`, `grill`, or the spec's
     assumptions section? This is the highest-value category on client work, and the one most often
     skipped in favour of code cleanup.
   - **Automated checks.** Could a lint, a test, a hook, or an analyzer rule have caught the mistake?
     Prefer this over any amount of added prose.
   - **Review rules.** Should `flutter-code-review`'s baseline gain an item, or lose one that keeps
     producing noise? Conventions belong to the reviewer, not the implementer: the implementing agent
     is under the most context pressure and the reviewing agent is under the least, so a rule lands
     better in the review skill than in `CLAUDE.md`.
   - **Navigation.** Did the agent spend a long time finding something? A pointer in `CLAUDE.md` or a
     row in `docs/agents/project.md` is cheaper than repeated searching.
   - **Glossary.** Did we and the client mean different things by a word? That is a `CONTEXT.md`
     entry, and possibly an ADR.
   - **No-ops.** Instructions in the steering files that do not change behaviour. Deleting these is
     as valuable as adding a good one, and safer than it feels.
   - **Kit versus project.** Decide where each edit belongs. A lesson true for every Flutter client
     app goes to the kit's skill; a lesson true only here goes to this project's `CLAUDE.md` or
     `project.md`. Putting a project fact in the kit is how a portable kit stops being portable.

4. Present the candidates in severity order, each as a concrete edit: the file, what changes, and the
   evidence from this round that motivates it. No general advice.

5. Apply only what the user approves. Skill changes affect every future project, so nothing lands
   automatically.

## The structural test

Before writing any candidate as prose, ask whether a lint rule, a test, a hook, or a type could
enforce it instead. If one could, that is the candidate, and the prose version is the fallback. A rule
that has to be remembered will be forgotten; a rule that fails a build will not.
