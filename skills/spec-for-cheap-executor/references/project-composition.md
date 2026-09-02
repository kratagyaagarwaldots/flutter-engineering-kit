# Composing with this project's skills, agents, rules and hooks

The generated doc must **name** the project's existing machinery so the cheap executor inherits
the project's conventions instead of re-deriving them. Naming a skill is a one-line instruction
that replaces two pages of restated convention — and it stays correct when the convention changes.

Three ways to cite, in order of preference:

1. **Invoke** — "Call the Skill tool with `flutter-write-tests` before step 6."
2. **Delegate** — "Delegate step 3 to the `flutter-repo-engineer` agent."
3. **Defer** — "`.claude/rules/flutter-bloc.md` governs the state shape here; follow it."

Cite the path. Pasting a skill's or a rule's contents into the doc forks it: the copy stops tracking
the original the moment either changes.

## Skills — instruct the executor to call the Skill tool

Write the instruction as a Skill tool call with the skill named, one call per line. A bare `/name`
dropped into prose reads as a label, and the executor will treat it as one.

| Skill | Cite it when the task involves | Typical doc line |
|-------|-------------------------------|------------------|
| `flutter-core-architecture` | Shared widgets, theming, dialogs, network, barrel, fixtures | "Call the Skill tool with `flutter-core-architecture` before inventing constants or dialogs." |
| `flutter-create-state-layer` | Creating or extending a bloc triad | "Call the Skill tool with `flutter-create-state-layer` for the triad, then apply §3 to the filter handler." |
| `flutter-create-model` | New DTOs / JSON shapes | "Call the Skill tool with `flutter-create-model` and build the response DTO from the field map in §4." |
| `flutter-create-repository` | Wrapping endpoints | "Call the Skill tool with `flutter-create-repository`. §3 fixes the signatures; keep them." |
| `flutter-create-screen` | A screen from Figma / CSS / spec | "Call the Skill tool with `flutter-create-screen`, using the mockups in §5 as the spec (no Figma node for this task)." |
| `flutter-create-feature` | Whole feature, API unknown | Rarely in a task doc — prefer naming the layer skills per build step. |
| `flutter-modernize-screen` | Legacy screen → BLoC + screenutil | "Step 2: call the Skill tool with `flutter-modernize-screen` on the page named in §1; §11 overrides its defaults where they differ." |
| `flutter-write-tests` | Any bloc test work | "Call the Skill tool with `flutter-write-tests`, then replace its generated assertions with the exact ones in §10.2." |
| `flutter-security-review` | Storage / network / secrets / WebView touched | "Step 7: call the Skill tool with `flutter-security-review` — this task adds a token to storage." |

The two end-to-end scaffolders and `store-compliance` are user-invoked, so no doc instruction can
start them. When the task's scope is one of those, say so in §1 and tell the reader which command a
human has to type: `/flutter-create-feature-e2e`, `/flutter-create-screen-e2e`, or
`/store-compliance`.

**Precedence must be stated.** A skill generates its own defaults; your doc's §3 / §5 / §10 are
authoritative. Say which wins, explicitly: *"Where `flutter-write-tests` output differs from §10.2,
§10.2 wins."* Without that line the executor keeps the generated version.

## Agents — delegate via the Agent tool

| Agent | Owns | Delegate when |
|-------|------|---------------|
| `flutter-state-engineer` | `lib/features/{f}/bloc/` | Events table + repo signatures are already fixed in the doc |
| `flutter-repo-engineer` | `lib/features/{f}/model/`, `repo/` | Field map + endpoint table are fixed |
| `flutter-ui-engineer` | `lib/features/{f}/view/`, `widget/` | §5 mockups are complete for every state |
| `flutter-test-engineer` | `test/features/{f}/` | §10 assertions are exact |

Only tell the executor to delegate when the delegated inputs are **fully specified in the doc** —
a subagent given a vague slice reintroduces exactly the judgment this skill removes. When a doc
step is delegable, say so and say what to hand over: *"Delegate step 5 to `flutter-ui-engineer`;
pass §1, §5 and §11 verbatim as its brief."*

## Rules — auto-load by path glob

| Rule file | Auto-loads for |
|-----------|----------------|
| `.claude/rules/flutter-bloc.md` | `**/bloc/**/*.dart` |
| `.claude/rules/flutter-models.md` | `**/model/**/*.dart` |
| `.claude/rules/flutter-ui.md` | `lib/**/*.dart` |
| `.claude/rules/store-compliance-docs.md` | `docs/store/**/*.md` |

The architecture source of truth is the `flutter-core-architecture` skill. The Cursor mirror under
`.cursor/` is generated from the same sources, so cite the skill rather than a mirrored path.
Always-on layer: [CLAUDE.md](CLAUDE.md).

Read the project's `.claude/rules/` directory for the rules it actually has before citing one. The
table above lists what the kit ships; a project may carry more.

These load automatically for the executor — but a rule that loads is not a rule that gets
followed. §11 of the doc still spells out the handful the task will actually brush against,
with the rule file cited beside each.

## Hooks — tell the executor these fire

Configured in `.claude/settings.json`. The executor will see their output and may mistake it
for its own error. Warn it in the doc when relevant:

| Hook | Trigger | What the executor sees |
|------|---------|------------------------|
| `dart-format.sh` | `PostToolUse` on `Edit`/`Write` | Files reformat themselves after every edit — **do not hand-format, and do not "fix" the reformat** |
| `scan-secrets.sh` | `UserPromptSubmit` | **Blocks** submission on a secret match; a literal key in the doc will jam the executor |
| `scan-fixtures.sh` | `PreToolUse` on `Bash` | A heads-up before `git commit` / `git push` when `FIXTURE` markers remain — expected in fixture mode, not an error |

Consequence for **you**, the doc author: never put a real key, token, or credential-shaped
string in the doc. Use `{{API_KEY}}` placeholders and a §7 note on where the real value lives.

## Always-include for this project

Regardless of task, a task doc's §11 includes the single-barrel import rule (S1) and
the `exports.dart` registration rule (S2) whenever any `lib/` file is created — they are the
project's most-violated conventions and the executor will not guess them.

If the task touches a feature in **fixture mode** (`lib/features/{f}/README.md` mentions it),
§1 must state whether fixture markers stay or go, and §6 must list any marker being removed.
Fixture markers are sanctioned conventions, not `TODO`s — an executor left to judge will
delete them.

## Verification commands for this project

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if mocks/codegen changed
dart format .
flutter analyze                                            # must report "No issues found."
flutter test
flutter test test/features/{feature}/widget/{name}_test.dart   # single file
flutter test --name '<test name>'                              # single test
```
