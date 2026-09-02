---
description: UI patterns - widgets, screens, navigation, styling
paths:
  - "lib/**/*.dart"
---

# UI Patterns

## Widget Architecture

- Break complex `build` methods into **private `StatelessWidget` classes** (underscore-prefixed)
- Never use widget-helper methods that return `Widget`
- Use `BlocBuilder` for state-driven UI, `BlocListener` for side-effects, `BlocConsumer` when both needed
- Use `context.read<Bloc>()` for dispatching events

```dart
// BAD - widget helper method
Widget _buildHeader() => Container(...);

// GOOD - private widget class
class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) => Container(...);
}
```

## Screen Structure

```dart
class FeaturePage extends StatelessWidget {
  static const String routeName = '/feature';

  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeatureBloc()..add(const FeatureStarted()),
      child: const _FeatureView(),
    );
  }
}

class _FeatureView extends StatelessWidget {
  const _FeatureView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeatureBloc, FeatureState>(
      listener: (context, state) {
        // navigation, snackbars, dialogs
      },
      builder: (context, state) => Scaffold(...),
    );
  }
}
```

## Styling

- Size from `AppDimensions` in the project's sizing strategy, not a raw number at the callsite
- Leave font sizes unscaled so the OS text-scale setting reaches the text
- Switch the layout at a `LayoutBuilder` breakpoint rather than scaling one layout to every width
- Never inline colors, strings, asset paths – use `AppColors`, `AppStrings`, `AppAssets`
- No `.withOpacity()` – encode alpha in the hex constant (e.g. `0x80FFFFFF`)

For shared widgets, theming, dialogs/mixins, snackbars, services, and `lib/core` layout, follow `.claude/skills/flutter-core-architecture/SKILL.md`.

## Imports

Every UI file imports the single barrel:

```dart
import '../../../core/router/exports.dart';
```

No direct package imports, no per-file project imports. Add new packages or
project files to `lib/core/router/exports.dart`.

## Common Widgets (prefer over raw Material)

| Use this | Instead of |
|---|---|
| `TextWidget(text: '...')` | `Text('...')` for in-app text |
| `CustomButton`, or the project's loading-aware variant | `ElevatedButton` / `MaterialButton` for primary CTAs |
| `CommonTextField` (or a feature wrapper around it) | bare `TextFormField` |
| `BackButtonWidget` | manual `IconButton(icon: Icons.arrow_back)` |
| `showSuccessSnackBar` / `showErrorSnackBar` | `ScaffoldMessenger.of(context).showSnackBar(...)` |
| `ConfirmationDialogMixin` / `showIosAlertDialog` | bespoke `showDialog` shells |
| `ApplicationUtils.hideKeyboard(context)` | `FocusScope.of(context).unfocus()` |
| `NavigationService.instance.push(Named/Replacement)` | `Navigator.of(context).push(Named/Replacement)` in BLoC listeners and services |

Feature-specific styled variants (e.g. `LoginTextField` for the dark theme)
are allowed when they encapsulate a fixed visual spec; otherwise reuse the
generic widget directly.

## Navigation

- Route IDs as `static const String routeName` on the page class (or referenced from `AppRoutes`)
- Pass typed argument objects, never raw `Map`s
- Use `NavigationService.instance` for programmatic navigation (BLoC listeners, services)
- After `await`, guard with `if (!context.mounted) return;`

## State-Driven Rendering

```dart
return switch (state.status) {
  FeatureStatus.loading => const Center(child: CircularProgressIndicator()),
  FeatureStatus.failure => Center(child: Text(state.errorMessage ?? 'Error')),
  FeatureStatus.success => _Content(data: state.data!),
  _ => const SizedBox.shrink(),
};
```
