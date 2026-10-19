# Changelog

What changed in each kit version, and what a project or an install has to do about it. A
**Migration** line means something you already have stops working until you act on it.

## 0.12.0

The kit is now two kits in one repo, ready to split: **product-engineer**, which runs a product and
its engineering on any stack, and **flutter-supabase**, the Flutter + Supabase stack kit. Neither
calls the other, and product-engineer names no stack. `kits.json` says which kit owns every skill,
agent and hook check, and check 23 fails on any call across the line.

- **`project-stack`** is the one route from product-engineer to a stack. It reads a new
  **Components** table in `docs/agents/project.md` (component, kind, stack, kit, path, and its
  install, check, test, run and build commands) and calls the stack kit's slot skills when they
  are installed: `<kit>-setup`, `-conventions`, `-design`, `-build`, `-verify`, `-release`.
  Without a kit, each slot falls back to the component's commands.
- **flutter-supabase fills the six slots**: `flutter-supabase-setup`, `-conventions`, `-design`,
  `-build`, `-verify` and `-release`. Its build lands a backend change before the app (migration,
  RLS, generated types, then the Flutter layers). Dedicated Supabase skills come next.
- **Renamed, now stack-free:** `flutter-plan-change` → `plan-change`, `flutter-tdd` → `tdd`,
  `flutter-verify` → `verify`, `flutter-code-review` → `code-review`, `flutter-diagnose-bug` →
  `diagnose-bug`, `flutter-explain` → `explain`, `flutter-merge-conflicts` → `merge-conflicts`.
  Their Flutter specifics moved into `flutter-supabase-verify` and `flutter-supabase-conventions`.
  `project-conventions` is now `flutter-supabase-conventions`. Agents: `flutter-architect` →
  `solution-architect`, `flutter-explore` → `codebase-explorer`.
- **New `security-audit`**: a stack-free security audit that adds each component's platform checks;
  `flutter-security-review` is its Flutter and Supabase depth, now with a Supabase backend pillar.
- `/fk-setup` writes a stack-free `project.md`, `CLAUDE.md` and `AGENTS.md`, then calls each
  component's `setup` slot, which adds the stack's own sections and rules. `/fk-build`,
  `/fk-release`, `setup-ci`, `takeover-audit` and the rest work through the Components table.
- `ask-kit` routes stack work through `project-stack` rather than naming stack skills.

**Migration:** a project set up before 0.12.0 has no Components table. Run `/fk-setup` again; it
keeps what the project added, writes the table, and moves the Flutter facts into the app
component's section. Anything calling a renamed skill by its old name must use the new one.

## 0.11.0

A command for requests the planned process does not cover.

