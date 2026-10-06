---
name: fk-setup
description: Configure a Flutter repo for the engineering kit. Run once per project before using the other skills.
disable-model-invocation: true
---

# Setup Flutter project

Every other skill in this kit assumes these exist: `docs/agents/project.md` (what differs between
client apps), a `CLAUDE.md` carrying the always-on conventions with an `AGENTS.md` twin for Codex,
opencode, Antigravity and Cursor, the memory vault at `docs/vault/`, and the tracker conventions in
`docs/agents/issue-tracker.md`. This skill writes them, and scaffolds the core structure when the
repo does not have it yet.

The kit itself is installed once per user, not into the project. What this skill writes is the
project's own configuration, and it is the only kit-shaped thing a project carries.

Works on a brand-new `flutter create` repo and on an existing project. Explore first, propose, get
confirmation, then write. Never overwrite a file the project already has without showing the diff.

## 1. Explore

Answer these from the repo. Only ask the user what you genuinely cannot observe.

- **Is this greenfield or existing?** `lib/features/` present with real features means existing.
- **Whose code is it?** `git log --reverse --format='%an %ad' | head` and the contributor list. A
  history written by people the user does not name, or one squashed import commit, suggests an
  inherited codebase. Confirm in step 2; an inherited one gets an audit before any estimate.
- **The stack.** Fill every row of the Architecture table from the repo, not from the kit's
  defaults. `pubspec.yaml` says what is available; an existing feature under `lib/features/` and its
  tests say what is actually used, and they win. On an existing project this is the most consequential
  part of setup: every code-generating skill reads these rows through `project-conventions`, so a
  row guessed here produces code in the wrong style for the life of the project.
- **Identity.** `pubspec.yaml` `name:`, `android/app/build.gradle.kts` `applicationId`,
  `ios/Runner.xcodeproj` bundle id, `git remote -v`.
- **Flavors.** A gitignored `.env`, any flavor-switching script under `tool/` or `scripts/`, a
  generated native secrets file, envied usage (`@Envied` annotations), and product flavors in the
  Gradle config.
- **Integrations.** Read `pubspec.yaml` dependencies. Sentry, OneSignal, `firebase_*`,
  `google_maps_flutter` or Places, a payments SDK, social sign-in packages.
- **Startup gates.** Read `lib/main.dart`. Every `await` before `runApp` is a gate a verification
  driver has to survive. List them.
- **Platforms.** Which of `android/ ios/ web/ macos/ windows/ linux/` exist.
- **Existing docs.** `CLAUDE.md`, `AGENTS.md`, `GLOSSARY.md`, `docs/`, a release checklist.
- **Test baseline.** Run `flutter analyze` and `flutter test`. Record the counts, including any
  failing test, before the project accumulates agent-authored code on top of it.

## 2. Propose

Show the user a filled-in draft of `docs/agents/project.md` using
[project.md](template/docs/agents/project.md) as the shape, with everything exploration
settled already filled and only the genuine unknowns marked. Then ask, one question at a time, in
this order. Lead each with your recommended answer so it can be accepted in a word.

1. **Whose code is this**, on an existing repo: the user's own, or inherited from someone else.
   Lead with what the history suggested.
2. **Safe flavor for verification.** Which flavor is safe to drive without creating real data. If
   the app has no flavors and talks to one live backend, say so plainly: verification will be
   limited to widget level until a staging environment exists.
3. **Design source.** Figma MCP server, pasted CSS plus screenshot, or written spec only.
4. **Issue tracker.** Recommend GitHub Issues when the remote is on GitHub and `gh auth status`
   succeeds: tickets, sprints and parallel agents all depend on it. Otherwise `none`, which keeps the
   backlog in the vault. Where the team already runs Linear or Jira, record it in `project.md` and
   use `none` for the kit's own tracking, since `project-tracker` speaks only GitHub. With GitHub,
   also ask the sprint length (recommend one week) and whether to create a project board.
5. **Test account.** Whether a credential exists for driving flows behind sign-in, and where it
   lives. Never write the credential itself into any file; record where it is kept.

Skip any question exploration already answered.

Ask about architecture only where the repo left a row genuinely undecided. Show the filled
Architecture table and ask the user to correct it rather than asking row by row: on an existing
project the code has already answered, and on a greenfield one the kit's defaults are a reasonable
starting point that `flutter-core-architecture` documents. What matters is that the table ends up
describing the project rather than the kit.

## 3. Scaffold, for a greenfield repo only

If `lib/core/` does not exist, create the structure `flutter-core-architecture` documents:

