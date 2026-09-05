# Motion

Whether a thing should move, and what it does when it moves.

*The gates, budgets and physics here are adapted from [`emilkowalski/skills`](https://github.com/emilkowalski/skills)
(MIT) and, through it, Apple's WWDC talks on fluid interfaces. Those skills target CSS and React
Native; the gates carry over because they are claims about human perception rather than about a
platform. The Flutter mapping is the kit's.*

## 1. The frequency gate

The gate itself, its tiers and its two precedence rules are in `SKILL.md`. Apply it before anything
here, because it produces zero lines of code often enough to be the point.

The reasoning behind it, which is what makes it hold up when someone pushes back: an animation is
paid for on every viewing and enjoyed on roughly the first three. At the top tier it is a tax, and
the user cannot opt out of it.

**Tabs are the case worth stating in Flutter.** `TabBarView` slides between tabs by default, and a
tab switch is a top-tier action. Tabs are peers rather than a hierarchy, so a slide implies a depth
that is not there and charges for it dozens of times a session. Where the design wants no slide, an
`IndexedStack` swaps the child with no transition; `NeverScrollableScrollPhysics` alone stops the
drag but keeps the animation on tap.

## 2. The purpose gate

Name the purpose in one word before building. These are the words:

| Purpose | What it means |
|---|---|
| **Feedback** | Confirming the interface heard the user — a press, a commit |
| **Spatial consistency** | Showing where something came from or went |
| **State indication** | Making a change of state legible |
| **Preventing a jarring change** | Bridging content that would otherwise teleport |
| **Explanation** | Demonstrating how something works — onboarding and marketing |
| **Delight** | Permitted at the rare or first-run tier only |

No word fits means the animation does not get written. Record the rejection; the skill's completion
criteria ask for it.

## 3. Curves

Flutter already ships the strong curves, so reach for a name before a `Cubic`.

| Situation | Curve | Value |
|---|---|---|
| Entering or exiting | `Curves.easeOutQuint` | `Cubic(0.23, 1.0, 0.32, 1.0)` |
| Moving or morphing on screen | `Curves.easeInOutQuart` | `Cubic(0.77, 0.0, 0.175, 1.0)` |
| Material-standard motion | `Curves.fastOutSlowIn` | `Cubic(0.4, 0.0, 0.2, 1.0)` |
| Constant motion — progress, marquee | `Curves.linear` | — |
| Sheets and drawers, iOS feel | `AppCurves.sheet` | `Cubic(0.32, 0.72, 0.0, 1.0)` |

Only the sheet curve has no Flutter name, so it is the one that becomes a custom `Cubic` in
`AppCurves`.

**Entering and exiting take ease-out.** A curve that starts slow delays the first frames, which is
exactly where the user is looking — the same duration reads as slower. Where the choice is unclear,
ease-out is the default.

Where a gesture is involved, curves stop being the right tool at all. Go to §5.

## 4. Durations

| Interaction | Duration |
|---|---|
| Press feedback | 100–150ms |
| A small state change — toggle, chip, selection | 150–200ms |
| Sheet, dialog, drawer | 200–300ms |
| Screen transition | The platform default, unchanged |

These are ceilings for interactions that already cleared §1, not permission to animate. Where the gate
put the interaction in the tens-a-day row, its own ceiling of 150ms wins over anything longer here.

UI motion stays under 300ms. A 180ms sheet reads as more responsive than a 400ms one, and the
difference in how fast the app feels is larger than the difference in how good the motion looks.

Flutter's own constants are already at these values and are worth reusing where they fit:
`kThemeAnimationDuration` is 200ms, `kRadialReactionDuration` is 100ms.

Screen transitions are the exception to beating the platform: matching what the OS does elsewhere is
worth more than shaving 80ms. In a Material app `PageTransitionsTheme` sets them per platform; a
Cupertino app or a router supplying its own `Page` transitions never consults it, so check which
applies before assuming the default is in force.

## 5. Springs, gestures and velocity

**If the gesture carried velocity, use a spring.** A tap does not — it gets a curve from §3. A drag,
a flick or a swipe does, and there a fixed-duration curve throws that velocity away and restarts from
zero, so the release reads as a replay rather than as a throw. A spring carries it through.

`SpringDescription.withDurationAndBounce` is the constructor to reach for. It takes two parameters,
both with defaults, and its own documentation states it produces the same result as SwiftUI's
`spring(duration:bounce:blendDuration:)` — so a value agreed with a designer in Apple's terms
transfers directly:

| Interaction | Bounce | Duration |
|---|---|---|
| Settle with no overshoot — the default for UI | `0.0` | 300–400ms |
| Snap back after a drag, sheet detent | `0.2` | ~300ms |

`SpringDescription.withDampingRatio` is the alternative, and it requires `mass` and `stiffness` as
well as `ratio`, so it is the right choice only when those are already known. Reaching for it with a
ratio alone means inventing the other two.

Overshoot only where the gesture carried momentum. Bounce on a menu that faded in reads as a bug;
bounce on a card that was flicked reads as physics. Keep it at or under `0.3`.

**Velocity handoff** is the seam that separates fluid from merely working. The finger's release
velocity becomes the animation's opening velocity, so there is no visible restart between dragging
and settling. Three things have to line up, and each one is silently wrong rather than loudly wrong:

```dart
// 1. Units. A SpringSimulation's start, end and velocity share one unit. The
//    controller runs 0..1, so the gesture's pixels-per-second is divided by the
//    distance the controller spans.
// 2. Sign. It has to point from start toward end. A downward drag has positive
//    dy, while a sheet's settled position is upward, so it is negated.
final double velocity = -details.velocity.pixelsPerSecond.dy / sheetExtent;

controller.animateWith(
  SpringSimulation(spring, controller.value, 1.0, velocity),
);
```

This is what Flutter's own bottom sheet does, and it is worth copying rather than deriving.

**3. Clamping.** `animateWith` clamps the simulation to the controller's bounds, so on a standard
controller any `bounce` above zero is computed and then discarded — the motion looks damped no matter
what the spring says. Where the overshoot should be visible, drive it with
`AnimationController.unbounded`.

Passing raw pixels per second into a 0..1 controller is the common version of this bug. It compiles,
it runs, and on a 700px sheet it launches with roughly seven hundred times the intended velocity.

At a boundary, resistance beats a wall: the further past the edge the drag goes, the less the element
follows. `ScrollConfiguration` gives scrollables `BouncingScrollPhysics` on iOS and macOS, but
`ClampingScrollPhysics` on Android, where overscroll is a stretch indicator with no rubber-band
resistance. So this is free on one platform only — a custom drag, and any deliberate rubber-band on
Android, needs it written.

## 6. Interruptibility

Flutter's implicit animations already do the right thing here, and it is worth knowing rather than
working around. `AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale` and their siblings retarget
from the **current** on-screen value when their target changes mid-flight, so a rapidly toggled
widget moves continuously instead of jumping back to a start frame.

So where §1 has already admitted an animation on something triggered repeatedly, an implicit widget is
the mechanism to reach for. This section decides **how** to build motion the gate allowed, never
whether to have it: a toggle, a selection and an expanding row are all tens-a-day interactions, and
most of them should still resolve instantly.

Reach for an explicit `AnimationController` when the motion is continuous, is driven by a gesture, or
has to be interrupted and re-aimed under your own control.

## 7. Physicality

- **Enter from `scale: 0.95` with opacity**, not from zero. Nothing in the physical world appears
  from nothing, and a widget that scales up from a point reads as arriving from somewhere off-screen.
- **Enter and exit along the same path.** A sheet that rises from the bottom dismisses downward. A
  panel that enters from the right and leaves through the bottom breaks the spatial story and makes a
  swipe-to-dismiss gesture feel arbitrary.
- **Where a group entrance cleared §1, stagger it by 30–80ms per item.** Longer reads as slow.
  Stagger is decorative, so it never blocks interaction — an item is tappable as soon as it is on
  screen. `Interval` on a shared controller is the mechanism. A list the user opens constantly is
  top-tier, and there the entrance is no animation at all.
- **Time the deliberate phase slowly and the response fast.** A hold-to-confirm fills over seconds
  and releases in 200ms. Slow where the user is deciding, snap where the system is answering.

## 8. Reduced motion

`MediaQuery.disableAnimationsOf(context)` carries the OS setting. Reduced motion means **fewer and
gentler**, not none: keep the opacity and colour changes that explain what happened, and drop
translation, scale, parallax and overshoot.

```dart
final reduced = MediaQuery.disableAnimationsOf(context);
```

A screen that removes all feedback under reduced motion has substituted one accessibility problem for
another — the user still needs to know the tap registered. Ship the reduced path with the animation
rather than after it, since it is a branch in the same widget.

The flag reaches Dart from the platform's own reduce-motion setting, so confirm it arrives on the
platforms this app targets before relying on it as the only path. Where it does not, the setting the
app offers in its own preferences is the fallback.

## 9. Haptics

Route through `HapticUtil`, per `flutter-core-architecture` §6. Three rules, and they hold absolutely:

- **Same frame as the visual.** Fire at the causal moment — the detent catching, the drag committing
  — not when the animation finishes. A haptic that lags its visual reads as a glitch.
- **One per user action.** Never per frame, never on scroll, never on an entrance the user did not
  cause.
- **Never the only feedback.** Haptics are off system-wide for many users and inconsistent across
  hardware. The visual has to carry the meaning alone.

Used sparingly, haptics are what make an app feel expensive. Used everywhere, they are what makes a
user turn them off.

## 10. Naming the values

Durations and curves become constants in `AppDurations` and `AppCurves`, following the family pattern
`flutter-core-architecture` §3 owns. Five hand-typed durations that nearly agree is the failure this
prevents: motion that is almost consistent reads worse than motion that is uniformly plain, because
the eye catches the disagreement without being able to name it.

Springs are named alongside the curves in `AppCurves`, since they answer the same question. One
mechanical note: `SpringDescription.withDurationAndBounce` is a factory rather than a const
constructor, so a named spring is `static final` where a curve is `static const`.

## 11. What only a device can settle

Curve, spring and gesture decisions can be made from a table. Whether the result **feels** right
cannot. Where a judgment depends on feel, say so and name the check rather than asserting a verdict:

- Run it at reduced speed, or step it frame by frame, to see whether coordinated properties stay in
  sync and the easing settles rather than stopping.
- Interrupt it mid-flight and reverse it. Continuous motion means the interruptibility is real.
- Judge gestures on a physical device in a release build, on the slowest hardware the app supports.
- Look again the next day. Timing errors invisible during development surface with fresh eyes.

For frame budget and jank rather than feel, call the Skill tool with `flutter-performance`.
