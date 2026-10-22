#!/bin/sh
# overlay.sh — Clone/refresh a pristine opnsense/plugins checkout and overlay
# our plugin directory into it, preserving upstream paths.
#
# Usage:   tools/overlay.sh [upstream_ref]     (default: master)
# Result:  .upstream/plugins/ ready for lint/build/PR-branch generation
# Env:     UPSTREAM_REPO  override upstream URL (default opnsense/plugins)
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REF=${1:-master}
UPSTREAM_REPO=${UPSTREAM_REPO:-https://github.com/opnsense/plugins.git}
WORKDIR="$REPO_ROOT/.upstream"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ -d plugins/.git ]; then
    git -C plugins fetch --depth 1 origin "$REF"
    git -C plugins checkout --detach FETCH_HEAD
else
    git clone --depth 1 --branch "$REF" "$UPSTREAM_REPO" plugins
fi

# Overlay our plugin (destructive by design: overlay must win)
rm -rf "plugins/net-mgmt/netdata"
cp -R "$REPO_ROOT/net-mgmt/netdata" "plugins/net-mgmt/netdata"

echo "Overlay complete: .upstream/plugins @ $REF ($(git -C plugins rev-parse --short HEAD))"
