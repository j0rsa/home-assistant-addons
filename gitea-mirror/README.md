# Gitea Mirror Add-on

Gitea Mirror lets you mirror GitHub users, organizations, and metadata into your self-hosted Gitea instance without leaving Home Assistant. It packages the upstream [RayLabsHQ/gitea-mirror](https://github.com/RayLabsHQ/gitea-mirror) container, enables persistent storage, and exposes the UI through Home Assistant ingress.

## Highlights
- 🔁 Mirror personal or organization repos (code, issues, labels, wiki, releases, LFS)
- 🗓️ Scheduler support via `SCHEDULE_ENABLED` / `GITEA_MIRROR_INTERVAL`
- 🔐 Built-in Better Auth with configurable trusted origins for reverse proxies/ingress
- 📦 Data persisted under `/data/gitea-mirror` inside the add-on
- 📈 Health endpoint wired to Home Assistant watchdog (`/api/health`)

## Access & Networking
- Default port: `4321` (remapped automatically when using ingress)
- Ingress URL: **Settings → Add-ons → Gitea Mirror → Open Web UI**
- Optional direct access: toggle the 4321/TCP port in the add-on configuration panel if you want to expose it on your Home Assistant host

## Configuration
| Option | Type | Purpose |
|--------|------|---------|
| `better_auth_url` | URL | Base URL Gitea Mirror should use for auth callbacks (defaults to the local container address) |
| `public_better_auth_url` | URL (optional) | Public URL shown to browsers (set when publishing through your own domain) |
| `trusted_origins` | List | Additional origins that are allowed to make auth requests (ingress host is added automatically when left empty) |
| `github_username`, `github_token` | String/Password | Pre-fill GitHub credentials; you can also enter these later via the UI |
| `github_account_type` | `personal` / `organization` | Mirrors only your user or includes org scopes |
| `github_app_*` | Strings | Optional GitHub App configuration (ID, installation ID, PEM private key) |
| `gitea_url`, `gitea_token`, `gitea_username`, `gitea_organization` | Strings | Target instance and default organization/account for mirrored repositories |
| `mirror_private`, `mirror_public`, `include_archived`, `skip_forks`, `mirror_starred`, `mirror_orgs`, `preserve_org_structure`, `only_mirror_orgs` | Bool | Toggle which repositories are imported and how they are organized |
| `schedule_enabled` | Bool | Enables the built-in scheduler at startup |
| `mirror_interval` | String | Interval string accepted by upstream (`30m`, `1h`, `8h`, `1d`, ...). Setting this also enables the scheduler |
| `gitea_skip_tls_verify` | Bool | Disable TLS validation when pointing at self-signed/on-prem Gitea

Secrets stay inside the add-on data directory; they are not written back to `configuration.yaml`.

## First-time Setup
1. Start the add-on and open the Web UI via ingress.
2. Create the first user — it becomes the admin automatically.
3. Configure GitHub + Gitea credentials from **Settings → Integrations** inside the app, or supply them through the add-on options above.
4. Click **Import** to discover repositories, then **Mirror** (or rely on the scheduler if enabled).
5. Use the activity feed to confirm successful runs; error details also appear in the Home Assistant add-on logs.

## Data & Updates
- Persistent state (SQLite DB, generated secrets, CA bundle overrides) lives in `/data/gitea-mirror`.
- The add-on automatically generates missing `BETTER_AUTH_SECRET` and `ENCRYPTION_SECRET` values during startup and reuses them from disk.
- Upgrades keep data intact; Home Assistant will restart the container if the `/api/health` probe fails.

## Troubleshooting
- Increase verbosity by enabling debug logging inside the Gitea Mirror UI (Settings → General → Logging).
- If ingress SSO fails, add your Home Assistant base URL to `trusted_origins` and set `public_better_auth_url` to the URL you use in the browser.
- When connecting to self-signed Gitea endpoints, either mount your CA bundle into `/data/gitea-mirror/certs` or toggle `gitea_skip_tls_verify` (less secure).
