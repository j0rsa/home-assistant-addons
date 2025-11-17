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

# Read trusted_origins from config (array)
TRUSTED_ORIGINS_ARRAY="$(bashio::config 'trusted_origins' '[]')"
bashio::log.info "TRUSTED_ORIGINS_ARRAY: ${TRUSTED_ORIGINS_ARRAY}"
# Convert array to comma-separated list, adding supervisor URL as default if empty
if [ "${TRUSTED_ORIGINS_ARRAY}" = "[]" ] || [ -z "${TRUSTED_ORIGINS_ARRAY}" ]; then
    # Use supervisor URL as default
    BETTER_AUTH_TRUSTED_ORIGINS="${SUPERVISOR_URL}"
else
    # Convert JSON array to comma-separated list using jq if available, otherwise use bash
    if command -v jq >/dev/null 2>&1; then
        BETTER_AUTH_TRUSTED_ORIGINS="$(echo "${TRUSTED_ORIGINS_ARRAY}" | jq -r 'join(",")')"
    else
        # Fallback: simple bash parsing (removes brackets and quotes)
        BETTER_AUTH_TRUSTED_ORIGINS="$(echo "${TRUSTED_ORIGINS_ARRAY}" | sed 's/\[//g' | sed 's/\]//g' | sed 's/"//g' | sed 's/, */,/g')"
    fi
    # Add supervisor URL if not already in the list
    if [[ ! "${BETTER_AUTH_TRUSTED_ORIGINS}" =~ ${SUPERVISOR_URL} ]]; then
        BETTER_AUTH_TRUSTED_ORIGINS="${SUPERVISOR_URL},${BETTER_AUTH_TRUSTED_ORIGINS}"
    fi
fi

export BETTER_AUTH_TRUSTED_ORIGINS
bashio::log.info "BETTER_AUTH_TRUSTED_ORIGINS: ${BETTER_AUTH_TRUSTED_ORIGINS}"

# Verify bun is available
if ! command -v bun >/dev/null 2>&1; then
    bashio::log.error "bun is not available in PATH. Current PATH: ${PATH}"
    exit 1
fi

bashio::log.info "bun version: $(bun --version)"

# Run the upstream entrypoint (using exec for proper signal handling)
exec /app/docker-entrypoint.sh