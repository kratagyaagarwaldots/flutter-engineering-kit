#!/usr/bin/env bash
set -euo pipefail

# Generate the .cursor/ mirror for a target project from this kit's single source.
# Usage: scripts/sync-cursor.sh /path/to/project
#
# skills/, agents/ and rules/ in this repo are the source of truth. Never hand-edit
# a generated mirror: re-run this script instead.

KIT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "usage: $(basename "$0") /path/to/project" >&2
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

echo "kit:    $KIT"
echo "target: $TARGET"

mkdir -p "$TARGET/.cursor/skills" "$TARGET/.cursor/agents" "$TARGET/.cursor/rules" "$TARGET/.cursor/hooks"

# Skills: copy each skill directory wholesale, including its references/ and scripts/.
count=0
for dir in "$KIT"/skills/*/; do
  name="$(basename "$dir")"
  rm -rf "$TARGET/.cursor/skills/$name"
  mkdir -p "$TARGET/.cursor/skills/$name"
  cp -R "$dir." "$TARGET/.cursor/skills/$name/"
  count=$((count + 1))
done
echo "synced $count skills"

# Template: setup-flutter-project links to ../../template/... from inside its own
# skill directory. Copying the tree to the mirror root keeps those links resolving
# here exactly as they do in a plugin install.
rm -rf "$TARGET/.cursor/template"
mkdir -p "$TARGET/.cursor/template"
cp -R "$KIT"/template/. "$TARGET/.cursor/template/"
echo "synced template/"

# Agents.
cp "$KIT"/agents/*.md "$TARGET/.cursor/agents/"
echo "synced $(ls -1 "$KIT"/agents/*.md | wc -l | tr -d ' ') agents"

# Rules: our sources are .md with `description:` and a `paths:` list. Cursor wants .mdc
# with `description:` and comma-separated `globs:`. Convert rather than concatenate,
# or the output carries two frontmatter blocks and Cursor reads neither.
python3 - "$KIT/rules" "$TARGET/.cursor/rules" <<'PYEOF'
import pathlib, re, sys

src, dest = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
dest.mkdir(parents=True, exist_ok=True)
written = 0

for f in sorted(src.glob("*.md")):
    text = f.read_text()
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if m:
        front, body = m.group(1), m.group(2).lstrip("\n")
    else:
        front, body = "", text

    desc = ""
    dm = re.search(r"^description:\s*(.+)$", front, re.M)
    if dm:
        desc = dm.group(1).strip()

    globs = re.findall(r'^\s*-\s*"?([^"\n]+)"?\s*$', front, re.M)

    out = ["---"]
    out.append(f"description: {desc}" if desc else f"description: {f.stem}")
    if globs:
        out.append("globs: " + ",".join(globs))
    out.append("alwaysApply: false")
    out.append("---")
    out.append("")
    out.append("<!-- Generated from flutter-engineering-kit. Do not hand-edit; re-run scripts/sync-cursor.sh. -->")
    out.append("")
    out.append(body.rstrip() + "\n")

    (dest / f"{f.stem}.mdc").write_text("\n".join(out))
    written += 1

print(f"synced {written} rules as .mdc")
PYEOF

# Hooks.
cp "$KIT"/hooks/*.sh "$TARGET/.cursor/hooks/"
chmod +x "$TARGET/.cursor/hooks/"*.sh
echo "synced hooks"

cat > "$TARGET/.cursor/skills/README.md" <<'INNER'
# Generated mirror

Every file under `.cursor/skills`, `.cursor/agents`, `.cursor/rules`, `.cursor/hooks` and
`.cursor/template` is generated from the flutter-engineering-kit repo by `scripts/sync-cursor.sh`.

Do not edit these files. Change the kit and re-run the script, or the next sync silently discards
your edit.
INNER

echo
echo "done. Cursor mirror written to $TARGET/.cursor"
echo "note: the .claude/ side is provided by the installed plugin, not copied here."
