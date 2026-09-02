---
name: flutter-core-architecture
description: The kit's lib/core conventions: project structure, barrel imports, constants families, shared components, services, network, failures, router, and fixture markers. Read before creating or extending shared UI, constants, or core infrastructure; other skills cite this instead of restating it.
---

# Core Architecture

The conventions every kit skill builds on. Feature skills (`flutter-create-*`, refactor, review,
security) and the kit's agents **cite this skill** rather than restating dialogs, text widgets,
constants, or folder layout.

## Two sources, and which is which

This skill owns the **conventions**: the layout, the naming families, the contracts, the rules. They
are fixed, they apply to every project the kit is installed in, and `setup-flutter-project` scaffolds
them on a greenfield repo.

The **repo owns the inventory**: which shared components, services, utils and constants actually
exist right now, and what their exact APIs are. That changes per project and per week.

So before you recommend or reuse a shared piece, **read `lib/core/` and confirm it is there.** Never
tell an agent to use a component because this skill mentions one by role. A recommendation for
something that does not exist in the repo costs more than writing it fresh.

Project-specific facts — flavors, integrations, commands — live in `docs/agents/project.md`.

## When to use

- Bootstrapping or extending anything under `lib/core/`
- Choosing a shared widget, util, service, or constant from a feature
- Before adding a new dialog, text helper, colour, or loading pattern
- Reviewing whether a feature reuses core correctly

Layer skills own the BLoC, model, repo and screen templates. This skill owns the substrate they sit
on.

---

## 1. Project structure

```
lib/
├── core/
│   ├── components/   # Cross-feature widgets
│   ├── constants/    # App* constant classes (see §3)
│   ├── error/        # Sealed Failure types
│   ├── models/       # DTOs shared by more than one feature
│   ├── network/      # ApiClient, ApiEndpoints, interceptors
│   ├── repositories/ # Repos used by more than one feature
│   ├── router/       # exports.dart (barrel) + AppRouter + AppRoutes
│   ├── services/     # Singletons: navigation, token storage, platform wrappers
│   └── utils/        # Snackbars, mixins, formatters, notifiers
└── features/{name}/
    ├── bloc/         # {name}_bloc.dart + part event/state
    ├── model/        # Feature DTOs
    ├── repo/         # Feature repository
    ├── view/         # {Name}Page (Scaffold root)
    └── widget/       # Feature-scoped widgets
```

**Rules**

- Share only through `lib/core/`. A feature never imports from another feature.
- HTTP lives in `network/`; storage and platform wrappers live in `services/`. Keep both there rather
  than adding a `data/` layer or a service locator.
- A feature's `repo/` wraps that feature's endpoints. Data access two features need goes in
  `core/repositories/`.
- Every new file under `lib/` is exported from `exports.dart` (§2).

---

## 2. Barrel / exports

Every file under `lib/` has exactly one import:

```dart
import '../../../core/router/exports.dart'; // adjust relative depth
```

| Rule | Detail |
|------|--------|
| Single barrel | One import per file — the barrel re-exports both runtime packages and project files |
| New package | Add an `export` line in `exports.dart`, alphabetical within its section |
| New project file | Add an `export` line in `exports.dart` |
| Conflicts | Hide the clashing symbol in the barrel (e.g. `export 'package:dartz/dartz.dart' hide State;`) |
| Part files | `part of` only, never an import — they inherit the bloc file's imports |
| Tests | Import `package:<package_name>/core/router/exports.dart` (name from `pubspec.yaml`), then the dev-only test packages directly |

---

## 3. Constants families

Every colour, string, asset path and dimension is a named constant, referenced from widgets rather
than written at the point of use.

| Class | File | Extend by |
|-------|------|-----------|
| `AppColors` | `app_colors.dart` | A `static const Color`. Encode alpha in the hex value rather than calling `.withOpacity()` |
| `AppStrings` | `app_strings.dart` | A `static const String` for every user-facing string |
| `AppAssets` | `app_assets.dart` | Asset path constants |
| `AppDimensions` | `app_dimensions.dart` | Named spacing and radius tokens, in logical pixels |
| `AppTextStyles` | `app_text_styles.dart` | Named factory methods returning a `TextStyle` in the project's font. Prefer a named style over an inline `TextStyle` |
| `AppGradients` | `app_gradients.dart` | Shared gradients, when the design uses them |
| `AppFieldLimits` | `app_field_limits.dart` | Max lengths and input constraints |

