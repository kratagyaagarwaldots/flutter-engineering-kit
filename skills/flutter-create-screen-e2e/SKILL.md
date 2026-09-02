---
name: flutter-create-screen-e2e
description: Build a screen backed by a FIXTURE repo from acceptance criteria and a Figma node, before the model and API exist.
disable-model-invocation: true
---

# Screen-first end-to-end feature

Build a complete feature **screen** from **two inputs** when the model and API are not yet defined:

1. **Acceptance criteria** – the AC list
2. **Figma design** – a node URL read via the Figma MCP server (`get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`); pasted CSS + screenshot accepted as a fallback

The output is a **working, runnable screen** powered by a `FIXTURE`-marked repository and an inferred placeholder model. Real model + API are added later via `flutter-create-feature-e2e`.

## Architecture

Before creating UI, constants, dialogs, or shared helpers, call the Skill tool with `flutter-core-architecture`. Reuse what it lists; do not invent parallel dialogs, text widgets, or theme constants.

## When to use this vs `flutter-create-feature-e2e`

| Inputs available | Skill |
|------------------|-------|
| Model + endpoint + AC + Figma design | `flutter-create-feature-e2e` |
| **AC + Figma design only** | **this skill** |
| AC only | `flutter-create-feature` |

If the user later provides the model and endpoint, run `flutter-create-feature-e2e` in **upgrade mode** (see Phase 10) to swap fixtures for the real implementation.

## Phase 0 – Validate Inputs

Confirm you have both inputs. **Do not invent missing pieces.**

```
Checklist:
- [ ] Acceptance criteria (numbered list)
- [ ] Figma node URL (or CSS + screenshot fallback)

Confirm with the user:
- [ ] Model and API endpoint will arrive LATER → fixture mode is correct
```

If model + endpoint exist, redirect to `flutter-create-feature-e2e`.

Then judge whether the acceptance criteria are actually settled. They are not when any AC names
only the happy path, when loading / empty / failure behaviour is unstated, or when the input
arrived as client prose rather than a numbered list. In that case call the Skill tool with
`grill` and use the AC list it produces as this phase's input. The fixture data you
invent in Phase 3 is only as good as the states the AC named.

## Phase 0.5 – Core architecture reuse

Report the reuse decision from the `flutter-core-architecture` read above: which existing components, utils and tokens this feature uses, and every `App*` constant you must add because no existing token fits.

## Phase 1 – Parse & Plan (no code yet)

Produce **four tables** and stop for confirmation before any code.

### 1a. Feature Design Table (from Acceptance Criteria)

| # | Acceptance criterion | Event | State status | Stub data needed | Edge case |
|---|----------------------|-------|--------------|------------------|-----------|
| 1 | User can see a list of products | `ProductsRequested` | `loading` → `success` | `List<Product>` with 5 fixture items | Empty list → `success` with empty data |
| 2 | Tapping a product shows detail | `ProductSelected(id)` | success with `selectedId` | – | Unknown id → snackbar |

### 1b. Inferred Schema (from the Figma node — `get_screenshot` / `get_metadata` — + AC)

Walk the rendered node. Every visible label, image, badge, or value becomes a field. Choose the **minimum viable** shape that supports the AC.

| Class | Field | Why it exists | Type | Default |
|-------|-------|---------------|------|---------|
| `Product` | `id` | Identity for navigation | `String` | `''` |
| `Product` | `name` | Visible in card title | `String` | `''` |
| `Product` | `price` | Visible in card | `double` | `0.0` |
| `Product` | `imageUrl` | Card thumbnail | `String` | `''` |
| `Product` | `isFavorite` | Heart icon state in screenshot | `bool` | `false` |

Mark this table **`(inferred — confirm shape on API integration)`** so the user knows it's a guess.

### 1c. Design Token Map (from `get_design_context` + `get_variable_defs`)

Run `get_variable_defs` first; map named variables to constants, then fill remaining raw values from `get_design_context` (it returns CSS-like values). Every value becomes a row. (Same table as `flutter-create-feature-e2e` Phase 1d.)

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

### 1d. Layout Plan (from `get_metadata` + `get_screenshot`)

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
            │       └── _ProductCard
            └── _PrimaryButton
