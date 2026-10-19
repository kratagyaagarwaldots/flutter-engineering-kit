# Debugging tools

The answer to the `conventions` aspect "debugging tools" for a Flutter component. The method is the
same in any stack: a loop that goes red, ranked hypotheses, one variable at a time. This file says
what runs each rung of that loop here, and which causes to put on the list.

## The loop, cheapest first

The Logic seam and Logic test tool rows of the Architecture table say what the first rung drives
and with what; resolve them before writing it.

| Rung | Here |
|---|---|
| State-layer test | The Logic test tool driving the seam's actions that produce the wrong state |
| UI test | A widget test: `pumpWidget` the screen inside the Widget-test wrapper, assert the symptom |
| Screenshot comparison | A golden test, `matchesGoldenFile`; establish the baseline with `flutter test --update-goldens` |
| Data-access test | A repository test with a mocked Supabase client replaying the saved payload |
| Model test | The literal JSON from the failing request fed into `fromJson` |
| Integration test | `flutter test integration_test/` on a simulator or emulator |
| Profiler | `flutter run --profile` plus DevTools: the timeline, the widget rebuild counter, the memory view |
| Physical device | Permissions, push delivery, background state, the camera |

`debugPrintRebuildDirtyWidgets = true` in `main` narrows a rebuild storm fast.

## Instruments

- One global observer on the logic seam, where the state library offers one (`BlocObserver`,
  `ProviderObserver`), logs every transition and beats ten `debugPrint` calls.
- `debugPrint` rather than `print` for tagged probes, so long lines are not dropped on Android.
- For rebuild and jank questions the DevTools timeline is the instrument, not logs.

## Common causes worth having on the list

- A `fromJson` default masking a missing field.
- Stale state in the logic seam after a route pop.
- A widget rebuilding on an unrelated state change.
- A `copyWith` that cannot express null.
- An async gap after which `context` is no longer mounted; check `context.mounted`.
- A listener firing on a state that only partly changed.

## Clean up

`flutter analyze` clean and `flutter test` matching the baseline in `docs/agents/project.md`.