```
lib/
├── core/
│   ├── components/   constants/   error/   models/
│   ├── network/      repositories/
│   ├── router/       exports.dart + app_router.dart + app_routes.dart
│   ├── services/     utils/
└── features/
```

Create `lib/core/router/exports.dart` with the runtime exports the kit expects, and make
`lib/main.dart` import only that barrel. Add `flutter_bloc`, `equatable`, `dartz`, `dio` and
`flutter_secure_storage` to `pubspec.yaml`, plus `bloc_test` and `mocktail` under
`dev_dependencies`. Run `flutter pub get`.

These are the kit's defaults, and a greenfield repo has nothing to contradict them. Where the user
names a different stack, scaffold that one instead and record it in the Architecture table; the
table is what every later skill reads.

Sizing needs no package. Create `AppDimensions` with spacing and radius tokens in logical pixels,
and leave font sizes to `AppTextStyles`.

On an existing repo, scaffold nothing. The Architecture table already records what the project does,
which is what stops skills assuming a shape it does not have.

## 4. Write

Write, showing each for approval first:

- **`docs/agents/project.md`** from the confirmed draft.
- **`CLAUDE.md`** from [CLAUDE.md](template/CLAUDE.md), with the identity and command tables
  filled in. If a `CLAUDE.md` already exists, merge rather than replace: keep everything the project
  added, add the kit's sections that are missing, and show the diff.
- **`AGENTS.md`** from [AGENTS.md](template/AGENTS.md), filled in the same way and kept in
  sync with `CLAUDE.md`. Codex, opencode, Antigravity and Cursor read this file where Claude Code
  reads `CLAUDE.md`. If an `AGENTS.md` already exists, merge rather than replace, as with
  `CLAUDE.md`.
- **`.claude/rules/`** from [template/rules/](template/rules/), choosing by the Architecture table:
  `flutter-ui.md` and `flutter-models.md` always, and `flutter-bloc.md` only where the Logic seam
  is `Bloc`. Each is path-scoped, so it loads only while the agent edits matching files. Copy a
  rule only where the project has no file of that name, and say which you skipped.
- **`docs/specs/.gitkeep`**, `docs/client/.gitkeep`, `docs/adr/.gitkeep` for whichever the answers
  above put in play.
- **`docs/vault/index.md`** and **`docs/vault/memory.md`** from [template/docs/vault/](template/docs/vault/),
  with the app name and today's date filled in. Create no other vault note: each is written by the
  skill that owns it, when it has something to say. Where a vault already exists, leave it.
- **`.gitattributes`** gains two lines, so agents on parallel branches merge their memory rather
  than conflict on it:

  ```
  docs/vault/memory.md merge=union
  docs/vault/index.md merge=union
  ```

- **With GitHub as the tracker**, `docs/agents/issue-tracker.md` from
  [issue-tracker.md](template/docs/agents/issue-tracker.md) with the repo, board and sprint answers
  filled in. Then call the Skill tool with `project-tracker` to set up the labels and, if the user
  wanted one, the board.

Hooks are not this skill's job: the user-level install wires them for every harness. Where the
user reports that formatting or the secret scan is not running, tell them to run `kit doctor`.

Do not write a `GLOSSARY.md`. That is `domain-glossary`'s job, and it should be created lazily when
the first term is actually resolved. The same holds for `docs/agents/design.md`: `flutter-design`
writes it once there is a settled product to design against, so leave the Design language row
pointing at it and unfilled here.

## 5. Hand off

Tell the user what was written, then name the next step based on what the project is:

- **Greenfield** → tell them to run `/fk-plan`. It writes the proposal, the design language and the
  backlog, starting with a questionnaire for the client where there is no brief yet.
- **The user's own existing app** → the skills now read `docs/agents/project.md`. Mention that
  `flutter-verify` will report the test baseline recorded in step 1, so a pre-existing failure is
  never mistaken for new breakage. Where the repo already has screens, its design language exists in
  practice but nowhere in writing; call the Skill tool with `flutter-design` to recover it into
  `docs/agents/design.md` before the next screen adds to the drift. Then tell them to run `/fk-plan`
  for the next phase of work, or `/fk-build` for a single change.
- **An inherited app** → call the Skill tool with `takeover-audit` before anything else. An
  estimate given before the audit is a guess about code nobody here has run. Then tell them to run
  `/fk-plan`, which builds the proposal on the audit's findings.

Where exploration found integrations whose keys a human has to fetch by hand, call the Skill tool
with `setup-wizard`.

Where the repo still carries a copy of the kit from an older version (kit skills under
`.opencode/skills/`, `.cursor/skills/` or `.claude/skills/`), tell the user to run
`kit clean-project <path>`, which removes the kit's files and keeps the project's own. Two copies
offer every skill twice.
