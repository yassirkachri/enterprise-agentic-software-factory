#!/usr/bin/env bash
# Break-glass (Acme runbook, not a platform feature): deny every
# credential the CI agent role issued before the cutoff, the
# mechanism of "Revoke active sessions" in the IAM console. The
# cutoff sits 60 seconds ahead to cover IAM propagation. A job
# that assumes the role after it is not affected, so stop new
# agent jobs first (ACME_AGENT_TIER, or remove the OIDC trust).
# Usage: revoke-ci-sessions.sh ROLE_NAME. Prints the cutoff for
# the incident record.
set -euo pipefail
role="${1:?usage: revoke-ci-sessions.sh ROLE_NAME}"
cutoff=$(jq -nr 'now + 60 | todate')
policy=$(jq -n --arg t "$cutoff" '{
  Version: "2012-10-17",
  Statement: [{
    Effect: "Deny", Action: ["*"], Resource: ["*"],
    Condition: {DateLessThan: {"aws:TokenIssueTime": $t}}
  }]}')
aws iam put-role-policy --role-name "$role" \
  --policy-name AWSRevokeOlderSessions \
  --policy-document "$policy"
echo "revoked: $role sessions issued before $cutoff"
