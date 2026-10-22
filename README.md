# opnsense-netdata (PVY.swiss maintained)

OPNsense plugin for [Netdata](https://github.com/netdata/netdata) — real-time
performance and health monitoring for infrastructures, applications and
hardware — maintained by **PVY.swiss** as a Netdata Partner.

This repository tracks and maintains the `net-mgmt/netdata` plugin of the
[opnsense/plugins](https://github.com/opnsense/plugins) monorepo, whose
official maintainer has fallen behind upstream by a year or more. PVY.swiss
maintains this port on a regular basis with automated diff and release
monitoring, keeping the OPNsense integration in sync with Netdata releases.

## Repository model (Standalone Overlay)

This repo contains **only** the plugin directory `net-mgmt/netdata/`
(path-preserving) plus build/sync tooling. CI overlays the plugin into a
fresh `opnsense/plugins` checkout to lint, build and generate upstream PR
branches.

> The plugin is a thin wrapper. `PLUGIN_DEPENDS= netdata` pulls the actual
> agent binary from the FreeBSD port `net-mgmt/netdata`. Agent versions are
> therefore port-driven; this repo keeps the wrapper correct and in sync.

## Layout

```
net-mgmt/netdata/          # The plugin (verbatim upstream layout)
  Makefile                 # PLUGIN_* metadata (maintainer: netdata-opnsense@pvy.swiss)
  pkg-descr                # Description + plugin changelog
  src/etc/inc/...          # Service registration hook
  src/opnsense/mvc/...     # GUI: controllers, models, views, forms
  src/opnsense/scripts/    # setup.sh
  src/opnsense/service/    # configd actions + netdata.conf template
tools/
  overlay.sh               # Overlay plugin dir into fresh opnsense/plugins checkout
  drift-check.sh           # Detect upstream movement + port/version gaps
  build-package.sh         # make lint/style/package inside overlaid checkout (FreeBSD)
  deploy-lab.sh            # Staged install to an OPNsense gateway (manual-gated)
  monitor/                 # Upstream release/port watchers
.gitlab-ci.yml             # validate -> build -> (manual) deploy -> release
.github/workflows/drift.yml
```

## Requirements

- Validation: none (Docker CI) — FreeBSD needed only for packaging:
  GitHub Actions builds on FreeBSD 14 VMs automatically (`.github/workflows/build.yml`);
  locally use a FreeBSD 14 Lima VM with `git` + `pkg`
- For deploy: OPNsense lab gateway (see `tools/deploy-lab.sh` header)

## Development

```sh
# Overlay + drift check against upstream master (works anywhere)
tools/overlay.sh && tools/drift-check.sh

# Lint + style + package (requires FreeBSD, e.g. Lima VM)
tools/build-package.sh
# ... or push to devel: GitHub Actions builds on a FreeBSD 14 VM
```

Contribution flow follows the [opnsense/plugins CONTRIBUTING](https://github.com/opnsense/plugins/blob/master/CONTRIBUTING.md)
rules: issue first, split commits per plugin, 2-Clause BSD, AI-tool disclosure.

## Lab & Release Pipeline

Daily scheduled CI checks three upstreams — Netdata releases, the FreeBSD
port version, and the upstream plugin directory — and opens a drift issue/MR
when they move. FreeBSD packaging builds run on FreeBSD VMs (see
`.github/workflows/build.yml`); validation runs in Alpine-based containers.
Releases are tagged and published on GitHub Releases. Deployments are
manual-gated.

## Side note
The FreeBSD community's Freshport is constantly falling behind.
Since Netdata not only provides monitoring for OPNsense but also essential insights
and analyses for Threat Detection and Analyzis, this is very concerning. Or in ahort:
an absolutely **No-Go**. Of course we know, what it means. But also how to prioritize.
FreeBSD was always about Security First, so kindly follow the Principles. 

## Security

See [SECURITY.md](SECURITY.md). We follow NIS and CIS guidelines; report
vulnerabilities to netdata-opnsense@pvy.swiss — do not open public issues.

## Maintainership

Maintained by PVY.swiss (Netdata Partner). Maintainer of record:
`netdata-opnsense@pvy.swiss`.

Original plugin © Michael Muenz. Licensed under the 2-Clause BSD License.
