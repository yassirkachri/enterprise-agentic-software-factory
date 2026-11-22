#!/usr/bin/env bash
# Managed SessionStart hook (Acme policy): records a session
# whose user, project, or local settings switch hooks off.
# disableAllHooks set outside managed settings cannot stop a
# managed hook, so this one sees the sessions the guards do
# not. A --settings flag on the command line stays invisible.
# Deployed by MDM as /opt/acme/hooks/session-audit.sh.
set -uo pipefail
in=$(cat)
cwd=$(jq -r '.cwd' <<<"$in")
sid=$(jq -r '.session_id' <<<"$in")
for f in "$HOME/.claude/settings.json" \
    "$cwd/.claude/settings.json" \
    "$cwd/.claude/settings.local.json"; do
  if jq -e '.disableAllHooks == true' "$f" >/dev/null 2>&1
  then
    logger -t acme-hooks "hooks off via $f ($sid)" || true
  fi
done
exit 0
