---
description: DTO model patterns - request/response models with JSON serialization
paths:
  - "**/model/**/*.dart"
---

# Models (DTOs)

## Structure

```dart
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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
```

## Rules

- `@immutable` on every class; every field `final`
- Implement `fromJson` factory and `toJson()` method
- Null-safe defaults: `?? ''`, `?? 0`, `?? false`, `?? []`
- **Never use `dynamic`** – cast JSON values explicitly
- Nested objects as separate `@immutable final class` in same file
- Extend `Equatable` for value equality

## Naming

| Type | Convention | Example |
|------|------------|---------|
| Request | `{Action}{Entity}Request` | `CreateUserRequest` |
| Response | `{Entity}Response` | `UserResponse` |
| Nested data | `{Entity}Data` / `{Entity}` | `UserData` |

## JSON Arrays

```dart
items: (json['items'] as List? ?? [])
    .map((e) => Item.fromJson(e as Map<String, dynamic>))
    .toList(),
```

## DateTime

```dart
createdAt: json['created_at'] != null
    ? DateTime.parse(json['created_at'] as String)
    : null,

'created_at': createdAt?.toIso8601String(),
```
