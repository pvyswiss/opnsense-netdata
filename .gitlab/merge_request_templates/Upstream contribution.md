# Upstream contribution MR

<!--
Follows opnsense/plugins CONTRIBUTING rules.
MRs in THIS repo are internal; this template documents what a compliant
upstream PR needs. Never push directly to opnsense/plugins from CI.
-->

## Upstream reference

- Issue opened in opnsense/plugins: <!-- link, REQUIRED before PR -->
- Branch based on latest `master`: yes/no
- Commits split to `net-mgmt/netdata/` only: yes/no

## Compliance checklist

- [ ] 2-Clause BSD license respected
- [ ] `PLUGIN_VERSION` / `PLUGIN_REVISION` bumped (only if behaviour changed)
- [ ] `pkg-descr` changelog entry added
- [ ] `make lint` and `make style` pass (build-package.sh output linked)
- [ ] AI tool usage disclosed in the upstream PR (name + model), if used

## Summary

<!-- What changed and why; link drift issue/MR in this repo -->
