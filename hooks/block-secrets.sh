#!/usr/bin/env bash
# PreToolUse hook (Edit|MultiEdit|Write): block writing hardcoded secrets into code.
# Reads the Claude Code hook JSON from stdin; inspects the content being written.
# exit 2 = block the action and feed the message back to the model. exit 0 = allow.
#
# Degrades gracefully: if jq is missing or no content is found, it allows the action
# (a hook must never wedge the dev loop).

set -uo pipefail
payload="$(cat)"

command -v jq >/dev/null 2>&1 || exit 0

file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

# Collect every chunk of text this tool would write:
#   Write    -> .tool_input.content
#   Edit     -> .tool_input.new_string
#   MultiEdit-> .tool_input.edits[].new_string
content="$(printf '%s' "$payload" | jq -r '
  [ .tool_input.content,
    .tool_input.new_string,
    ( .tool_input.edits // [] )[].new_string
  ] | map(select(. != null)) | join("\n")
' 2>/dev/null)"

[ -z "$content" ] && exit 0

# Never let a real .env be created/edited through the assistant.
case "$file_path" in
  *.env|*/.env) base="$(basename "$file_path")"
    if [ "$base" = ".env" ]; then
      echo "BLOCKED: refusing to write a real .env file ($file_path). Use .env.example with placeholders, and load real values from the environment / a secrets manager." >&2
      exit 2
    fi ;;
esac

# Hardcoded secret assignment: KEY = "literal-value" (quoted, non-empty).
# Matches secret/password/passwd/api_key/apikey/token/access_key/secret_key style names.
secret_re='(secret|secret[_-]?key|password|passwd|pwd|api[_-]?key|apikey|access[_-]?key|auth[_-]?token|token)[[:alnum:]_]*[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']+'

# Tolerate obvious non-secret placeholders to cut false positives.
placeholder_re='(changeme|change-me|placeholder|example|dummy|fake|test|xxx+|your[_-]|<.*>|\$\{|os\.(getenv|environ)|getenv\(|settings\.|config\.|process\.env)'

hits="$(printf '%s' "$content" | grep -nEi "$secret_re" 2>/dev/null | grep -vEi "$placeholder_re" 2>/dev/null || true)"

if [ -n "$hits" ]; then
  {
    echo "BLOCKED: a hardcoded secret looks like it is being written to ${file_path:-this file}:"
    printf '%s\n' "$hits" | head -n 5
    echo "Move it to an env var / secrets manager (e.g. pydantic-settings, os.environ) — see standards/security.md."
  } >&2
  exit 2
fi

exit 0