A project adds its own families to this pattern as it needs them. Read `lib/core/constants/` for
the ones that exist; the naming convention is what this skill fixes, not the list.

### Sizing

Call the Skill tool with `project-conventions` for the Sizing strategy row before writing sizes; the
two strategies read very differently and mixing them in one tree is worse than either.

**Tokens and breakpoints**, the default on a new project. Spacing and radii are `AppDimensions`
constants in logical pixels, which are already density-independent, so they need no multiplier.
Where a layout should differ on a wider screen, switch it with `LayoutBuilder` at a named breakpoint
rather than scaling the phone layout up: a tablet has more room, not bigger fingers.

Leave font sizes unscaled. The OS text-scale setting reaches the tree through `TextScaler`, and a
size multiplied at the callsite overrides the setting a user chose for legibility. Where large text
would break a layout, give the text room to grow rather than capping it.

**`flutter_screenutil`**, on projects already using it: `16.w`, `20.h`, `8.r`, and follow what the
existing screens do. Prefer fixed sizes for fonts even here, so OS text scaling still works.

---

## 4. The shared component set

The kit scaffolds four components by role. Confirm the exact API in `lib/core/components/` before
using one; the role is the convention, the signature is the repo's.

| Role | Typical name | Use it for |
|---|---|---|
| Text | `TextWidget` | All in-app copy, so overflow and style defaults are consistent. Pair it with `AppTextStyles` |
| Primary action | `CustomButton` | Every CTA, rather than a raw `ElevatedButton` |
| Text input | `CommonTextField` | Form fields, rather than a bare `TextFormField`. A feature-local wrapper is fine when it encapsulates one fixed visual spec |
| Back affordance | `BackButtonWidget` | The app-wide back control, rather than a hand-rolled `IconButton` |

A project usually grows more: a loading-aware button, a secondary button, a card shell. Read the
directory and reuse what is there before adding another.

---

## 5. Dialogs and confirmation

Confirmation and destructive prompts go through one shared path so every one looks and behaves the
same.

The convention is a mixin on the view, exposing a future that resolves to the user's choice:

```dart
class _ProfileView extends StatelessWidget with ConfirmationDialogMixin {
  Future<void> _onSignOut(BuildContext context) async {
    final bool confirmed = await showConfirmationDialog(
      context,
      title: AppStrings.signOutTitle,
      message: AppStrings.signOutMessage,
      confirmLabel: AppStrings.signOutConfirm,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    // dispatch the event, or navigate
  }
}
```

