# Agents

Specialists the skills delegate to. Each owns one layer or one document, so a skill can fan out
without any single agent holding the whole feature in context.

These files are the source. `scripts/kit.py` converts them for each harness at install time
(TOML for Codex, opencode and Cursor frontmatter), so edit here and re-run `kit install`. Never
edit an installed copy.

## Models

The `model:` line in each file is Claude Code's default and nothing more. Which model an agent
really runs on is the user's choice: `install/roles.json` puts every agent in a role (explore,
build, judge, qa) and says what that role needs, the `configure-models` skill picks a model per role
in each harness the user has, and `kit install` pins it. Without that step, agents outside Claude
Code inherit the session's model. The tier column below is the reasoning behind each default.

## Feature layers

The model tier tracks how much judgement the layer needs, not how much code it writes.

| Agent | Owns | Model |
|-------|------|-------|
| `flutter-explore` | Read-only search: where things are, what already exists | `haiku` |
| `flutter-architect` | Design decisions, planning tables, hard root-cause work | `opus` |
| `flutter-ui-engineer` | `view/` and `widget/`, translating a design into a tree | `opus` |
| `flutter-state-engineer` | The state layer: actions, state shape, handlers, repository calls | `sonnet` |
| `flutter-repo-engineer` | `model/` and `repo/`: DTOs and data access | `sonnet` |
| `flutter-test-engineer` | `test/features/{f}/`, mapped back to acceptance criteria | `haiku` |

UI sits on `opus` because a design leaves more unstated than a schema does. Tests sit on `haiku`
because by the time they are written the assertions are already decided.

`flutter-architect` holds no procedure of its own: it calls `flutter-plan-change`,
`flutter-diagnose-bug` or `engineering-principles`, so the method has one home and the agent is the
context it runs in.

## Store pack

| Agent | Writes | Model |
|-------|--------|-------|
| `store-doc-writer` | One store or compliance document per invocation | `sonnet` |

`store-compliance` calls this once per document, passing the document name and the path to the
Signal Inventory. It used to be five agents, one per document group. One writer replaced them
because the documents have to agree with each other on governing law, contacts and URLs, and
separate contexts produced disagreements that the orchestrator then had to reconcile. Consistency is
cheaper to keep than to repair.

## Delivery

| Agent | Does | Model |
|-------|------|-------|
| `qa-engineer` | Tests a sprint's merged build against every ticket's criteria, files each failure as a bug | `sonnet` |

`/fk-sprint qa` sends it the commit a client is about to receive. Each builder proved its own ticket
on its own branch; this agent tests them together, which is where tickets that passed alone break
each other. It runs the build and files bugs, and never edits source.

## When to delegate

Reach for `flutter-explore` for discovery, and `flutter-architect` for judgement before any code
generation. Both pay for themselves by keeping the parent's context clear.

Split by layer only once the planning tables are stable. A layer engineer handed a table that is
still moving builds against a shape that changes under it, and reconciling that costs more than
running the layers in sequence would have.
