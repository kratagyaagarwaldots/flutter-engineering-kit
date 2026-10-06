# CLAUDE.md — Flutter Engineering Kit

This repo is a Claude Code plugin, not an app. Its product is the skills under `skills/`, the agents
under `agents/`, and the project templates under `skills/fk-setup/template/`.

## Before editing any skill

Call the Skill tool with `writing-for-agents`. It is the standard this repo holds itself to:
invocation choice, composition by tool call, single source of truth, completion criteria, pruning.

## The portability rule

**No client or project name appears anywhere in this repo.** The kit is written *from* real
projects — read them for reference while authoring — but a skill that names one stops being
portable, and reads as someone else's app to the next team. `scripts/validate-kit.py` check 8
enforces this. The terms it scans for are client data, so they live in the gitignored
`.kit-private/{client-names,project-symbols}.txt`, never in a tracked file; add a line there when a
new client starts. A checkout without that directory configures zero terms and the check passes.

The same applies to a client's **domain vocabulary**, which leaks more quietly than the name.
An example built on one client's nouns teaches the agent that domain. Use neutral examples, or the
generic Flutter case.

**A project fact never goes in a skill.** If something is true of one client's app but not of every
Flutter app, it belongs in that project's `docs/agents/project.md`, and the skill reads it from
there. Breaking this is how a portable kit stops being portable.

Fixed kit conventions (feature-first, a single barrel, sizing tokens, no hardcoded values, fixture
mode) are the exception: those are what the kit imposes, and `flutter-core-architecture` owns them.
Every other skill cites that skill rather than restating them.

## The stack rule

**A skill never names a state-management library.** The project's stack is a project fact, so it
lives in the Architecture table of `docs/agents/project.md`, and a skill reaches it by calling
`project-conventions`. `flutter_bloc` is the kit's *default* for a greenfield repo, not its
assumption.

Where a skill genuinely needs per-stack code, it goes in `skills/<name>/templates/<stack>.md` and
`SKILL.md` becomes a stack-neutral procedure routing to it. `flutter-create-state-layer` is the
worked example.

`validate-kit.py` check 10 enforces this. Its exemption list is a **ratchet**: remove a name when
that skill is restructured, never add one. A new skill needing stack-specific code gets a
`templates/` directory instead.

## Repo invariants

- Every `skills/<name>/SKILL.md` has `name:` exactly equal to its directory name.
- Every skill is registered in `.claude-plugin/plugin.json`'s `skills` array. Adding a skill means
  adding the path.
- An **invocation** is always an instruction to call the Skill tool with the name, never a link to
  `../other/SKILL.md` and never a bare `/name`.
- **Reading** a reference file owned by another skill may cross folders, but only when that skill is
  user-invoked and therefore cannot be called at all. That is the one sanctioned cross-link, and it
  is why `triage-executor-bugs` links into `spec-for-cheap-executor/references/`. Anywhere the owner
  is model-invoked, call it instead.
- The command surface is fixed: `ask-kit`, the six `fk-` commands, `retro`, and the tools
  `handoff`, `unslop` and `spec-for-cheap-executor`. Every other skill is model-invoked and reached
  through a command. Check 19 holds the list.
- Nothing calls a user-invoked skill. A user-invoked skill is reachable only by a human typing it,
  so a step needing one tells the user to run it.
- `ask-kit` routes every user-invoked skill. Adding, renaming or removing one means updating the
  router, or it lies.
- `README.md`'s Reference lists every skill, with the bullet text equal to the frontmatter
  description minus its trailing trigger sentence. Check 9 compares them, so the two cannot drift.
- `fk-setup/template/AGENTS.md` twins its `CLAUDE.md`. Both carry the same sections;
  every harness but Claude Code reads the AGENTS.md one.
- A skill carries every file it reads, inside its own folder. Nothing links out to `../../`, so a
  skill works from any harness's install location.
- Every user-invoked skill stays human-started in every harness that can enforce it: Codex through
  a generated `agents/openai.yaml` policy, opencode through a `permission.skill` gate and a
  same-named command. `scripts/kit.py` derives both from the frontmatter scan; never hand-write
  them. Check 16 holds this.
- No skill outside a `templates/` directory names a state-management library. See the stack rule.
- Agents obey the same rules: they reach a skill by calling the Skill tool, never by a
  `.claude/skills/...` path, and name no state library. Check 18 holds this.
- The opencode plugin matches opencode's **literal** tool ids: `bash` for the shell tool
  (`tool/shell/id.ts` keeps `ToolID = "bash"` until 2.0) and `apply_patch` for the patch tool
  (`Tool.define("apply_patch", ...)`). A source filename (`shell.ts`) and a registry variable
  (`tool.patch`) are not ids — reading either as one silently kills the hook. Checks 13 and 17
  hold both directions, so match those ids and nothing else.
- The delivery skills (`project-memory`, `project-tracker`, `project-proposal`,
  `project-backlog`) name no framework and call no engineering skill: they describe how a project
  is run. The `fk-` commands are where the delivery layer meets the Flutter skills. Check 20 holds
  this.
- Run `claude plugin validate . --strict` after touching either manifest.

Run `python3 scripts/validate-kit.py` before committing. It encodes all twenty, so a broken
invariant fails a check rather than surviving to review.

## Installing

The kit installs once per user, never into a project. `scripts/kit.py` is the installer:
Claude Code gets the managed plugin; Codex, opencode, Antigravity and Cursor get the skills
linked from a generated build under `~/.flutter-kit/build`, plus agents, commands and hooks
converted to the shape each one reads. `install/harnesses.json` is the one list of harnesses and
their paths; the installer and the site both read it, so add a harness there and nowhere else.

Generated files are never edited by hand: change the source here and re-run `kit install`.
`hooks/kit-hook.py` is the one hook for every command-hook harness, answering each in its own
payload shape; `opencode/plugins/flutter-kit.ts` is its opencode equivalent. The root
`install.sh` downloads a pinned tarball and delegates to `scripts/kit.py`. It carries no kit
content itself, so keep it that way.

## Site

`scripts/build-site.py` builds the GitHub Pages site from the kit: skills from their
frontmatter, groups and tracks from `README.md`, agents from `agents/`, harnesses from the
registry. `.github/workflows/pages.yml` runs it on every push to `main`. Edit
`site/template.html` for layout and copy; never edit the generated `_site/`.

## Versioning

Bump `version` in `.claude-plugin/plugin.json` when skill behaviour changes, so a project can tell
which kit it is running.
