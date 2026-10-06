# Issue tracker

Written by `/fk-setup`. The kit's `project-tracker` skill reads this file before it touches a
ticket, and owns the conventions: labels, ticket body, sprints. This file records only what is
true of this project.

## Where

| Field | Value |
|---|---|
| Tracker | GitHub Issues |
| Repo | `<owner>/<repo>` |
| Board | `<project number>` owned by `<@me or organisation>`, or `none` |
| Board Status options | `Todo`, `In Progress`, `Done` |

## Sprints

| Field | Value |
|---|---|
| Length | `<1 week>` |
| Starts on | `<Monday>` |
| Capacity for the next sprint | `<points, or "guess: N" until a sprint has closed>` |

Capacity is the average velocity of the last three closed sprints. Until one has closed it is a
guess, and every plan built on it says so.

## Velocity

One row per closed sprint, appended by `/fk-sprint close`.

| Sprint | Committed | Closed | Notes |
|---|---|---|---|
