# Flutter Engineering Kit

Skills and agents for **engineering** Flutter apps rather than vibe-coding them: understand the
code, design the change, build it test-first, prove it works, and ship it.

Every skill is small, readable, and adapts to the stack the project already uses. Nothing here owns
your process; you compose the parts you want.

Built from what worked across a run of real apps, and from three public skill sets
([pstack](https://github.com/cursor/plugins/tree/main/pstack),
[mattpocock/skills](https://github.com/mattpocock/skills) and
[emilkowalski/skills](https://github.com/emilkowalski/skills)).

## Install

Two ways in. **As a plugin** the kit is managed and read-only, and a `git pull` on the marketplace
updates it. **As local files** it is copied into your repo, yours to edit, and nothing changes
underneath you. Pick one: installing both offers every skill twice and fires every hook twice.

### 1. Get the kit

<details>
<summary><strong>Claude Code</strong></summary>

```bash
# once per machine
/plugin marketplace add kratagyaagarwaldots/flutter-engineering-kit

# then
/plugin install flutter-engineering-kit@kratagyaagarwal
```

The repo is its own marketplace, so there is nothing else to add first. `git pull` on the
marketplace picks up new skills.

</details>

<details>
<summary><strong>Local files, yours to edit</strong></summary>

```bash
git clone https://github.com/kratagyaagarwaldots/flutter-engineering-kit.git
cd flutter-engineering-kit

./scripts/install-local.sh /path/to/your/project   # → <project>/.claude/
./scripts/install-local.sh --user                  # → ~/.claude/, every project
```

This writes `.claude/{skills,agents,rules,hooks}` as ordinary files. Delete the skills you do not
want and edit the ones you keep. It prints the `settings.json` block that activates the hooks, since
files alone do not wire them.

Re-running it overwrites what it installed, so a skill you have edited should be forked under a
different name before the next pull.

</details>

<details>
<summary><strong>A whole team, from the project repo</strong></summary>

Commit this to the project's `.claude/settings.json` and everyone who clones it gets the kit
without running any install command:

```json
{
  "extraKnownMarketplaces": {
    "kratagyaagarwal": {
      "source": { "source": "github", "repo": "kratagyaagarwaldots/flutter-engineering-kit" }
    }
  },
  "enabledPlugins": { "flutter-engineering-kit@kratagyaagarwal": true }
}
```

</details>

<details>
<summary><strong>Cursor</strong></summary>

Cursor has no plugin system, so the kit is mirrored into the project as files:

```bash
scripts/sync-cursor.sh /path/to/project
```

This writes `.cursor/{skills,agents,rules,hooks}` from `skills/`, `agents/` and `rules/`. The
mirror is generated. Never hand-edit it; change the kit and re-run the script.

</details>

### 2. Run `/setup-flutter-project`

Once per project, before any other skill. It will:

- Explore the repo and ask only the few things it cannot observe
- Fill in the **Architecture table**, which records the stack this project actually uses
- Write `docs/agents/project.md` and a `CLAUDE.md`
- Copy the hooks into `.claude/hooks/` and wire them into `settings.json`
- Scaffold `lib/core` if the repo is greenfield

Every other skill reads `docs/agents/project.md`, which is what makes one kit serve many apps.

### 3. That's it

Type `/ask-kit` whenever you are unsure which skill fits.

---

## Why this kit exists

Six failures, each one the reason for a group of skills.

### #1. We built the wrong thing

**The problem.** The expensive failure is almost never bad code. It is the right code for the wrong
requirement. You read the brief, you think you understood it, you build for a week, and then it
turns out something else was meant. The gap was never in the implementation. It was in the
conversation before it.

**The fix** is to front-load alignment, before there is code to throw away:
[`/grill`](./skills/grill/SKILL.md) interviews you until every undefined state has an answer,
[`domain-glossary`](./skills/domain-glossary/SKILL.md) settles the words, and
[`/to-spec`](./skills/to-spec/SKILL.md) writes it down including what is *out* of scope. On client
work, [`/client-questionnaire`](./skills/client-questionnaire/SKILL.md) asks the things only they
can answer.

### #2. We wrote code before we knew the shape

**The problem.** Straight from a ticket to a keyboard. The types get invented while typing, the
seams land where the first draft happened to put them, and the design is whatever the code settled
into. Every later change fights it.

**The fix** is to decide the shape while it is still text.
[`flutter-plan-change`](./skills/flutter-plan-change/SKILL.md) sketches the types, signatures and
boundaries with no bodies, and records hard-to-reverse decisions as ADRs.
[`engineering-principles`](./skills/engineering-principles/SKILL.md) is the vocabulary for choosing
between two shapes. [`flutter-explain`](./skills/flutter-explain/SKILL.md) comes first when the code
is not yours.

### #3. We said done without proving it

**The problem.** "Done" degrades into "it compiles and the happy path looked fine on my simulator."
Nobody ran the error state. Nobody checked it against the spec, only against taste.

**The fix** is to build test-first and to name your evidence.
[`flutter-tdd`](./skills/flutter-tdd/SKILL.md) writes the failing test before the code,
[`flutter-write-tests`](./skills/flutter-write-tests/SKILL.md) covers logic, widget and golden
levels, and [`flutter-verify`](./skills/flutter-verify/SKILL.md) makes you **name the rung** you
actually reached. [`/setup-integration-harness`](./skills/setup-integration-harness/SKILL.md) builds
the top rung when the project has none.

### #4. It got slow and nobody measured

**The problem.** "The list feels janky." Someone sprinkles `const` and `RepaintBoundary`, it feels
about the same, and nobody can say whether anything improved. Meanwhile the actual cost was an image
decoded at full resolution on the raster thread.

**The fix** is a measurement, then one change, then the same measurement.
[`flutter-performance`](./skills/flutter-performance/SKILL.md) owns that loop, starting with the
question that decides everything after it: is the UI thread or the raster thread over budget.

### #5. It rotted

**The problem.** Dependencies drift until an upgrade is a week's work. The native build breaks on a
new machine and nobody knows which version disagreed. Accessibility and localization were never
anyone's job.

**The fix** is to make each of those a named, small task rather than an eventual crisis:
[`flutter-upgrade-deps`](./skills/flutter-upgrade-deps/SKILL.md),
[`flutter-build-failure`](./skills/flutter-build-failure/SKILL.md),
[`flutter-merge-conflicts`](./skills/flutter-merge-conflicts/SKILL.md),
[`flutter-accessibility`](./skills/flutter-accessibility/SKILL.md) and
[`flutter-localization`](./skills/flutter-localization/SKILL.md).

### #6. It was correct and it looked amateur

**The problem.** Everything above can hold and the result still reads as unfinished. The loading
state is a spinner over content the user was reading, the empty state says "No data", the error shows
what the exception returned, and something animates on a tab switch a user makes forty times a day.
None of it is a bug, so no test catches it and no review flags it. It comes back as a feedback round.

**The fix** is to make the design decisions explicit rather than leaving them to whatever the first
draft produced. [`flutter-design`](./skills/flutter-design/SKILL.md) holds the gates — how often a
thing is seen, what an animation is *for*, what belongs in a state nobody drew — and makes the answer
name what it chose not to do.

---

## Two tracks

### The engineering loop

The default. Each step's output is the next step's input.

| # | Step | Skill |
|---|---|---|
| 1 | Configure the repo, once | `setup-flutter-project` |
| 2 | Understand what is there | `flutter-explain` |
| 3 | Settle the requirement | `grill` |
| 4 | Settle how it should look and move | `flutter-design` |
| 5 | Design the shape of the change | `flutter-plan-change` |
| 6 | Build it, test-first, to a reviewed commit | `flutter-implement` |
| 7 | Prove it, and name the rung | `flutter-verify` |
| 8 | Ship it | `setup-ci`, `release-readiness` |

Step 6 drives steps of its own: `flutter-tdd` per slice, then the analyzer, the suite,
`flutter-code-review` and `flutter-verify`, stopping at a commit.

Step 4 is settled once per app rather than once per change: it writes `docs/agents/design.md`, and
every later screen reads it instead of deciding again.

### Client delivery

Everything above still applies. This track adds what a paying client needs on top, and is optional
if you are building your own product.

| # | Step | Skill |
|---|---|---|
| 1 | Ask the client what only they know | `client-questionnaire` |
| 2 | Turn answers or a feedback round into numbered criteria | `grill` |
| 3 | Fix the vocabulary you and the client share | `domain-glossary` |
| 4 | Write it down, including what you are *not* building | `to-spec` |
| 5 | Settle the app's design language, once | `flutter-design` |
| 6 | Scaffold from a design and an endpoint | `flutter-create-feature-e2e` |
| 7 | Check the release, prove the one safety fact | `release-readiness` |
| 8 | Ship the store pack | `store-compliance` |
| 9 | Fold what you learned back into the kit | `retro` |

The alignment steps are the cheapest in the kit and the ones most often skipped.

---

## Reference

These split on one axis: who can invoke them. **User-invoked** skills carry
`disable-model-invocation: true`, so they are reachable only when you type them (`/to-spec`, say).
Their job is to orchestrate, and they cost nothing in context until used. **Model-invoked** skills
can be invoked by you or reached for automatically by the agent when the task fits; they hold the
reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another
user-invoked one.

### Understand

Working out what the code does, and what it should do, before changing it.

**User-invoked**

- **[ask-kit](./skills/ask-kit/SKILL.md)**: Ask which kit skill fits what you are about to do. A
  router over every skill in the engineering kit.
- **[client-questionnaire](./skills/client-questionnaire/SKILL.md)**: Turn decisions you cannot
  make in-house into a questionnaire for the client to fill in.
- **[to-spec](./skills/to-spec/SKILL.md)**: Turn the current conversation into a written spec,
  with an explicit out-of-scope section.

**Model-invoked**

- **[flutter-explain](./skills/flutter-explain/SKILL.md)**: Explain how a Flutter feature,
  subsystem or codebase actually works, and why it was built that way.
- **[grill](./skills/grill/SKILL.md)**: Interview the user until a feature's requirements are
  settled.
- **[domain-glossary](./skills/domain-glossary/SKILL.md)**: Build and sharpen the project's shared
  vocabulary in CONTEXT.md, and record hard-to-reverse decisions as ADRs.
- **[project-conventions](./skills/project-conventions/SKILL.md)**: Resolve which state
  management, serialization, navigation, sizing and test tooling this project actually uses,
  before generating code.
- **[flutter-core-architecture](./skills/flutter-core-architecture/SKILL.md)**: The kit's lib/core
  conventions: project structure, barrel imports, constants families, shared components, services,
  network, failures, router, and fixture markers.

### Design

Deciding the shape of a change while it is still cheap to change.

**Model-invoked**

- **[flutter-plan-change](./skills/flutter-plan-change/SKILL.md)**: Design a change before writing
  it: the types, signatures and module boundaries it needs, and the order the work lands in.
- **[engineering-principles](./skills/engineering-principles/SKILL.md)**: Four principles that
  change how a change is shaped rather than what it does: root causes, subtraction, reader load,
  and modelling the domain in types.

### Build

Writing the code. `flutter-implement` is the entry point for changing existing code; the two end-to-end scaffolders are for a new feature folder built from a design and an endpoint.

**User-invoked**

- **[flutter-implement](./skills/flutter-implement/SKILL.md)**: Drive a spec or sketch to a
  reviewed, verified commit: test-first at the agreed seams, then analyze, test, review and prove.
- **[flutter-create-feature-e2e](./skills/flutter-create-feature-e2e/SKILL.md)**: Build or upgrade
  a complete feature (model, repo, bloc, view, widgets, tests) from a model spec, one API
  endpoint, acceptance criteria and a Figma node.
- **[flutter-create-screen-e2e](./skills/flutter-create-screen-e2e/SKILL.md)**: Build a screen
  backed by a FIXTURE repo from acceptance criteria and a Figma node, before the model and API
  exist.

**Model-invoked**

- **[flutter-tdd](./skills/flutter-tdd/SKILL.md)**: Build a change test-first: a failing test at a
  named seam, then the smallest code that passes it.
- **[flutter-create-feature](./skills/flutter-create-feature/SKILL.md)**: Scaffold a complete
  feature folder (bloc + model + repo + view + widget) from requirements alone, without API spec.
- **[flutter-create-state-layer](./skills/flutter-create-state-layer/SKILL.md)**: Generate a
  feature's state layer in whichever state management the project uses: the seam holding its
  behaviour, its actions, and the state the UI reads back.
- **[flutter-create-model](./skills/flutter-create-model/SKILL.md)**: Generate request and
  response DTO classes for a feature, immutable and with JSON serialization in whichever mechanism
  the project uses.
- **[flutter-create-repository](./skills/flutter-create-repository/SKILL.md)**: Generate a
  Repository class for a feature with dependency-injected API client and proper error handling
  using Either.
- **[flutter-create-screen](./skills/flutter-create-screen/SKILL.md)**: Generate a screen (view +
  widgets) from a Figma node URL (read via the Figma MCP server), or a pasted CSS + screenshot
  fallback, or a written spec.
- **[flutter-design](./skills/flutter-design/SKILL.md)**: Judge and shape what a screen looks like
  and how it moves, when no design source settles it: visual hierarchy, the states a build skips,
  and whether something should animate at all.
- **[flutter-navigation](./skills/flutter-navigation/SKILL.md)**: Wire routes, typed arguments and
  deep links, and test that they arrive.
- **[flutter-modernize-screen](./skills/flutter-modernize-screen/SKILL.md)**: Migrate a legacy
  screen onto the project's current state management, sizing and widget conventions without
  changing what it renders.

### Prove

Separating *does it work* from *is it written well*, and answering both out loud.

**User-invoked**

- **[setup-integration-harness](./skills/setup-integration-harness/SKILL.md)**: Stand up an
  integration test harness that boots the real app, prove it runs once, and record it so
  verification can reach the top rung.

**Model-invoked**

- **[flutter-write-tests](./skills/flutter-write-tests/SKILL.md)**: Write the tests for a feature:
  logic tests at the state seam, widget tests for what the user sees, and goldens for the pixels.
- **[flutter-verify](./skills/flutter-verify/SKILL.md)**: Prove a Flutter change actually works
  before calling it done.
- **[flutter-code-review](./skills/flutter-code-review/SKILL.md)**: Review changes on two
  independent axes: does the code follow the project's conventions, and does it do what the spec
  asked.
- **[flutter-diagnose-bug](./skills/flutter-diagnose-bug/SKILL.md)**: Disciplined diagnosis loop
  for hard Flutter bugs, jank, and regressions.
- **[flutter-performance](./skills/flutter-performance/SKILL.md)**: Measure and improve Flutter
  performance against a budget: jank, dropped frames, slow startup, memory growth, and app size.
- **[flutter-security-review](./skills/flutter-security-review/SKILL.md)**: Security and quality
  audit for the codebase covering secrets, storage, network, state, webview, and code quality.

### Keep it working

The work that stops a codebase decaying between features.

**Model-invoked**

- **[flutter-upgrade-deps](./skills/flutter-upgrade-deps/SKILL.md)**: Upgrade Flutter and Dart
  dependencies one at a time, with the breaking changes read first and the suite green between
  each.
- **[flutter-build-failure](./skills/flutter-build-failure/SKILL.md)**: Diagnose a native build
  failure: Gradle, AGP, Kotlin, JDK, CocoaPods, Xcode or signing.
- **[flutter-merge-conflicts](./skills/flutter-merge-conflicts/SKILL.md)**: Resolve conflicts in a
  Flutter repo by intent, including the generated files and lockfiles that must be regenerated
  rather than merged.
- **[flutter-accessibility](./skills/flutter-accessibility/SKILL.md)**: Make a Flutter screen
  usable with a screen reader, large text and low vision, and add the tests that keep it that way.
- **[flutter-localization](./skills/flutter-localization/SKILL.md)**: Add or extend localization:
  ARB files, plurals, RTL layouts and locale-aware formatting, including migrating off a static
  strings class.

### Ship

Everything between "it works on my machine" and "it is live".

**User-invoked**

- **[setup-ci](./skills/setup-ci/SKILL.md)**: Generate a CI pipeline that runs the verification
  ladder on every push, and builds per flavor.
- **[release-readiness](./skills/release-readiness/SKILL.md)**: Before shipping to a live app,
  find what a change could break elsewhere and prove the one fact its safety depends on by running
  code.
- **[store-compliance](./skills/store-compliance/SKILL.md)**: Generate the App Store / Google Play
  metadata, privacy, terms, permissions, SDK-audit and release-checklist pack for this app.

**Model-invoked**

- **[setup-wizard](./skills/setup-wizard/SKILL.md)**: Generate an interactive script that walks a
  human through setup steps only they can perform, such as provisioning credentials, store
  accounts, or signing.

### Working across sessions and models

Handing work to another session, a cheaper model, or a teammate.

**User-invoked**

- **[handoff](./skills/handoff/SKILL.md)**: Compact the current conversation into a handoff
  document another session can pick up.
- **[spec-for-cheap-executor](./skills/spec-for-cheap-executor/SKILL.md)**: Turn a feature request
  into one self-contained task doc a cheaper model can execute end to end.

**Model-invoked**

- **[triage-executor-bugs](./skills/triage-executor-bugs/SKILL.md)**: Diagnose and route bugs
  found after a cheap model executed a spec-for-cheap-executor task doc. Batches bug reports,
  finds root causes (which usually cluster), then routes each one to inline repair, a mechanical
  fix doc for the cheap executor, or an amendment to the original spec.

### Meta

Configuring the kit and editing it.

**User-invoked**

- **[setup-flutter-project](./skills/setup-flutter-project/SKILL.md)**: Configure a Flutter repo
  for the engineering kit. Run once per project before using the other skills.
- **[retro](./skills/retro/SKILL.md)**: After a round of work, propose improvements to the kit and
  the project's agent environment so the next round is shorter.
- **[unslop](./skills/unslop/SKILL.md)**: Cut AI tells from any writing. Must always apply.

**Model-invoked**

- **[writing-for-agents](./skills/writing-for-agents/SKILL.md)**: How to write documents agents
  consume: skills, CLAUDE.md, and any doc reached by a pointer.
## Agents

Layer specialists the scaffolding skills delegate to: `flutter-explore`, `flutter-architect`,
`flutter-state-engineer`, `flutter-repo-engineer`, `flutter-ui-engineer`, `flutter-test-engineer`,
plus the store-pack writer. See [agents/README.md](./agents/README.md).

## What the kit assumes

Less than it used to. The **Architecture table** in `docs/agents/project.md` records what this
project actually uses, and `project-conventions` resolves it for every skill that generates code. A
Riverpod project gets Riverpod, a Provider project gets Provider.

What the kit still imposes, and `flutter-core-architecture` owns:

- Feature-first layout, with sharing only through `lib/core/`
- A single barrel import per file
- No hardcoded colours, strings, assets or dimensions
- Spacing tokens in logical pixels, breakpoints for layout, and font sizes left for the OS to scale
- Fixture mode: screens can ship before their API exists, explicitly marked, then upgraded

Its defaults for a greenfield repo are `flutter_bloc`, `dartz` and `dio`, which is what
`setup-flutter-project` scaffolds when nothing contradicts it.

## Editing the kit

Read `writing-for-agents` first. Then the rule that keeps this portable: **a project fact never goes
in a skill.** If it is true of one app but not of every Flutter app, it belongs in
`docs/agents/project.md`.

`rules/` holds four always-on convention files. The plugin manifest has no key for them, so a
plugin install does not deliver them: Claude Code gets the same conventions through the `CLAUDE.md`
that `/setup-flutter-project` writes and through `flutter-core-architecture`, while the Cursor mirror
copies `rules/` verbatim. `store-compliance` reads `rules/store-compliance-docs.md` from the kit
directly.

`CLAUDE.md` in this repo carries the authoring conventions. Run `scripts/validate-kit.py` before
committing: it checks ten invariants, including that every skill appears in this README with a
description matching its frontmatter, and that no skill outside `templates/` names a state
management library.

## Credits

The alignment skills adapt `grilling`, `to-questionnaire`, `to-spec`, `domain-modeling`,
`code-review`, `diagnosing-bugs`, `tdd`, `wizard`, `handoff` and `writing-for-agents` from
**mattpocock/skills** (MIT). The verification ladder, `release-readiness`, the harness generator and
the principles adapt `create-verification-skill`, `prove-it-works`, `blast-radius`, `hillclimb` and
the principle set from **pstack** (MIT). `flutter-design` adapts its motion judgment — the frequency
and purpose gates, the duration budgets, the physicality and interruptibility rules, and the habit of
naming what you chose *not* to animate — from [`emilkowalski/skills`](https://github.com/emilkowalski/skills)
(MIT), chiefly `emil-design-eng`, `animate`, `animate-expo`, `review-animations`,
`find-animation-opportunities` and `apple-design`. The gates port because they are claims about human
perception; the implementations are CSS and React Native and were rewritten for Flutter. All three
are worth reading in full.
