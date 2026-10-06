# Fixture mode

A fixture-mode feature runs on in-memory data so its screen can be built, reviewed and tested
before the model and API exist. Everything here exists so that the later upgrade is a **body swap**
rather than a rewrite: the signatures, the markers and the handoff README are what upgrade mode
looks for.

## The markers

The marker vocabulary belongs to `flutter-core-architecture`. In a fixture-mode feature:

- `/// FIXTURE:` opens the docstring of every placeholder model class and of the repository class.
- `// FIXTURE_START` and `// FIXTURE_END` wrap every fixture method body. These are the swap-in
  points.
- `// FIXTURE:` heads every test file that runs against the fixture repository.

An unmarked placeholder is a fixture that ships as a feature, because nothing will find it. Use the
markers in place of a `TODO`.

## Placeholder model (Phase 3)

Generate it from the inferred schema with the same mechanism the real model will use: call the
Skill tool with `flutter-create-model`, so `fromJson` and `toJson` already exist and the contract
stays stable when the API lands. Then open each class's docstring with:

```dart
/// FIXTURE: shape inferred from the design and the acceptance criteria.
/// Replaced in upgrade mode once the API contract is defined.
```

## Fixture repository (Phase 4)

```dart
import '../../../core/router/exports.dart';

/// FIXTURE: returns in-memory data. The method signatures are the contract the
/// real repository keeps; upgrade mode swaps the bodies and nothing else.
class {Feature}Repository {
  {Feature}Repository();

  /// Real version: GET /items
  Future<List<Item>?> fetchItems() async {
    // FIXTURE_START
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      Item(id: '1', title: 'First item', imageUrl: 'https://picsum.photos/seed/1/200'),
      Item(id: '2', title: 'Second item', imageUrl: 'https://picsum.photos/seed/2/200'),
      Item(id: '3', title: 'Third item', imageUrl: 'https://picsum.photos/seed/3/200'),
    ];
    // FIXTURE_END
  }

  /// Real version: POST /items
  Future<Either<Failure, Item>> createItem({required CreateItemRequest request}) async {
    // FIXTURE_START
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Right(Item(id: DateTime.now().millisecondsSinceEpoch.toString(), title: request.title));
    // FIXTURE_END
  }
}
```

The rules that make the swap work:

- **Signatures are the future contract.** Reads return `Future<T?>`, writes
  `Future<Either<Failure, T>>`, exactly as the real repository will (`flutter-create-repository`).
- **Every body returns fixture data.** A real network call here makes the screen depend on a backend
  the feature is defined as not having.
- **A short delay** keeps the loading state visible, so it gets built and tested.
- **No API client yet.** Upgrade mode adds the injection.
- **Fixture data includes an empty case and a failure case** wherever the criteria name one, so the
  screen's other states can be reached and tested now.

## Handoff README (Phase 11)

Write `lib/features/{feature_name}/README.md`:

```markdown
# {Feature} – fixture mode

Built screen-first, before its model and API existed. It runs on a fixture repository.

## Swap-in points

| File | Marker | Becomes |
|---|---|---|
| `repo/{feature}_repository.dart` | class `/// FIXTURE:` | the real, API-client-backed repository |
| `repo/{feature}_repository.dart` | `// FIXTURE_START` … `// FIXTURE_END` | a real API call |
| `model/{feature}_response.dart` | class `/// FIXTURE:` | the real DTOs |
| `test/features/{feature}/` | `// FIXTURE:` file header | tests against the real models |

## Upgrading

When the model spec and the endpoint exist, run `/fk-build` on this feature with both. It reads
this file, diffs the inferred schema against the real one, swaps every fixture body, and keeps the
acceptance criteria, the design and the state layer's actions unchanged.
```

The phrase "fixture mode" in the heading is what upgrade mode and the kit's commit hook look for.
Keep it until the upgrade removes it.
