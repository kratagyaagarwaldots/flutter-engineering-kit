#!/usr/bin/env bash
#
# UserPromptSubmit hook: BLOCK prompt submission when it appears to paste a
# likely secret (API key / token / JWT). Fails open – any script error or
# missing input lets the prompt through.

set -u

input="$(cat)"
prompt="$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null)"

if [[ -z "$prompt" ]]; then
  exit 0
fi

# Common secret-shaped patterns: stripe keys, AWS access keys, JWTs,
# bearer tokens, GitHub PATs, and high-entropy hex/base64 blobs > 32 chars.
if echo "$prompt" | grep -E -q \
  '(sk_(live|test)_[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}|Bearer\s+[A-Za-z0-9_\-\.=]{20,})'; then
  jq -n '{
    decision: "block",
    reason: "Prompt appears to contain a secret (API key / token / JWT). Strip secrets out of source and use --dart-define or flutter_secure_storage instead."
  }'
  exit 0
fi

exit 0
