#!/usr/bin/env bash
# Break-glass (Acme runbook, not a platform feature): stop all
# laptop model traffic. An explicit deny on the gateway's
# upstream role refuses every Bedrock call, whatever the spend
# caps, overrides, or the state of the spend store. IAM changes
# propagate with a delay; confirm on a test request. Revert by
# deleting the AcmeStopAll policy in a reviewed change.
# Usage: stop-laptop-traffic.sh [ROLE_NAME]
set -euo pipefail
role="${1:-acme-gw-user}"
policy=$(jq -n '{
  Version: "2012-10-17",
  Statement: [{Effect: "Deny", Action: ["*"], Resource: ["*"]}]
  }')
aws iam put-role-policy --role-name "$role" \
  --policy-name AcmeStopAll --policy-document "$policy"
echo "stopped: every call through $role is denied"
