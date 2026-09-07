---
name: setup-flutter-project
description: Configure a Flutter repo for the engineering kit. Run once per project before using the other skills.
disable-model-invocation: true
---

# Setup Flutter project

Every other skill in this kit assumes two things exist: `docs/agents/project.md` (what differs
between client apps) and a `CLAUDE.md` carrying the always-on conventions, with an `AGENTS.md` twin
for opencode. This skill writes them,
and scaffolds the core structure when the repo does not have it yet.

Works on a brand-new `flutter create` repo and on an existing project. Explore first, propose, get
confirmation, then write. Never overwrite a file the project already has without showing the diff.

## 1. Explore

Answer these from the repo. Only ask the user what you genuinely cannot observe.

- **Is this greenfield or existing?** `lib/features/` present with real features means existing.
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
- **Existing docs.** `CLAUDE.md`, `AGENTS.md`, `CONTEXT.md`, `docs/`, a release checklist.
- **Test baseline.** Run `flutter analyze` and `flutter test`. Record the counts, including any
  failing test, before the project accumulates agent-authored code on top of it.

## 2. Propose

Show the user a filled-in draft of `docs/agents/project.md` using
[project.md](../../template/docs/agents/project.md) as the shape, with everything exploration
settled already filled and only the genuine unknowns marked. Then ask, one question at a time, in
this order. Lead each with your recommended answer so it can be accepted in a word.

1. **Safe flavor for verification.** Which flavor is safe to drive without creating real data. If
   the app has no flavors and talks to one live backend, say so plainly: verification will be
   limited to widget level until a staging environment exists.
2. **Design source.** Figma MCP server, pasted CSS plus screenshot, or written spec only.
3. **Issue tracker.** Default `none`, which routes specs and acceptance criteria to `docs/specs/`.
   Only name a real tracker if the project actually uses one.
4. **Test account.** Whether a credential exists for driving flows behind sign-in, and where it
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
- **`CLAUDE.md`** from [CLAUDE.md](../../template/CLAUDE.md), with the identity and command tables
  filled in. If a `CLAUDE.md` already exists, merge rather than replace: keep everything the project
  added, add the kit's sections that are missing, and show the diff.
- **`AGENTS.md`** from [AGENTS.md](../../template/AGENTS.md), filled in the same way and kept in
  sync with `CLAUDE.md`. opencode reads this file where Claude Code reads `CLAUDE.md`. If an
  `AGENTS.md` already exists, merge rather than replace, as with `CLAUDE.md`.
- **`docs/specs/.gitkeep`**, `docs/client/.gitkeep`, `docs/adr/.gitkeep` for whichever the answers
  above put in play.
- **Hooks, only if the kit is not installed as a plugin.** A plugin install already loads them
  from the kit's own `hooks/hooks.json`, so copying them again runs dart-format twice and blocks a
  pasted secret with two identical messages. Check `enabledPlugins` in `.claude/settings.json` and
  `~/.claude/settings.json` first: if either names `flutter-engineering-kit`, say the hooks are
  already active and copy nothing.
  Under opencode the equivalent check is whether `.opencode/plugins/flutter-kit.ts` exists and
  `opencode.json` sets the `formatter` key (both written by `scripts/sync-opencode.sh` in the kit):
  if both are present, say the opencode wiring is already active and copy nothing. If the project
  uses opencode but has no `.opencode/` mirror, tell the user to run that script rather than
  hand-copying files: it also generates the `commands/` and converted `agents/` opencode needs.
  Otherwise — a Cursor mirror, or the skills copied into `.claude/skills/` — copy `hooks/*.sh` into
  `.claude/hooks/` and wire them in `.claude/settings.json`: dart-format on `Edit|Write`,
  secret-scan on `UserPromptSubmit`, fixture-scan on `Bash`. Where a `settings.json` already
  exists, add only the missing hooks.

Do not write a `CONTEXT.md`. That is `domain-glossary`'s job, and it should be created lazily when
the first term is actually resolved. The same holds for `docs/agents/design.md`: `flutter-design`
writes it once there is a settled product to design against, so leave the Design language row
pointing at it and unfilled here.

## 5. Hand off

Tell the user what was written, then name the next step based on what the project is:

- **Greenfield, no brief yet** → tell them to run `/client-questionnaire`, to get the client's
  answers before any code exists. It is user-invoked, so only they can start it.
- **Greenfield with a brief** → call the Skill tool with `grill` to turn the brief into numbered
  acceptance criteria.
- **Existing project** → nothing further. The skills now read `docs/agents/project.md`. Mention that
  `flutter-verify` will report the test baseline recorded in step 1, so a pre-existing failure is
  never mistaken for new breakage. Where the repo already has screens, its design language exists in
  practice but nowhere in writing; call the Skill tool with `flutter-design` to recover it into
  `docs/agents/design.md` before the next screen adds to the drift.

Where exploration found integrations whose keys a human has to fetch by hand, call the Skill tool
with `setup-wizard`. Mention `scripts/sync-cursor.sh` in the kit if the team uses Cursor on this
repo, or `scripts/sync-opencode.sh` if it uses opencode.
