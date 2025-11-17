# Repository Guidelines

## Project Structure & Module Organization
Each top-level directory named after an add-on (e.g., `airang`, `duplicati`, `ollama`, `netmaker`) contains `config.yaml`, `Dockerfile`, optional `build.yaml`, assets, and helper scripts such as `run.sh`. Shared docs live under `docs/` (`_addons/` per add-on, `assets/` for media), and `repository.json` must be kept in sync whenever add-ons are added, renamed, or deprecated.

## Build, Test, and Development Commands
Use the Home Assistant CLI to build locally: `ha addons build <addon_slug>` from a Supervisor devcontainer pointed at this checkout. For a standalone smoke test run `docker build -t local/<slug> <slug>` and `docker run --rm -it --env-file <slug>/build.yaml local/<slug>`; ensure `run.sh` stays executable and idempotent for asset-heavy add-ons like `open-webui`.

## Coding Style & Naming Conventions
Dockerfiles should keep the existing base images (Alpine or Debian Slim) and minimize layers. Shell scripts start with `#!/bin/bash` plus `set -euo pipefail`, indenting four spaces; YAML files use two. Config keys stay kebab-case in `config.yaml`, environment variables screaming snake case, and filenames lowercase with hyphens unless Home Assistant mandates otherwise (`Dockerfile`, `README.md`).

## Testing Guidelines
Before opening a PR run `ha addons validate` (available inside the Home Assistant development container) to catch schema or manifest issues. When modifying scripts, add lightweight `--dry-run` or log statements for reviewers, and refresh `docs/_addons/<slug>.md` with sample options that match `config.yaml`, including required ports or credentials.

## Commit & Pull Request Guidelines
Commits follow the concise, imperative style already in history (`Added docs`, `create webui tmp dir`) and should group related changes per add-on. Reference impacted add-ons in the PR title, link forum threads or issues, list the build/test commands you ran, and attach screenshots or curl output for UI or API updates. Highlight edits to `repository.json` because they affect the Supervisor store cache.

## Security & Configuration Tips
Never embed secrets or tokens in `config.yaml` defaults, Docker build args, or `run.sh`; require users to supply them via Home Assistant options. When downloading third-party binaries, pin versions and hashes, prefer official mirrors, and document the source in the add-on README. Exposed web UIs (Ariang, Open WebUI, Netmaker) should bind to `0.0.0.0` yet clearly document auth expectations and TLS/SNI nuances in `docs/`.
