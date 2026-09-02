# Models: freezed

Codegen writes equality, `copyWith`, `toString` and the JSON pair. The class becomes a declaration
of fields and nothing else, and `Equatable` is unnecessary because freezed generates equality
itself.

## Response

```dart
import '../../../core/router/exports.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    @Default(false) bool success,
    String? message,
    UserData? data,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}

@freezed
class UserData with _$UserData {
  const factory UserData({
    @Default('') String id,
    @Default('') String name,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
```

## Request

```dart
@freezed
class CreateUserRequest with _$CreateUserRequest {
  const factory CreateUserRequest({
    required String name,
    required String email,
  }) = _CreateUserRequest;

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);
}
```

## Where freezed earns its keep

A union, which is the one thing the other two templates cannot express cleanly. Use it where a
response is genuinely one of several shapes, and the compiler should force every case to be handled:

```dart
@freezed
sealed class PaymentResult with _$PaymentResult {
  const factory PaymentResult.approved(String reference) = Approved;
  const factory PaymentResult.declined(String reason) = Declined;
  const factory PaymentResult.pending(Duration retryAfter) = Pending;
}
```

Consumed with an exhaustive `switch`, so adding a fourth case turns every incomplete handler into a
compile error rather than a silent fallthrough. That is the property worth adopting freezed for; a
plain DTO does not need it.

## Two things to keep straight

- `@Default(...)` replaces a constructor default, and a field with neither a default nor `?` nor
  `required` will not compile.
- Both part files are declared: `.freezed.dart` and `.g.dart`. Omitting the second is the usual
  cause of a missing `_$...FromJson`.

## Build

```bash
dart run build_runner build --delete-conflicting-outputs
```

`freezed_annotation` and `json_annotation` in `dependencies`; `freezed`, `json_serializable` and
`build_runner` in `dev_dependencies`. Both generated files are never hand-edited, and a conflict in
one is resolved by regenerating.
