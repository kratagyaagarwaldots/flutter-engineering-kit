---
name: flutter-create-feature
description: Scaffold a complete feature folder (bloc + model + repo + view + widget) from requirements alone, without API spec. Use when creating a new feature module or building a feature from acceptance criteria when API contract is not yet known.
---

# Create feature

Generate a complete feature folder from acceptance criteria.

This skill is for the design-incomplete case. When the feature has a defined API endpoint **and** a
Figma design, tell the user to run `/flutter-create-feature-e2e` instead, which is user-invoked and
reachable only by them typing it.

## Architecture

Before creating UI, constants, dialogs, or shared helpers, call the Skill tool with `flutter-core-architecture`. Reuse what it lists; do not invent parallel dialogs, text widgets, or theme constants.

## Required context

- **Feature name** in snake_case (e.g. `user_profile`)
- **Feature PascalCase**
- **Acceptance criteria** – what the feature must do

## Requirements to implementation

| Concern | Derived from |
|---------|--------------|
| **Events** | One per user action or system trigger |
| **State variants** | One enum value per observable UI state |
| **Repository methods** | One per data exchange |
| **Edge cases** | Every "when X fails" → failure status + user feedback |
| **Navigation** | Each "navigates to" → a call in the listener the seam provides |
| **Validation** | Each "must / required" → guard in handler |

## Folder structure

```
lib/features/{feature_name}/
├── bloc/
│   ├── {feature}_bloc.dart
│   ├── {feature}_event.dart
│   └── {feature}_state.dart
├── model/
│   ├── {feature}_request.dart
│   └── {feature}_response.dart
├── repo/
│   └── {feature}_repository.dart
├── view/
│   └── {feature}_page.dart
└── widget/
    └── {feature}_widget.dart
```

## Build the layers

Each layer has its own skill, and each owns its own rules. Work in this order, one Skill tool call
per layer, so the shape of one layer is settled before the next depends on it.

1. Call the Skill tool with `flutter-create-model` for the request and response DTOs.
2. Call the Skill tool with `flutter-create-repository` for the data access.
3. Call the Skill tool with `flutter-create-state-layer` for the triad.
4. Call the Skill tool with `flutter-create-screen` for the view and widgets.
5. Call the Skill tool with `flutter-write-tests` for the bloc coverage.

Without an API contract you are inferring the repository's method signatures from the criteria.
Write them down in the mapping table above and show the user before step 2, because every later
layer inherits whatever you guessed.

## Screen template

`flutter-create-screen` owns the page shape and carries one template per state-management seam.
Call it rather than working from a copy here.

## Completion criteria

The feature is done when every row of the mapping table above has code behind it and every
acceptance criterion has a test naming it. Report three things:

- **Criteria covered**, each against the action, status and test that implements it.
- **Signatures you inferred** rather than were given, since these are what a real API contract will
  contradict first.
- **Criteria you could not implement** from the requirements alone, and what you would need.

Then call the Skill tool with `flutter-verify` and name the rung you reached.
