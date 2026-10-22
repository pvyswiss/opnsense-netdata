#!/bin/sh
# deploy-lab.sh — Staged package install on the OPNsense lab gateway.
#
# STATUS: STUB — wired in M4. Pipeline uses a dedicated restricted SSH key/user
# (netdata-deploy), NEVER root credentials. Manual CI gate required.
#
# Rollback procedure (verified before any deploy):
#   opnsense# pkg remove os-netdata-devel   # or plugin package name
#   opnsense# pkg install os-netdata        # restore previous from official repo
#
# Usage:  tools/deploy-lab.sh <package.txz> <host>
set -eu

PKG=${1:?package .txz required}
HOST=${2:?host required}

echo "M4: deploy of $PKG to $HOST not yet enabled (manual gate + restricted deploy user required)."
exit 1
