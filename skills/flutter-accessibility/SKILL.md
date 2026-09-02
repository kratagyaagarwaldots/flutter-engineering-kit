---
name: flutter-accessibility
description: Make a Flutter screen usable with a screen reader, large text and low vision, and add the tests that keep it that way. Use when asked about accessibility, a11y, screen readers, TalkBack, VoiceOver, contrast, tap targets or text scaling.
---

# Flutter accessibility

Flutter renders to a canvas, so nothing is accessible by default the way HTML partly is. A
`GestureDetector` around a `Container` is invisible to a screen reader no matter how obvious it looks
on screen.

The good news is that Flutter can assert most of this in a test, which makes accessibility a thing
you keep rather than a thing you audit once.

## 1. The text-scaling problem this kit had

The OS text-scale setting reaches the tree through `TextScaler`. A font size multiplied at the
callsite, which is what `flutter_screenutil`'s `.sp` does, **overrides the size the user chose for
legibility**. Someone who set large text because they cannot read small text gets small text.

Font sizes stay unscaled. `flutter-core-architecture` §3 owns the sizing convention; call it rather
than working from a copy here.

Then check the layout survives it:

```dart
tester.platformDispatcher.textScaleFactorTestValue = 2.0;
```

At 200%, text should reflow, wrap or scroll. Where it overflows, give it room rather than clamping
it with `maxLines: 1` and an ellipsis, which trades a visible bug for an invisible one.

## 2. Label what is tappable

| The widget | What a screen reader announces |
|---|---|
| `IconButton` with no tooltip | The icon's code point, meaninglessly |
| `GestureDetector` on a `Container` | Nothing, and it is not focusable |
| An image carrying meaning | Nothing |
| A `TextField` with only `hintText` | The hint, which disappears once typing starts |

The fixes, in order of preference: use a widget that is already semantic (`IconButton` with a
`tooltip`, `InkWell` inside a `Material`), then reach for `Semantics` where you must:

```dart
Semantics(
  button: true,
  label: AppStrings.removeItemLabel,
  child: GestureDetector(onTap: _remove, child: const Icon(Icons.close)),
)
```

Give a `TextField` a `labelText` rather than only a hint, and an `InputDecoration` an
`errorText` that says what to fix rather than that something is wrong.

## 3. Merge and exclude

A card announcing "Order" then "1234" then "Pending" as three separate stops is exhausting to
navigate. Merge them into one:

```dart
MergeSemantics(child: /* the card */)
```

And hide what is decorative, so it does not become a focus stop:

```dart
ExcludeSemantics(child: /* a background flourish */)
```

Both are about the *number of stops* a user has to move through, which is the part of screen-reader
use that sighted developers most consistently underestimate.

## 4. Size and contrast

- **Tap targets at least 48x48 logical pixels.** A 24px icon needs padding to reach it, and Flutter
  will happily render a 20px tappable icon.
- **Text contrast at least 4.5:1** against its background, 3:1 for large text. Compute it from the
  `AppColors` values rather than judging by eye; muted greys on white are the usual failure.
- **Never signal state by colour alone.** A red border for invalid needs text or an icon too.

## 5. Test it

Flutter ships guideline checks, and they are the cheapest way to hold the line:

```dart
testWidgets('meets accessibility guidelines', (tester) async {
  final SemanticsHandle handle = tester.ensureSemantics();
  await tester.pumpWidget(/* the screen */);

  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

  handle.dispose();
});
```

`ensureSemantics()` matters: without it the semantics tree is not built in a test and the guidelines
pass trivially.

Add a second test at 200% text scale asserting no overflow. Call the Skill tool with
`flutter-write-tests` for where these live.

## 6. Then use it

The tests catch the mechanical failures. They cannot tell you the reading order is confusing or a
label is technically present and useless. Turn on VoiceOver or TalkBack and navigate one flow with
the screen off.

Where that is not possible in this session, say so rather than implying it was done.

## Completion criteria

Every tappable element has a label and meets the tap-target guideline, contrast passes, the screen
survives 200% text scale without overflow, and the guideline test above is in the suite.

Name what you could not verify without a real device and screen reader. A screen that passes every
automated check can still be unusable, and that gap should be stated rather than closed by
assumption.
