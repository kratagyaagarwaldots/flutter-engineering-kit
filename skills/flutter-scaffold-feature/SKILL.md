---
name: flutter-scaffold-feature
description: Scaffold a complete feature folder (model, repository, state layer, view, widgets, tests) from acceptance criteria, in one of three modes: real (a model and endpoint exist), fixture (build the screen first, the API comes later) or upgrade (move a fixture-mode feature onto its real API). Use when /fk-build is given a new feature or screen, or a fixture-mode feature whose API now exists.
---

# Scaffold a feature

Build a whole feature folder, every layer, from what is known about it. What is known decides the
mode; the phases are the same in every mode except where the data comes from.

## Pick the mode

Read `lib/features/{feature_name}/README.md` first, if the folder exists.

| What you have | Mode |
|---|---|
| The README says "fixture mode", and a model spec and endpoint are now available | **Upgrade.** Read [references/upgrade.md](references/upgrade.md) and follow it instead of the phases below. |
| Acceptance criteria, a model spec and an API endpoint | **Real** |
| Acceptance criteria, and the model and API come later | **Fixture** |

Independently of the mode, name the **design source**: a Figma node read through the Figma MCP
server (`get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`), a pasted
screenshot with CSS, or none. With no design source, call the Skill tool with `flutter-design` in
Phase 1 to settle hierarchy and the states before anything is drawn.

Say the mode and the design source in one line before Phase 0. Work through the phases in order,
and finish each before starting the next.

## Phase 0 – Inputs

Confirm the inputs the mode needs and stop to ask for anything missing; never invent one.

- Every mode: numbered acceptance criteria, and the feature name in snake_case and PascalCase.
- Real: the model spec (fields and types) and the endpoint (method, path, request and response).
- Fixture: confirmation from the user that the model and endpoint really do arrive later.

Then judge whether the criteria are settled. They are not when any names only the happy path,
leaves loading, empty or failure behaviour unstated, or arrived as client prose. Call the Skill tool
with `grill` and use the list it produces. Scaffolding on thin criteria is how a feature reaches
Phase 9 and then needs rebuilding.

## Phase 0.5 – Reuse before you add

Call the Skill tool with `flutter-core-architecture`, then the Skill tool with `project-conventions`
for the stack every later phase generates in. Report which existing components, utils and tokens
this feature uses, and every new `App*` constant it needs because no existing one fits.

## Phase 1 – Plan, no code yet

Produce the planning tables in [references/planning-tables.md](references/planning-tables.md): the
feature design table in every mode, the API contract and schema field map in real mode, the inferred
schema in fixture mode, and the design token map and layout plan when there is a design source.

**Stop and present them.** Every later phase reads these tables, so a mistake caught here costs a
sentence and one caught in Phase 6 costs a layer.

## Phase 2 – Constants and assets

Add every new colour, text style, string, asset and dimension from Phase 1 to its `App*` family in
`lib/core/constants/`, register new asset paths in `pubspec.yaml`, and add an export line to the
barrel for every file the later phases create. Feature code refers to a constant for every value.

In fixture mode, an image the API will serve later uses `https://picsum.photos/seed/{id}/200` or a
local placeholder asset, so nothing points at a CDN that can change under the screen.

## Phase 3 – Model

- **Real:** call the Skill tool with `flutter-create-model`, with the schema field map.
- **Fixture:** build the placeholder model from the inferred schema, marked as
  [references/fixture.md](references/fixture.md) describes.

## Phase 4 – Repository

- **Real:** call the Skill tool with `flutter-create-repository`, with the API contract table. One
  method per row.
- **Fixture:** build the fixture repository as [references/fixture.md](references/fixture.md)
  describes. Its signatures are the contract the real one keeps, so the upgrade is a body swap.

## Phase 5 – State layer

Call the Skill tool with `flutter-create-state-layer`, with the actions and statuses from the feature
design table and the repository's signatures. The state layer never knows whether it calls a
fixture: that is what lets the upgrade leave it untouched.

## Phase 6 – View and widgets

Call the Skill tool with `flutter-create-screen`, with the layout plan and the design token map. It
owns the page shape for this stack. Every sub-tree the layout plan marks as reusable becomes a
widget in `widget/`.

With a design source, compare the built screen against the `get_screenshot` render (or the pasted
screenshot) and say what differs before moving on.

## Phase 7 – Route

Give the page a `routeName` and register it in `lib/core/router/`. Arguments travel as a typed
arguments class, never a raw `Map`. For deep links, call the Skill tool with `flutter-navigation`.

## Phase 8 – Tests

Call the Skill tool with `flutter-write-tests`: the state layer at least happy, empty and failure
per handler, the repository's success and error paths, and the page rendered under each status. In
fixture mode, every test file starts with the `// FIXTURE:` header from
[references/fixture.md](references/fixture.md).

## Phase 9 – Criteria coverage

Walk every acceptance criterion:

| AC # | Implemented in | Test |
|---|---|---|
| 1 | the handler and the widget that show it | the test's name |

An empty cell is unfinished work. Finish it before Phase 10.

## Phase 10 – Prove it

Call the Skill tool with `flutter-verify` and report the rung reached for each criterion. A
fixture-mode feature is provable to the widget rung and no further, since there is no real network
path yet: say so, and name every criterion whose proof waits for the API.

Then confirm each new file imports only the barrel and is exported from it, and that snackbars,
dialogs and navigation use the shared helpers `flutter-core-architecture` lists.

## Phase 11 – Handoff, fixture mode only

Write the feature's `README.md` from the template in
[references/fixture.md](references/fixture.md). It is what upgrade mode reads to find the swap-in
points. Without it the feature can only be rebuilt, not upgraded.

## Delegating, optional

For a large feature, hand independent phases to sub-agents once the Phase 1 tables have stopped
moving. A sub-agent given a table that is still changing builds against a shape that changes under
it. Each brief names one skill to call and carries the table it works from.

| Phase | Agent | Hand it |
|---|---|---|
| 3 and 4, real mode | `flutter-repo-engineer` | the schema field map and the API contract |
| 5 | `flutter-state-engineer` | the feature design table and the repository signatures |
| 6 | `flutter-ui-engineer` | the design token map and the layout plan |
| 8 | `flutter-test-engineer` | the feature design table and the acceptance criteria |

In fixture mode, Phases 3 and 4 stay with you: the fixture model and repository are this skill's own
output.

## Completion criteria

Every row of the feature design table has code behind it and every acceptance criterion has a test
naming it. Report:

- **Criteria covered**, each against the handler, status and test that implement it.
- **What you inferred** rather than were given: fixture schema fields, repository signatures, design
  decisions made without a design source. These are what the real API or design contradicts first.
- **Criteria not proven**, and the rung each one needs.