- **`/fk-change`**, the seventh `fk-` command. It states what will be true when the change is done,
  maps which plans it alters (architecture, design language, glossary, scope, open tickets, the
  sprint, code already built), gives each open ticket it touches a verdict (keep, rewrite, block on
  the change's tracer, supersede), and sizes it as a detour or a re-plan. After the user confirms
  the map, it changes each document through its owner in order: decision, then record, then
  tickets. It then makes room in the sprint or offers the re-plan.
- Each change gets a note at `docs/vault/changes/NN-<slug>.md`, which the vault index's **Now**
  line points at while it is open, so a change that spans sessions resumes where it stopped.
- `ask-kit` routes plan-changing requests to `/fk-change`, and names it first when a change is open.
  `fk-sprint close` links the changes that ran during the sprint.

- **`kit update`** installs the latest release for every harness already installed, prints the
  changelog since the installed version, and asks for a restart. In Claude Code it also updates the
  plugin. `kit doctor` shows the installed version and says when a newer one exists.
- The install line now installs the **latest release** instead of a version written into the
  script, so it no longer falls behind. `--version vX.Y.Z` still pins one.

**Migration:** projects set up before 0.11.0 have no **Changes** heading in `docs/vault/index.md`;
`/fk-change` adds it with its first note. An install from before 0.11.0 has no `kit update`: run
the install line once more.

## 0.10.0

Planning now has an order you can see, and a feature list to plan sprints from.

- **Feature list.** `project-proposal` writes `docs/vault/features.md` beside the proposal: every
  agreed feature, numbered under its module (`M2.3`), with a priority (Must, Should, Could) and a
  phase. Adding or removing a feature is a proposal revision; moving its priority or phase is an
  edit the client agrees to.
- `project-backlog` cuts tickets for the **current phase's** features only, Must first, and every
  ticket names its feature in a `Feature:` line. Later phases are cut when they start.
- `fk-sprint plan` picks whole features by priority up to capacity, and the sprint note lists them.
  `close` reports features finished and says when a phase is done.
- **Criteria have one home per ticket.** Where a feature has a spec, its tickets name the spec's
  criterion numbers instead of copying them. `to-spec` records the feature ID and links the spec
  from the feature's row.
- **`ask-kit` reads where the project stands** (set up, scoped, backlogged, sprint planned, in a
  sprint) from the files each stage leaves, and names that stage's command first. The planning
  skills are listed in run order with what each leaves behind, so they no longer look
  interchangeable.
- `project-tracker` reports per feature; `fk-feedback` treats behaviour no feature promises as a
  change request, and adds the feature's row on approval.

**Migration:** a project planned before 0.10.0 has no `features.md`. Run `/fk-plan`; it routes to
`project-proposal`, which lists the features from the agreed proposal's modules as a new revision.
Existing tickets keep working, and gain a `Feature:` line when they are next edited.

## 0.9.2

`spec-for-cheap-executor` is now only for work that leaves the session with nobody reviewing it
before it lands. Inside the kit, a cheaper model builds through the agents and the loop, where a
check after the work is far cheaper than a spec that removes every guess up front.

- `spec-for-cheap-executor` opens with a gate: a kit agent routes to `/fk-build`, a sprint to
  `kit loop run`, and a change the doc would mostly write out to building it directly. It cites
  kit skills and agents only where the executor has the kit.
- `fk-build` stops sending "use a cheaper model" to the spec. It hands mechanical slices to the
  build-role agents with a four-part brief (scope, obsolete code with an `rg` proof, a test that
  fails first, normal and failing outcomes) and checks each diff itself.
- `ask-kit` routes cheaper builds to `configure-models`, and the spec only to outside handoffs.

## 0.9.1

Sync with [pstack](https://github.com/cursor/plugins/tree/main/pstack) (Lauren Tan, MIT) from
0.14.5, where the kit forked it, to 0.15.15, rewritten for Flutter. The kit now credits pstack.

- `engineering-principles` gains a fifth principle, design for agent contributors: one owner per
  piece of state, one way per task, no hand-kept duplicate lists, nothing feature-private callable
  from everywhere. `flutter-plan-change` sketches owners, and `flutter-code-review` flags a second
  writer, way or list.
- `flutter-write-tests` requires every test to be able to fail: a test that would still pass if
  every function it calls returned `null` gets rewritten or deleted. The review baseline flags it.
- `retro` proposes the highest fix level that works (remove the cause, make it unwritable, a lint
  whose error names the fix, a test), proves each new check fails on the round's own mistake, and
  records what enforces each applied edit.
- `flutter-performance` checks a number before trusting it: repeated alternating runs, what bounds
  it, whether the work happened, equal setups, and its share of what the user waits for.
- `pr` adds a Scope section and keeps long evidence out of the body.
- `flutter-verify` labels every claim as measured, inferred or guess.
- `flutter-diagnose-bug` stops after two failed fixes to test the assumption they shared.
- `unslop` drops "Adding soul" and gains rules 32 (mannered prose) and 33 (over-compression).

## 0.9.0

Agents can now build a planned sprint unattended, on models the user chose, without a model
sitting in a loop.

- `kit loop run <project>` builds the sprint's `ready-for-agent` tickets in worktrees, opens each
  pull request, sends red CI back to the builder, has a reviewer from another model family review
  each new commit, escalates only one-way doors to the strongest model, and labels the pull
  request `ready-for-human` with a desktop notification. It cleans up the worktree and branch after
  you merge. It stops and hands over after three review rounds, three CI fixes or the budget.
- The kit names no models. `install/roles.json` describes five roles; the new `configure-models`
  skill picks a model per role and harness with the user; `kit models show | discover | probe |
  set | report` manages and audits the choice.
- `kit install` pins those models into every harness's agents. Before this, every kit sub-agent
  outside Claude Code inherited the session's model.
- The tracker gains the `agent-loop` and `agent-stuck` labels; `issue-tracker.md` gains an Agent loop
  table.

**Migration:** run `kit install` again, then let your agent run `configure-models`. Without it,
agents keep inheriting the session's model and `kit loop` refuses to start. The loop creates its
two labels on its first run.

## 0.8.0

The kit can now run a project, not only build one: a proposal, a pointed backlog, sprints, a QA
gate, feedback triage and acceptance testing, with the project's memory in the repo and its tickets
in GitHub.

- `/fk-sprint` (new): `plan`, `status`, `qa`, `close` and `uat`.
- `/fk-feedback` (new): sorts feedback into bugs, change requests and questions against the
  proposal, files them and drafts the reply.
- `/fk-plan` gains a product path: proposal, agreement, design language, backlog. The feature path
  is unchanged.
- `/fk-build` takes a ticket number, closes it through the pull request, and leaves a log entry.
- `/fk-setup` asks whether the code is inherited, recommends GitHub Issues as the tracker, writes
  `docs/vault/` and `docs/agents/issue-tracker.md`, creates the labels, and audits an inherited app.
- New background skills: `project-memory`, `project-tracker`, `project-proposal`,
  `project-backlog` (stack-neutral, held by check 20) and `takeover-audit`.
- New agent: `qa-engineer`.
- Project templates: `CLAUDE.md` and `AGENTS.md` gain a Memory section and list six commands;
  `project.md`'s Documents table names the vault and the tracker.

**Migration:** for an existing project, re-run `/fk-setup` to add the vault, the tracker conventions
and the labels; nothing it wrote before is replaced. Re-run `kit install` so the other harnesses get
the two new commands and the new agent.

## 0.7.0

- `flutter-create-feature-e2e`, `flutter-create-screen-e2e` and `flutter-create-feature` are one
  skill, `flutter-scaffold-feature`, in three modes: real (a model and endpoint exist), fixture
  (screen first, API later) and upgrade (fixture to real API). `/fk-build` routes to it.
- The scaffolder is stack-neutral: it generates in the project's state management through
  `project-conventions`, and sizes in the project's sizing strategy rather than `.w`/`.sp`.

**Migration:** none for a project. A fixture-mode feature built by the old screen scaffolder
upgrades through `/fk-build` as before; its README's "fixture mode" heading is still what is read.

## 0.6.0

Four commands now carry the work, and every other skill is reached through them.

- `/fk-setup` (was `/setup-flutter-project`), `/fk-plan` (new), `/fk-build` (was
  `/flutter-implement`, now also routes to the scaffolders), `/fk-release` (new).
- `client-questionnaire`, `to-spec`, `setup-ci`, `setup-integration-harness`,
  `flutter-create-feature-e2e`, `flutter-create-screen-e2e`, `release-readiness` and
  `store-compliance` are no longer typed; the commands call them, and the agent can still reach
  for one directly.
- `retro`, `ask-kit`, and the tools `handoff`, `unslop` and `spec-for-cheap-executor` stay as
  commands.

**Migration:** type the new names. Re-run the installer (`kit install --for ...`) so Codex and
opencode drop the old command gates. A project whose `CLAUDE.md` or `AGENTS.md` was written by an
earlier `/setup-flutter-project` still names the old commands in its Skills section; run `/fk-setup`
to refresh it, or edit the section by hand.

## 0.5.1

- `retro` reads the repo's existing guardrails first and sorts every mistake into an automated
  check or a review rule.
- `flutter-code-review` carries the general code smells and reads a project's
  `docs/agents/coding-standards.md`.
- New `pr` skill for pull request bodies.

## 0.5.0

- The kit installs once per user for Claude Code, Codex, opencode, Antigravity and Cursor, through
  `install.sh` and `kit`. Projects no longer carry a copy.
- `CONTEXT.md` is now `GLOSSARY.md`.

**Migration:** run `kit clean-project <path>` on any project holding a `.opencode/`, `.cursor/` or
`.claude/` copy of the kit; `domain-glossary` renames an existing `CONTEXT.md` the first time it
runs.
