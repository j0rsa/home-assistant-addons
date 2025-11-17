#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Gitea Mirror add-on..."

# Set defaults
export HOST="0.0.0.0"
export PORT="4321"
export DATABASE_URL="file:/data/gitea-mirror.db"

# Setup data directory (read from config with default)
DATA_DIR="$(bashio::config 'data_dir')"
DATA_DIR="${DATA_DIR:-/share/gitea-mirror/}"
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

# Ensure PATH includes /usr/local/bin where bun is installed
export PATH="/usr/local/bin:/usr/bin:/bin:${PATH}"

# Verify bun is available
if ! command -v bun >/dev/null 2>&1; then
    bashio::log.error "bun is not available in PATH. Current PATH: ${PATH}"
    exit 1
fi

bashio::log.info "bun version: $(bun --version)"

# Run the upstream entrypoint (using exec for proper signal handling)
exec /app/docker-entrypoint.sh