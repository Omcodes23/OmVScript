# OmScript

OmScript is a lightweight, modular bootstrap installer and provisioning toolkit for Linux systems.
Start small with idempotent shell modules (developer workstation, server roles, NAS, Docker checks),
then scale to a full OS project later.

OmScript is intentionally script-first: small, reviewable modules that are safe to run multiple times.

---

## Project goals

- Provide simple, auditable `curl | bash` bootstrap that is safer than single-file installers.
- Organize functionality into small, idempotent `modules/*` scripts (one module = one task).
- Make it easy to convert or provision an existing Linux machine into roles: developer, server, NAS, etc.
- Provide CI (shellcheck) and release artifacts (sha256 sums) to improve trust.

---

## Quickstart (recommended)

> Inspect before running. Do **not** run unknown scripts.

```bash
# Preview the bootstrap (recommended)
curl -fsSL https://raw.githubusercontent.com/<OWNER>/omscript/main/install.sh -o /tmp/omscript-install.sh
less /tmp/omscript-install.sh

# Verify checksum (after you publish a release and generate SHAS)
curl -fsSL https://raw.githubusercontent.com/<OWNER>/omscript/main/scripts/generate-sha256sums.sh -o /tmp/generate-sha256sums.sh
bash /tmp/generate-sha256sums.sh

# Run (after inspection / verification)
sudo bash /tmp/omscript-install.sh
