#!/usr/bin/env bash
set -euo pipefail

# Generate the .opencode/ mirror for a target project from this kit's single source.
# Usage: scripts/sync-opencode.sh [--uninstall] /path/to/project
#
# --uninstall removes exactly the paths this kit version generated (skill dirs, converted
# agents, generated commands, rules, plugin, template tree, generated README) and strips the
# kit's instructions entry and its own permission.skill gates from opencode.json. Files the
# project added itself, and gate values it changed, are never touched.
#
# skills/, agents/, rules/ and opencode/plugins/ in this repo are the source of truth.
# Never hand-edit a generated mirror: re-run this script instead.
#
# What it writes into <project>/.opencode/:
#   skills/    every kit skill, copied wholesale (opencode discovers
#              .opencode/skills/<name>/SKILL.md natively)
#   agents/    kit agents converted to opencode frontmatter
#              (mode: subagent, tools: → permission:, Claude model
#              shorthands unpinned so agents inherit the project default)
#   commands/  one /<name> command per user-invoked skill, loading that skill
#   rules/     kit rules, wired via the "instructions" key in opencode.json
#   plugins/   flutter-kit.ts, the opencode equivalent of hooks/hooks.json
#              (fixture heads-up + secret refusal; dart formatting comes from
#              the built-in dart formatter enabled in opencode.json)
#   template/  the kit's template/ tree, so the ../../template/... links inside
#              setup-flutter-project resolve here as they do in a plugin install
#
# It also merges <project>/opencode.json (creating it from
# template/opencode.json when missing): formatter on, instructions pointing
# at .opencode/rules/*.md, a permission.skill "ask" gate per user-invoked skill
# (opencode ignores disable-model-invocation, so the gate is what keeps those
# human-started), everything else the project already had untouched.

KIT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="install"
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --uninstall) MODE="uninstall" ;;
    -h|--help) echo "usage: $(basename "$0") [--uninstall] /path/to/project" >&2; exit 2 ;;
    -*) echo "error: unknown flag $arg" >&2; exit 2 ;;
    *) TARGET="$arg" ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "usage: $(basename "$0") [--uninstall] /path/to/project" >&2
  exit 2
fi
if [ ! -d "$TARGET" ]; then
  echo "error: $TARGET is not a directory" >&2
  exit 1
fi
if [ ! -f "$TARGET/pubspec.yaml" ]; then
  echo "error: $TARGET has no pubspec.yaml; this does not look like a Flutter project" >&2
  exit 1
fi

if [ "$MODE" = "uninstall" ]; then
  echo "kit:    $KIT"
  echo "target: $TARGET  (uninstall)"
  python3 - "$KIT" "$TARGET" <<'PYEOF'
import json, pathlib, re, shutil, sys

kit, target = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
op = target / ".opencode"
RULES_GLOB = ".opencode/rules/*.md"
MARKER = "flutter-engineering-kit repo by `scripts/sync-opencode.sh`"
removed = []


def rm(path, label):
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
        removed.append(label)
    elif path.exists() or path.is_symlink():
        path.unlink()
        removed.append(label)


# The same scan the install side uses to generate commands and permission gates.
def user_invoked() -> list[str]:
    names = []
    for skill in sorted((kit / "skills").glob("*/SKILL.md")):
        m = re.match(r"^---\n(.*?)\n---\n", skill.read_text(), re.S)
        if m and "disable-model-invocation: true" in m.group(1):
            names.append(skill.parent.name)
    return names


for skill in sorted((kit / "skills").glob("*/SKILL.md")):
    rm(op / "skills" / skill.parent.name, f"skill {skill.parent.name}")
for name in user_invoked():
    rm(op / "commands" / f"{name}.md", f"command {name}")
rm(op / "template", "template/ (generated)")
for agent in sorted((kit / "agents").glob("*.md")):
    if agent.name == "README.md":
        continue
    rm(op / "agents" / agent.name, f"agent {agent.name}")
for rule in sorted((kit / "rules").glob("*.md")):
    rm(op / "rules" / rule.name, f"rule {rule.name}")
