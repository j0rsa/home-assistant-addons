#!/usr/bin/with-contenv bashio

PROXY_USER=$(bashio::config 'proxy_user')
PROXY_PASSWORD=$(bashio::config 'proxy_password')
ALLOWED_DEST_FQDN=$(bashio::config 'allowed_dest_fqdn')

bashio::log.info "Starting Go SOCKS5 Proxy add-on..."

# Port is always 1080 internally (can be remapped in HA network config)
export PROXY_PORT="1080"

# Configure authentication
if [[ -n "${PROXY_USER}" ]] && [[ -n "${PROXY_PASSWORD}" ]]; then
    bashio::log.info "Authentication enabled for user: ${PROXY_USER}"
    export PROXY_USER="${PROXY_USER}"
    export PROXY_PASSWORD="${PROXY_PASSWORD}"
else
    bashio::log.warning "Running without authentication - consider setting username and password for production use"
    export PROXY_USER=""
    export PROXY_PASSWORD=""
fi

# Configure IP allowlist (convert list to comma-separated string)
if bashio::config.has_value 'allowed_ips'; then
    ALLOWED_IPS=$(bashio::config 'allowed_ips' | jq -r 'join(",")')
    if [[ -n "${ALLOWED_IPS}" ]]; then
        bashio::log.info "IP allowlist configured: ${ALLOWED_IPS}"
        export ALLOWED_IPS="${ALLOWED_IPS}"
    fi
fi

# Configure destination filter
if [[ -n "${ALLOWED_DEST_FQDN}" ]]; then
    bashio::log.info "Destination filter configured: ${ALLOWED_DEST_FQDN}"
    export ALLOWED_DEST_FQDN="${ALLOWED_DEST_FQDN}"
fi

bashio::log.info "SOCKS5 proxy will be available on port 1080"

exec /usr/local/bin/socks5
