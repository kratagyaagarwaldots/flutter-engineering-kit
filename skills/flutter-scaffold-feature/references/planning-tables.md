# Planning tables

Phase 1 produces these before any code. Each later phase reads one of them, so a table is finished
when a layer could be built from it without asking a question.

| Table | Mode | Read by |
|---|---|---|
| A. Feature design | every mode | state layer, tests, coverage |
| B. API contract | real | repository |
| C. Schema field map | real | model |
| C′. Inferred schema | fixture | placeholder model |
| D. Design token map | with a design source | constants, view |
| E. Layout plan | with a design source | view, widgets |

## A. Feature design (from the acceptance criteria)

One row per criterion. The action and status names become the state layer's.

| # | Acceptance criterion | Action | Status | Repository method | Edge case |
|---|---|---|---|---|---|
| 1 | User sees the list of items | `ItemsRequested` | `loading` → `success` | `fetchItems` | Empty list → `success` with no items, empty state shown |
| 2 | A failed load can be retried | `ItemsRequested` | `failure` | `fetchItems` | Error message and a retry button |

In fixture mode, swap the repository column for **stub data needed** (`List<Item>`, five fixtures).

## B. API contract (from the endpoint), real mode

| # | Method | Path | Request | Response | Success codes |
|---|---|---|---|---|---|
| 1 | GET | `/items` | – | `ItemsResponse` | 200 |
| 2 | POST | `/items` | `CreateItemRequest` | `ItemResponse` | 201 |

## C. Schema field map (from the model), real mode

Every class, every field. `flutter-create-model` generates from this table.

| Class | Field | Source type | Nullable | Dart type | Default when absent |
|---|---|---|---|---|---|
| `Item` | `id` | string | no | `String` | `''` |
| `Item` | `price` | number | no | `double` | `0.0` |
| `Item` | `tags` | array of string | no | `List<String>` | `[]` |

## C′. Inferred schema (from the design and the criteria), fixture mode

Walk the design: every visible label, image, badge and value becomes a field. Choose the smallest
shape that supports the criteria, and say why each field exists, since the real model will
contradict some of them.

| Class | Field | Why it exists | Type | Default |
|---|---|---|---|---|
| `Item` | `id` | Identity for navigation | `String` | `''` |
| `Item` | `title` | The card's heading | `String` | `''` |
| `Item` | `imageUrl` | The card's thumbnail | `String` | `''` |
| `Item` | `isSaved` | The bookmark icon in the design | `bool` | `false` |

Head the table **inferred — confirm on API integration**.

## D. Design token map (from `get_variable_defs`, then `get_design_context`)

Map named design variables first, then every remaining raw value. Each row either reuses an existing
`App*` constant or names the one Phase 2 adds. Sizes are written in the project's sizing strategy
(`project-conventions`); in the kit's default that is a named `AppDimensions` token in logical
pixels, and font sizes stay unscaled so the OS text-scale setting still applies.

| Design property | Value | Flutter | Constant |
|---|---|---|---|
| `background` | `#FFFFFF` | `Color(0xFFFFFFFF)` | `AppColors.background` |
| `padding` | `16px 24px` | `EdgeInsets.symmetric(horizontal: …, vertical: …)` | `AppDimensions` spacing tokens |
| `border-radius` | `12px` | `BorderRadius.circular(…)` | an `AppDimensions` radius token |
| `font-size` / `font-weight` | `16px` / `500` | a text style | `AppTextStyles.bodyMedium` |
| `gap` | `8px` | `SizedBox` between children | an `AppDimensions` spacing token |
| `color` | `rgba(0,0,0,0.5)` | `Color(0x80000000)` | `AppColors.textMuted` |
| `box-shadow` | `0 2px 4px rgba(0,0,0,0.1)` | `BoxShadow(…)` | a shared shadow, if the project has one |
| `display: flex; flex-direction: row` | – | `Row` | – |
| `justify-content` | `space-between` | `MainAxisAlignment.spaceBetween` | – |

## E. Layout plan (from `get_metadata` and `get_screenshot`)

Sketch the tree before writing it, and mark which sub-trees become reusable widgets.

```
Scaffold
└── SafeArea
    └── Column
        ├── _Header
        ├── Expanded
        │   └── ListView.separated
        │       └── ItemCard            → widget/item_card.dart
        └── _PrimaryAction
```

Name the states the design did not draw (loading, empty, failure) and where each renders. A design
almost never shows them, and the build is where they get forgotten.
