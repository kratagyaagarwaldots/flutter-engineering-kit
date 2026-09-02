---
name: flutter-create-feature-e2e
description: Build or upgrade a complete feature (model, repo, bloc, view, widgets, tests) from a model spec, one API endpoint, acceptance criteria and a Figma node.
disable-model-invocation: true
---

# End-to-end feature

Build a complete feature from **four user-provided inputs**:

1. **Model** – the data shape (Dart-like spec, JSON sample, or field list)
2. **API endpoint** – HTTP method + path + request/response association
3. **Acceptance criteria** – the AC list
4. **Figma design** – a node URL read via the Figma MCP server (`get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`); pasted CSS + screenshot accepted as a fallback

> This skill **does not** use Swagger or OpenAPI. Everything comes from the four inputs above.

## Architecture

Before creating UI, constants, dialogs, or shared helpers, call the Skill tool with `flutter-core-architecture`. Reuse what it lists; do not invent parallel dialogs, text widgets, or theme constants.

## Two Modes

| Mode | When | What happens |
|------|------|--------------|
| **Build** (default) | Feature folder doesn't exist | Run Phases 0–10 below |
| **Upgrade** | `lib/features/{feature_name}/README.md` exists and mentions "fixture mode" | Skip to Phase U – see end of this file |

Detect the mode by checking for `lib/features/{feature_name}/README.md` containing the string "fixture mode" before starting.

## How This Works

Work through phases **in strict order**. Do not start Phase N+1 until Phase N is complete and presented to the user.

## Phase 0 – Validate Inputs

Before doing anything else, confirm you have **all four** inputs. If anything is missing, ask for it.

```
Checklist:
- [ ] Model spec (fields + types)
- [ ] API endpoint (method + path + request body / response shape link)
- [ ] Acceptance criteria (numbered list)
- [ ] Figma node URL (or CSS + screenshot fallback)

Derived:
- [ ] Feature name (snake_case)
- [ ] Feature PascalCase
```

If any are missing, **stop and ask** – do not invent the missing pieces.

Then judge whether the acceptance criteria are actually settled. They are not when any AC names
only the happy path, when loading / empty / failure behaviour is unstated, or when the input
arrived as client prose rather than a numbered list. In that case call the Skill tool with
`grill` and use the AC list it produces as this phase's input. Scaffolding against thin
AC is how a feature reaches Phase 9 and then needs rebuilding.

## Phase 0.5 – Core architecture reuse

Report the reuse decision from the `flutter-core-architecture` read above: which existing components, utils and tokens this feature uses, and every `App*` constant you must add because no existing token fits.

## Phase 1 – Parse & Plan (no code yet)

Produce **four tables** and present them to the user before writing any code.

### 1a. Feature Design Table (from Acceptance Criteria)

| # | Acceptance criterion | Event | State status | Repo method | Edge case |
|---|----------------------|-------|--------------|-------------|-----------|
| 1 | User can view items | `ItemsRequested` | `loading` → `success` | `fetchItems` | Empty list → success with empty data |
| 2 | Errors are shown | – | `failure` | – | Show snackbar, retry button |

### 1b. API Contract Table (from API Endpoint)

| # | Method | Path | Request schema | Response schema | Success codes |
|---|--------|------|----------------|-----------------|---------------|
| 1 | GET | `/items` | – | `ItemsResponse` | 200 |
| 2 | POST | `/items` | `CreateItemRequest` | `ItemResponse` | 201 |

### 1c. Schema Field Map (from Model)

For every model class, list:

| Class | Field | Source type | Nullable? | Dart type | fromJson default |
|-------|-------|-------------|-----------|-----------|------------------|
| `Item` | `id` | string | no | `String` | `?? ''` |
| `Item` | `price` | number | no | `double` | `?? 0.0` |
| `Item` | `tags` | array<string> | no | `List<String>` | `?? []` |

