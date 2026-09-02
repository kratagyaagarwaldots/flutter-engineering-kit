#!/usr/bin/env bash
#
# afterFileEdit hook: format any edited .dart file with `dart format`.
# Fails open – if dart isn't on PATH or formatting fails, the edit still succeeds.

set -u

input="$(cat)"
file_path="$(echo "$input" | jq -r '.file_path // .tool_input.file_path // empty')"

if [[ -z "$file_path" ]]; then
  exit 0
fi

if [[ "$file_path" != *.dart ]]; then
  exit 0
fi

if ! command -v dart >/dev/null 2>&1; then
  exit 0
fi

dart format "$file_path" >/dev/null 2>&1 || true

exit 0