plugindir = kit / "opencode" / "plugins"
if plugindir.is_dir():
    for plug in sorted(plugindir.glob("*")):
        if plug.is_file():
            rm(op / "plugins" / plug.name, f"plugin {plug.name}")
readme = op / "README.md"
if readme.is_file() and MARKER in readme.read_text():
    readme.unlink()
    removed.append("README.md (generated)")

for sub in ("skills", "agents", "commands", "rules", "plugins"):
    try:
        (op / sub).rmdir()
    except OSError:
        pass
try:
    op.rmdir()
except OSError:
    pass


def strip_jsonc(text: str) -> str:
    out, i, n = [], 0, len(text)
    in_str, esc = False, False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            i += 1
        elif c == '"':
            in_str = True
            out.append(c)
            i += 1
        elif c == "/" and i + 1 < n and text[i + 1] == "/":
            while i < n and text[i] != "\n":
                i += 1
        elif c == "/" and i + 1 < n and text[i + 1] == "*":
            i += 2
            while i + 1 < n and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


cfg_path = target / "opencode.json"
if cfg_path.exists():
    try:
        raw = cfg_path.read_text()
        try:
            cfg = json.loads(raw)
        except json.JSONDecodeError:
            cfg = json.loads(strip_jsonc(raw))
        touched = False
        instr = cfg.get("instructions")
        if isinstance(instr, list) and RULES_GLOB in instr:
            cfg["instructions"] = [i for i in instr if i != RULES_GLOB]
            if not cfg["instructions"]:
                del cfg["instructions"]
            touched = True
            removed.append("opencode.json instructions entry")
        # Only the kit's own "ask" gates go; a value the project changed is theirs.
        perm = cfg.get("permission")
        skill = perm.get("skill") if isinstance(perm, dict) else None
        if isinstance(skill, dict):
            gated = 0
            for name in user_invoked():
                if skill.get(name) == "ask":
                    del skill[name]
                    gated += 1
            if not skill:
                del perm["skill"]
            if not perm:
                del cfg["permission"]
            if gated:
                touched = True
                removed.append(f"opencode.json permission.skill ({gated} gates)")
        if touched:
            cfg_path.write_text(json.dumps(cfg, indent=2) + "\n")
    except (json.JSONDecodeError, OSError) as e:
        print(f"warning: opencode.json left untouched ({e})", file=sys.stderr)

print(f"removed {len(removed)} kit-owned path(s)")
for r in removed:
    print(f"  - {r}")
print("note: the formatter key is left as-is; turn it off yourself if nothing else needs it.")
PYEOF
  echo
  echo "done. kit mirror removed; your own .opencode files were kept."
  echo "note: quit and restart opencode so it drops the removed skills and commands."
  exit 0
fi

echo "kit:    $KIT"
echo "target: $TARGET"

mkdir -p "$TARGET/.opencode/skills" "$TARGET/.opencode/agents" \
  "$TARGET/.opencode/commands" "$TARGET/.opencode/rules" "$TARGET/.opencode/plugins"

