#!/bin/sh
# drift-issue.sh — Create (or update) a GitLab issue when upstream drift
# is detected. Called from CI after drift-check.sh reported drift.
#
# Env required:
#   GITLAB_API   e.g. https://git.quadcom.ch/api/v4
#   GITLAB_TOKEN project-scoped token with api scope (CI variable)
#   PROJECT_ID   numeric GitLab project id (CI variable)
#   DRIFT_SUMMARY file with drift-check output (arg 1, default drift.log)
#
# Dedup: one open issue with label "upstream-drift" — reopens/comments
# on the existing one instead of spamming new issues.
set -eu

GITLAB_API=${GITLAB_API:?GITLAB_API required}
GITLAB_TOKEN=${GITLAB_TOKEN:?GITLAB_TOKEN required}
PROJECT_ID=${PROJECT_ID:?PROJECT_ID required}
SUMMARY_FILE=${1:-drift.log}
LABEL="upstream-drift"
API="$GITLAB_API/projects/$PROJECT_ID"

[ -f "$SUMMARY_FILE" ] || { echo "no drift summary file"; exit 1; }

BODY=$(sed 's/"/\\"/g; s/^/> /' "$SUMMARY_FILE")
TITLE="Upstream drift detected: $(date -u +%Y-%m-%d)"

# Find existing open drift issue
EXISTING=$(curl -sfS --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$API/issues?state=opened&labels=$LABEL" \
    | sed -n 's/.*"iid":\([0-9]*\).*/\1/p' | head -1 || true)

if [ -n "$EXISTING" ]; then
    # Comment on the existing issue with the new drift report
    curl -sfS --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --data-urlencode "body=Drift re-detected $(date -u +%Y-%m-%dT%H:%M:%SZ):

$BODY" \
        "$API/issues/$EXISTING/notes" > /dev/null
    echo "Updated existing drift issue #$EXISTING"
else
    curl -sfS --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --data-urlencode "title=$TITLE" \
        --data-urlencode "description=Automated upstream drift report (daily schedule).

$BODY

**Action** (ADR-002): re-import the changed upstream files, merge our
maintainer delta, open upstream PR if applicable. Never auto-merge." \
        --data-urlencode "labels=$LABEL,automated" \
        "$API/issues" > /dev/null
    echo "Created new drift issue"
fi
