# Changelog

What changed in each kit version, and what a project or an install has to do about it. A
**Migration** line means something you already have stops working until you act on it.

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
