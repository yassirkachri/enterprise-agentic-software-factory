#!/usr/bin/env bash
# Dispensation expiry check (Acme policy, not a platform
# feature). Runs daily and on every pull request that touches
# dispensations/ in the factory policy repository. A record
# fails the day after its expires: date, or when it has none or
# one not written YYYY-MM-DD. Closed and renewed records move to
# dispensations/closed/, which the check does not read. The
# maximum term is checked in review, not here.
set -euo pipefail
shopt -s nullglob
today=$(date -u +%F)
d='[0-9]{4}-[01][0-9]-[0-3][0-9]'
status=0
for f in dispensations/*.yaml dispensations/*.yml; do
  exp=$(sed -nE "s/^expires: *($d)( *#.*)?\$/\1/p" "$f")
  if [[ -z "$exp" ]]; then
    echo "$f: no expires: date in YYYY-MM-DD form" >&2
    status=1
  elif [[ "$exp" < "$today" ]]; then
    echo "$f: expired $exp; renew as a new record or" \
      "remove the change it allowed" >&2
    status=1
  fi
done
exit "$status"
