# The states a build skips

The happy path gets designed because it is what the feature is for. Everything else gets a spinner, a
centred `Text('No data')`, and whatever the exception's `toString()` returns. `flutter-code-review`
calls missing state branches the single most common source of a client feedback round, and this is
why: the states are not missing from the code so much as missing from the design.

`flutter-create-screen` requires that every state the logic seam can emit has a branch. This file is
about what goes **in** that branch.

## The shape every non-happy state has

Three things, and a state reads as unfinished when one is absent:

1. **What happened**, in the user's words rather than the system's. Not the exception, not the status
   code.
2. **What they can do about it** — a button, a gesture, or an explicit statement that there is
   nothing to do and it will resolve on its own.
3. **A way out.** No state traps the user with only a back gesture they have to guess at.

A state that says what happened but offers no action is a dead end. A state that offers an action but
not what happened makes the user guess whether it is safe to press.

## Loading

The decision is not which spinner. It is whether to show anything.

| Situation | What to show |
|---|---|
| Work that usually finishes under ~300ms | Nothing. Leave the previous content in place |
| First load of a screen whose shape is known | A skeleton in the shape of the real content |
| First load of a screen whose shape is unknown | A single centred progress indicator |
| Refreshing content already on screen | Keep the content, mark it refreshing at the edge |
| Loading the next page of a list | An indicator at the end of the list, not over it |
| A user-initiated action — submit, save | Disable and mark the control that was pressed |

**A spinner shown for 120ms is worse than no spinner.** It appears and vanishes as a flicker, which
reads as a glitch rather than as progress. Where a duration is unpredictable, delaying the indicator
by ~300ms removes the flicker for fast responses and costs nothing for slow ones.

**A skeleton earns its cost when it matches the final layout.** Its real job is holding the space so
content does not shove the page around on arrival. A skeleton in a different shape from the content
causes the exact jump it was meant to prevent.

**Never replace loaded content with a full-screen spinner on refresh.** The user had something to
read, and taking it away to say "working" is a downgrade. This is the most common loading mistake in
a pull-to-refresh.

## Empty

Empty is not one state. Treating it as one is why empty states read as broken.

| Which empty | What the user needs |
|---|---|
| **First-run** — never had data | What this screen is for, and the action that creates the first item |
| **Filtered to nothing** — data exists, the query excludes it | That the filter is the cause, and a way to clear it |
| **Cleared** — the user emptied it themselves | Confirmation this is expected, and no alarm |
| **Nothing yet, arriving later** — a feed with no activity | That it is working and what will appear here |

The first-run empty is the highest-value screen in most apps and the one most often left blank: it is
the only moment the user is guaranteed to be looking for guidance. It carries the invitation to the
core action.

A filtered-to-nothing empty that says "No results" and stops makes the user suspect the data is gone.
Naming the filter is what separates the two.

## Error

Split by whether the user can do anything.

| Kind | Design |
|---|---|
| **Recoverable** — network, timeout, a failed request | Inline, with a retry that actually retries the same operation |
| **Terminal** — malformed data, an unsupported version | A clear stop, and a route to support or an update |
| **Validation** — the user's input is wrong | At the field, on the field, as soon as it is knowable |
| **Auth expired** | Not an error screen — a route back to sign-in that returns to where they were |
| **Permission denied** | What the permission is for and how to grant it, with a route to settings |

**Errors get a message the user can act on.** A message that names the failed operation and the next
step beats one that names the layer that threw. Where a diagnostic code helps support, it goes at the
bottom in small text and is selectable, not in the headline.

**Validation belongs at the field.** A form that collects five inputs and reports one error at the
top after submission makes the user hunt. Validate when the answer is knowable — usually on blur —
and mark the field itself.

**A retry that reloads the whole screen is not a retry.** If a single request failed, retry that
request and leave the rest of the screen standing.

Where the failure model is `Failure` types from the repository layer, map each to one of these kinds
deliberately, rather than rendering every branch with the same generic message. That mapping is a
design decision, not a default.

## Offline and stale

An app that shows a blank error screen with no connection is worse than one that shows what it last
knew. Where content was cached, show it with a marker saying when it is from and that it may be out
of date, and give a manual refresh.

The distinction that matters: **not connected** is different from **connected and the request
failed**. The first has an obvious cause and resolves on its own; the second needs a retry. Saying
"check your connection" when the connection is fine sends the user to fix the wrong thing.

## Partial

A screen assembled from several sources can be half-successful. Two ways to design it, and the wrong
one is chosen by default:

- **Degrade per section**, where the sections are independent — render what arrived, mark the section
  that failed, retry just that.
- **Fail the whole screen**, where a missing piece makes the rest misleading — a balance without its
  pending transactions is worse than no balance.

Which applies is a judgment about the content, so name it rather than letting the widget tree decide
by accident.

## Completion

Confirm actions that changed something the user cannot see. A save that returns to a list with no
acknowledgement leaves the user unsure whether it took. This is the same purpose word from
`motion.md` — **feedback** — and it does not need an animation to be satisfied: a changed label, a
snackbar routed through the project's shared helpers, or the item simply appearing in the list all
count.

Destructive actions confirm **before**, and offer undo **after** where the operation permits it. An
undo that works is worth more than a dialog that asks, because it costs nothing on the common path.

## What to state when this is done

Per the skill's completion criteria: name every state the logic seam can emit and which of the above
shapes it got. Where a state the design never specified had to be invented, say which and what was
assumed — that is the line that turns a silent guess into a decision the client can correct.
