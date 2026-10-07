# Changelog

What changed in each kit version, and what a project or an install has to do about it. A
**Migration** line means something you already have stops working until you act on it.

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
