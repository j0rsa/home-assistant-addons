#!/usr/bin/with-contenv bashio

API_KEY=$(bashio::config 'api_key')
READ_ONLY_API_KEY=$(bashio::config 'read_only_api_key')
READ_ONLY=$(bashio::config 'read_only')
LOG_LEVEL=$(bashio::config 'log_level')
MAX_REQUEST_SIZE_MB=$(bashio::config 'max_request_size_mb')
WEB_UI_ENABLED=$(bashio::config 'web_ui_enabled')
CONFIG_DIR="/config"
QDRANT_CONFIG_FILE="${CONFIG_DIR}/config.yaml"

bashio::log.info "Starting Qdrant add-on..."

# Create Qdrant configuration file
bashio::log.info "Creating Qdrant configuration..."

mkdir -p /data/static

cat > "${QDRANT_CONFIG_FILE}" << EOF
log_level: ${LOG_LEVEL}

cluster:
  enabled: false

service:
  host: 0.0.0.0
  http_port: 6333
  grpc_port: 6334
  max_request_size_mb: ${MAX_REQUEST_SIZE_MB}
  enable_static_content: ${WEB_UI_ENABLED}
  static_content_dir: /data/static
  enable_cors: true
EOF

# Add API key and read-only configuration if needed
if [[ -n "${API_KEY}" ]]; then
    bashio::log.info "API key authentication enabled"
    cat >> "${QDRANT_CONFIG_FILE}" << EOF
  api_key: "${API_KEY}"
EOF
else
    bashio::log.info "Running without API key authentication"
fi

if [[ -n "${READ_ONLY_API_KEY}" ]]; then
    bashio::log.info "Read-only API key authentication enabled"
    cat >> "${QDRANT_CONFIG_FILE}" << EOF
  read_only_api_key: "${READ_ONLY_API_KEY}"
EOF
fi

if [[ "${READ_ONLY}" == "true" ]]; then
    bashio::log.info "Read-only mode enabled"
    cat >> "${QDRANT_CONFIG_FILE}" << EOF
  read_only: true
EOF
fi

bashio::log.info "Qdrant configuration created successfully"
bashio::log.info "REST API will be available on port 6333"
bashio::log.info "gRPC API will be available on port 6334"

if [[ -n "${API_KEY}" ]]; then
    bashio::log.info "API authentication is enabled"
    bashio::log.info "Read-only mode: ${READ_ONLY}"
else
    bashio::log.warning "API authentication is disabled - consider setting an API key for production use"
fi

qdrant --config-path "${QDRANT_CONFIG_FILE}"