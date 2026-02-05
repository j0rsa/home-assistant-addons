---
name: gitea-mirror
title: Gitea Mirror - GitHub ➜ Gitea Sync
description: Mirror GitHub repos, orgs, and metadata into your self-hosted Gitea from Home Assistant
date: 2026-02-02
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
- 🧱 Built-in SQLite storage with configurable data directory (default: `/share/gitea-mirror/`)
- 🩺 Health endpoint wired into the app watchdog (`/api/health`)

## Access
| Method | Details |
|--------|---------|
| Ingress | Settings → Apps → **Gitea Mirror** → Open Web UI (recommended)
| Direct | Expose port 4321/TCP in the app configuration if you need LAN access outside of ingress |

## Configuration Options

**Minimal configuration required!** This app uses sensible defaults and most settings can be configured through the web UI:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `data_dir` | String | `/share/gitea-mirror/` | Directory where application data (SQLite DB, secrets, CA certs) is stored |

**Other defaults:**
- **Authentication**: Configured automatically for ingress
- **Mirror behavior**: Private and public repos, excludes archived/forks
- **Scheduling**: Enabled with 8-hour intervals
- **Account type**: Personal GitHub account
- **Database**: Stored at `/config/gitea-mirror.db` (included in app backups)

All credentials (GitHub token, Gitea URL, Gitea token) and advanced options can be set up through the web UI after first launch.

**Note**: The `data_dir` option allows you to choose where application data is stored. Use `/share/gitea-mirror/` for shared access or `/data/gitea-mirror/` to include it in app backups.

## First Run Checklist
1. Start the app and open the ingress UI.
2. Sign up with your preferred email address — that account becomes the admin.
3. Configure GitHub and Gitea credentials through **Settings → Integrations** in the web UI.
4. Click **Import** to discover repositories, then **Mirror** (scheduler runs automatically every 8 hours).
5. Monitor **Activity → Logs** for mirror progress; the same logs are streamed to the Home Assistant app log window.

**Note**: No app configuration required. The scheduler is enabled by default, and all settings can be adjusted through the web UI.

## Data & Secrets
- **Database**: Stored at `/config/gitea-mirror.db` (included in app backups)
- **Application data**: Stored in the directory specified by `data_dir` option (default: `/share/gitea-mirror/`)
  - SQLite database files (if not using `/config`)
  - Generated secrets (`BETTER_AUTH_SECRET`, `ENCRYPTION_SECRET`)
  - CA bundle overrides
- `BETTER_AUTH_SECRET` and `ENCRYPTION_SECRET` are auto-generated if left unset and stored in the data directory.
- To trust internal or self-signed CAs, drop `*.crt` files into `{data_dir}/certs` and restart the app.

**Backup considerations:**
- Data in `/config/` (including the database) is included in app backups
- Data in `/share/` is not included in app backups but is accessible via Samba if configured
- Data in `/data/` is included in app backups

## Troubleshooting Tips
- **Authentication failures**: Configure credentials through the web UI (Settings → Integrations). Verify your GitHub token has repository access permissions and your Gitea token can create repositories.
- **TLS errors**: Add CA files to `{data_dir}/certs` for self-signed certificates (default: `/share/gitea-mirror/certs`), or adjust TLS settings through the web UI.
- **Stuck jobs**: Use the UI action **Maintenance → Restart Jobs** or restart the app; the startup script automatically runs recovery scripts before launching the server.
- **Data directory**: Check the app logs to see which data directory is being used. You can change it via the `data_dir` configuration option.
- **Backups**: If you want application data included in app backups, set `data_dir` to `/data/gitea-mirror/` instead of the default `/share/gitea-mirror/`.

Need more help? Open an issue on [GitHub](https://github.com/j0rsa/home-assistant-addons/issues) with the app logs attached.
