# Changelog — opnsense-netdata (PVY.swiss)

All notable changes to the `net-mgmt/netdata` OPNsense plugin maintained by
PVY.swiss. The plugin-level changelog visible to users lives in
`net-mgmt/netdata/pkg-descr` (OPNsense convention).

## [0.1.0] — 2026-10-22

### Added
- Repository scaffold: standalone overlay model
- Seeded `net-mgmt/netdata/` verbatim from opnsense/plugins master
  @ e4578ae667349c7300cd61a01677399ab6e389cc (upstream plugin v1.2 rev 1)
- Tooling: overlay, drift-check, build-package, deploy-lab (stub), monitors
- CI: GitLab validate/build/deploy/release stages + GitHub drift mirror
- Security policy (NIS/CIS posture), BSD-2 LICENSE, MR template

### Changed
- `PLUGIN_MAINTAINER` → netdata-opnsense@pvy.swiss (PVY group mailbox)
