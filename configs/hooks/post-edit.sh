#!/usr/bin/env bash
# PostToolUse for Edit|Write on Python files: format, lint,
# typecheck. Exit 2 shows stderr to Claude; the edit stays.
set -uo pipefail
f=$(jq -r '.tool_input.file_path')
case "$f" in *.py) ;; *) exit 0 ;; esac
# A missing tool is the platform's problem, not the agent's:
# exit 1 is a non-blocking error the agent does not act on.
command -v ruff >/dev/null && command -v mypy >/dev/null \
  || exit 1
cd "$(git -C "$(dirname "$f")" rev-parse --show-toplevel)" \
  || exit 1

ruff format --quiet "$f"
if ! out=$(ruff check --quiet "$f" 2>&1 \
           && mypy --no-error-summary "$f" 2>&1); then
  echo "Fix these before continuing:" >&2
  head -n 30 <<<"$out" >&2
  exit 2
fi
exit 0
