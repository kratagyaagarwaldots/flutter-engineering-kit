---
name: flutter-supabase-setup
description: Configure a Flutter app or Supabase backend component: its Architecture table from the code, its commands in the Components table, its sections of docs/agents/project.md, CLAUDE.md and AGENTS.md, its path-scoped rules, and the lib/core scaffold on a greenfield app. Use when asked for the setup slot of a component this kit serves, or when a Flutter project's stack configuration needs writing or redoing.
---

# Flutter + Supabase setup

The `setup` slot for every component whose Kit is `flutter-supabase`. The project's own
configuration (identity, the Components table, environments, documents) is already in
`docs/agents/project.md`; this skill adds what only a Flutter app or a Supabase backend has.

Explore first, propose, get confirmation, then write. Never overwrite a file the project already
has without showing the diff.

## 1. Explore the component

Read `docs/agents/project.md` first, for the component's row and the environment marked safe.

**A Flutter app** (a `pubspec.yaml` at the row's Path):

- **The Architecture rows.** Call the Skill tool with `flutter-supabase-conventions` for every row
  of the Architecture table in [templates/project-section.md](templates/project-section.md). With
  no table written yet it resolves each from the repo, an existing feature and its tests winning
  over `pubspec.yaml`, and names the file that proves it. On an existing project this is the most
  consequential part of setup: every code-generating skill reads these rows, so a row guessed here
  produces code in the wrong style for the life of the project. A greenfield app resolves to the
  kit's defaults, which `flutter-core-architecture` owns.
- **Identity.** `pubspec.yaml` `name:`, `android/app/build.gradle.kts` `applicationId`,
  `ios/Runner.xcodeproj` bundle id.
- **Flavors.** A gitignored `.env`, any flavor-switching script under `tool/` or `scripts/`, a
  generated native secrets file, envied usage (`@Envied` annotations), and product flavors in the
  Gradle config. The safe flavor is the one pointing at the environment marked safe.
- **Startup gates.** Read `lib/main.dart`. Every `await` before `runApp` is a gate a verification
  driver has to survive. List them.
- **Platforms.** Which of `android/ ios/ web/ macos/ windows/ linux/` exist.
- **Integration harness.** Whether `integration_test/` exists and anything drives it.
- **Codegen.** Whether `build_runner` is a dev dependency, and which files it generates.

**A Supabase backend** (a `supabase/` folder): its migrations under `supabase/migrations/`, its
tests under `supabase/tests/`, and its edge functions under `supabase/functions/`.

Done when every Architecture row has a file proving it or is named the greenfield default, and
every field of the section template is filled or marked as a question.

## 2. Propose

Show the user the filled section of `docs/agents/project.md`, built on
[templates/project-section.md](templates/project-section.md), and the component's commands. Show
the Architecture table and ask the user to correct it rather than asking row by row: on an existing
project the code has already answered, and on a greenfield one the kit's defaults are a reasonable
starting point. Ask about a row only where the repo left it genuinely undecided. What matters is
that the table ends up describing the project rather than the kit.

Done when the user has confirmed the section and the commands.

## 3. Write

Write, showing each for approval first:

- **The component's row** in the Components table, its five commands filled:

  | Column | Flutter app | Supabase backend |
  |---|---|---|
  | Kind | `client` | `database`, or `server` where `supabase/functions/` holds edge functions |
  | Stack | `Flutter` | `Supabase` |
  | Kit | `flutter-supabase` | `flutter-supabase` |
  | Install | `flutter pub get`, then the codegen command where the app generates code | `none`: the Supabase CLI is installed per machine |
  | Check | `dart format --output=none --set-exit-if-changed . && flutter analyze` | `supabase db lint` |
  | Test | `flutter test` | `supabase test db` |
  | Run | `flutter run`, on the safe flavor | `supabase start` |
  | Build | `flutter build appbundle` and `flutter build ipa`, per flavor | `none`: migrations ship as written |

  Install carries codegen so that Check never analyzes symbols nobody generated. Where the project
  runs a command of its own instead (a flavor script, a Makefile target), record that one.
- **The component's section of `docs/agents/project.md`**, from
  [templates/project-section.md](templates/project-section.md), appended at the end of the file.
  A Supabase backend gets no section yet.
- **The component's section of `CLAUDE.md` and of `AGENTS.md`**, from
  [templates/conventions-section.md](templates/conventions-section.md), appended to each, the two
  identical. Fill the logic seam folder and the data return contract from the confirmed rows.
- **`.claude/rules/`** from [templates/](templates/), choosing by the Architecture table:
  `flutter-ui.md` and `flutter-models.md` always, and `flutter-bloc.md` only where the Logic seam
  is `Bloc`. Each is path-scoped, so it loads only while the agent edits matching files. Copy a
  rule only where the project has no file of that name, and say which you skipped.

Fuller Supabase setup (schema conventions, row-level security, generated types) arrives with the
Supabase skills. Until then this slot records the backend's row and nothing more.

Done when every file above is written or its skip is named.

## 4. Scaffold, for a greenfield app only

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
`lib/main.dart` import only that barrel. Add the packages
[templates/scaffold.md](templates/scaffold.md) lists for the confirmed rows.

These are the kit's defaults, and a greenfield repo has nothing to contradict them. Where the user
names a different stack, scaffold that one instead and record it in the Architecture table; the
table is what every later skill reads.

Sizing needs no package. Create `AppDimensions` with spacing and radius tokens in logical pixels,
and leave font sizes to `AppTextStyles`.

On an existing repo, scaffold nothing. The Architecture table already records what the project does,
which is what stops skills assuming a shape it does not have.

Done when `flutter analyze` is clean on the scaffold.

## Completion criterion

Hand back, per component: its row with every command filled, the files written and the rules
skipped, and each Architecture row with the file that proves it or the word `default`. A row left
blank is not set up: name it and the question that settles it.
