#!/usr/bin/env bash
#
# PreToolUse hook (matcher: "Bash"):
# When the agent is about to commit or push, scan lib/ for FIXTURE markers
# and surface a heads-up if any features are still in fixture mode.
#
# Never blocks. Always allows the command and injects an additionalContext
# heads-up when markers are present, so the agent can confirm with the user
# whether shipping fixtures is intentional.
#
# Fails open.

set -u

input="$(cat)"
cmd="$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"

if [[ -z "$cmd" ]]; then
  exit 0
fi

# Only act on commit / push, not status / log / diff
if ! echo "$cmd" | grep -E -q 'git[[:space:]]+(commit|push)'; then
  exit 0
fi

# Bail early if there's no lib/features folder yet
if [[ ! -d lib/features ]]; then
  exit 0
fi

# 1. Find features still in fixture mode (README.md mentions "fixture mode")
fixture_features=""
while IFS= read -r -d '' readme; do
  if grep -q 'fixture mode' "$readme" 2>/dev/null; then
    feature_dir="${readme#lib/features/}"
    feature_dir="${feature_dir%/README.md}"
    fixture_features+="${feature_dir},"
  fi
done < <(find lib/features -maxdepth 2 -name README.md -print0 2>/dev/null)
fixture_features="${fixture_features%,}"

# 2. Count dangling FIXTURE_START / FIXTURE_END markers in dart files
fixture_blocks=0
if find lib -name '*.dart' -print0 2>/dev/null | xargs -0 grep -l 'FIXTURE_\(START\|END\)' 2>/dev/null | head -1 >/dev/null; then
  fixture_blocks="$(find lib -name '*.dart' -print0 2>/dev/null | xargs -0 grep -c 'FIXTURE_\(START\|END\)' 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')"
fi

if [[ -z "$fixture_features" && "$fixture_blocks" -eq 0 ]]; then
  exit 0
fi

message="Heads up: this repo still has fixture-mode artefacts."
if [[ -n "$fixture_features" ]]; then
  message="$message Features in fixture mode: $fixture_features."
fi
if [[ "$fixture_blocks" -gt 0 ]]; then
  message="$message $fixture_blocks FIXTURE_START/FIXTURE_END marker(s) remain in lib/."
fi
message="$message If shipping fixtures is intentional, proceed - otherwise upgrade via flutter-create-feature-e2e first."

jq -n --arg msg "$message" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $msg
  }
}'
exit 0
