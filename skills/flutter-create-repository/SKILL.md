---
name: flutter-create-repository
description: Generate a Repository class for a feature with dependency-injected API client and proper error handling using Either. Use when creating repositories, wrapping API endpoints, or adding data-access classes for a feature.
---

# Create repository

Generate a Repository over one or more API endpoints.

## Required context

- **Feature name** in snake_case
- **Feature PascalCase**
- **API endpoints** (HTTP method + path + request/response types)

## Architecture

When this layer touches barrel imports, Failure types, the network/services layout, or shared helpers, call the Skill tool with `flutter-core-architecture` instead of working from a restated copy of its rules.

## Repository template

```dart
import '../../../core/router/exports.dart';

class {Feature}Repository {
  final ApiClient _apiClient;

  {Feature}Repository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /endpoint → returns null on failure
  Future<{Feature}Data?> fetchData() async {
    try {
      final response = await _apiClient.get('/endpoint');
      if (response.statusCode == 200) {
        return {Feature}Response.fromJson(response.data as Map<String, dynamic>).data;
      }
      return null;
    } catch (e) {
      debugPrint('{Feature}Repository.fetchData error: $e');
      return null;
    }
  }

  /// POST /endpoint → returns Either<Failure, T>
  Future<Either<Failure, {Feature}Data>> create{Feature}({
    required Create{Feature}Request request,
  }) async {
    try {
      final response = await _apiClient.post(
        '/endpoint',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = {Feature}Response.fromJson(response.data as Map<String, dynamic>);
        if (parsed.data == null) {
          return const Left(ServerFailure('Empty response'));
        }
        return Right(parsed.data!);
      }
      return Left(ServerFailure(response.statusMessage ?? 'Unknown error'));
    } catch (e) {
      debugPrint('{Feature}Repository.create{Feature} error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

## Which verb maps to which return type

`flutter-core-architecture` fixes the contract: reads return `Future<T?>`, writes return
`Future<Either<Failure, T>>`. This is how the HTTP verbs land on it.

| Verb | Returns | Because |
|---|---|---|
| GET | `Future<T?>` | The UI treats absence as an empty or error state and needs no reason |
| POST / PUT / PATCH | `Future<Either<Failure, T>>` | A failed write needs a reason to show the user |
| DELETE | `Future<Either<Failure, void>>` | A write with nothing to hand back |

```dart
Future<Either<Failure, void>> deleteItem({required String id}) async {
  try {
    final response = await _apiClient.delete('/items/$id');
    if (response.statusCode == 200 || response.statusCode == 204) {
      return const Right(null);
    }
    return Left(ServerFailure(response.statusMessage ?? 'Delete failed'));
  } catch (e) {
    debugPrint('Repository.deleteItem error: $e');
    return Left(ServerFailure(e.toString()));
  }
}
```

## Rules

The barrel import, the export line, and the `Failure` hierarchy belong to
`flutter-core-architecture`; call it rather than working from a copy. What is specific to this layer:

- Constructor-inject `ApiClient` with a null fallback, so a test can substitute a mock.
- Method names start with a verb: `fetch`, `get`, `create`, `update`, `delete`.
- Multi-argument methods take `required` named parameters.
- Wrap every call in `try/catch`, and log with class and method context through `debugPrint`.
- Every method terminates at the API call. A method that calls itself will recurse until the app
  dies, and it is the one mistake in this layer that gets past review.
- Pull shared response handling into private helpers such as `_handleResponse` or `_parseError`.
- Comments explain a non-obvious branch, such as why a particular status code counts as success.

## Completion criteria

The repository is done when every endpoint in the input has one method, each returns the side of the
contract its verb calls for, and no method can throw past its own `try/catch`. Name any endpoint you
were given that you did not wrap, and why.
