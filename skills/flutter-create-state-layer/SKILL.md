---
name: flutter-create-state-layer
description: Generate a feature's state layer in whichever state management the project uses: the seam holding its behaviour, its actions, and the state the UI reads back. Use when adding state management to a feature, wiring user actions to a repository, or creating a bloc, notifier or controller.
---

# Create state layer

Generate the layer holding a feature's behaviour: what can happen to it, what it does in response,
and what the view reads back.

## Resolve the shape first

Call the Skill tool with `project-conventions` for the Logic seam and Dependency injection rows,
then read the matching template. The procedure and the rules below are the same for every stack;
only the shape differs.

| Logic seam | Template |
|---|---|
| `Bloc<Event, State>` | [templates/bloc.md](templates/bloc.md) |
| `Notifier` / `AsyncNotifier` | [templates/riverpod.md](templates/riverpod.md) |
| `ChangeNotifier` | [templates/provider.md](templates/provider.md) |

Where the project uses a seam no template covers, read one existing feature and follow what is
there. A template is a starting shape, not a licence to reshape a codebase that already decided.

## Required context

- **Feature name** in snake_case, and its PascalCase form
- **The actions** the feature responds to, as a settled list: user gestures and system triggers
- **Repository method signatures**, so the calls wire correctly

Where the actions are still a guess, call the Skill tool with `grill` before generating. A state
layer built on an invented action list gets rewritten when the real one arrives, and rewriting it
costs more than the interview would have.

## Rules that hold in every stack

- **One named action per thing that can happen.** A single "refresh everything" action hides which
  part failed, and the view then cannot tell the user what to retry.
- **Constructor-inject the repository with a fallback**, so a test substitutes a mock without a
  service locator. Riverpod's equivalent is a provider override; the template says which.
- **Model status as a value the view can switch on**, and give every path out of a handler a
  terminal status. A path that exits without one leaves the UI spinning. This is the most common
  defect in this layer, in every stack, so trace each early return before calling the handler done.
- **Keep `BuildContext`, navigation and dialogs out.** Emit state and let the view react, so the
  behaviour stays testable without pumping a widget.
- **Keep passwords, raw tokens and payment secrets out of equality and `toString`**, so they never
  reach a log or a state dump.
- Comments explain why a handler does something surprising. The signature already says what.

Barrel imports, `Failure` types, and the snackbar and navigation helpers belong to
`flutter-core-architecture`; call it rather than working from a copy.

## Completion criteria

Every action named in the requirements has a handler, every handler reaches both a success and a
failure state, and `flutter analyze` is clean.

Then say which acceptance criteria the status values now cover and which are left to the view. The
split is where a feature quietly loses a requirement, so naming it is what stops the gap being
assumed closed.
