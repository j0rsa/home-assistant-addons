# Gitea Mirror App

Gitea Mirror lets you mirror GitHub users, organizations, and metadata into your self-hosted Gitea instance without leaving Home Assistant. It packages the upstream [RayLabsHQ/gitea-mirror](https://github.com/RayLabsHQ/gitea-mirror) container, enables persistent storage, and exposes the UI via direct port forwarding.

## Highlights
- 🔁 Mirror personal or organization repos (code, issues, labels, wiki, releases, LFS)
- 🗓️ Scheduler support via `SCHEDULE_ENABLED` / `GITEA_MIRROR_INTERVAL`
- 🔐 Built-in Better Auth with configurable trusted origins for reverse proxies/ingress
- 📦 Configurable data directory (default: `/share/gitea-mirror/`)
- 📈 Health endpoint wired to Home Assistant watchdog (`/api/health`)

## Access & Networking
- Default port: `4321` (exposed via port forwarding)
- Web UI: Access via **Settings → Apps → Gitea Mirror → Open Web UI** or directly at `http://[HASS_HOST]:4321`
- Port forwarding: The app exposes port `4321/tcp` by default for direct access to the web UI

## Configuration

**Minimal configuration required!** This app uses sensible defaults and most settings can be configured through the web UI:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `data_dir` | String | `/share/gitea-mirror/` | Directory where application data (SQLite DB, secrets, CA certs) is stored |
| `better_auth_url` | URL | `http://172.30.32.1:8123` | Base URL for authentication callbacks (typically your Home Assistant URL) |
| `trusted_origins` | Array | `["http://172.30.32.1:8123"]` | List of trusted origins for authentication (add your public domain if accessing externally) |

**Other defaults:**
- **Authentication**: Better Auth with configurable trusted origins
- **Mirror behavior**: Mirrors both private and public repos, excludes archived and forks
- **Scheduler**: Enabled with 8-hour interval
- **Account type**: Personal (not organization)
- **Database**: Stored at `{data_dir}/gitea-mirror.db` (default: `/share/gitea-mirror/gitea-mirror.db`)

All credentials (GitHub token, Gitea URL, Gitea token) can be set up through the web UI after first launch. Secrets stay inside the app data directory; they are not written back to `configuration.yaml`.

**Note**: The `data_dir` option allows you to choose where application data is stored. Use `/share/gitea-mirror/` for shared access or `/data/gitea-mirror/` to include it in app backups.

**Authentication**: If you're accessing the app from multiple origins (e.g., localhost and a public domain), configure `better_auth_url` to your primary public URL and add all origins to `trusted_origins`. The app will use `window.location.origin` for client-side auth requests when `PUBLIC_BETTER_AUTH_URL` is not set.

## First-time Setup
1. Start the app and open the Web UI via **Settings → Apps → Gitea Mirror → Open Web UI** or directly at `http://[HASS_HOST]:4321`.
2. Create the first user — it becomes the admin automatically.
3. Configure GitHub and Gitea credentials through **Settings → Integrations** in the web UI.
4. Click **Import** to discover repositories, then **Mirror** (the scheduler runs automatically every 8 hours).
5. Use the activity feed to confirm successful runs; error details also appear in the Home Assistant app logs.

All settings (credentials, mirror behavior, scheduling, auth) can be configured and adjusted through the web UI.

## Data & Updates
- **Database**: Stored at `{data_dir}/gitea-mirror.db` (default: `/share/gitea-mirror/gitea-mirror.db`)
- **Application data**: Stored in the directory specified by `data_dir` option (default: `/share/gitea-mirror/`)
  - SQLite database files
  - Generated secrets (`BETTER_AUTH_SECRET`, `ENCRYPTION_SECRET`)
  - CA bundle overrides
- The app automatically generates missing `BETTER_AUTH_SECRET` and `ENCRYPTION_SECRET` values during startup and reuses them from disk.
- Upgrades keep data intact; Home Assistant will restart the container if the `/api/health` probe fails.

**Backup considerations:**
- Data in `/share/` (default location) is not included in app backups but is accessible via Samba if configured
- Data in `/data/` is included in app backups
- To include the database in backups, set `data_dir` to `/data/gitea-mirror/`

## Troubleshooting
- **Authentication issues**: Configure credentials through the web UI (Settings → Integrations). Verify your GitHub token has the necessary permissions and your Gitea token can create repositories. If accessing from multiple origins, ensure all origins are listed in `trusted_origins`.
- **Debug logging**: Enable debug logging inside the Gitea Mirror UI (Settings → General → Logging).
- **Self-signed certificates**: Add CA files to `{data_dir}/certs` for self-signed certificates (default: `/share/gitea-mirror/certs`), or adjust TLS settings through the web UI.
- **Data directory**: Check the app logs to see which data directory is being used. You can change it via the `data_dir` configuration option.
- **Backups**: If you want application data included in app backups, set `data_dir` to `/data/gitea-mirror/` instead of the default `/share/gitea-mirror/`.
- **Configuration**: Most settings can be managed through the web UI. Configure `data_dir`, `better_auth_url`, and `trusted_origins` in the app options if needed.
- **Port access**: If you can't access the web UI, verify that port `4321` is exposed in the app configuration and not blocked by your firewall.
