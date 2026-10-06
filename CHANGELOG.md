# Changelog

What changed in each kit version, and what a project or an install has to do about it. A
**Migration** line means something you already have stops working until you act on it.

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
