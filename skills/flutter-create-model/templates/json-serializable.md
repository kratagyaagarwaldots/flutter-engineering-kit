# Models: json_serializable

Codegen writes `fromJson` and `toJson` from the field declarations, so the class stays short and a
field can only be missed in one place. The tradeoff is a build step and less visible behaviour at
the boundary, which the annotations below make explicit again.

## Response

```dart
import '../../../core/router/exports.dart';

part 'user_response.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
final class UserResponse extends Equatable {
  final bool success;
  final String? message;
  final UserData? data;

  const UserResponse({
    this.success = false,
    this.message,
    this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@immutable
@JsonSerializable()
final class UserData extends Equatable {
  final String id;
  final String name;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const UserData({
    this.id = '',
    this.name = '',
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  @override
  List<Object?> get props => [id, name, createdAt];
}
```

## Request

```dart
part 'create_user_request.g.dart';

@immutable
@JsonSerializable()
final class CreateUserRequest extends Equatable {
  final String name;
  final String email;

  const CreateUserRequest({required this.name, required this.email});

  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);

  @override
  List<Object?> get props => [name, email];
}
```

## The annotations that matter

| Need | Annotation |
|---|---|
| A JSON key that differs from the field | `@JsonKey(name: 'created_at')` |
| Nested `toJson` actually called | `@JsonSerializable(explicitToJson: true)` on the parent |
| A default when the key is absent | `@JsonKey(defaultValue: '')`, or a constructor default |
| snake_case keys throughout | `@JsonSerializable(fieldRename: FieldRename.snake)` |
| A field that never serializes | `@JsonKey(includeToJson: false)` |
| An unrecognised enum value | `@JsonEnum` plus `@JsonKey(unknownEnumValue: Status.unknown)` |

Set `explicitToJson: true` on any class holding another model. Without it the generated `toJson`
puts the nested object in the map unconverted, and the request goes out with an object where the
server expects a map. That is the defect this stack invites.

## Build

```bash
dart run build_runner build --delete-conflicting-outputs
```

`json_annotation` in `dependencies`; `json_serializable` and `build_runner` in `dev_dependencies`.
The `.g.dart` part file is generated, so it is never hand-edited and a merge conflict in one is
resolved by regenerating.
