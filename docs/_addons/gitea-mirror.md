---
name: gitea-mirror
title: Gitea Mirror - GitHub ➜ Gitea Sync
description: Mirror GitHub repos, orgs, and metadata into your self-hosted Gitea from Home Assistant
date: 2024-01-01
category: DevOps & Git
version: 3.9.2
architectures:
  - amd64
  - aarch64
ports:
  - 4321
---

# Gitea Mirror

Gitea Mirror packages the upstream [RayLabsHQ/gitea-mirror](https://github.com/RayLabsHQ/gitea-mirror) project so you can manage repository mirroring without leaving Home Assistant. The first user you create becomes the admin; everything else is configured via the built-in dashboard.

## Features
- 🔁 Mirror personal accounts, organizations, starred repositories, and metadata (issues, labels, milestones, wiki)
- 🗓️ Scheduler support via `SCHEDULE_ENABLED`/`GITEA_MIRROR_INTERVAL`
- 🔐 Better Auth with ingress-friendly trusted origins and optional public URL overrides
- 🧱 Built-in SQLite storage persisted under `/data/gitea-mirror`
- 🩺 Health endpoint wired into the add-on watchdog (`/api/health`)

## Access
| Method | Details |
|--------|---------|
| Ingress | Settings → Add-ons → **Gitea Mirror** → Open Web UI (recommended)
| Direct | Expose port 4321/TCP in the add-on configuration if you need LAN access outside of ingress |

## Configuration Options
| Option | Type | Notes |
|--------|------|-------|
| `better_auth_url` | URL | Internal base URL used by the Better Auth backend (default: `http://127.0.0.1:4321`) |
| `public_better_auth_url` | URL | Optional public URL shown to browsers; set when reverse-proxying through your own domain |
| `trusted_origins` | List | Extra origins that can make auth requests. Leave empty to auto-fill with the ingress host |
| `github_username`, `github_token`, `github_account_type` | String/Password/List | Pre-seed GitHub credentials (`personal` or `organization`) |
| `github_app_*` | Strings | Populate when using a GitHub App (ID, installation ID, PEM private key) |
| `gitea_url`, `gitea_token`, `gitea_username`, `gitea_organization` | Strings | Target instance and default destination |
| `mirror_*` toggles | Bool | Control which repos to mirror (private/public/org/starred, include archived, skip forks, etc.) |
| `schedule_enabled`, `mirror_interval` | Bool/String | Enable the scheduler and choose an interval like `30m`, `1h`, `8h`, `1d` |
| `gitea_skip_tls_verify` | Bool | Disable TLS verification for self-signed targets (prefer mounting CA certs instead) |

All options simply seed environment variables; once the UI has booted you can override everything interactively.

## First Run Checklist
1. Start the add-on and open the ingress UI.
2. Sign up with your preferred email address — that account becomes the admin.
3. Supply GitHub and Gitea credentials (either in the UI or via the add-on options).
4. Configure the scheduler interval and click **Enable Scheduler** if you want automatic syncing.
5. Monitor **Activity → Logs** for mirror progress; the same logs are streamed to the Home Assistant add-on log window.

## Data & Secrets
- Persistent files live in `/data/gitea-mirror` (SQLite DB, generated secrets, CA bundle overrides).
- `BETTER_AUTH_SECRET` and `ENCRYPTION_SECRET` are auto-generated if left unset and stored alongside the database.
- To trust internal or self-signed CAs, drop `*.crt` files into `/data/gitea-mirror/certs` and restart the add-on.

## Troubleshooting Tips
- **Ingress redirect loops**: Set `public_better_auth_url` to the URL you use in the browser and add the same origin to `trusted_origins`.
- **Scheduler not running**: Ensure either `schedule_enabled` is `true` or `mirror_interval` is set (both will start the scheduler on boot).
- **TLS errors**: Prefer adding CA files to `/data/gitea-mirror/certs`; fall back to `gitea_skip_tls_verify` only for testing.
- **Stuck jobs**: Use the UI action **Maintenance → Restart Jobs** or restart the add-on; the startup script automatically runs recovery scripts before launching the server.

Need more help? Open an issue on [GitHub](https://github.com/j0rsa/home-assistant-addons/issues) with the add-on logs attached.
