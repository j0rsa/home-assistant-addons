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

# Configure header-based authentication (always enabled for nginx proxy)
export HEADER_AUTH_ENABLED=true
export HEADER_AUTH_USER_HEADER="X-Remote-User"
export HEADER_AUTH_EMAIL_HEADER="X-Remote-Email"
export HEADER_AUTH_NAME_HEADER="X-Remote-Name"
export HEADER_AUTH_AUTO_PROVISION="true"

bashio::log.info "Header-based authentication enabled for nginx proxy"
bashio::log.info "Admin user will be auto-provisioned: admin@homeassistant.local"

# Start the application on internal port 4322 (nginx will proxy from 4321)
export HOST=0.0.0.0
export PORT=4322

# Function to handle shutdown signals
cleanup() {
    bashio::log.info "Shutting down..."
    kill $APP_PID 2>/dev/null || true
    kill $NGINX_PID 2>/dev/null || true
    wait $APP_PID 2>/dev/null || true
    wait $NGINX_PID 2>/dev/null || true
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Start the application in the background
bashio::log.info "Starting Gitea Mirror application on port 4322..."
/app/docker-entrypoint.sh &
APP_PID=$!

# Wait for the app to be ready (check if process is still running and port is listening)
bashio::log.info "Waiting for application to start..."
for i in $(seq 1 30); do
    if ! kill -0 $APP_PID 2>/dev/null; then
        bashio::log.error "Application failed to start"
        exit 1
    fi
    # Check if port 4322 is listening (using netcat or curl)
    if command -v nc >/dev/null 2>&1 && nc -z 127.0.0.1 4322 2>/dev/null; then
        bashio::log.info "Application is ready on port 4322"
        break
    elif command -v curl >/dev/null 2>&1 && curl -s http://127.0.0.1:4322/api/health >/dev/null 2>&1; then
        bashio::log.info "Application is ready on port 4322"
        break
    fi
    if [ $i -eq 30 ]; then
        bashio::log.warning "Application may not be ready, but starting nginx anyway"
    fi
    sleep 1
done

# Start nginx (which will proxy from 4321 to 4322 with admin headers)
bashio::log.info "Starting nginx reverse proxy on port 4321..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Wait for nginx to start
sleep 2

# Check if nginx is running
if ! kill -0 $NGINX_PID 2>/dev/null; then
    bashio::log.error "Nginx failed to start"
    kill $APP_PID 2>/dev/null || true
    exit 1
fi

bashio::log.info "Nginx proxy started successfully"
bashio::log.info "Requests to port 4321 will be proxied to the app with admin headers"
bashio::log.info "Admin user: admin@homeassistant.local (auto-provisioned on first request)"

# Wait for nginx (main process) - if it exits, we exit
wait $NGINX_PID
EXIT_CODE=$?

# Cleanup
cleanup