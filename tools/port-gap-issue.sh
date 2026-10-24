#!/bin/sh
# port-gap-issue.sh — Advisory: the FreeBSD netdata port lagging behind
# upstream Netdata releases is chronic (ADR-002, escalation outside this
# repo). Update a standing issue's description instead of spamming.
#
# Env required: GITLAB_API, GITLAB_TOKEN, PROJECT_ID (same as drift-issue.sh)
set -eu

GITLAB_API=${GITLAB_API:?GITLAB_API required}
GITLAB_TOKEN=${GITLAB_TOKEN:?GITLAB_TOKEN required}
PROJECT_ID=${PROJECT_ID:?PROJECT_ID required}
STATE_FILE=${1:-upstream-state.json}
LABEL="port-gap"
API="$GITLAB_API/projects/$PROJECT_ID"

[ -f "$STATE_FILE" ] || { echo "no state file"; exit 0; }

ND=$(sed -n 's/.*"netdata_release": *"\([^"]*\)".*/\1/p' "$STATE_FILE")
PORT=$(sed -n 's/.*"freebsd_port_version": *"\([^"]*\)".*/\1/p' "$STATE_FILE")

[ -n "$ND" ] && [ -n "$PORT" ] || { echo "state incomplete"; exit 0; }
[ "$ND" != "$PORT" ] || { echo "port in sync"; exit 0; }

TITLE="Standing advisory: FreeBSD netdata port lags upstream (port $PORT vs Netdata $ND)"

EXISTING=$(curl -sfS --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$API/issues?state=opened&labels=$LABEL" \
    | sed -n 's/.*"iid":\([0-9]*\).*/\1/p' | head -1 || true)

DESC="The FreeBSD port \`net-mgmt/netdata\` tracks at **$PORT** while Netdata
releases are at **$ND**. Agent versions on OPNsense are port-driven
(ADR-002: wrapper maintenance + monitoring; port takeover decided for
Q1/2027). Until then this gap is tracked here.

Data as of $(date -u +%Y-%m-%d). Updated automatically by the daily
drift schedule — description refresh, no new issues."

if [ -n "$EXISTING" ]; then
    curl -sfS --request PUT --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --data-urlencode "description=$DESC" \
        "$API/issues/$EXISTING" > /dev/null
    echo "Updated standing port-gap issue #$EXISTING (port $PORT vs $ND)"
else
    curl -sfS --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --data-urlencode "title=$TITLE" \
        --data-urlencode "description=$DESC" \
        --data-urlencode "labels=$LABEL,advisory,automated" \
        "$API/issues" > /dev/null
    echo "Created standing port-gap issue (port $PORT vs $ND)"
fi