### 1d. Design Token Map (from `get_design_context` + `get_variable_defs`)

Run `get_variable_defs` first; map named variables to constants, then fill remaining raw values from `get_design_context` (it returns CSS-like values). Every value becomes a row.

| CSS property | Value | Flutter equivalent | Constant target |
|--------------|-------|--------------------|-----------------|
| `background` | `#FFFFFF` | `Color(0xFFFFFFFF)` | `AppColors.background` |
| `padding` | `16px 24px` | `EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h)` | – |
| `border-radius` | `12px` | `BorderRadius.circular(12.r)` | – |
| `font-size` | `16px` | `16.sp` | `AppTextStyles.bodyMedium` |
| `font-weight` | `500` | `FontWeight.w500` | – |
| `gap` | `8px` | `SizedBox(height: 8.h)` between Column children | – |
| `color` | `rgba(0,0,0,0.5)` | `Color(0x80000000)` | `AppColors.textMuted` |
| `box-shadow` | `0 2px 4px rgba(0,0,0,0.1)` | `BoxShadow(offset: Offset(0, 2.h), blurRadius: 4.r, color: Color(0x1A000000))` | – |
| `display: flex; flex-direction: row` | – | `Row(...)` | – |
| `justify-content` | `space-between` | `MainAxisAlignment.spaceBetween` | – |
| `align-items` | `center` | `CrossAxisAlignment.center` | – |
| `width: 100%` | – | `double.infinity` or `Expanded` | – |

### 1e. Layout Plan (from `get_metadata` + `get_screenshot`)

Sketch the widget tree before writing it:

```
Scaffold
└── SafeArea
    └── Padding
        └── Column
            ├── _Header
            ├── _SearchBar
            ├── Expanded
            │   └── ListView.separated
            │       └── _ItemCard
            └── _PrimaryButton
```

Identify which sub-trees become reusable widgets in `widget/`.

**Stop here and present all five sub-sections to the user.** Wait for confirmation before Phase 2.

## Phase 2 – Constants & Assets

Update / create:

- `lib/core/constants/app_colors.dart` – add every new color from Phase 1d
- `lib/core/constants/app_text_styles.dart` – add every typography variant
- `lib/core/constants/app_strings.dart` – add every static label
- `lib/core/constants/app_assets.dart` – add every image / icon
- `pubspec.yaml` – register new asset paths
- `lib/core/router/exports.dart` – append `export` lines for any **new** constant / asset / component / util / model / repo / bloc / view / widget file you create in later phases

No inline values in feature code – everything refers to a constant.

## Phase 3 – Models

Create in `lib/features/{feature_name}/model/`:

- **One file per logical group** (e.g. `{feature}_request.dart`, `{feature}_response.dart`)
- Use Phase 1c (Schema Field Map) as the source of truth
- Follow the `flutter-create-model` skill for templates
- Every class: `@immutable`, `final` fields, `fromJson` + `toJson`, `props`

## Phase 4 – Repository

Create `lib/features/{feature_name}/repo/{feature_name}_repository.dart`:

- One method per row in Phase 1b (API Contract Table)
- Constructor-inject `ApiClient` (null fallback)
- GET → `Future<T?>`
- POST / PUT / PATCH → `Future<Either<Failure, T>>`
- DELETE → `Future<Either<Failure, void>>`
- All `try/catch` + `debugPrint` with method context
- Follow the `flutter-create-repository` skill for templates

## Phase 5 – BLoC

Create the triad in `lib/features/{feature_name}/bloc/`:

- Events from Phase 1a column "Event"
- Status enum values from Phase 1a column "State status"
- One handler per event
- Constructor-inject repository
- Follow the `flutter-create-state-layer` skill for templates

## Phase 6 – View & Widgets

Create:

- `lib/features/{feature_name}/view/{feature_name}_page.dart` – `BlocProvider` root
- `lib/features/{feature_name}/widget/*.dart` – every reusable chunk from Phase 1e