```

Identify which sub-trees become reusable widgets in `widget/`.

**Stop here and present all four sub-sections to the user.** Wait for confirmation before Phase 2.

## Phase 2 – Constants & Assets

Update / create:

- `lib/core/constants/app_colors.dart` – every new color from Phase 1c
- `lib/core/constants/app_text_styles.dart` – every typography variant
- `lib/core/constants/app_strings.dart` – every static label
- `lib/core/constants/app_assets.dart` – every image / icon
- `pubspec.yaml` – register new asset paths
- `lib/core/router/exports.dart` – append `export` lines for every new file created in later phases

For images that will eventually come from the API (e.g. `Product.imageUrl`), use `https://picsum.photos/seed/{id}/200` or a local placeholder asset. **Never** ship a real CDN URL in fixtures.

## Phase 3 – Placeholder Model

Create `lib/features/{feature_name}/model/{feature_name}_response.dart` from the Phase 1b Inferred Schema.

The file's only import is the barrel:

```dart
import '../../../core/router/exports.dart';
```

Every placeholder class **must start with this docstring**:

```dart
/// FIXTURE: inferred shape from screenshot + AC.
/// Replace via `flutter-create-feature-e2e` once the API contract is defined.
@immutable
final class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final bool isFavorite;

  const Product({
    this.id = '',
    this.name = '',
    this.price = 0.0,
    this.imageUrl = '',
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image_url': imageUrl,
        'is_favorite': isFavorite,
      };

  @override
  List<Object?> get props => [id, name, price, imageUrl, isFavorite];
}
```

Still implement `fromJson` and `toJson` even on fixtures – it keeps the contract stable when the real API lands.

## Phase 4 – Fixture Repository

Create `lib/features/{feature_name}/repo/{feature_name}_repository.dart`:

```dart
import '../../../core/router/exports.dart';

/// FIXTURE: returns in-memory data. The public method signatures here are
/// the contract the real repository must keep.
///
/// Replace the body of every method with a real API call via
/// `flutter-create-feature-e2e` once the endpoint is defined.
/// The signatures below are the swap-in points - do not change them.
class {Feature}Repository {
  {Feature}Repository();

  /// Real version: Future<List<Product>?> from GET /products
  Future<List<Product>?> fetchProducts() async {
    // FIXTURE_START
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      Product(id: '1', name: 'Latte', price: 4.50, imageUrl: 'https://picsum.photos/seed/1/200'),
      Product(id: '2', name: 'Espresso', price: 3.00, imageUrl: 'https://picsum.photos/seed/2/200'),
      Product(id: '3', name: 'Cappuccino', price: 4.00, imageUrl: 'https://picsum.photos/seed/3/200'),
    ];
    // FIXTURE_END
  }

  /// Real version: Future<Product?> from GET /products/{id}
  Future<Product?> fetchProduct({required String id}) async {
    // FIXTURE_START
    final all = await fetchProducts() ?? const [];
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      debugPrint('{Feature}Repository.fetchProduct: id $id not found in fixtures');
      return null;
    }
    // FIXTURE_END
  }
}
```

### Fixture repository rules

- **Method signatures = future API contract** – match the shape the real repo will need
- Reads (`fetch*`, `get*`) → `Future<T?>`
- Writes (`create*`, `update*`, `delete*`) → `Future<Either<Failure, T>>` (even when stubbed)
- Every fixture body wrapped in `// FIXTURE_START` ... `// FIXTURE_END` markers – these are the swap-in points
- Small `Future.delayed(const Duration(milliseconds: 300))` keeps the loading state observable
- No `ApiClient` injection yet – add it during the upgrade phase
- Class-level docstring **must** start with `FIXTURE:` so the upgrade skill can find it

### Write method fixture template

```dart
/// Real version: Future<Either<Failure, Product>> from POST /products
Future<Either<Failure, Product>> createProduct({
  required CreateProductRequest request,
}) async {
  // FIXTURE_START
  await Future<void>.delayed(const Duration(milliseconds: 300));
  return Right(Product(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: request.name,
    price: request.price,
  ));
  // FIXTURE_END
}
```

## Phase 5 – BLoC

Create the bloc triad in `lib/features/{feature_name}/bloc/`. Follow `.cursor/skills/flutter-create-state-layer/SKILL.md` exactly.

The BLoC does **not** know it's calling a fixture – it depends on `{Feature}Repository`. When the upgrade swaps the repo body for real API calls, this layer is unchanged.

## Phase 6 – View & Widgets

Create the page + widgets. Follow `.cursor/skills/flutter-create-screen/SKILL.md`.

- Translate every row of Phase 1c (Design Token Map) into the build method
- Build the widget tree from Phase 1d (Layout Plan)
- Render images via `Image.network(product.imageUrl, errorBuilder: ...)` so picsum failures degrade gracefully

**Verify the rendered output matches the `get_screenshot` render** (or the fallback screenshot) before moving on.