For a one-off prompt with no mixin, the kit's convention is a single shared alert helper
(`showIosAlertDialog` or the project's equivalent) rather than a bespoke `showDialog` shell.

Reach for the shared path before adding another alert widget. Where the shared path genuinely does
not fit, extend it rather than building alongside it.

---

## 6. Snackbars, haptics, keyboard

| Helper | Where | Convention |
|--------|-------|------------|
| `showSuccessSnackBar` / `showErrorSnackBar` / `showInfoSnackBar` | `utils/snackbar.dart` | Use these rather than reaching for `ScaffoldMessenger` at a callsite |
| `HapticUtil.*` | `utils/haptic_utils.dart` | Taps that warrant tactile feedback |
| `ApplicationUtils.hideKeyboard` | `utils/application_utils.dart` | On submit and before navigation |

Side effects, meaning snackbars, dialogs and navigation, belong in the listener the project's
state-management seam provides, driven by emitted state. Keep them out of the state layer itself.

---

## 7. Services and network

| Piece | Path | Pattern |
|-------|------|---------|
| `NavigationService.instance` | `services/navigation_service.dart` | Programmatic navigation from listeners and services, with typed route arguments. Use it instead of `Navigator.of(context)` outside the widget tree |
| `TokenStorage` | `services/token_storage.dart` | Backed by `flutter_secure_storage`. Sensitive values never go in `SharedPreferences` |
| Platform services | `services/` | One singleton or static helper per concern. `docs/agents/project.md` lists which the project wires |
| `ApiClient` | `network/api_client.dart` | A Dio wrapper that maps transport and status errors onto `Failure` types |
| `ApiEndpoints` | `network/api_endpoints.dart` | Path constants, never inline URL strings |
| Log interceptor | `network/` | Debug builds only |

Inject `ApiClient` into a repository through its constructor with a fallback
(`client ?? ApiClient()`), so a test can substitute one.

---

## 8. Errors — `Failure`

A sealed hierarchy in `lib/core/error/failure.dart`. The kit's baseline set:

- `NetworkFailure` — no connectivity, timeout, transport error
- `ServerFailure` — a well-formed error response from the backend
- `InvalidCredentialsFailure` — authentication rejected
- `UnknownFailure` — the fallback, so nothing escapes untyped

A project adds its own cases to the same sealed base as its domain needs them, and each one exists
so the UI can tell states apart. Read `failure.dart` for the current set.

Repository contract, everywhere:

- **Reads** return `Future<T?>` — `null` on failure
- **Writes** return `Future<Either<Failure, T>>`

The asymmetry is deliberate: a read that fails shows an empty or error state, while a write that
fails needs a reason to show the user.

---

## 9. Router

- A route id as `static const String routeName` on the page, collected in `AppRoutes`
- Registered in `AppRouter.onGenerateRoute`
- Arguments passed as typed objects rather than a raw `Map`
- After any `await` in a widget: `if (!context.mounted) return;`

---

## 10. Fixture markers

Sanctioned conventions, not `TODO`s. They survive review, and they are replaced rather than
hand-edited when the API arrives (`flutter-create-feature-e2e` Upgrade Mode).

| Marker | Where |
|--------|-------|
| `/// FIXTURE:` docstring | Placeholder `model/` or `repo/` classes |
| `// FIXTURE_START` / `// FIXTURE_END` | The swap-in point inside a repo method |
| `// FIXTURE:` header | A test whose data depends on the fixture repo |
| `# {Feature} – fixture mode` | `lib/features/{feature}/README.md` |

A feature is finished when the markers are gone, **or** its README still documents fixture mode.
Presenting a fixture-backed screen as a finished feature is the failure these markers prevent.

---

## 11. Recurring patterns worth building

Needs that come up on most client apps. None of these is scaffolded, and none exists until a project
builds it. Described here so the shape is consistent when it does, not so an agent assumes it is
present.

| Need | The shape that works |
|---|---|
| App-wide loading veil | A `ValueNotifier` the app listens to, and a barrier widget installed through `MaterialApp.builder`. A loading-aware button toggles the notifier rather than each screen managing its own overlay |
| Force-update gating | A gate resolved before the first network call, plus a blocking dialog that replaces the navigator rather than sitting on top of it. Pair it with a dedicated `Failure` case so the client layer can refuse requests from an unsupported build |
| Session expiry | An interceptor that recognises the expiry response, clears secure storage, and routes to sign-in through `NavigationService` |
| Connectivity | One service exposing a stream, consumed by whichever screens need it, rather than per-screen checks |

Check `docs/agents/project.md` for which of these the project actually has.

---

## 12. Do / don't

| Do | Instead of |
|----|-------|
| Import only `exports.dart` | Per-file project and package imports |
| Add constants to the `App*` families | Inline colours, strings, assets, dimensions |
| Read `lib/core/` to see what exists | Assuming a component because this skill names a role |
| Use the shared text widget with `AppTextStyles` | Raw `Text` with a one-off style for app copy |
| Use the shared confirmation path | A bespoke `showDialog` shell |
| Use the snackbar helpers | `ScaffoldMessenger.of(context).showSnackBar` at a callsite |
| Put shared code in `core/` | A cross-feature import |
| Keep HTTP in `network/`, storage in `services/` | A `data/` layer or a service locator |
| Emit state from the bloc and react in the UI | Navigating or showing a dialog inside the bloc |
| Export every new file from the barrel | Leaving a new file unreachable |
| Size from `AppDimensions` in the project's sizing strategy | A raw number at the callsite |
| Switch the layout at a breakpoint | Scaling one layout to every screen width |
| Let the OS scale text | A multiplier on font size that overrides the user's setting |

---

## Composition with other skills

Call the Skill tool with one of these, one call per need:

| Need | Skill |
|------|-------|
| A feature from criteria alone | `flutter-create-feature` |
| One layer only | `flutter-create-state-layer` / `flutter-create-model` / `flutter-create-repository` |
| A screen from a design | `flutter-create-screen` |
| Legacy migration | `flutter-modernize-screen` |
| Tests | `flutter-write-tests` |
| Review a branch | `flutter-code-review` |
| Security pass | `flutter-security-review` |
| Prove it works | `flutter-verify` |

The two end-to-end scaffolders are user-invoked, so no skill can reach them. When a request needs a
full feature or a fixture-mode screen, tell the user to run `/flutter-create-feature-e2e` or
`/flutter-create-screen-e2e`.
