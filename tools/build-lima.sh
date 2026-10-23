#!/bin/sh
# build-lima.sh — Build the plugin package inside the local Lima FreeBSD VM
# (ADR-003: Lima = local dev build environment; GitHub Actions = CI build).
#
# Usage:  tools/build-lima.sh
# Needs:  limactl, running instance "freebsd15" (see Obsidian vault config)
# Result: os-netdata*.pkg in ../build-output/ (native macOS folder)
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_DIR="$REPO_ROOT/../build-output"
VM=freebsd15

limactl list | grep -q "$VM.*Running" || limactl start "$VM"

# Toolchain guard: VM may have been factory-reset (GUI restart semantics);
# provision blocks restore it at instance creation, but check fast & advise.
if ! limactl shell "$VM" -- sh -c 'command -v phpcs >/dev/null && command -v gmake >/dev/null' 2>/dev/null; then
    echo "ERROR: build toolchain missing in VM (phpcs/gmake)." >&2
    echo "       Recreate the instance: limactl delete -f $VM && limactl start freebsd15.yaml" >&2
    echo "       (provision blocks re-install the toolchain)" >&2
    exit 1
fi

# Ship plugin tree into VM (mounts are read-only for ~; build-output is the write path)
limactl cp -r "$REPO_ROOT/net-mgmt" "$VM":/tmp/plugin-import

limactl shell "$VM" -- sudo sh -c '
set -e
rm -rf /tmp/build && mkdir -p /tmp/build
git clone -q --depth 1 https://github.com/opnsense/plugins.git /tmp/build/plugins
git clone -q --depth 1 https://github.com/opnsense/core.git /tmp/build/core
rm -rf /tmp/build/plugins/net-mgmt/netdata
cp -R /tmp/plugin-import/netdata /tmp/build/plugins/net-mgmt/netdata
cd /tmp/build/plugins/net-mgmt/netdata
make lint
make style
make package
cp work/pkg/*.pkg "/Volumes/Data/Repos/opnsense-netdata-plugin/build-output/"
'

echo "Build artifacts:"
ls -l "$OUTPUT_DIR"/*.pkg
