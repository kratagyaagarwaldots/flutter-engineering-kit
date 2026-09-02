# Task-doc template

Eleven sections plus a header, in this order. None is optional; a section with nothing to say
writes `**None.**` and one line of why.

For each section below: **Form** is the skeleton to emit, **Example** is a filled instance,
**Fails when** is the executor behaviour you are preventing.

---

## Header

```markdown
# {NN} — {Imperative title}

| | |
|---|---|
| **Status** | Ready to execute |
| **Executor** | Assume no prior context on this repo |
| **Prerequisites** | Doc 02 must be shipped and merged first / None |
| **Supersedes** | Doc 01 §4 and §7 (see Changelog) / Nothing |
| **Est. touched files** | 6 modified, 2 created, 1 deleted |

## Changelog
| Date | Change | Reason |
|------|--------|--------|
| 2026-08-01 | §4 rewritten, §6 deleted | Doc 02 shipped `OrderStatus.pending`, invalidating both |
```

Omit the Changelog table entirely on a first-issue doc.

---

## §1 Scope box

**Form** — three explicit lists and one yes/no. Put it above everything else; it is the
executor's contract.

```markdown
## 1. Scope

**Code in scope:** YES — Dart source under `lib/features/order/` and `test/features/order/`.

**Create**
- `lib/features/order/widget/order_status_chip.dart`
- `test/features/order/widget/order_status_chip_test.dart`

**Modify**
- `lib/features/order/widget/order_card.dart` — add the chip, delete the inline badge
- `lib/core/router/exports.dart` — export the new widget
- `lib/core/constants/app_colors.dart` — add three status colours

**Do NOT touch**
- `lib/features/<other_feature>/**` — visually similar cards; out of scope, leave them inconsistent
- `lib/core/network/api_client.dart` — no network change in this task
- Any file under `lib/features/notifications/` — doc 04 owns it
```

**Fails when** omitted: the executor "helpfully" refactors the adjacent card, or
touches a file another in-flight doc owns, producing a conflict nobody asked for.

**Rule:** "Do NOT touch" must name the things a reasonable executor would be *tempted* to
touch — near-duplicates, obvious inconsistencies, adjacent dead code. Listing unrelated
directories is noise.

---

## §2 Findings — measured, not assumed

**Form** — a table of defects, each with a `file:line` link and a concrete number. Follow with
the boundary values you computed; they become the §10 fixtures.

```markdown
## 2. Findings

| # | Finding | Location | Measured |
|---|---------|----------|----------|
| F1 | Difficulty multiplier is unbounded | [progression.dart:88](lib/core/progression.dart#L88) | At score 3.0 it prescribes **17 pull-ups × 5 sets**; at 4.0, **31 × 5** |
| F2 | Order list rebuilds every card per keystroke | [order_list_page.dart:140](lib/features/order/view/order_list_page.dart#L140) | 40 cards rebuilt per character; 9 chars typed = 360 rebuilds |
| F3 | `status` is parsed but never rendered | [order.dart:31](lib/features/order/model/order.dart#L31) | Field read in `fromJson`, zero references in `lib/features/order/view/` or `widget/` |

**Boundary values measured today (become test fixtures in §10):**

| Input score | Current reps | Current sets |
|---|---|---|
| 0.0 | 3 | 3 |
| 1.0 | 5 | 3 |
| 2.0 | 9 | 4 |
| 3.0 | 17 | 5 |
| 4.0 | 31 | 5 |
```

**Fails when** omitted or hedged: the executor cannot verify the premise, so it either
re-derives the problem (differently) or implements a fix for a defect that does not exist.

**Rule:** no *appears to* / *probably* / *seems*. If you could not measure it, do not claim it.

---

## §3 Algorithms as literal code

**Form** — the complete function body, in the project's language, with the signature the
executor will paste. Not pseudocode, not a description.

````markdown
## 3. Algorithm — replacement progression curve

Replace the body of `nextPrescription` at [progression.dart:88-104](lib/core/progression.dart#L88-L104)
with exactly this:

```dart
({int reps, int sets}) nextPrescription(double score) {
  // Logistic ceiling: reps asymptote at 20, never the exponential blow-up in F1.
  final double clamped = score.clamp(0.0, 5.0);
  final int reps = (3 + (17 / (1 + math.exp(-1.4 * (clamped - 2.5))))).round();
  final int sets = clamped < 1.0
      ? 3
      : clamped < 3.0
          ? 4
          : 5;
  return (reps: reps, sets: sets);
}
```

`math` is already exported by the barrel; add no import.
````

**Fails when** written as prose ("cap the reps with a smooth curve"): every executor produces
a different curve, and none matches the §10 assertions.

**Rule:** if the executor would have to *derive* anything — a constant, a rounding mode, a tie
break, an ordering — derive it here. A 40-line function body is cheap; a judgment call is not.

---

## §4 Enumerate, never describe

**Form** — the full table. Generate it with a script in your scratchpad and paste the output.

```markdown
## 4. Rep ranges — complete table (79 rows)

Apply exactly. Do not infer from the movement name; if a movement is absent from this table
it is out of scope for this task.

| # | Movement | Category | Min reps | Max reps | Sets |
|---|----------|----------|----------|----------|------|
| 1 | Barbell back squat | compound-lower | 4 | 8 | 5 |
| 2 | Front squat | compound-lower | 4 | 8 | 5 |
| 3 | Lateral raise | isolation-shoulder | 12 | 20 | 3 |
| … | (all 79 rows present in the shipped doc) | | | | |
```

**Fails when** replaced by the rule that generated it ("isolation moves get 8–20 reps"): the
executor's classification of *isolation* differs from yours on ~15% of rows, silently.

**Rule:** long is fine, ambiguous is not. State the closed-world clause explicitly — "if it is
not in this table, it is out of scope" — or the executor will extend the table by analogy.

---

## §5 UI as ASCII mockups with exact tokens

**Form** — one mockup **per screen state**, not per screen. Annotate every text run and box
with size, weight, colour token, radius, padding.

```markdown
## 5. UI — `OrderCard`, all four states

### 5.1 State: confirmed

┌──────────────────────────────────────────────┐  ← Card: radius 12.r, AppColors.surface,
│  ┌────┐                                      │     padding EdgeInsets.all(16.w)
│  │ AV │  Priya Raman            ┌──────────┐ │  ← Avatar 40.w × 40.w, radius 20.r
│  └────┘  Confirmed              │ Confirmed│ │  ← Chip: h 24.h, padding 8.w/4.h,
│          +61 4XX XXX XXX        └──────────┘ │     radius 12.r, AppColors.successBg
└──────────────────────────────────────────────┘

| Element | Style |
|---------|-------|
| Name | `16.sp` / `FontWeight.w600` / `AppColors.textPrimary` |
| Phone | `13.sp` / `FontWeight.w400` / `AppColors.textMuted` |
| Chip label | `11.sp` / `FontWeight.w500` / `AppColors.successFg` |
| Chip fill | `AppColors.successBg` (add: `Color(0xFFE7F6EC)`) |
| Gap avatar→text | `SizedBox(width: 12.w)` |
| Gap name→phone | `SizedBox(height: 4.h)` |

### 5.2 State: pending
Identical to 5.1 except: chip label "Pending", fill `AppColors.warningBg`
(add: `Color(0xFFFFF4E0)`), text `AppColors.warningFg` (add: `Color(0xFF8A5A00)`).

### 5.3 State: declined
… (one block per state — never "and similarly for the others")

### 5.4 State: loading (skeleton)
…
```

**Fails when** written as "make it look consistent with the other card": the executor copies
that card wholesale, including its hardcoded colours, violating the constants rule.

**Rule:** every colour is a named token. If the token does not exist yet, the mockup says
`(add: 0xFF…)` and §1 lists the constants file under **Modify**.

---

## §6 Deletions — explicit

**Form** — a table. Each row is an instruction, and each row states what replaces it (often
"nothing").

```markdown
## 6. Deletions

| # | Delete | Location | Replaced by |
|---|--------|----------|-------------|
| D1 | `_StatusBadge` class (lines 118–166) | [order_card.dart:118](lib/features/order/widget/order_card.dart#L118) | `OrderStatusChip` from §5 |
| D2 | `formatBadgeLabel()` | [order_card.dart:472](lib/features/order/widget/order_card.dart#L472) | **Nothing.** Its only caller is D1. |
| D3 | `AppColors.badgeGrey` | [app_colors.dart:64](lib/core/constants/app_colors.dart#L64) | **Nothing.** Unused after D1; verified with `rg badgeGrey`. |
| D4 | Test group `'_StatusBadge'` (lines 88–140) | [order_list_widgets_test.dart:88](test/features/order/widget/order_list_widgets_test.dart#L88) | New group in §10.2 |

After applying D1–D4, this command must print nothing:

```bash
rg -n '_StatusBadge|formatBadgeLabel|badgeGrey' lib/ test/
```
```

**Fails when** omitted: the executor adds the new widget and leaves the old one in place —
compiling, untested, and now silently dead. This is the single most common cheap-executor
failure. Always pair deletions with a `rg` command that proves they happened.

---

## §7 Migration & back-compat hazards

**Form** — what must never change, plus the exact guard code to copy.

````markdown
## 7. Migration & back-compat

**Must never change**
- `OrderStatus` enum **ordering** — index is persisted in `SharedPreferences` under
  `order_filter_index`. Append new values at the end only.
- The `status` JSON string values (`"confirmed"`, `"pending"`, `"declined"`) — server-owned.
- Route id `AppRoutes.orderList` — deep links in production notifications point at it.

**Guard for rows written before this change** — paste verbatim into
`Order.fromJson` at [order.dart:31](lib/features/order/model/order.dart#L31):

```dart
// Rows written before 2026-08 have no `status`; they are all confirmed orders.
status: OrderStatus.values.firstWhere(
  (OrderStatus s) => s.name == (json['status'] as String? ?? 'confirmed'),
  orElse: () => OrderStatus.confirmed,
),
```

`orElse` is required: an unknown server value must degrade to `confirmed`, never throw.
````

**Fails when** omitted: the executor reorders an enum alphabetically "for tidiness" and every
stored index now points at the wrong value.

---

## §8 Failure modes, labelled

**Form** — a table separating *normal* outcomes from *something is wrong*, tied to observable
behaviour.

```markdown
## 8. Failure modes

| Outcome | Verdict | What to do |
|---------|---------|------------|
| Order list renders 0 cards, empty-state shown | **Normal** — user has no orders | Nothing |
| `OrderStatusChip` renders with no label | **Wrong** — status failed to parse; §7 guard missing or misapplied | Re-check §7 |
| Migration loop exits before reading any row | **Wrong** — a data gap, not a valid result. Do not report success | Stop and report the row count read |
| `flutter test` passes but `rg` in §6 prints matches | **Wrong** — new code added, old code not deleted | Apply §6 fully |
| Analyzer reports unused import of `order_status_chip.dart` | **Wrong** — the chip was never wired into `OrderCard` | Complete step 4 of §9 |
```

**Fails when** omitted: the executor treats "zero rows migrated, no exception" as success and
reports the task complete.

---

## §9 Build order

**Form** — numbered steps, each of which **compiles on its own**, with the single behavioural
cutover named.

```markdown
## 9. Build order

Each step leaves the tree compiling and `flutter analyze` clean. Commit per step if you like.

1. Add the three colour constants (§5) to `app_colors.dart`. *No behaviour change.*
2. Add the `status` field + §7 guard to `Order`. *No behaviour change — nothing reads it yet.*
3. Create `order_status_chip.dart` (§5) and export it from `exports.dart`. *Not yet used.*
4. **CUTOVER** — in `order_card.dart`, replace the `_StatusBadge` usage with `OrderStatusChip`.
   This is the only step that changes what the user sees.
5. Apply deletions D1–D4 (§6) and run the §6 `rg` check.
6. Add the tests in §10.2 and run the full suite.
```

**Fails when** omitted: the executor writes everything at once, hits a compile error in the
middle, and starts "fixing" unrelated code to get green.

**Rule:** exactly one step is labelled **CUTOVER**. If you need two, the doc should be two docs.

---

## §10 Verification

**Form** — three parts: exact-assertion unit tests (including one fail-before/pass-after),
manual steps, and the static-analysis commands.

````markdown
## 10. Verification

### 10.1 Regression test — must FAIL before step 1, PASS after step 4

```dart
testWidgets('OrderCard renders a status chip for a pending order', (WidgetTester tester) async {
  await tester.pumpWidget(_wrap(OrderCard(order: _order(status: OrderStatus.pending))));
  expect(find.byType(OrderStatusChip), findsOneWidget);
  expect(find.text(AppStrings.orderStatusPending), findsOneWidget);
});
```

Run it **before** starting: it must fail with `Could not find OrderStatusChip`. If it fails
for any other reason, stop — the doc's premise does not match the tree.

### 10.2 Assertions — exact, from §2 boundary values

| Test | Input | Expect |
|------|-------|--------|
| `nextPrescription` floor | `0.0` | `reps == 3`, `sets == 3` |
| `nextPrescription` midpoint | `2.5` | `reps == 12`, `sets == 4` |
| `nextPrescription` ceiling | `5.0` | `reps == 20`, `sets == 5` |
| `nextPrescription` clamps above range | `9.9` | identical to `5.0` |
| `Order.fromJson` legacy row | `{"id":"1"}` (no `status`) | `status == OrderStatus.confirmed` |
| `Order.fromJson` unknown value | `{"status":"archived"}` | `status == OrderStatus.confirmed`, no throw |

### 10.3 Manual

1. `flutter run`, navigate Home → Orders.
2. Confirm each of the four states in §5 renders as mocked (seed with the fixture in §10.2).
3. Rotate the device — the chip must not wrap or clip.

### 10.4 Static

```bash
dart format .
flutter analyze          # must report "No issues found."
flutter test
rg -n '_StatusBadge|formatBadgeLabel|badgeGrey' lib/ test/   # must print nothing
```
````

**Fails when** assertions are approximate ("reps should be reasonable"): the executor writes a
test that passes against its own wrong implementation.

---

## §11 Style contract

**Form** — the project's **non-obvious** idioms only, each as a rule plus one example, each
pointing at the authoritative rule file rather than restating it.

```markdown
## 11. Style contract

The rules below are non-obvious and violated by default. Full spec:
[CLAUDE.md](CLAUDE.md), `.claude/rules/flutter-ui.md`, `.cursor/rules/dart-conventions.mdc`.

| # | Rule | Example |
|---|------|---------|
| S1 | Exactly one project import per file — the barrel | `import '../../../core/router/exports.dart';` and nothing else |
| S2 | Every new `lib/` file gets an `export` line in `exports.dart`, alphabetical within its section | `export '../../features/order/widget/order_status_chip.dart';` |
| S3 | Sizes come from `AppDimensions` in the project's sizing strategy; font sizes unscaled | `AppDimensions.gapM`, not `16` |
| S4 | No `.withOpacity()` — encode alpha in the hex constant | `Color(0x80000000)`, not `Colors.black.withOpacity(0.5)` |
| S5 | Private `StatelessWidget` classes, never widget-returning methods | `class _StatusRow extends StatelessWidget`, not `Widget _buildStatusRow()` |
| S6 | No `dynamic`, no `var` — explicit types, prefer `final` | `final String label = json['label'] as String? ?? '';` |
| S7 | No inline colours / strings / asset paths | `AppStrings.orderStatusPending`, not `'Pending'` |
| S8 | `// FIXTURE_START` / `/// FIXTURE:` markers are sanctioned conventions — leave them alone | Do not "clean up" a fixture marker |
```

**Fails when** omitted: the executor writes idiomatic Flutter, which is *wrong* here — direct
package imports, raw numbers at the callsite, `.withOpacity()`, and helper methods returning
`Widget`.

**Rule:** point at the rule file; restate only the handful of rules this task will actually
brush against. A style contract that restates the whole convention set gets skimmed.
