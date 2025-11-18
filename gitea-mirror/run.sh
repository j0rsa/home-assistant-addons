#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Gitea Mirror add-on..."

# Setup data directory (read from config with default)
DATA_DIR="$(bashio::config 'data_dir')"
DATA_DIR="${DATA_DIR:-/share/gitea-mirror/}"
export DATABASE_URL="file:${DATA_DIR}/gitea-mirror.db"
APP_DATA_LINK="/app/data"

bashio::log.info "Using data directory: ${DATA_DIR}"

mkdir -p "${DATA_DIR}"
# Delete existing symlink if it exists
if [ -e "${APP_DATA_LINK}" ] && [ ! -L "${APP_DATA_LINK}" ]; then
    rm -rf "${APP_DATA_LINK}"
fi
# Create symlink to data directory if it doesn't exist
if [ ! -L "${APP_DATA_LINK}" ]; then
    ln -s "${DATA_DIR}" "${APP_DATA_LINK}"
fi

bashio::log.info "Gitea Mirror configuration complete"

# Setup BETTER_AUTH_URL and BETTER_AUTH_TRUSTED_ORIGINS
# Get Home Assistant supervisor URL as default
SUPERVISOR_URL="http://172.30.32.1:8123"
if bashio::var.has_value "$(bashio::supervisor 'host')"; then
    SUPERVISOR_HOST="$(bashio::supervisor 'host')"
    SUPERVISOR_PORT="$(bashio::supervisor 'port' || echo '8123')"
    SUPERVISOR_URL="http://${SUPERVISOR_HOST}:${SUPERVISOR_PORT}"
fi

# Read better_auth_url from config with supervisor URL as default
BETTER_AUTH_URL="$(bashio::config 'better_auth_url')"
BETTER_AUTH_URL="${BETTER_AUTH_URL:-${SUPERVISOR_URL}}"
export BETTER_AUTH_URL
bashio::log.info "BETTER_AUTH_URL: ${BETTER_AUTH_URL}"

# Read trusted_origins from /data/options.json directly
BETTER_AUTH_TRUSTED_ORIGINS=$(cat /data/options.json | jq -r '.trusted_origins // [] | if type == "array" and length > 0 then join(",") else empty end' 2>/dev/null || echo '')
if [ -z "${BETTER_AUTH_TRUSTED_ORIGINS}" ]; then
    BETTER_AUTH_TRUSTED_ORIGINS="${SUPERVISOR_URL}"
fi

# Ensure supervisor URL is included if not already present
if [[ ! "${BETTER_AUTH_TRUSTED_ORIGINS}" =~ ${SUPERVISOR_URL} ]]; then
    BETTER_AUTH_TRUSTED_ORIGINS="${SUPERVISOR_URL},${BETTER_AUTH_TRUSTED_ORIGINS}"
fi

export BETTER_AUTH_TRUSTED_ORIGINS
bashio::log.info "BETTER_AUTH_TRUSTED_ORIGINS: ${BETTER_AUTH_TRUSTED_ORIGINS}"

# Verify bun is available
if ! command -v bun >/dev/null 2>&1; then
    bashio::log.error "bun is not available in PATH. Current PATH: ${PATH}"
    exit 1
fi

bashio::log.info "bun version: $(bun --version)"

export HOST=0.0.0.0
export PORT=4321

# Run the upstream entrypoint (using exec for proper signal handling)
exec /app/docker-entrypoint.sh