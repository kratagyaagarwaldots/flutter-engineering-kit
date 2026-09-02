# Screen wiring: Provider / ChangeNotifier

The page creates the controller, the view watches it. `ChangeNotifierProvider` disposes the
controller for you, which is why the controller is created here rather than passed in.

```dart
import '../../../core/router/exports.dart';

class {Feature}Page extends StatelessWidget {
  static const String routeName = '/{feature}';

  const {Feature}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<{Feature}Controller>(
      create: (_) => {Feature}Controller()..started(),
      child: const _{Feature}View(),
    );
  }
}

class _{Feature}View extends StatelessWidget {
  const _{Feature}View();

  @override
  Widget build(BuildContext context) {
    final {Feature}Controller controller = context.watch<{Feature}Controller>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.{feature}Title)),
      body: switch (controller.status) {
        {Feature}Status.loading =>
          const Center(child: CircularProgressIndicator()),
        {Feature}Status.success => _{Feature}Content(data: controller.data!),
        {Feature}Status.failure => Center(
            child: TextWidget(controller.errorMessage ?? AppStrings.genericError),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _{Feature}Content extends StatelessWidget {
  final {Feature}Data data;

  const _{Feature}Content({required this.data});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

## The side-effect problem, and the fix

`ChangeNotifier` has no listener callback, so there is nowhere natural to show a snackbar. Watching
in `build` and showing one there fires on every rebuild.

The shape that works is a `StatefulWidget` view holding the previous value, so the snackbar fires
on the transition rather than on the state:

```dart
class _{Feature}ViewState extends State<_{Feature}View> {
  {Feature}Status? _previous;

  @override
  Widget build(BuildContext context) {
    final {Feature}Controller controller = context.watch<{Feature}Controller>();

    if (controller.status != _previous) {
      _previous = controller.status;
      if (controller.status == {Feature}Status.failure) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showErrorSnackBar(
            context,
            controller.errorMessage ?? AppStrings.genericError,
          );
        });
      }
    }
    // ...
  }
}
```

The `addPostFrameCallback` is what keeps it legal: showing a snackbar during a build throws, so the
call waits for the frame to finish.

## Which to reach for

| API | Use it when |
|---|---|
| `context.watch<C>()` | The widget renders controller state and should rebuild |
| `Selector<C, T>` | One field drives the rebuild |
| `context.read<C>()` | Dispatching an action from a callback |
| `Consumer<C>` | Only a subtree should rebuild, not the whole view |
