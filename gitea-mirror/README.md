# Gitea Mirror Add-on

Gitea Mirror lets you mirror GitHub users, organizations, and metadata into your self-hosted Gitea instance without leaving Home Assistant. It packages the upstream [RayLabsHQ/gitea-mirror](https://github.com/RayLabsHQ/gitea-mirror) container, enables persistent storage, and exposes the UI through Home Assistant ingress.

## Highlights
- 🔁 Mirror personal or organization repos (code, issues, labels, wiki, releases, LFS)
- 🗓️ Scheduler support via `SCHEDULE_ENABLED` / `GITEA_MIRROR_INTERVAL`
- 🔐 Built-in Better Auth with configurable trusted origins for reverse proxies/ingress
- 📦 Configurable data directory (default: `/share/gitea-mirror/`)
- 📈 Health endpoint wired to Home Assistant watchdog (`/api/health`)

## Access & Networking
- Default port: `4321` (remapped automatically when using ingress)
- Ingress URL: **Settings → Add-ons → Gitea Mirror → Open Web UI**
- Optional direct access: toggle the 4321/TCP port in the add-on configuration panel if you want to expose it on your Home Assistant host

## Configuration

**Minimal configuration required!** This add-on uses sensible defaults and most settings can be configured through the web UI:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `data_dir` | String | `/share/gitea-mirror/` | Directory where application data (SQLite DB, secrets, CA certs) is stored |

**Other defaults:**
- **Authentication**: Configured automatically for ingress
- **Mirror behavior**: Mirrors both private and public repos, excludes archived and forks
- **Scheduler**: Enabled with 8-hour interval
- **Account type**: Personal (not organization)
- **Database**: Stored at `/config/gitea-mirror.db` (included in add-on backups)

All credentials (GitHub token, Gitea URL, Gitea token) can be set up through the web UI after first launch. Secrets stay inside the add-on data directory; they are not written back to `configuration.yaml`.

**Note**: The `data_dir` option allows you to choose where application data is stored. Use `/share/gitea-mirror/` for shared access or `/data/gitea-mirror/` to include it in add-on backups.

## First-time Setup
1. Start the add-on and open the Web UI via ingress.
2. Create the first user — it becomes the admin automatically.
3. Configure GitHub and Gitea credentials through **Settings → Integrations** in the web UI.
4. Click **Import** to discover repositories, then **Mirror** (the scheduler runs automatically every 8 hours).
5. Use the activity feed to confirm successful runs; error details also appear in the Home Assistant add-on logs.

All settings (credentials, mirror behavior, scheduling, auth) can be configured and adjusted through the web UI.

## Data & Updates
- **Database**: Stored at `/config/gitea-mirror.db` (included in add-on backups)
- **Application data**: Stored in the directory specified by `data_dir` option (default: `/share/gitea-mirror/`)
  - SQLite database files (if not using `/config`)
  - Generated secrets (`BETTER_AUTH_SECRET`, `ENCRYPTION_SECRET`)
  - CA bundle overrides
- The add-on automatically generates missing `BETTER_AUTH_SECRET` and `ENCRYPTION_SECRET` values during startup and reuses them from disk.
- Upgrades keep data intact; Home Assistant will restart the container if the `/api/health` probe fails.

**Backup considerations:**
- Data in `/config/` (including the database) is included in add-on backups
- Data in `/share/` is not included in add-on backups but is accessible via Samba if configured
- Data in `/data/` is included in add-on backups

## Troubleshooting
- **Authentication issues**: Configure credentials through the web UI (Settings → Integrations). Verify your GitHub token has the necessary permissions and your Gitea token can create repositories.
- **Debug logging**: Enable debug logging inside the Gitea Mirror UI (Settings → General → Logging).
- **Self-signed certificates**: Add CA files to `{data_dir}/certs` for self-signed certificates (default: `/share/gitea-mirror/certs`), or adjust TLS settings through the web UI.
- **Data directory**: Check the add-on logs to see which data directory is being used. You can change it via the `data_dir` configuration option.
- **Backups**: If you want application data included in add-on backups, set `data_dir` to `/data/gitea-mirror/` instead of the default `/share/gitea-mirror/`.
- **Configuration**: Most settings can be managed through the web UI - only `data_dir` needs to be configured in the add-on options.
