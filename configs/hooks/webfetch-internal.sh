#!/usr/bin/env bash
# Managed PreToolUse guard for WebFetch (Acme policy): the
# agent fetches internal hosts only, so a followed injection
# cannot post data to an outside URL. Deployed by MDM as
# /opt/acme/hooks/webfetch-internal.sh. Fails closed.
set -euo pipefail
url=$(jq -er '.tool_input.url')
url=$(tr '[:upper:]' '[:lower:]' <<<"$url")
# Match the whole authority: user info, a backslash, or a
# second host cannot sit before or after the internal name.
re='^https?://([a-z0-9-]+\.)+acme\.internal(:[0-9]+)?([/?#]|$)'
[[ $url =~ $re ]] && exit 0
host=${url#*://}
host=${host%%[/?#]*}
logger -t acme-hooks "deny webfetch $host" || true
echo "BLOCKED: WebFetch reaches *.acme.internal only." >&2
exit 2
