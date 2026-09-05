---
name: flutter-design
description: Judge and shape what a screen looks like and how it moves, when no design source settles it: visual hierarchy, the states a build skips, and whether something should animate at all. Use when building UI without a design source, when acceptance criteria or a spec have just been settled and the app still has no design language, when choosing spacing, type scale or emphasis, when a screen needs loading, empty, error or first-run states, or when adding animation, transitions, gestures or haptics.
---

# Flutter design

Where a design source answers the question, it is transcribed rather than judged, and every token
maps to a constant — that is `flutter-create-screen`'s job, and this skill does not send work back to
it. This skill is for the rest: the screen that never had a design, the state the design did not
draw, and the decision a Figma node cannot contain because it is about behaviour rather than pixels.

Those decisions get made either way. Left unnamed, they get made by whatever the first draft happened
to produce.

## What this skill does not own

Each row is owned elsewhere and stated once. Route rather than answering from a copy.

| Question | Owner |
|---|---|
| Contrast ratios, tap-target size, text scaling, screen-reader labels | Call the Skill tool with `flutter-accessibility` |
| Frame budget, jank, dropped frames, `Opacity` over a subtree, shader warm-up | Call the Skill tool with `flutter-performance` |
| Constants families, the sizing strategy, the shared component set, `lib/core` layout | Call the Skill tool with `flutter-core-architecture` |
| Which state seam, sizing strategy and test tooling this project actually uses | Call the Skill tool with `project-conventions` |
| Which acceptance criteria a screen has to satisfy at all | Call the Skill tool with `grill` |

These route a *different question* elsewhere. Where this skill was called by one of them, answer the
design question and return: sending the work back re-enters a task already in flight.

The overlap worth naming: accessibility sets the **floor** and owns every number that defines it.
This skill works above that floor, and does not restate a threshold it does not own. A screen can
clear every accessibility guideline and still read as unfinished.

## Restraint is the posture

The strongest design move is subtraction, and for motion it is usually deletion. An interface earns
trust by being predictable, and every element, every colour and every animation added is a claim on
the user's attention that has to pay for itself.

This matters more when an agent is holding the keyboard, because generating another animation is
cheaper than deciding not to. Call the Skill tool with `engineering-principles` when the choice is
between two shapes rather than two appearances.

So the default answers are: fewer weights, fewer colours, one dominant element, and no animation
until a gate below admits one.

## The three decisions

Read the reference that covers the decision in front of you. The gates below and the completion
criteria apply to every design pass whichever one that is, so they live here rather than in a file
that might not be opened.

| The decision | Read |
|---|---|
| The app has settled nothing yet, and the same choices are about to repeat on every screen | [references/design-language.md](references/design-language.md) |
| Whether this should move, and with what curve, duration and physics | [references/motion.md](references/motion.md) |
| What the user sees when there is nothing, it is slow, or it broke | [references/states.md](references/states.md) |
| What the eye lands on first, and what the spacing and type say | [references/hierarchy.md](references/hierarchy.md) |

Two gates from `motion.md` decide so much that they belong here too. Apply them before writing any
animation code.

**The frequency gate.** How often will one user see this?

| Frequency | What it gets | Examples |
|---|---|---|
| 100+ times a day | No added motion. It resolves instantly | Switching tabs, opening the keyboard, scrolling, returning to the home screen |
| Tens of times a day | 150ms at most, or nothing | Selecting a row, expanding an item, toggling a setting |
| Occasional | A standard animation | Sheets, dialogs, snackbars, onboarding steps |
| Rare or first-run | Where the delight budget lives | Success, celebration, an empty state seen once |

Two rules stop the table being argued with, and both loopholes are worth closing explicitly:

- **The gate rules on what the press causes, not on the press.** Every pressable thing gets a pressed
  appearance, and this table never forbids one. A pressed appearance lasts only while the finger is
  down: anything that persists after the finger lifts is a *selected* appearance, which is a state
  change, which is what the press caused — and that gets tiered. A tab button may highlight under the
  thumb **and** its selected state and content still change instantly.
- **An interaction that fits two rows takes the higher-frequency one.** The tier is a property of how
  often this app's users hit it, so where the count is unknown, assume more rather than fewer.

**The purpose gate.** Name the purpose in one word before building: **feedback**, **spatial
consistency**, **state indication**, **preventing a jarring change**, **explanation**, or **delight**
(rare tier only). No word fits means the animation does not get written.

## The app's design language

`docs/agents/design.md` holds what this app has already settled: its personality, type steps, colour
roles, spacing, motion tokens and state patterns. **Read it before the references above, and where it
and a kit default disagree, it wins.** It exists so that thirty screens do not each answer the same
question differently.

Where it does not exist, or the decision in front of you is one it leaves open, settle it — read
[references/design-language.md](references/design-language.md) and write the file. Create it lazily,
when there is something real to settle, the way `domain-glossary` creates `CONTEXT.md`. The moment
worth taking it is when acceptance criteria or a spec have just been settled: the product is locked
and the visual language is the remaining unstated half.

`docs/agents/project.md` still owns the architecture facts a design decision leans on — where the
theme lives, and the sizing strategy resolved by calling the Skill tool with `project-conventions`.

Where neither file answers and you had to assume, name the assumption in the answer, so it is
corrected once rather than re-litigated per screen.

## Working with the design tokens

Every value resolves to a named constant, in the family pattern `flutter-core-architecture` §3 owns.
Motion adds two families to that pattern, on the same terms as every other:

| Class | File | Holds |
|---|---|---|
| `AppDurations` | `app_durations.dart` | Named `Duration` constants per interaction class |
| `AppCurves` | `app_curves.dart` | Named `Curve` constants, any custom `Cubic`, and the named `SpringDescription` values gestures settle with |

Read `lib/core/constants/` before adding either: a project may already carry them under its own
names, and the naming convention is what the kit fixes, not the list.

## Completion criteria

The design work is done when all five hold, and the answer says so in these terms:

1. **Every element the user can act on has a pressed appearance.** Where a screen has more than a
   handful, state the default once and enumerate only the elements that depart from it, with the
   reason — a list of twenty identical lines proves nothing.
2. **Every state the logic seam can emit has a designed branch**, loading, empty and failure
   included. `flutter-create-screen` requires the branch to exist; this criterion is about what is
   in it.
3. **Every animation names its frequency tier and its purpose word.** An animation that cannot be
   labelled with both is not finished being decided.
4. **Name what you chose not to animate, and which gate rejected it.** A design pass that only adds
   is a wishlist. This line is the evidence that the gates ran.
5. **Every value resolves to a named constant.** State which tokens you added and to which family.

Where a judgment cannot be made from code — whether a curve feels right, whether a spring's overshoot
is too much — say so and name what to look at on a device, rather than asserting it. Motion that is
mechanically correct can still feel wrong, and the fix for that is running it.

For proof that the pixels match an approved baseline, goldens are rung 4: call the Skill tool with
`flutter-verify`.
