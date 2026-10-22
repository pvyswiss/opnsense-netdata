#!/bin/sh
# drift-check.sh — Detect meaningful drift between our import base and the
# world. Drift semantics:
#
#   1. Upstream wrapper movement: opnsense/plugins changed net-mgmt/netdata
#      since UPSTREAM_IMPORT  -> action: re-import + merge our delta.
#      (Our OWN intentional delta vs upstream — maintainer field, changelog —
#      is NOT drift; it is our working state pending the upstream PR.)
#   2. Port gap: Netdata latest release != FreeBSD port version
#      -> action: escalate to port maintainer / Netdata Inc.
#
# Usage:   tools/drift-check.sh
# Exit:    0 = quiet, 1 = upstream wrapper moved (actionable), 3 = tool error; port gap is advisory-only
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
IMPORT_SHA=$(cat "$REPO_ROOT/UPSTREAM_IMPORT" 2>/dev/null || true)
[ -n "$IMPORT_SHA" ] || { echo "UPSTREAM_IMPORT missing"; exit 3; }

STATUS=0

echo "=== Upstream wrapper movement since import ${IMPORT_SHA:0:8} ==="
COMPARE=$(curl -fsS \
    "https://api.github.com/repos/opnsense/plugins/compare/${IMPORT_SHA}...master" \
    || true)
if [ -z "$COMPARE" ]; then
    echo "ERROR - GitHub compare API unreachable"
    exit 3
fi
MOVED=$(printf '%s' "$COMPARE" \
    | grep -o '"filename": *"net-mgmt/netdata/[^"]*"' \
    | sed 's/.*: *"//;s/"//' | sort -u || true)
if [ -n "$MOVED" ]; then
    echo "UPSTREAM MOVED - files changed since our import:"
    echo "$MOVED"
    STATUS=1
else
    echo "No movement - upstream net-mgmt/netdata unchanged since import."
fi

echo
echo "=== Netdata release vs FreeBSD port ==="
ND_VERSION=$(curl -fsS https://api.github.com/repos/netdata/netdata/releases/latest \
    | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p')
PORT_VERSION=$(curl -fsS "https://cgit.freebsd.org/ports/plain/net-mgmt/netdata/Makefile" \
    | sed -n 's/^DISTVERSION=\t*v*\([^ \t]*\).*/\1/p' | head -1)
echo "Netdata latest release - ${ND_VERSION:-unknown}"
echo "FreeBSD port version  - ${PORT_VERSION:-unknown}"
if [ -n "${ND_VERSION:-}" ] && [ -n "${PORT_VERSION:-}" ] && [ "$ND_VERSION" != "$PORT_VERSION" ]; then
    # Chronic condition, not actionable in this repo: warn only,
    # recorded in upstream-state.json for the daily report. Not a pipeline
    # failure — a permanently red main branch hides real drift signals.
    echo "GAP (advisory) - port ${PORT_VERSION} lags upstream ${ND_VERSION}; escalate outside this repo"
else
    echo "In sync."
fi

exit $STATUS
