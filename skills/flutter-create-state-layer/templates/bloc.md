# State layer: flutter_bloc

The triad, in `lib/features/{feature_name}/bloc/`:

```
{feature_name}_bloc.dart
{feature_name}_event.dart
{feature_name}_state.dart
```

## `{feature}_bloc.dart`

```dart
import '../../../core/router/exports.dart';

part '{feature}_event.dart';
part '{feature}_state.dart';

class {Feature}Bloc extends Bloc<{Feature}Event, {Feature}State> {
  final {Feature}Repository _repository;

  {Feature}Bloc({{Feature}Repository? repository})
      : _repository = repository ?? {Feature}Repository(),
        super(const {Feature}State()) {
    on<{Feature}Started>(_onStarted);
  }

  FutureOr<void> _onStarted(
    {Feature}Started event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(state.copyWith(status: {Feature}Status.loading));
    try {
      final data = await _repository.fetchData();
      if (data == null) {
        emit(state.copyWith(
          status: {Feature}Status.failure,
          errorMessage: 'Failed to load',
        ));
        return;
      }
      emit(state.copyWith(
        status: {Feature}Status.success,
        data: data,
      ));
    } catch (e) {
      debugPrint('{Feature}Bloc._onStarted error: $e');
      emit(state.copyWith(
        status: {Feature}Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
```

## `{feature}_event.dart`

```dart
part of '{feature}_bloc.dart';

@immutable
sealed class {Feature}Event extends Equatable {
  const {Feature}Event();

  @override
  List<Object?> get props => [];
}

@immutable
final class {Feature}Started extends {Feature}Event {
  const {Feature}Started();
}

@immutable
final class {Feature}ItemRequested extends {Feature}Event {
  final String id;

  const {Feature}ItemRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
```

## `{feature}_state.dart`

```dart
part of '{feature}_bloc.dart';

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

## Shape rules

- One `on<Event>(_handler)` registration per event, in the constructor.
- Handler signature: `FutureOr<void> _on{Event}({Event} event, Emitter<State> emit) async`.
- Each event is `@immutable final class <Verb><Noun> extends {Feature}Event`, with `required` named
  params.
- Every field appears in `props`, except the secrets the skill's rules exclude.
- Part files carry `part of` and no imports; they inherit the bloc file's.

## The nullable copyWith sentinel

For a field that must be explicitly settable back to `null`:

```dart
class _Undefined { const _Undefined(); }

{Feature}State copyWith({
  Object? errorMessage = const _Undefined(),
}) {
  return {Feature}State(
    errorMessage: errorMessage is _Undefined
        ? this.errorMessage
        : errorMessage as String?,
  );
}
```

## Dependencies

`flutter_bloc`, `equatable`, `meta` and `dartz` reach this layer through the barrel already. Read
`exports.dart` to confirm before assuming a package is available; a new one goes in `pubspec.yaml`
and the barrel both.
