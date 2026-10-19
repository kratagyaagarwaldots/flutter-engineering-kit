## `<component>`: Flutter app

Written by `flutter-supabase-setup`. Install, Check, Test, Run and Build are this component's row
in **Components**; this section holds what the row does not.

### Identity

| Field | Value |
|---|---|
| App display name | `<App Name>` |
| Dart package name | `<dart_package_name>` |
| Android application id | `<com.client.app>` |
| iOS bundle id | `<com.client.app>` |

### Flavors

| Field | Value |
|---|---|
| Flavors | `<staging, live>` or `none` |
| Selected by | `<how the flavor is chosen, e.g. a FLAVOR key in a gitignored .env>` |
| Secret layers | `<Dart envied codegen, Android build.gradle.kts, iOS Secrets.xcconfig>` |
| Safe flavor for verification | `<staging>`, the flavor pointing at the environment marked safe |

### Architecture

`flutter-core-architecture` documents the kit's defaults. This table records what **this** project
actually uses, and it wins wherever the two differ. `flutter-supabase-conventions` resolves these
rows for every skill that generates code, so a wrong row here produces code in the wrong style.

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
| Theme location | `lib/core/constants/`, where colour, type and component defaults live | |
| Other deviations | `<none>` | |

### Verification surfaces

| Field | Value |
|---|---|
| Platforms | `<android, ios>` |
| Drivable surface | `<iOS simulator>` |
| Integration harness | `<none yet>` / `<integration_test + flutter drive>` |
| Startup gates in `main()` | `<Firebase, Remote Config, force-update, connectivity, push, Sentry>` |

Startup gates decide whether a driver can boot the app: every `await` before `runApp` is one.

### Commands

| Purpose | Command |
|---|---|
| Format | `dart format .` |
| Single test file | `flutter test <path>` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Switch flavor | `<the project's flavor-switching command>` |
