# Project configuration

Written by `/setup-flutter-project`. Every kit skill reads this file for anything that differs
between client apps. If a skill needs a fact that is not here, the fact belongs here.

Edit this file directly when something changes. Re-run the setup skill only to start over.

## Identity

| Field | Value |
|---|---|
| App display name | `<App Name>` |
| Dart package name | `<dart_package_name>` |
| Android application id | `<com.client.app>` |
| iOS bundle id | `<com.client.app>` |
| Client | `<client or internal>` |
| Repo | `<git remote url>` |

## Flavors

| Field | Value |
|---|---|
| Flavors | `<staging, live>` or `none` |
| Selected by | `<how the flavor is chosen, e.g. a FLAVOR key in a gitignored .env>` |
| Secret layers | `<Dart envied codegen, Android build.gradle.kts, iOS Secrets.xcconfig>` |
| Safe flavor for verification | `<staging>` |

**Never verify against the live flavor** when the app writes real data (orders, payments,
messages). Name the safe flavor above and use it.

## Architecture

`flutter-core-architecture` documents the kit's defaults. This table records what **this** project
actually uses, and it wins wherever the two differ. `project-conventions` resolves these rows for
every skill that generates code, so a wrong row here produces code in the wrong style.

The Value column below is filled with the kit's default. Replace each with what the repo does.

| Field | Value | Common alternatives |
|---|---|---|
| Logic seam | `Bloc<Event, State>` | `Notifier` / `AsyncNotifier`, `ChangeNotifier`, plain class |
| Logic test tool | `bloc_test` | `ProviderContainer`, `addListener`, plain `test` |
| Widget-test wrapper | `BlocProvider.value` | `ProviderScope(overrides:)`, `ChangeNotifierProvider.value` |
| Dependency injection | constructor | `ref.watch`, `get_it`, `InheritedWidget` |
| Serialization | hand-written `fromJson` | `json_serializable`, `freezed` |
| Navigation | `AppRouter.onGenerateRoute` | `go_router`, `auto_route` |
| Data return contract | reads `Future<T?>`, writes `Future<Either<Failure, T>>` | a `Result` type, throwing |
| Sizing strategy | tokens + breakpoints | `flutter_screenutil` |
| Barrel path | `lib/core/router/exports.dart` | per-file imports |
| Other deviations | `<none>` | |

## Design source

| Field | Value |
|---|---|
| Source | `<Figma MCP server>` / `<pasted CSS + screenshot>` / `<written spec only>` |
| Figma file or project | `<url>` |
| Token strategy | `<get_variable_defs first, then get_design_context>` |
| Theme location | `<lib/core/constants/>` — where colour, type and component defaults are centralised |
| Design language | `<docs/agents/design.md>` — personality, type steps, colour roles, motion tokens and state patterns. Written by `flutter-design` once there is something to settle; `<not yet settled>` until then |

## Documents

| Field | Value |
|---|---|
| Acceptance criteria and specs | `docs/specs/` |
| Domain glossary | `CONTEXT.md` |
| Decisions worth recording | `docs/adr/` |
| Client questionnaires | `docs/client/` |
| Store and compliance pack | `docs/store/` |
| Issue tracker | `<none — specs and AC live in docs/>` |

When the tracker is `none`, skills that would publish an issue write a file under `docs/specs/`
instead. Set it to GitHub, Linear, or Jira once the project actually uses one.

## Integrations

Only what is wired. An empty row means the app does not do this.

| Concern | Provider |
|---|---|
| Crash and error reporting | `<Sentry>` |
| Push notifications | `<OneSignal / FCM>` |
| Remote config or force-update | `<Firebase Remote Config>` |
| Maps and places | `<Google Places>` |
| Payments | `<>` |
| Auth | `<email + social>` |
| Analytics | `<>` |

## Verification

| Field | Value |
|---|---|
| Platforms | `<android, ios>` |
| Drivable surface | `<iOS simulator>` |
| Integration harness | `<none yet>` / `<integration_test + flutter drive>` |
| Test account | `<none — most flows need sign-in>` |
| Startup gates in `main()` | `<Firebase, Remote Config, force-update, connectivity, push, Sentry>` |
| Known failing tests | `<none>` |

`flutter-verify` reads the last two rows. Startup gates decide whether a driver can boot the app;
known failing tests stop an agent reporting a pre-existing failure as its own breakage.

## Commands

| Purpose | Command |
|---|---|
| Install deps | `flutter pub get` |
| Lint | `flutter analyze` |
| Format | `dart format .` |
| Test | `flutter test` |
| Single test file | `flutter test <path>` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Switch flavor | `<the project's flavor-switching command>` |
