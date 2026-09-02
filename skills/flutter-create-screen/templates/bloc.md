# Screen wiring: flutter_bloc

The page provides, a private view consumes, and content is its own widget. The split matters: the
page owns the lifetime of the state object, the view owns rebuilding, and neither is the widget
that renders data.

```dart
import '../../../core/router/exports.dart';

class {Feature}Page extends StatelessWidget {
  static const String routeName = '/{feature}';

  const {Feature}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => {Feature}Bloc()..add(const {Feature}Started()),
      child: const _{Feature}View(),
    );
  }
}

class _{Feature}View extends StatelessWidget {
  const _{Feature}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.{feature}Title)),
      body: BlocConsumer<{Feature}Bloc, {Feature}State>(
        listener: (context, state) {
          if (state.status == {Feature}Status.failure) {
            showErrorSnackBar(context, state.errorMessage ?? AppStrings.genericError);
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            {Feature}Status.loading =>
              const Center(child: CircularProgressIndicator()),
            {Feature}Status.success =>
              _{Feature}Content(data: state.data!),
            {Feature}Status.failure => Center(
                child: TextWidget(state.errorMessage ?? AppStrings.genericError),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _{Feature}Content extends StatelessWidget {
  final {Feature}Data data;

  const _{Feature}Content({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // ...
        ],
      ),
    );
  }
}
```

## Which of the three to reach for

| Widget | Use it when |
|---|---|
| `BlocBuilder` | The subtree only renders state |
| `BlocListener` | The subtree only reacts (snackbar, navigation, dialog) |
| `BlocConsumer` | Both, at the same node |
| `context.select` | One field drives the rebuild and the rest of the state should not |

Dispatch with `context.read<{Feature}Bloc>().add(...)` from a callback. Reading with `watch` inside
a callback rebuilds on every state change for no benefit.