## Phase 7 – Route Registration

- Add `static const String routeName = '/{feature}';` to the page
- Register the route in `lib/core/router/`

## Phase 8 – Tests

Create `test/features/{feature_name}/`:

- Bloc tests against the fixture repo (still cover happy / null / exception per handler)
- Widget tests rendering each status

Mark every fixture-driven test with a top-of-file comment:

```dart
// FIXTURE: tests run against the fixture repository.
// Update mocks here when the repository is upgraded to a real API.
```

## Phase 9 – Acceptance Criteria Coverage

Same as `flutter-create-feature-e2e` Phase 9. Map every AC to a test.

## Phase 9.5 – Verification

Call the Skill tool with `flutter-verify` and climb its ladder as far as the acceptance criteria
require. It owns the commands, the known-failure baseline, and the rung-per-claim rule.

A fixture-mode screen is verifiable to **rung 3 (widget)** and no further: the fixture repo means
there is no real network path to prove. Say that explicitly rather than implying the flow works
end to end, and name every AC whose proof has to wait for the real API.

## Phase 10 – Handoff Notes (REQUIRED)

Write `lib/features/{feature_name}/README.md` with:

```markdown
# {Feature} – fixture mode

This feature was scaffolded with `flutter-create-screen-e2e` before the API and
real model existed. It runs on a FIXTURE repository.

## Swap-in points (do not move these)

| File | Marker | Replace with |
|------|--------|--------------|
| `repo/{feature}_repository.dart` | class-level `/// FIXTURE:` | Real `ApiClient`-backed implementation |
| `repo/{feature}_repository.dart` | `// FIXTURE_START` ... `// FIXTURE_END` | Real API call body |
| `model/{feature}_response.dart` | class-level `/// FIXTURE:` on each placeholder class | Real DTOs from API |
| `test/features/{feature}/` | `// FIXTURE:` test-file header | Tests against real models |

## How to upgrade

Once the model spec and API endpoint are known, a human runs `/flutter-create-feature-e2e` in
**upgrade mode**. It is user-invoked, so no skill can start it:

> "Use `flutter-create-feature-e2e` to upgrade the `{feature}` feature.
> Model: <paste model spec>
> Endpoint: <paste endpoint>
> Keep existing AC, Figma design, BLoC events, and screen layout unchanged."

The upgrade phase will:
1. Diff inferred schema (Phase 1b) against the real model and report mismatches
2. Replace every `FIXTURE_START` ... `FIXTURE_END` block with real API calls
3. Remove `/// FIXTURE:` docstrings
4. Re-run tests
```

## Hard rules

Barrel imports, the constants families, the shared component set and the marker vocabulary belong to
`flutter-core-architecture`, called in the Architecture section above. What binds this skill
specifically:

- Every repository method returns fixture data. A real network call in fixture mode makes the
  screen's behaviour depend on a backend the feature is defined as not having yet.
- Fixture data uses `picsum.photos` or local assets, so nothing points at a CDN that can change or
  disappear under the screen.
- Mark every placeholder: a `/// FIXTURE:` docstring on the class, a `// FIXTURE_START` /
  `// FIXTURE_END` pair around each fixture body. These are the swap-in points the upgrade phase
  looks for, and an unmarked one is a fixture that ships as a feature.
- Match the signatures the real API will need: `Future<T?>` for reads, `Future<Either<Failure, T>>`
  for writes. Getting these right now is what makes the upgrade a body swap rather than a rewrite.
- Use the `FIXTURE` markers in place of a `TODO`.
- Comments explain *why*, beyond the sanctioned markers.
- Stop after Phase 1 and present the planning tables before writing code.
- Phase 10's handoff README is what the upgrade skill reads to find the swap-in points. Without it
  the feature cannot be upgraded, only rebuilt.

## Sub-agent delegation, optional

When the screen is large, delegate independent phases to sub-agents in parallel. Do this only once
the Phase 1 tables are stable: a sub-agent given a table that is still moving builds against a shape
that will change under it.

Each sub-agent's brief tells it to call the Skill tool with one skill, and carries the Phase 1 table
it works from. Phases 3 and 4 stay with the parent, since the fixture model and repository are this
skill's own output rather than another skill's.

| Phase | Agent | The sub-agent's skill |
|-------|-------|----------------------|
| 5 – Bloc | `flutter-state-engineer` | `flutter-create-state-layer` |
| 6 – UI | `flutter-ui-engineer` | `flutter-create-screen` |
| 8 – Tests | `flutter-test-engineer` | `flutter-write-tests` |
