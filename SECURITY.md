# Security Policy — opnsense-netdata (PVY.swiss)

## Supported versions

| Version | Supported |
|---|---|
| main (latest release) | yes |
| older releases | best effort |

## Reporting a vulnerability

Report to **netdata-opnsense@pvy.swiss** (PGP available on request).
Do **not** open public issues for security-relevant findings. Target
response time: 48h; assessment: 5 business days.

## Hardening posture

This project follows NIS and CIS security guidelines:

- No credentials in the repository. Pipeline secrets live as masked,
  protected GitLab CI/CD variables only. Tokens are fine-grained and scoped.
- Deploy to the lab gateway uses a dedicated restricted SSH key/user,
  never root credentials or interactive passwords.
- Release tags are signed; packages are verified before lab installation
  and a rollback procedure is documented in `tools/deploy-lab.sh`.
- CI never auto-merges upstream changes; drift produces an issue/MR that
  requires human review (supply-chain risk mitigation).
- `pkg audit` runs on every build; SBOM is attached to releases.
