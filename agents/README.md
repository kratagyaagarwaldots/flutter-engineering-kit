# Agents

Specialists the skills delegate to. Each owns one layer or one document, so a skill can fan out
without any single agent holding the whole feature in context.

These files are the source. `scripts/sync-cursor.sh` generates the `.cursor/agents/` mirror from
them, and `scripts/sync-opencode.sh` generates the `.opencode/agents/` mirror (converted to
opencode frontmatter: `mode: subagent`, `tools:` becomes `permission:`, model tier unpinned), so
edit here and re-run the script. Never edit a mirror.

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

## When to delegate

Reach for `flutter-explore` for discovery, and `flutter-architect` for judgement before any code
generation. Both pay for themselves by keeping the parent's context clear.

Split by layer only once the planning tables are stable. A layer engineer handed a table that is
still moving builds against a shape that changes under it, and reconciling that costs more than
running the layers in sequence would have.
