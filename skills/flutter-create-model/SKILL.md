---
name: flutter-create-model
description: Generate request and response DTO classes for a feature, immutable and with JSON serialization in whichever mechanism the project uses. Use when creating data models, DTOs, API request/response classes, or mapping a JSON shape to Dart.
---

# Create model

Turn a JSON shape into Dart types, so a shape change fails at the boundary rather than several
frames later in a widget.

## Resolve the mechanism first

Call the Skill tool with `project-conventions` for the Serialization row, then read the matching
template. The field mapping and the rules below hold either way; only the mechanism differs.

| Serialization | Template |
|---|---|
| Hand-written `fromJson` | [templates/hand-written.md](templates/hand-written.md) |
| `json_serializable` | [templates/json-serializable.md](templates/json-serializable.md) |
| `freezed` | [templates/freezed.md](templates/freezed.md) |

Follow what the project already does rather than introducing a second mechanism. Two serialization
styles in one codebase is worse than either, because a reader can no longer tell from a class
whether editing a field requires a build step.

## Required context

- **Model name** in PascalCase
- **Target folder**, e.g. `lib/features/user/model/`
- **Field definitions**, from a model spec or a real JSON sample

Prefer a real response sample over a written spec. A spec says what the API should return; a sample
says what it does, including the nulls the spec omitted.

## API type to Dart type

| API type | Dart type | Default |
|----------|-----------|---------|
| `string` | `String` | `''` |
| `string` (date-time) | `DateTime` | `null` |
| `integer` | `int` | `0` |
| `number` / `double` | `double` | `0.0` |
| `boolean` | `bool` | `false` |
| `array<T>` | `List<T>` | `[]` |
| `nullable: true` | append `?` | `null` |

A default is what the app shows when the field is absent, so pick it for the UI rather than for the
type. Where a missing value must be distinguishable from an empty one, keep the field nullable
instead of defaulting it.

## Rules

The barrel import and the export line belong to `flutter-core-architecture`; call it rather than
working from a copy. What is specific to this layer:

- Every field is immutable, and equality covers every field.
- Cast each JSON value to a concrete type at the boundary. An unchecked value moves a parse failure
  into a random later frame, where it reads as a UI bug.
- Nested objects become their own class in the same file.
- Request models take `required` named params, so a caller cannot omit one.
- Keep passwords, raw tokens and payment secrets out of `toString` and equality, so they never reach
  a log.
- Comments explain a non-obvious decision, such as why a field stays out of equality. The field list
  already says the shape.

## Naming

| Type | Convention | Example |
|------|------------|---------|
| Request | `{Action}{Entity}Request` | `CreateOrderRequest` |
| Response | `{Entity}Response` | `OrderResponse` |
| Nested data | `{Entity}Data` / `{Entity}` | `OrderData` |

## Completion criteria

Every field in the source spec or sample appears with a type, every nullable field is marked, and a
round trip through `fromJson` and `toJson` preserves the sample. Where the mechanism generates code,
`dart run build_runner build --delete-conflicting-outputs` completes and `flutter analyze` is clean.

Name any field in the sample you deliberately left out, and why. A silently dropped field is
indistinguishable from one nobody noticed.
