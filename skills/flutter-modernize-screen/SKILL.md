---
name: flutter-modernize-screen
description: Migrate a legacy screen onto the project's current state management, sizing and widget conventions without changing what it renders. Use when modernising a screen, cleaning up legacy code, extracting constants, or improving UI architecture without changing visual behaviour.
---

# Modernize screen

Migrate screens to the project's modern patterns without changing the visual output.

## Architecture

Before creating UI, constants, dialogs, or shared helpers, call the Skill tool with `flutter-core-architecture`. Reuse what it lists; do not invent parallel dialogs, text widgets, or theme constants.

## Required context

- **Target files** (paths to refactor)

## Migration checklist, in order

### 1. Extract constants

```dart
// BEFORE
Text('Submit', style: TextStyle(color: Color(0xFF2196F3)))

// AFTER
Text(AppStrings.submit, style: TextStyle(color: AppColors.primary))
```

### 2. Move sizes into tokens

Call the Skill tool with `project-conventions` for the Sizing strategy row, and follow it. On a
project already using a scaling library, match the existing screens; the migration below is for the
default strategy.

```dart
// BEFORE
MediaQuery.of(context).size.width * 0.9
Padding(padding: EdgeInsets.all(16))
Text(label, style: TextStyle(fontSize: 14))

// AFTER
LayoutBuilder(builder: (context, c) => SizedBox(width: c.maxWidth * 0.9, ...))
Padding(padding: EdgeInsets.all(AppDimensions.gapM))
Text(label, style: AppTextStyles.body())
```

Three moves, in order. A raw number becomes an `AppDimensions` token. A width derived from the
screen becomes a constraint from `LayoutBuilder`, which is the box the widget actually sits in
rather than the whole window. A font size stays unscaled, so the OS text-scale setting still
applies; where large text then overflows, give it room rather than clamping it.

### 3. Helper methods to private widget classes

```dart
// BEFORE
Widget _buildHeader() => Container(...);

// AFTER
class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) => Container(...);
}
```

### 4. const constructors

```dart
// BEFORE
SizedBox(height: 16)

// AFTER
const SizedBox(height: 16)
```

### 5. setState to the project's state layer

Call the Skill tool with `project-conventions` for the Logic seam row, then move the work behind it.
The move is the same in every stack: the widget stops owning the data and stops awaiting, and
dispatches a named action instead.

```dart
// BEFORE
onPressed: () async {
  final result = await api.fetchData();
  setState(() => _data = result);
}

// AFTER — the widget dispatches and renders; it no longer awaits
onPressed: () => _dispatchFetchData(context),
```

Where the screen has no state layer yet, call the Skill tool with `flutter-create-state-layer`
first. Migrating a screen onto a seam that does not exist is two changes at once.

### 6. Navigation

```dart
// BEFORE
Navigator.of(context).push(MaterialPageRoute(builder: (_) => Page()));

// AFTER
Navigator.of(context).pushNamed(FeaturePage.routeName);
```

### 7. State-driven UI

```dart
// BEFORE
if (isLoading) return const CircularProgressIndicator();
if (hasError) return Text(error);
return Content();

// AFTER
return switch (state.status) {
  FeatureStatus.loading => const Center(child: CircularProgressIndicator()),
  FeatureStatus.failure => Center(child: Text(state.errorMessage ?? 'Error')),
  FeatureStatus.success => _Content(data: state.data!),
  _ => const SizedBox.shrink(),
};
```

### 8. Dispose controllers

```dart
// BEFORE
final controller = TextEditingController();

// AFTER
late final TextEditingController _controller;

@override
void initState() {
  super.initState();
  _controller = TextEditingController();
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### 9. Guard BuildContext across async gaps

```dart
// BEFORE
onPressed: () async {
  await doSomething();
  Navigator.of(context).pop();
}

// AFTER
onPressed: () async {
  await doSomething();
  if (!context.mounted) return;
  Navigator.of(context).pop();
}
```

### 10. Route registration

- Add `static const String routeName` to every page
- Register route in `lib/core/router/`
- Replace raw `Map` arguments with typed argument classes

## Common patterns

### Loading overlay

```dart
Stack(
  children: [
    const _Content(),
    if (state.status == FeatureStatus.loading)
      const Positioned.fill(
        child: ColoredBox(
          color: Color(0x66000000),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
  ],
)
```

### Pull to refresh

`RefreshIndicator` keeps its spinner up until the returned future completes, so the future has to
resolve when the refresh actually finishes rather than when the action is dispatched. Dispatch, then
await the state leaving `loading`; how you observe that is the seam's business.

```dart
RefreshIndicator(
  onRefresh: () async {
    _dispatchRefresh(context);
    await _whenNoLongerLoading(context);
  },
  child: ListView(...),
)
```

Returning immediately is the common bug: the spinner vanishes before the data lands, and the screen
looks broken on a slow connection.

### 11. Collapse the imports to the barrel

```dart
// BEFORE
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../repo/feature_repository.dart';

// AFTER
import '../../../core/router/exports.dart';
```

The barrel rules are `flutter-core-architecture`'s; call it for what belongs in `exports.dart`.

### 12. Swap bespoke primitives for the shared ones

Call the Skill tool with `flutter-core-architecture` for the component set, then read
`lib/core/components/` and `lib/core/utils/` to see what this project actually has. Replace each
hand-rolled primitive with the shared equivalent: in-app copy, the primary button, form fields, the
back affordance, snackbars, confirmation dialogs, keyboard dismissal, and navigation from a listener.

Where the project has no equivalent, leave the widget alone and say so. Inventing a shared component
mid-refactor is a second change riding on one that promised no visual difference.

### 13. Trim comments

Strip doc comments that restate the signature and keep the ones explaining a non-obvious decision.
Leave `// FIXTURE_START`, `// FIXTURE_END` and `/// FIXTURE:` markers exactly as they are.

## Completion criteria

A refactor is done when the screen renders identically and the migration is total. Prove both:

- **Identical output.** A golden test captured before the change and passing after it, per
  `flutter-verify` rung 4. Where no golden exists, say the visual match is unverified rather than
  implying you checked.
- **No half-migration.** Every item 1 to 13 either applied or explicitly not applicable. A screen
  left between two patterns is worse than the one you started with, because the next reader cannot
  tell which is current.
- `flutter analyze` clean, and the suite matching the baseline in `docs/agents/project.md`.

List anything you deliberately left on the old pattern, and why.