Wire pattern:

- `BlocProvider` fires the initial event from Phase 1a
- `BlocListener` handles side-effects (snackbars, navigation)
- `BlocBuilder` / `BlocConsumer` renders state
- Use `switch (state.status)` for state-driven UI
- All dimensions from `AppDimensions`, in the project's sizing strategy; font sizes unscaled
- Translate Phase 1d (Design Token Map) row by row into the build method

**Verify against the `get_screenshot` render** (or the fallback screenshot) after writing. If anything differs, adjust before moving on.

## Phase 7 – Route Registration

- Add `static const String routeName = '/{feature}';` to the page class
- Register the route in `lib/core/router/`
- If the route takes arguments, pass them as a typed `{Feature}Arguments` class – never raw `Map`

## Phase 8 – Tests

Create `test/features/{feature_name}/`:

- `bloc/{feature_name}_bloc_test.dart` – at least 3 cases per handler (happy / null / exception)
- `repo/{feature_name}_repository_test.dart` – mock `ApiClient`, test success + error responses
- `widget/{feature_name}_page_test.dart` – render under each status

Map every acceptance criterion in the `AC coverage` group. Follow the `flutter-write-tests` skill for templates.

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test
```

## Phase 9 – Acceptance Criteria Coverage Check

Walk the AC list end-to-end:

| AC # | Implemented in | Test |
|------|----------------|------|
| 1 | `bloc._onItemsRequested` + `_ItemsView` | `'emits [loading, success]...'` |
| 2 | `BlocListener` snackbar branch | `'emits [loading, failure] when repository throws'` |

If any row is empty, finish it before declaring done.

## Phase 10 – Final Verification

Call the Skill tool with `flutter-verify` and climb its ladder as far as the acceptance criteria
require. It owns the commands, the known-failure baseline, and the rule for which rung a given
claim needs — do not re-derive them here, and do not report the suite as green without checking
its baseline table first.

Report the rung you stopped on, and name any AC you could **not** prove at that rung.

Then confirm:

- Every new `.dart` file imports **only** `../../../core/router/exports.dart`.
- Every new file is exported from `lib/core/router/exports.dart`.
- Snackbars / dialogs / navigation use the shared helpers (`showSuccessSnackBar`, `showErrorSnackBar`, `ConfirmationDialogMixin` / `showIosAlertDialog`, `NavigationService.instance`) — see `flutter-core-architecture`.
- No restate-the-signature doc comments left behind.

## Hard rules

Barrel imports, the constants families, the shared component set and the cross-feature boundary
belong to `flutter-core-architecture`, called in the Architecture section above. What binds this
skill specifically:

- Build from the four inputs only. This skill reads no Swagger or OpenAPI document.
- Finish every requirement in the phase that owns it. A `TODO` left behind means the phase is
  incomplete, and Phase 9 will report a criterion as covered when it is not.
- Keep `// FIXTURE_START`, `// FIXTURE_END` and `/// FIXTURE:` markers exactly as they are.
- Comments explain *why*. The signature already says what.
- Stop after Phase 1 and present the planning tables. The tables are what every later phase reads.
- After Phase 6, compare the built screen against the `get_screenshot` render, or the fallback
  screenshot, and say what differs.

## Sub-agent delegation, optional

When the feature is large, delegate independent phases to sub-agents in parallel. Do this only once
the Phase 1 tables are stable: a sub-agent given a table that is still moving builds against a shape
that will change under it.

Each sub-agent's brief tells it to call the Skill tool with one skill, and carries the Phase 1 table
it works from.

| Phase | The sub-agent's skill | What to hand it |
|-------|----------------------|-----------------|
| 3 – Models | `flutter-create-model` | The Schema Field Map (1c) |
| 4 – Repository | `flutter-create-repository` | The API Contract Table (1b) |
| 6 – Widgets | `flutter-create-screen` | The Design Token Map (1d) and Layout Plan (1e) |
| 8 – Tests | `flutter-write-tests` | The Feature Design Table (1a) and the acceptance criteria |

