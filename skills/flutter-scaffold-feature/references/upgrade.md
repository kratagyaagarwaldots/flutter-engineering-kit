# Upgrade mode

Move a fixture-mode feature onto its real model and API **without changing** the state layer's
actions, statuses and handler signatures, the screen's layout and styling, or which acceptance
criteria the tests cover. Those are what the fixture build already settled and reviewed.

## U.0 – Inputs

Confirm the user has supplied the model spec and the endpoint (method, path, request and response
shapes). Stop and ask for whichever is missing.

## U.1 – Diff the inferred schema against the real one

Read every class marked `/// FIXTURE:` under `model/`, compare it with the real spec, and produce:

| Class | Field | Inferred | Real | Action |
|---|---|---|---|---|
| `Item` | `price` | `double` | `int` (cents) | change type, update every reader |
| `Item` | `imageUrl` | `String` | `String` from `image_url` | keep |
| `Item` | – | – | `currency: String` | **add** |
| `Item` | `isSaved` | `bool` | – | **remove**, check the screen for uses |

Present it and stop for confirmation before editing. This table is where the fixture's guesses meet
the truth, and every row is a decision the user should see.

## U.2 – Models

Call the Skill tool with `flutter-create-model` to regenerate the DTOs from the real spec, apply the
diff, add request DTOs for write endpoints, and remove every `/// FIXTURE:` docstring.

## U.3 – Repository

For every method, keep the signature exactly as it is: the state layer depends on it. Replace the
body between `// FIXTURE_START` and `// FIXTURE_END` with the real API call, then remove the markers.
Add the API client by constructor injection, as `flutter-create-repository` shapes it, and remove the
class docstring's `FIXTURE:` once every body is real.

Where a consumer relied on a fixture quirk, such as data arriving instantly, handle it as a state
change in the state layer, not in the repository.

## U.4 – State layer and screen, only where the schema changed

Walk every handler and widget that reads an added, removed or retyped field. The state layer's
structure does not change, only the field accesses. For a removed field the screen still shows,
ask the user: remove the element, or drive it from local state. An added field with no UI yet stays
in the model.

## U.5 – Retire the handoff README

Remove the "fixture mode" heading and add one line: `Upgraded to the real API on {date}: {method}
{path}.`

## U.6 – Tests

Mock the API client instead of relying on fixture lists, update test data to the real shapes, drop
the `// FIXTURE:` headers, and add tests for behaviour only the real API has, such as its specific
error codes. Call the Skill tool with `flutter-write-tests` for the shapes.

## U.7 – Prove it

Call the Skill tool with `flutter-verify`. The real network path now exists, so the rungs above the
widget level that fixture mode could not reach are available; name the one reached.

Then confirm no marker survived:

```bash
rg --no-heading 'FIXTURE' lib/features/{feature_name}/ test/features/{feature_name}/ \
  || echo 'All fixture markers removed.'
```

Any match is a regression: a fixture still shipping inside a feature that now claims to be real.

## Completion criteria

The marker search prints `All fixture markers removed.`, every acceptance criterion still has a test,
and the report lists each schema change from U.1 with what it touched.
