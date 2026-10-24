#!/bin/sh
# monitor-upstreams.sh — One-shot upstream state snapshot (wrapper, port,
# Netdata releases). CI schedules this daily and compares against the last
# known state (CI cache artifact) to open drift issues/MRs.
#
# Usage:  tools/monitor/monitor-upstreams.sh   ->  JSON on stdout
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

UPSTREAM_REPO=${UPSTREAM_REPO:-https://github.com/opnsense/plugins.git}

# Latest commit touching the upstream plugin dir
UPSTREAM_COMMIT=$(curl -fsS \
    "https://api.github.com/repos/opnsense/plugins/commits?path=net-mgmt/netdata&per_page=1" \
    | sed -n 's/.*"sha": "\([0-9a-f]*\)".*/\1/p' | head -1)

# Latest Netdata release (v prefix stripped for comparability)
NETDATA_RELEASE=$(curl -fsS https://api.github.com/repos/netdata/netdata/releases/latest \
    | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p')

# FreeBSD port version (ports git repo — authoritative, avoids flaky mirrors)
PORT_VERSION=$(curl -fsS "https://cgit.freebsd.org/ports/plain/net-mgmt/netdata/Makefile" \
    | sed -n 's/^DISTVERSION=\t*v*\([^ \t]*\).*/\1/p' | head -1)

# Our imported upstream SHA (from UPSTREAM_IMPORT file)
OUR_IMPORT=$(cat "$REPO_ROOT/UPSTREAM_IMPORT" 2>/dev/null || echo unknown)

cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "upstream_wrapper_commit": "${UPSTREAM_COMMIT:-unknown}",
  "our_import_commit": "${OUR_IMPORT}",
  "netdata_release": "${NETDATA_RELEASE:-unknown}",
  "freebsd_port_version": "${PORT_VERSION:-unknown}"
}
EOF
