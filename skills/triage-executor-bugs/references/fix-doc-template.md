# Fix-doc template (Route B only)

A fix doc is **not** a small spec doc. It is a mechanical patch list for a model that already got
this code wrong once, and that now half-owns the file it is editing.

Two rules govern every section below:

1. **Nothing is described that can be quoted.** Every edit ships as verbatim before/after.
2. **The site list is produced by a command, not by prose.** The executor must be able to
   regenerate the list and count it.

Path: `docs/tasks/{NN}-fix-{slug}.md`.

---

## Header

```markdown
# {NN} — Fix: {one-line symptom}

| | |
|---|---|
| **Type** | Mechanical fix — no design decisions in this doc |
| **Fixes bugs** | B1, B2, B5 (cluster C1) |
| **Root cause** | `OrderStatusChip` wired into the confirmed state only |
| **Origin doc** | [docs/tasks/05-order-status-chip.md](docs/tasks/05-order-status-chip.md) §5 — **amended**, re-read it before starting |
| **Sites** | 3 |
| **Design decisions required** | **None.** If you find one, stop and report it. |
```

That last row is load-bearing. It tells the executor that encountering a judgment call means the
doc is wrong — not that it should exercise judgment.

---

## §1 Scope — harder than a spec's

```markdown
## 1. Scope

Fix exactly the 3 sites in §3. **Change nothing else.**

You have worked in these files before. Do not:
- rename anything, even something obviously misnamed
- extract a helper, even where the same 4 lines repeat
- reformat (the `dart-format.sh` hook handles formatting on every write)
- fix an unrelated bug you notice — **report it instead, at the end**
- touch any file not listed in §3

**Files touched:** `lib/features/order/widget/order_card.dart` only.
```

**Fails when** omitted: the executor "improves" the surrounding code, and your three-line fix
arrives inside a 300-line diff nobody can review.

---

## §2 Site inventory — produced by a command

```markdown
## 2. Sites

Run this first:

```bash
rg -n 'OrderStatus\.(pending|declined|cancelled)' lib/features/order/widget/order_card.dart
```

**Expected: exactly 3 matches**, at lines 142, 158 and 174.

If you get a different count, **stop and report it** — the tree does not match this doc and
applying it will corrupt the file.
```

**Fails when** the sites are merely described: the executor finds four, fixes four, and the extra
one was deliberate.

**Rule:** always pair the command with the expected count, and always state that a mismatch is a
stop condition rather than something to reconcile.

---

## §3 Edits — verbatim before/after, one block per site

````markdown
## 3. Edits

### Site 1 of 3 — [order_card.dart:142](lib/features/order/widget/order_card.dart#L142)

Find exactly:

```dart
      case OrderStatus.pending:
        return const SizedBox.shrink();
```

Replace with exactly:

```dart
      case OrderStatus.pending:
        return OrderStatusChip(status: OrderStatus.pending);
```

- [ ] Applied

### Site 2 of 3 — [order_card.dart:158](lib/features/order/widget/order_card.dart#L158)

Find exactly:

```dart
      case OrderStatus.declined:
        return const SizedBox.shrink();
```

Replace with exactly:

```dart
      case OrderStatus.declined:
        return OrderStatusChip(status: OrderStatus.declined);
```

- [ ] Applied

### Site 3 of 3 — [order_card.dart:174](lib/features/order/widget/order_card.dart#L174)

… (never "and the same for the remaining sites")
````

**Fails when** collapsed into a rule ("wire the chip into each remaining state"): that is the
exact instruction shape that caused the bug. If three sites feel repetitive to write, good — the
repetition is the deliverable.

**Rule:** the find-block must be unique in the file. If it is not, widen it until it is, and say
so: *"the two surrounding lines are included to disambiguate — match all four."*

---

## §4 Proof of completion

```markdown
## 4. Proof

After all sites are applied, this must print **nothing**:

```bash
rg -n 'case OrderStatus\.(pending|declined|cancelled):\s*$' -A1 lib/features/order/widget/order_card.dart | rg 'SizedBox.shrink'
```

And this must print **exactly 4 matches** (one per status):

```bash
rg -c 'OrderStatusChip\(status:' lib/features/order/widget/order_card.dart
```

Both conditions must hold. One passing and one failing means a partial application — report it,
do not attempt a repair.
```

**Fails when** omitted: the executor applies two of three sites and reports success. A count
assertion is the only thing that mechanically distinguishes "done" from "mostly done".

---

## §5 Regression tests — fail before, pass after

````markdown
## 5. Regression tests

Add to [order_card_test.dart](test/features/order/widget/order_card_test.dart), in the existing
`OrderCard` group. Run them **before** editing §3: all three must fail.

```dart
for (final OrderStatus status in <OrderStatus>[
  OrderStatus.pending,
  OrderStatus.declined,
  OrderStatus.cancelled,
]) {
  testWidgets('renders a status chip for ${status.name}', (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(OrderCard(order: _order(status: status))));
    expect(find.byType(OrderStatusChip), findsOneWidget);
  });
}
```

Expected failure before §3: `Expected: exactly one matching candidate / Actual: no matching
candidates`. **Any other failure message means the tree does not match this doc — stop.**
````

**Rule:** state the expected pre-fix failure message. Without it, a test failing for an unrelated
reason reads as confirmation.

---

## §6 Verification

```markdown
## 6. Verification

```bash
dart format .
flutter analyze          # must report "No issues found."
flutter test test/features/order/widget/order_card_test.dart
flutter test             # full suite must stay green
```

Then re-run both commands in §4.
```

---

## §7 Report back

```markdown
## 7. Report

State, in this order:

1. Site count found by §2 vs the 3 expected
2. Which sites you applied (the checkboxes in §3)
3. §4 command output — both commands, verbatim
4. Test results before and after
5. **Anything you noticed but did not fix**, per §1

If any step failed, say so with the output. Do not report success with a caveat attached.
```

**Fails when** omitted: you get "done!" and have to re-diagnose from scratch to find out whether
it actually was.

---

## What a fix doc never contains

| Never | Because |
|-------|---------|
| A new abstraction to design | That is a judgment call — Route A |
| "Use your best judgment on X" | If X exists, the doc is not finished |
| A rule where sites can be enumerated | Rules are what caused the bug |
| More than one root cause | One cluster per doc; two clusters interleave and neither gets proven |
| A refactor bundled with the fix | Unreviewable diff; ship the fix, propose the refactor separately |
| An unverified line number | Re-read the file after any prior fix landed — never adjust by arithmetic |
