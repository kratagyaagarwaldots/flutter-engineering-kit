---
name: flutter-performance
description: Measure and improve Flutter performance against a budget: jank, dropped frames, slow startup, memory growth, and app size. Use when the app feels slow, janky or stuttery, when scrolling drops frames, when startup is slow, or when asked to optimise or profile.
---

# Flutter performance

Performance work without measurement is guessing, and Flutter makes guessing especially tempting
because the usual advice (`const`, `RepaintBoundary`) is cheap to apply and rarely the cause.

Measure, change one thing, measure again, keep or revert. This skill owns that loop.

Where the complaint is a specific reported symptom whose cause is unknown, call the Skill tool with
`flutter-diagnose-bug` first: it owns building a reproduction. Come back here once the cause is
known to be cost rather than a defect.

## 1. Profile mode, always

```bash
flutter run --profile
```

Debug builds are slow by construction: assertions run, the code is JIT-compiled, and the widget
inspector adds per-frame work. **A timing measured in debug mode is not a measurement**, and acting
on one produces changes that help nothing. This is the most common mistake in Flutter performance
work.

Profile on a real device where you can. A simulator has no GPU pipeline resembling a phone's, so
raster-side problems either vanish or invert.

## 2. Name the metric and the budget

One metric, one number, before any change:

| Complaint | Metric | Budget |
|---|---|---|
| Janky scrolling | Frame build and raster times, 90th percentile | Under 16ms at 60Hz, 8ms at 120Hz |
| Slow startup | Time to first meaningful frame | State the current number, then target |
| Grows over time | Heap after N repetitions of the flow | Returns to baseline after the flow ends |
| Large download | `flutter build --analyze-size` total | State current, then target |

Write the number down. Without a before, "it feels smoother" is the only available conclusion, and
it is usually wrong.

## 3. Find which thread is losing

This is the fork in the road, and it decides everything after it. Open DevTools' Performance view
and read the frame chart: each frame has a **UI** portion and a **raster** portion.

**UI thread over budget** means Dart is doing too much per frame: rebuilding too much of the tree,
work in `build`, a large synchronous computation, expensive layout.

**Raster thread over budget** means the GPU is doing too much: overdraw, expensive clips and
shadows, opacity over a large subtree, large images being resampled, shader compilation.

They have almost no fixes in common, which is why identifying the thread first saves the whole
investigation.

## 4. Fix the thing you measured

### UI thread

| Finding | The fix |
|---|---|
| A wide subtree rebuilds on every state change | Narrow what listens: select one field rather than the whole state |
| A whole list rebuilds when one row changes | `const` constructors on rows, and stable keys |
| Work inside `build` | Move it out: `build` runs often, and anything expensive there runs often |
| A long list building every child | `ListView.builder`, and a `cacheExtent` tuned to the row height |
| A synchronous parse of a large payload | `compute`, so it runs off the UI isolate |
| A rebuild triggered by an unnecessary `setState` | Push state down to the smallest widget that needs it |

`debugPrintRebuildDirtyWidgets = true` names what is rebuilding, and it is faster than reasoning
about it. The DevTools rebuild counter does the same visually.

### Raster thread

| Finding | The fix |
|---|---|
| A subtree repainting with its parent | `RepaintBoundary` around the part that changes independently |
| `Opacity` over a large subtree | Bake the alpha into the colour, or use `AnimatedOpacity` on a leaf |
| Layered shadows and clips | Fewer layers; a decoration rather than a stack of clipped boxes |
| Large images | Decode at display size with `cacheWidth`/`cacheHeight`, not full resolution |
| A stutter on first showing an animation | Shader jank: warm up with `--cache-sksl` and ship the bundle |

`RepaintBoundary` is not free: each one is a layer with memory and composition cost. Adding them
speculatively makes raster time worse, which is why this table only applies after step 3 pointed
here.

## 5. One change, then measure again

Apply one change. Measure the same metric the same way. Keep the number, and revert anything that
did not move it, even when it is obviously correct in principle.

This is the discipline that separates performance work from performance folklore. A batch of six
plausible optimisations measured once at the end teaches nothing about which one mattered, and
leaves five changes in the codebase for no reason.

Where a change helps, commit it on its own with the before and after numbers in the message.

## Completion criteria

The metric is stated with its before and after value, the command that produced both is shown, and
each kept change is tied to the measurement that justified it.

Name what you tried that did **not** help and reverted. That list is the most useful part of the
report, because it stops the next person spending the same day on it.
