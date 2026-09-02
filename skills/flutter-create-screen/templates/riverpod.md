# Screen wiring: Riverpod

There is no provider widget around the page: `ProviderScope` sits once at the app root, and the
page reads what it needs. The page is a `ConsumerWidget`, and content stays a plain
`StatelessWidget` so it can be pumped in a test without a scope.

```dart
import '../../../core/router/exports.dart';

class {Feature}Page extends ConsumerStatefulWidget {
  static const String routeName = '/{feature}';

  const {Feature}Page({super.key});

  @override
  ConsumerState<{Feature}Page> createState() => _{Feature}PageState();
}

class _{Feature}PageState extends ConsumerState<{Feature}Page> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read({feature}NotifierProvider.notifier).started(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen({feature}NotifierProvider, (previous, next) {
      if (next.status == {Feature}Status.failure) {
        showErrorSnackBar(context, next.errorMessage ?? AppStrings.genericError);
      }
    });

    final {Feature}State state = ref.watch({feature}NotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.{feature}Title)),
      body: switch (state.status) {
        {Feature}Status.loading =>
          const Center(child: CircularProgressIndicator()),
        {Feature}Status.success => _{Feature}Content(data: state.data!),
        {Feature}Status.failure => Center(
            child: TextWidget(state.errorMessage ?? AppStrings.genericError),
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

## Two rules that prevent the usual defects

**Side effects go in `ref.listen`, never in `build`.** A snackbar shown from `build` fires again on
every rebuild, including the one it causes itself.

**Never call a notifier method directly inside `build`.** Kicking off a load needs
`initState` with a `Future.microtask`, as above, or an `AsyncNotifier` whose `build` returns the
future. Calling it from `build` mutates state during a build and throws.

## Which to reach for

| API | Use it when |
|---|---|
| `ref.watch(p)` | The widget renders the value and should rebuild |
| `ref.watch(p.select((s) => s.field))` | One field drives the rebuild |
| `ref.read(p.notifier)` | Dispatching an action from a callback |
| `ref.listen(p, ...)` | Reacting with a snackbar, dialog or navigation |

Where the feature is one load with no other actions, an `AsyncNotifier` with
`state.when(data:, loading:, error:)` replaces the status enum and the `switch` above.
