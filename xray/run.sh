#!/usr/bin/with-contenv bashio

XRAY_CONFIG_JSON=$(bashio::config 'xray_config_json')
XRAY_CONFIG_BASE64=$(bashio::config 'xray_config_base64')
LOG_LEVEL=$(bashio::config 'log_level')
DEBUG_MODE=$(bashio::config 'debug_mode')

CONFIG_FILE="/config/xray_config.json"

bashio::log.info "Starting Xray add-on..."

# Check if either config is provided
if [[ -z "${XRAY_CONFIG_JSON}" && -z "${XRAY_CONFIG_BASE64}" ]]; then
    bashio::log.error "No Xray configuration provided. Please set either 'xray_config_json' or 'xray_config_base64'."
    exit 1
fi

# Process configuration
if [[ -n "${XRAY_CONFIG_BASE64}" ]]; then
    bashio::log.info "Using base64 encoded configuration"
    echo "${XRAY_CONFIG_BASE64}" | base64 -d > "${CONFIG_FILE}"
    if [[ $? -ne 0 ]]; then
        bashio::log.error "Failed to decode base64 configuration"
        exit 1
    fi
elif [[ -n "${XRAY_CONFIG_JSON}" ]]; then
    bashio::log.info "Using JSON configuration"
    echo "${XRAY_CONFIG_JSON}" > "${CONFIG_FILE}"
fi

# Validate JSON configuration
if ! jq empty "${CONFIG_FILE}" 2>/dev/null; then
    bashio::log.error "Invalid JSON configuration provided"
    exit 1
fi

bashio::log.info "Configuration file created successfully"

# Set log level in config if not already set
jq --arg level "${LOG_LEVEL}" '.log.loglevel = $level' "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

bashio::log.info "Starting Xray with configuration..."
bashio::log.info "Proxy will be available on port 8080"

# Debug: Show configuration (without sensitive data) if debug mode is enabled
if [[ "${DEBUG_MODE}" == "true" ]]; then
    bashio::log.info "Configuration preview (debug mode):"
    jq 'del(.outbounds[].settings.vnext[]?.users[]?.id) | del(.outbounds[].settings.servers[]?.password)' "${CONFIG_FILE}" || bashio::log.warning "Could not preview config"
fi

# Debug: Test connectivity to server
SERVER=$(jq -r '.outbounds[0].settings.vnext[0].address // .outbounds[0].settings.servers[0].address // "unknown"' "${CONFIG_FILE}")
PORT=$(jq -r '.outbounds[0].settings.vnext[0].port // .outbounds[0].settings.servers[0].port // "unknown"' "${CONFIG_FILE}")

if [[ "${SERVER}" != "unknown" && "${PORT}" != "unknown" ]]; then
    bashio::log.info "Testing connectivity to ${SERVER}:${PORT}..."
    if timeout 10 nc -z "${SERVER}" "${PORT}"; then
        bashio::log.info "✓ Server ${SERVER}:${PORT} is reachable"
    else
        bashio::log.warning "✗ Server ${SERVER}:${PORT} is not reachable - this may cause connection issues"
    fi
else
    bashio::log.warning "Could not extract server info from config for connectivity test"
fi

# Start Xray
exec /usr/local/bin/xray run -config "${CONFIG_FILE}"