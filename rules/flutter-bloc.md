---
description: BLoC layer patterns - events, states, handlers
paths:
  - "**/bloc/**/*.dart"
---

# BLoC Layer

## File Triad

```
bloc/
├── {feature}_bloc.dart   # owns part directives, imports
├── {feature}_event.dart  # part of {feature}_bloc.dart
└── {feature}_state.dart  # part of {feature}_bloc.dart
```

## Bloc Skeleton

```dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../repo/{feature}_repository.dart';
import '../model/{feature}_response.dart';

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
      emit(state.copyWith(
        status: {Feature}Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
```

## State Skeleton

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

## Event Skeleton

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
```

## Hard Rules

- Constructor-inject repository (null fallback) for testability
- `on<Event>(_handler)` in constructor – never in methods
- Emit `loading` first, then success/failure in `try/catch`
- No `BuildContext`, navigation, or UI calls in BLoC
- Sensitive fields never in `props`; clear them after use

## Nullable copyWith Sentinel

When a field needs to be set explicitly to `null` via copyWith:

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
