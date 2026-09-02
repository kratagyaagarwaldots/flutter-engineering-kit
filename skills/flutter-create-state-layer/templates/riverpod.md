# State layer: Riverpod

One notifier plus its state, in `lib/features/{feature_name}/notifier/`:

```
{feature_name}_notifier.dart
{feature_name}_state.dart
```

Read an existing feature before generating: whether the project uses the code-generated
`@riverpod` annotation or plain `NotifierProvider` is a project decision, and mixing the two in one
repo is the thing to avoid. Both shapes are below.

## `{feature}_state.dart`

The state is a plain immutable value. Actions are methods on the notifier, so there is no event
class to write.

```dart
import '../../../core/router/exports.dart';

enum {Feature}Status { initial, loading, success, failure }

@immutable
final class {Feature}State extends Equatable {
  final {Feature}Status status;
  final String? errorMessage;
  final {Feature}Data? data;

  const {Feature}State({
    this.status = {Feature}Status.initial,
    this.errorMessage,
    this.data,
  });

  {Feature}State copyWith({
    {Feature}Status? status,
    String? errorMessage,
    {Feature}Data? data,
  }) {
    return {Feature}State(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, data];
}
```

## `{feature}_notifier.dart`, generated

```dart
import '../../../core/router/exports.dart';

part '{feature}_notifier.g.dart';

@riverpod
class {Feature}Notifier extends _${Feature}Notifier {
  @override
  {Feature}State build() => const {Feature}State();

  Future<void> started() async {
    state = state.copyWith(status: {Feature}Status.loading);
    try {
      final data = await ref.read({feature}RepositoryProvider).fetchData();
      if (data == null) {
        state = state.copyWith(
          status: {Feature}Status.failure,
          errorMessage: 'Failed to load',
        );
        return;
      }
      state = state.copyWith(status: {Feature}Status.success, data: data);
    } catch (e) {
      debugPrint('{Feature}Notifier.started error: $e');
      state = state.copyWith(
        status: {Feature}Status.failure,
        errorMessage: e.toString(),
      );
    }
  }
}
```

## `{feature}_notifier.dart`, hand-written

```dart
final {feature}NotifierProvider =
    NotifierProvider<{Feature}Notifier, {Feature}State>({Feature}Notifier.new);

class {Feature}Notifier extends Notifier<{Feature}State> {
  @override
  {Feature}State build() => const {Feature}State();

  // same action methods as above
}
```

## Shape rules

- One public method per action. The method name is the action, so it reads as a verb: `started()`,
  `itemRequested(String id)`.
- Reach the repository through `ref.read({feature}RepositoryProvider)`, and define that provider so
  a test overrides it. This is Riverpod's substitute for constructor injection, and it is what makes
  the notifier testable.
- Assign a whole new state rather than mutating it. `state = state.copyWith(...)` is the only write.
- `build()` returns the initial state and performs no async work. Where data must load on creation,
  call the action from the view, or use an `AsyncNotifier` whose `build` returns the future.
- Reach for `AsyncNotifier` and `AsyncValue` where the feature is one load with no other actions;
  the explicit status enum above earns its place once there are several actions that can each fail.

## Dependencies

`flutter_riverpod` (or `hooks_riverpod`), `equatable` and `meta`. The generated shape also needs
`riverpod_annotation` plus `riverpod_generator` and `build_runner` under `dev_dependencies`, and a
`dart run build_runner build --delete-conflicting-outputs` after each change.