# Skills: copy each skill directory wholesale, including its references/ and templates/.
count=0
for dir in "$KIT"/skills/*/; do
  name="$(basename "$dir")"
  rm -rf "$TARGET/.opencode/skills/$name"
  mkdir -p "$TARGET/.opencode/skills/$name"
  cp -R "$dir." "$TARGET/.opencode/skills/$name/"
  count=$((count + 1))
done
echo "synced $count skills"

# Template: setup-flutter-project links to ../../template/... from inside its own
# skill directory. Copying the tree to the mirror root keeps those links resolving
# here exactly as they do in a plugin install.
rm -rf "$TARGET/.opencode/template"
mkdir -p "$TARGET/.opencode/template"
cp -R "$KIT"/template/. "$TARGET/.opencode/template/"
echo "synced template/"

# Agents: our sources use Claude frontmatter (name:/tools:/model: haiku|sonnet|opus).
# opencode wants mode:/permission: and a provider/model-id it cannot get from a
# Claude shorthand, so convert rather than copy or opencode inherits nothing useful.
python3 - "$KIT/agents" "$TARGET/.opencode/agents" <<'PYEOF'
import pathlib, re, sys

src, dest = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
dest.mkdir(parents=True, exist_ok=True)
written = 0

for f in sorted(src.glob("*.md")):
    if f.name == "README.md":
        continue
    text = f.read_text()
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if m:
        front, body = m.group(1), m.group(2).lstrip("\n")
    else:
        front, body = "", text

    dm = re.search(r"^description:\s*(.+)$", front, re.M)
    if not dm:
        print(f"warning: {f.name} has no description; skipped", file=sys.stderr)
        continue
    desc = dm.group(1).strip()

    tm = re.search(r"^tools:\s*(.+)$", front, re.M)
    tools = tm.group(1) if tm else ""
    readonly = not re.search(r"Write|Edit", tools)

    mm = re.search(r"^model:\s*(.+)$", front, re.M)
    tier = mm.group(1).strip() if mm else "unpinned"

    out = ["---", f"description: {desc}", "mode: subagent"]
    if readonly:
        out.append("permission:")
        out.append("  edit: deny")
    out.append("---")
    out.append("")
    out.append("<!-- Generated from flutter-engineering-kit by scripts/sync-opencode.sh. Do not hand-edit; re-run the script. -->")
    out.append(f"<!-- Kit model tier was `{tier}` (a Claude shorthand). Model intentionally unpinned so this agent inherits the project's default; pin per-agent models in opencode.json to override. -->")
    out.append("")
    out.append(body.rstrip() + "\n")

    (dest / f.name).write_text("\n".join(out))
    written += 1

print(f"synced {written} agents")
PYEOF

# Commands: opencode has no user-invoked skills, so every skill carrying
# disable-model-invocation becomes a /<name> command that loads that skill.
python3 - "$KIT/skills" "$TARGET/.opencode/commands" <<'PYEOF'
import pathlib, re, sys

src, dest = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
dest.mkdir(parents=True, exist_ok=True)
written = 0

for skill in sorted(src.glob("*/SKILL.md")):
    text = skill.read_text()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        continue
    front = m.group(1)
    if "disable-model-invocation: true" not in front:
        continue
    name = skill.parent.name
    dm = re.search(r"^description:\s*(.+)$", front, re.M)
    if not dm:
        print(f"warning: {name} has no description; skipped", file=sys.stderr)
        continue
    desc = dm.group(1).strip()

    out = "\n".join([
        "---",
        f"description: {desc}",
        "---",
        "",
        "<!-- Generated from flutter-engineering-kit by scripts/sync-opencode.sh. Do not hand-edit; re-run the script. -->",
        "",
        f"Load and follow the `{name}` skill before doing anything else. Call the skill tool with name `{name}`, passing the user input below, then follow that skill's instructions exactly. Do not start the work without loading the skill first.",
        "",
        "User input:",
        "$ARGUMENTS",
        "",
    ])
    (dest / f"{name}.md").write_text(out)
    written += 1

print(f"synced {written} commands")
PYEOF

# Rules: opencode has no rules directory of its own; these files are loaded
# through the "instructions" key the opencode.json merge below maintains.
cp "$KIT"/rules/*.md "$TARGET/.opencode/rules/"
echo "synced $(ls -1 "$KIT"/rules/*.md | wc -l | tr -d ' ') rules"

# Plugin: opencode auto-loads .opencode/plugins/*.ts, no config entry needed.
cp "$KIT"/opencode/plugins/*.ts "$TARGET/.opencode/plugins/"
echo "synced $(ls -1 "$KIT"/opencode/plugins/*.ts | wc -l | tr -d ' ') plugins"

# opencode.json: create from the kit template when missing, otherwise merge —
# formatter on, instructions wired, the user-invoked skills gated behind a
# permission prompt, every other key untouched.
python3 - "$KIT/template/opencode.json" "$TARGET/opencode.json" "$KIT/skills" <<'PYEOF'
import json, pathlib, re, sys

template_path, target_path = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
skills_dir = pathlib.Path(sys.argv[3])
template = json.loads(template_path.read_text())
RULES_GLOB = ".opencode/rules/*.md"


def strip_jsonc(text: str) -> str:
    out, i, n = [], 0, len(text)
    in_str, esc = False, False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            i += 1
        elif c == '"':
            in_str = True
            out.append(c)
            i += 1
        elif c == "/" and i + 1 < n and text[i + 1] == "/":
            while i < n and text[i] != "\n":
                i += 1
        elif c == "/" and i + 1 < n and text[i + 1] == "*":
            i += 2
            while i + 1 < n and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


# opencode ignores `disable-model-invocation`, so a copied user-invoked skill is
# model-invocable in the mirror — the kit's rule is that only a human starts those.
# Gate each one behind a permission prompt, from the same frontmatter scan that
# generates the commands, so the list can never drift from the skills.
def user_invoked() -> list[str]:
    names = []
    for skill in sorted(skills_dir.glob("*/SKILL.md")):
        m = re.match(r"^---\n(.*?)\n---\n", skill.read_text(), re.S)
        if m and "disable-model-invocation: true" in m.group(1):
            names.append(skill.parent.name)
    return names


