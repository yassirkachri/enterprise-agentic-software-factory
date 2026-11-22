#!/usr/bin/env bash
# Stop gate: Claude may finish only when the unit and
# contract suites pass. The attempt budget is Acme
# policy; the built-in cap resets on every tool call.
set -uo pipefail
in=$(cat)
cwd=$(jq -r '.cwd' <<<"$in")
sid=$(jq -r '.session_id' <<<"$in")
msg=$(jq -r '.last_assistant_message // ""' <<<"$in")
max=${ACME_GATE_MAX:-5}
cd "$(git -C "$cwd" rev-parse --show-toplevel)" || exit 1

# A spec question hands the item to a human: let it stop.
case "$msg" in "SPEC-QUESTION:"*) exit 0 ;; esac

# Nothing changed under src/ or tests/: nothing to gate.
changed=$(git status --porcelain -- src tests
          git diff --name-only origin/main...HEAD -- src tests)
[ -z "$changed" ] && exit 0

# Same tree as the last green run: nothing new to test.
state="${TMPDIR:-/tmp}/acme-gate-$sid"
fp=$({ git rev-parse HEAD; git diff HEAD -- src tests
       git ls-files -o --exclude-standard -z -- src tests \
         | xargs -0 -r git hash-object
     } | git hash-object --stdin)
[ "$(cat "$state.green" 2>/dev/null)" = "$fp" ] && exit 0

n=$(( $(cat "$state" 2>/dev/null || echo 0) + 1 ))
if out=$(make test bdd 2>&1); then
  rm -f "$state"
  echo "$fp" >"$state.green"
  exit 0
fi
echo "$n" >"$state"

if [ "$n" -ge "$max" ]; then
  logger -t acme-hooks "gate exhausted $sid $PWD" || true
  jq -n --arg m "Test gate failed $n times. Escalate to L2." \
    '{systemMessage: $m}'
  exit 0
fi
jq -n --arg r "Tests fail (attempt $n of $max). Fix the code,
not the tests. If the spec is wrong, start your reply with
SPEC-QUESTION: and stop.
$(tail -n 40 <<<"$out")" '{decision: "block", reason: $r}'
