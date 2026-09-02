# Models: hand-written fromJson / toJson

No codegen, no build step. Every cast is visible, which is the point: the boundary is where a shape
change should fail, and here you can read exactly what happens to a missing or wrong-typed field.

## Response

```dart
import '../../../core/router/exports.dart';

@immutable
final class UserResponse extends Equatable {
  final bool success;
  final String? message;
  final UserData? data;

  const UserResponse({
    this.success = false,
    this.message,
    this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? UserData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };

  @override
  List<Object?> get props => [success, message, data];
}

@immutable
final class UserData extends Equatable {
  final String id;
  final String name;
  final String email;

  const UserData({
    this.id = '',
    this.name = '',
    this.email = '',
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };

  @override
  List<Object?> get props => [id, name, email];
}
```

## Request

```dart
@immutable
final class CreateUserRequest extends Equatable {
  final String name;
  final String email;

  const CreateUserRequest({
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };

  @override
  List<Object?> get props => [name, email];
}
```

## The three shapes worth memorising

Arrays:

```dart
items: (json['items'] as List? ?? [])
    .map((e) => Item.fromJson(e as Map<String, dynamic>))
    .toList(),
```

Dates:

```dart
createdAt: json['created_at'] != null
    ? DateTime.parse(json['created_at'] as String)
    : null,

'created_at': createdAt?.toIso8601String(),
```

Enums, with a fallback case so an unrecognised value cannot throw:

```dart
status: OrderStatus.values.firstWhere(
  (e) => e.name == (json['status'] as String?),
  orElse: () => OrderStatus.unknown,
),

'status': status.name,
```