def gate_skills(cfg: dict) -> int:
    perm = cfg.get("permission")
    if not isinstance(perm, dict):
        if perm is not None:
            print("note: permission is not an object; skill gating skipped.", file=sys.stderr)
            return 0
        perm = cfg["permission"] = {}
    skill = perm.get("skill")
    if not isinstance(skill, dict):
        if skill is not None:
            print(f"note: permission.skill is {skill!r}, not an object; skill gating skipped.",
                  file=sys.stderr)
            return 0
        skill = perm["skill"] = {}
    added = 0
    for name in user_invoked():
        if name not in skill:  # never overwrite a value the project set
            skill[name] = "ask"
            added += 1
    if not skill:
        del perm["skill"]
    if not perm:
        del cfg["permission"]
    return added


if not target_path.exists():
    cfg = dict(template)
    gated = gate_skills(cfg)
    target_path.write_text(json.dumps(cfg, indent=2) + "\n")
    print(f"wrote opencode.json from kit template ({gated} user-invoked skills gated)")
else:
    try:
        cfg = json.loads(strip_jsonc(target_path.read_text()))
    except json.JSONDecodeError as e:
        print(f"warning: existing opencode.json could not be parsed ({e}); left untouched.", file=sys.stderr)
        print("merge this manually:", file=sys.stderr)
        print(json.dumps(template, indent=2), file=sys.stderr)
        sys.exit(0)
    if not isinstance(cfg, dict):
        print("warning: existing opencode.json is not an object; left untouched.", file=sys.stderr)
        sys.exit(0)
    cfg.setdefault("$schema", template["$schema"])
    if "formatter" not in cfg:
        cfg["formatter"] = template["formatter"]
    elif cfg.get("formatter") is False:
        print("note: formatter stays disabled (your opencode.json sets it false); `dart format` will not auto-run.", file=sys.stderr)
    instr = cfg.get("instructions")
    if not isinstance(instr, list):
        cfg["instructions"] = list(template["instructions"])
    elif RULES_GLOB not in instr:
        cfg["instructions"] = [*instr, RULES_GLOB]
    gated = gate_skills(cfg)
    target_path.write_text(json.dumps(cfg, indent=2) + "\n")
    print(f"merged opencode.json (formatter default, instructions wired, "
          f"{gated} user-invoked skills gated, your keys kept)")
PYEOF

cat > "$TARGET/.opencode/README.md" <<'INNER'
# Generated mirror

Everything under `.opencode/skills`, `.opencode/agents`, `.opencode/commands`,
`.opencode/rules`, `.opencode/plugins` and `.opencode/template` is generated from
the flutter-engineering-kit repo by `scripts/sync-opencode.sh`.

Do not edit these files. Change the kit and re-run the script, or the next sync silently discards
your edit. `opencode.json` is yours: the script only merges the formatter default, the
`instructions` entry that loads `.opencode/rules/*.md`, and a `permission.skill` gate per
user-invoked skill, and leaves every other key alone.
INNER

echo
echo "done. opencode mirror written to $TARGET/.opencode"
echo "note: quit and restart opencode so it picks up the new config."
echo "note: run /setup-flutter-project once per project, as with the other installs."
echo "note: do not also install the .claude/ mirror in this project: opencode reads"
echo "      .claude/skills too, so two mirrors offer every skill twice."
