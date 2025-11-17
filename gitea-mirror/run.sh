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

# Check if upstream entrypoint exists, otherwise run directly
if [ -x "/app/docker-entrypoint.sh" ]; then
    exec /app/docker-entrypoint.sh
else
    # Fallback: try to run gitea-mirror directly
    if command -v gitea-mirror >/dev/null 2>&1; then
        exec gitea-mirror
    else
        bashio::log.error "Could not find gitea-mirror executable or entrypoint"
        exit 1
    fi
fi
