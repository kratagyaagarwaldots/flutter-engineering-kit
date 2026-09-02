#!/usr/bin/env bash
set -euo pipefail

# Copy the kit into a project (or your user directory) as ordinary editable files, instead of
# installing it as a managed plugin.
#
#   scripts/install-local.sh /path/to/project    → <project>/.claude/
#   scripts/install-local.sh --user              → ~/.claude/
#
# Nothing updates behind your back afterwards: these are your files. Delete the skills you do not
# want, edit the ones you keep, and re-run this to pull the kit's latest over the top — which
# overwrites your edits, so fork the ones you change under a different name.

KIT="$(cd "$(dirname "$0")/.." && pwd)"

case "${1:-}" in
  --user) TARGET="$HOME"; SCOPE="user" ;;
  "" | -h | --help)
    echo "usage: $(basename "$0") /path/to/project | --user" >&2; exit 2 ;;
  *)
    TARGET="$1"; SCOPE="project"
    if [ ! -d "$TARGET" ]; then echo "error: $TARGET is not a directory" >&2; exit 1; fi
    if [ ! -f "$TARGET/pubspec.yaml" ]; then
      echo "warning: $TARGET has no pubspec.yaml; this may not be a Flutter project root" >&2
    fi ;;
esac

DEST="$TARGET/.claude"
echo "kit:    $KIT"
echo "target: $DEST  ($SCOPE scope)"

mkdir -p "$DEST/skills" "$DEST/agents" "$DEST/rules" "$DEST/hooks"

count=0
for dir in "$KIT"/skills/*/; do
  name="$(basename "$dir")"
  rm -rf "$DEST/skills/$name"
  cp -R "$dir" "$DEST/skills/$name"
  count=$((count + 1))
done
echo "installed $count skills"

for f in "$KIT"/agents/*.md; do
  [ "$(basename "$f")" = "README.md" ] && continue
  cp "$f" "$DEST/agents/"
done
echo "installed $(find "$DEST/agents" -name '*.md' | wc -l | tr -d ' ') agents"

cp "$KIT"/rules/*.md "$DEST/rules/"
cp "$KIT"/hooks/*.sh "$DEST/hooks/"
chmod +x "$DEST"/hooks/*.sh
echo "installed rules and hooks"

cat <<'NOTE'

Hooks are files, not wiring. Add this to the settings.json next to them to activate them:

  {
    "hooks": {
      "PostToolUse":      [{ "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": ".claude/hooks/dart-format.sh" }] }],
      "PreToolUse":       [{ "matcher": "Bash",
        "hooks": [{ "type": "command", "command": ".claude/hooks/scan-fixtures.sh" }] }],
      "UserPromptSubmit": [{
        "hooks": [{ "type": "command", "command": ".claude/hooks/scan-secrets.sh" }] }]
    }
  }

Do not also install the plugin. Two copies means every skill is offered twice and every hook fires
twice. Then run /setup-flutter-project, which writes docs/agents/project.md.
NOTE