---

## Phase U – Upgrade Mode

Use this phase **instead of** Phases 0–10 when the feature was previously scaffolded by `flutter-create-screen-e2e` (the `lib/features/{feature_name}/README.md` mentions "fixture mode").

The goal is to replace fixtures with the real API + model **without changing**:

- BLoC events, states, or handler signatures
- Screen layout, widgets, or styling
- Acceptance-criteria coverage in tests

### U.0 – Validate Inputs

Confirm the user has now supplied:

- [ ] Model spec
- [ ] API endpoint (method + path + request/response shape)

If either is missing, stop and ask.

### U.1 – Diff Inferred Schema vs Real Model

Open `lib/features/{feature_name}/model/{feature_name}_response.dart` and read every class marked with `/// FIXTURE:`. Compare against the real model spec and produce:

| Class | Field | Inferred | Real | Action |
|-------|-------|----------|------|--------|
| `Product` | `price` | `double` | `int` (cents) | Change type + update consumers |
| `Product` | `imageUrl` | `String` | `String` (from `image_url`) | Keep |
| `Product` | – | – | `currency: String` | **Add** field |
| `Product` | `isFavorite` | `bool` | – | **Remove** field – check screen for usages |

Present the table to the user. Stop for confirmation before editing.

### U.2 – Update Models

- Remove every `/// FIXTURE:` docstring
- Apply the diff from U.1
- Add request DTOs for write endpoints
- Rerun `dart format` on edited files

### U.3 – Replace Fixture Repository

For every method in `repo/{feature_name}_repository.dart`:

1. Keep the method signature **exactly as-is** (parent BLoC depends on it)
2. Replace the body between `// FIXTURE_START` and `// FIXTURE_END` with a real `_apiClient` call
3. Remove the `// FIXTURE_START` / `// FIXTURE_END` markers after the body is real
4. Add the `ApiClient` constructor injection (null fallback):

```dart
class {Feature}Repository {
  final ApiClient _apiClient;
  {Feature}Repository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  ...
}
```

5. Remove the class-level `/// FIXTURE:` docstring once **every** method body is real

If any consumer relied on a synchronous fixture quirk (e.g. instant data), surface it as a state-change side-effect in the bloc, not in the repo.

### U.4 – Adapt BLoC if Schema Changed

If U.1 added or removed fields, walk every handler that reads / writes those fields. The BLoC structure itself does not change – only the field accesses.

### U.5 – Adapt Screen if Schema Changed

If a removed field had UI presence (e.g. `isFavorite`'s heart icon), choose with the user:

- Remove the UI element, **or**
- Keep it driven by local state instead of the model

If an added field has no UI yet, that's fine – leave it in the model for future screens.

### U.6 – Retire Handoff README

Update `lib/features/{feature_name}/README.md`:

- Remove the "fixture mode" header
- Add a one-line note: "Upgraded to real API on {date}. Endpoint: {method} {path}."

### U.7 – Re-run Tests

- Update test mocks to mock `ApiClient` instead of returning hardcoded lists
- Update test fixtures to match the real model shape (if changed)
- Remove the `// FIXTURE:` test-file header
- `flutter test` must pass

### U.8 – Verification

```bash
flutter analyze
dart format .
flutter test
rg --no-heading 'FIXTURE' lib/features/{feature_name}/ test/features/{feature_name}/ || echo 'All fixture markers removed.'
```

The `rg` command must return "All fixture markers removed." – any remaining `FIXTURE` markers in the feature folder are a regression.

### U.9 – AC Coverage Re-Check

Walk the AC list again. Confirm every criterion still has a test row. Add new tests for any behaviour the real API exposes (e.g. specific error codes).
