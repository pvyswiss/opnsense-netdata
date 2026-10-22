#!/bin/sh
# build-package.sh — Lint, style-check and package the plugin inside an
# overlaid opnsense/plugins checkout. REQUIRES FreeBSD (or Lima FreeBSD VM)
# with the OPNsense plugin toolchain (git, pkg, sudo).
#
# Usage:  tools/build-package.sh          (runs overlay.sh first)
# Exits:  non-zero on lint/style/package failure
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

"$(dirname -- "$0")/overlay.sh"

cd "$REPO_ROOT/.upstream/plugins/net-mgmt/netdata"

make clean
make lint
make style
make package

echo "Package built:"
ls -l *.txz 2>/dev/null || true
