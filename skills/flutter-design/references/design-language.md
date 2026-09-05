# Settling the app's design language

Run this once, when the product is settled enough that the same decisions are about to be made on
every screen. It produces `docs/agents/design.md`, which every later design pass reads first.

The point is not to design the app up front. It is to decide the handful of things that must be the
same everywhere — the type steps, the colour roles, the motion budget, what a loading state looks
like in *this* app — so that thirty screens do not each answer them separately and disagree.

Create it lazily, the way `domain-glossary` creates `CONTEXT.md`: when there is something real to
settle, not as an empty scaffold at setup.

## When this runs

| Moment | Why here |
|---|---|
| Acceptance criteria have just been settled | The states are known, so the state patterns can be decided once instead of per screen |
| A spec has just been written | The product is locked; the visual language is the remaining unstated half |
| The second screen is about to be built | One screen is a choice, two is a convention. This is the last cheap moment |
| A rebrand, or a design system arriving | The existing rows are re-decided rather than accumulated around |

Where the doc already exists, do not rewrite it. Read it, and add only the rows the current work
forces open.

## Facts are yours, decisions are theirs

The same split `grill` uses, and it matters more here because taste feels like it invites guessing.

**Derive without asking**: what constants already exist in `lib/core/constants/`, which type sizes and
colours the current screens actually use, how many near-identical values have accumulated, what the
design source already settles. Read before asking; a question whose answer is in the repo spends the
user's attention for nothing.

**Put to the user, and wait**: the personality, the motion budget, whether the app has a delight
budget at all and where, and any brand rule that overrides a default. These are theirs. Offer a
recommendation with each so the question is answerable in one word rather than in an essay.

**Decide yourself, and record it**: everything the two above leave open. An undecided row is a
decision deferred to whoever writes the next screen at 5pm, which is how a scale grows by accretion.
Pick the defaults from the other references, write them down, and mark them as defaults so they are
cheap to overrule.

## The document

Write `docs/agents/design.md`. Every row is either a decision or an explicit `<undecided>` — never a
plausible-looking guess presented as settled.

```markdown
# Design language

Written by `flutter-design`. Read before any design decision on any screen; where this file and a
kit default disagree, this file wins. A row marked `<undecided>` means the kit default applies and
nobody has ruled on it yet.

## Personality

| Field | Value |
|---|---|
| Reads as | `<a crisp daily-use tool>` |
| Motion budget | `<restrained>` — motion where it prevents confusion, not where it decorates |
| Delight allowed at | `<first-run and success moments only>` |

## Type scale

| Step | Style | Used for |
|---|---|---|

Steps in the scale, and nothing between them.

## Colour roles

| Role | Constant | Used for |
|---|---|---|

One accent, carrying the primary action. A colour that means two things means neither.

## Spacing

| Step | Constant | Used for |
|---|---|---|

| Field | Value |
|---|---|
| Page inset | `<horizontal padding applied once per screen>` |
| Between groups | `<step>` |
| Within a group | `<a smaller step>` |

## Motion tokens

| Interaction | Duration | Curve or spring |
|---|---|---|

Frequency verdicts already reached for this app, so they are not re-argued per screen:

| Interaction | Tier | Verdict |
|---|---|---|

## State patterns

What each state looks like here, so every screen matches without deciding again.

| State | This app's treatment |
|---|---|
| Loading, first load | |
| Loading, refresh | |
| Empty, first-run | |
| Empty, filtered to nothing | |
| Error, recoverable | |
| Offline with cached content | |

## Pressed appearance

| Field | Value |
|---|---|
| Default for pressable elements | |
| Elements that depart from it | |

## Not yet decided

Rows nobody has ruled on, and what the kit default is doing in the meantime.
```

## Working with what exists

On a project with screens already built, the language is mostly **recovered rather than invented**.
Read the constants and the screens first, and write down what the app already does — including where
it disagrees with itself.

Where a value appears in three near-identical variants, that is a finding rather than three rows.
Name the convergence you propose and put it to the user, because collapsing them changes pixels on
screens that currently pass their goldens.

Do not change any code in this pass. Settling the language and migrating to it are two pieces of
work, and a design doc that silently restyles screens is the harder one wearing the easier one's
clothes.

## Completion criteria

1. **Every section has either decided rows or an explicit `<undecided>`.** A section quietly left
   blank reads as settled when it is not.
2. **Every decision that was the user's was actually put to them.** Name which questions you asked
   and what they answered.
3. **Every value you chose yourself is marked as a default**, so the cost of overruling it is one
   edit rather than an argument.
4. **Existing disagreements are named, not silently resolved.** Where the repo already contradicts
   itself, say so and propose the convergence separately.
5. **No source file changed.** State that the pass wrote one document and nothing else.

Then point at what reads it: `docs/agents/project.md` gets the pointer row if it is missing, and the
next screen built reads this file before the kit defaults.
