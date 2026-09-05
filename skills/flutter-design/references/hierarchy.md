# Hierarchy

What the eye lands on first, and what the spacing and type say before anything is read.

*The typography rules — tracking and leading moving inversely with size, hierarchy built from weight,
size and leading as a set — are adapted from the `apple-design` skill in
[`emilkowalski/skills`](https://github.com/emilkowalski/skills) (MIT), and through it from Apple's
WWDC talks on UI typography.*

A screen where everything is emphasised has no hierarchy, and a screen with no hierarchy is read
linearly — slowly, and in whatever order the widget tree happened to produce. This is the most common
reason a functionally correct screen reads as amateur.

Contrast ratios, tap-target sizes and text scaling are the floor and are owned elsewhere: call the
Skill tool with `flutter-accessibility`.

## One dominant element

Every view has exactly one thing the user is most likely to want. It gets the largest type, the
strongest colour, or the most space — one of those, not all three. Everything else steps down.

Where two elements compete for dominance, the screen is doing two jobs and the honest fix is usually
to split it or to demote one. Two primary buttons side by side is the visible symptom.

## Type

**Build a scale and use only its steps.** Four or five sizes covers almost any app. Sizes invented at
the callsite are how a codebase ends up with 15px, 16px and 17px text that no one chose and no one
can tell apart, but which collectively read as careless.

**Hierarchy comes from weight, size and spacing as a set**, not from size alone. Weight adds presence
without consuming space, which is what makes it the right tool in dense UI.

| Size | What changes with it |
|---|---|
| Large display and headings | Tighter line height; letters read too far apart as they grow, so slightly negative letter spacing |
| Body | Comfortable line height, letter spacing near zero |
| Small labels and captions | Slightly looser letter spacing for legibility, and enough weight to survive |

Line height moves inversely to size: tight on large text, looser on body. A heading at body line
height floats; body at heading line height reads as cramped.

**Cap the measure.** Body text past roughly 70 characters a line is hard to track back to the next
line. On a tablet or a wide window this bites, and it is why a text column gets a max width rather
than filling the screen.

A scale is a set of named `AppTextStyles` entries. `flutter-core-architecture` §3 owns how they are
declared and how sizes behave; this file is only about how many steps there should be and what
separates them.

## Spacing

**Spacing carries grouping, and grouping is read before content.** Elements closer together are
understood as related, whatever the labels say. Most layout problems that get described as "it looks
off" are a spacing relationship contradicting the intended grouping.

- **Space between groups exceeds space within a group.** A label 16px from its own field and 16px
  from the next field belongs to neither.
- **Use the steps in `AppDimensions` and no values between them.** A rhythm built on a few multiples
  reads as deliberate; arbitrary values read as drift even when no single one is wrong.
- **Padding is usually the answer, not margin.** A container that owns its inner space composes; one
  that pushes on its neighbours makes every caller compensate.
- **Give a screen breathing room at the edges consistently.** One horizontal page inset, applied
  once, beats per-widget padding that nearly agrees.

On a wider screen the question is which relationships change, not how much to multiply. A tablet has
more room, not bigger fingers, so a two-column split or a capped measure is usually the answer where
a scaled-up phone layout is not. `flutter-core-architecture` §3 owns the mechanism.

## Depth

Depth separates layers. It is not decoration, and it is the fastest thing to overdo.

| Layer | What it needs |
|---|---|
| Page content | No elevation. It is the ground |
| A card or grouped region | A border, or a shadow so soft it reads as a seam — one or the other |
| Floating chrome — bars, sheets | A shadow that appears only when content is behind it |
| Modal surfaces | A scrim, so the layer beneath is clearly out of play |

**Prefer a border to a heavy shadow for grouping.** A shadow says "this is above"; where the card is
not above anything, the shadow is a claim the layout does not support. Reserve real elevation for
things that actually float over content.

**A shadow under a fixed header belongs only when content is scrolled under it.** Painted
unconditionally, it draws a line the design does not have.

Stack sparingly. Three shadowed cards inside a shadowed section inside an elevated sheet flattens
into visual noise — with everything raised, nothing is.

## Colour

**Colour carries role, not decoration.** Each colour in the palette means something: the primary
action, a destructive action, a warning, a disabled control. When a colour is used for a second
meaning, the first meaning weakens everywhere it appears.

- **One accent, used for the primary action.** Applied to three different things, an accent stops
  pointing at anything.
- **Never signal state by colour alone** — that floor is owned by `flutter-accessibility`, and it is
  also a hierarchy point: an icon or a label survives a screenshot, a theme change, and a user who
  cannot separate the hues.
- **Muted greys are where hierarchy quietly fails.** Secondary text drifts toward the background
  until it is decorative rather than readable. Have the ratio computed — call the Skill tool with
  `flutter-accessibility` — rather than settling it by eye here. A grey that clears the floor against
  white can fail against a card surface or a dark theme, and those variants rarely get re-checked.

A role is a named `AppColors` entry, declared as `flutter-core-architecture` §3 sets out. The
judgment here is how many roles the app needs, which is almost always fewer than it has.

## Alignment and mapping

- **Align to a small number of edges.** Most screens need one or two vertical alignment lines. A
  third is usually an accident, and the eye finds it.
- **Put a control near what it affects.** A toggle beside its setting is understood without a label;
  the same toggle in a distant panel needs one and will still be misread.
- **Order controls to mirror what they change.** Where the arrangement of controls matches the
  arrangement of what they operate on, the mapping needs no explanation.

Where a label is required to explain what a control does, the mapping is weak. That is a layout
finding, not a copy finding, and adding words is the workaround rather than the fix.

## Copy

Microcopy is part of the hierarchy, because it is read before anything is pressed.

- **Buttons name their action**, not their acknowledgement. "Save changes" beats "OK".
- **Titles say what the screen is**, in the vocabulary the user brought. Call the Skill tool with
  `domain-glossary` where the term is contested.
- **Specific labels beat safe generic ones.** A navigation item named for its contents is
  predictable; an umbrella term is not.

Where the strings themselves live is settled by `flutter-core-architecture` §3, or by the
localization layer where the app has one.

## What to state when this is done

Name the dominant element for the view, and which type steps, spacing steps and colour roles you used.
Where you introduced a step or role that did not exist, say so — a scale grows by decision, not by
accretion.
