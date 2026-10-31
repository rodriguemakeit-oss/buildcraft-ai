#!/usr/bin/env bash
# PostToolUse hook (Edit|MultiEdit|Write): auto-format and lint-fix the edited file.
# Reads the Claude Code hook JSON from stdin and acts on .tool_input.file_path.
#
# Non-blocking by design: every tool is optional and guarded with `command -v`; the hook
# always exits 0 so formatting never interrupts the dev loop. Mirrors what pre-commit does
# (ruff / eslint / prettier) so the model fixes style before pre-commit complains.

set -uo pipefail

payload="$(cat)"

command -v jq >/dev/null 2>&1 || exit 0
file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

case "$file" in
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$file" >/dev/null 2>&1 || true
      ruff check --fix "$file" >/dev/null 2>&1 || true
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    if command -v npx >/dev/null 2>&1; then
      npx --no-install eslint --fix "$file" >/dev/null 2>&1 || true
      npx --no-install prettier --write "$file" >/dev/null 2>&1 || true
    fi
    ;;
  *.json|*.css|*.scss|*.md|*.yaml|*.yml|*.html)
    if command -v npx >/dev/null 2>&1; then
      npx --no-install prettier --write "$file" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
