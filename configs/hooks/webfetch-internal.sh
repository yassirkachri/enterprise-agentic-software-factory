#!/usr/bin/env bash
# Managed PreToolUse guard for WebFetch (Acme policy): the
# agent fetches internal hosts only, so a followed injection
# cannot post data to an outside URL. Deployed by MDM as
# /opt/acme/hooks/webfetch-internal.sh. Fails closed.
set -euo pipefail
url=$(jq -er '.tool_input.url')
host=${url#*://}
host=${host%%[/?#]*}
host=${host##*@}
host=${host%%:*}
host=$(tr '[:upper:]' '[:lower:]' <<<"$host")
case "$host" in
  *.acme.internal) exit 0 ;;
esac
logger -t acme-hooks "deny webfetch $host" || true
echo "BLOCKED: WebFetch reaches *.acme.internal only." >&2
exit 2
