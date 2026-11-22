#!/usr/bin/env bash
# PreToolUse guard for Edit|Write. Exit 2 denies the call and
# Claude reads stderr as the reason. Fails closed: settings
# set "onFailure": "block", so a crash also blocks.
# Git names the file inside its own repository or worktree,
# so "..", symlinks, case, or another worktree cannot move a
# protected path out of the patterns below.
set -euo pipefail
in=$(cat)
f=$(jq -er '.tool_input.file_path' <<<"$in")
d=$(dirname "$f")
while [ ! -d "$d" ]; do d=$(dirname "$d"); done
rel=$(git -C "$d" rev-parse --show-prefix)${f#"$d"/}
root=$(git -C "$d" rev-parse --show-toplevel)
br=$(git -C "$d" branch --show-current)   # the work item key
shopt -s nocasematch

deny() {
  logger -t acme-hooks "deny $br $rel: $1" || true
  echo "BLOCKED $rel: $1" >&2
  exit 2
}

case "$rel" in
  tests/contracts/*)
    deny "contracts change only through a Spec Gate PR" ;;
  .env | .env.* | */.env | */.env.*)
    deny "agents never write secrets files" ;;
  .claude/hooks/* | .claude/settings*.json | .claude/agents/*)
    deny "agents cannot edit their own guardrails" ;;
  .github/* | .gitlab-ci.yml | Makefile)
    deny "agents cannot edit the jobs that judge them" ;;
  migrations/*)
    if git -C "$root" cat-file -e "origin/main:$rel" \
        2>/dev/null; then
      deny "applied migration (on main); add a new one"
    fi ;;
esac
exit 0
