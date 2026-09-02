---
name: engineering-principles
description: Four principles that change how a change is shaped rather than what it does: root causes, subtraction, reader load, and modelling the domain in types. Use when choosing between implementation shapes, when a fix could be made at more than one level, or when reviewing whether a change was built the right way.
---

# Engineering principles

Four principles that survived the test the kit applies to everything else: does stating this change
what gets built, versus not stating it? Each is one file. Read the one that bears on the decision in
front of you, rather than all four.

| The situation | Read |
|---|---|
| A fix could be applied at the symptom or deeper | [references/fix-root-causes.md](references/fix-root-causes.md) |
| The change is only adding things | [references/subtract-before-you-add.md](references/subtract-before-you-add.md) |
| The code works but is hard to follow | [references/minimize-reader-load.md](references/minimize-reader-load.md) |
| Invalid states are possible and guarded against at runtime | [references/model-the-domain.md](references/model-the-domain.md) |

These govern **shape**, not behaviour. Where the question is what the software should do, that is a
requirement, and calling the Skill tool with `grill` settles it faster than any principle will.

## Using one honestly

Cite a principle only where it changed a concrete decision, and say which decision. A principle
named in a summary but not visible in the diff is decoration, and it makes the next reader trust
the other citations less.

Where two principles point in opposite directions, say so and pick one with a reason. That tension
is real: subtraction and reader load frequently disagree, because the smallest change and the
clearest one are not always the same change.
