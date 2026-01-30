#!/usr/bin/with-contenv bashio

bashio::log.info "Starting SNI Socket Proxy add-on..."

# Read SOCKS5 proxy configuration from Home Assistant
SOCKS5_ADDRESS="$(bashio::config 'socks5_address' '10.0.1.3')"
SOCKS5_PORT="$(bashio::config 'socks5_port' '1080')"

# Validate configuration
if [ -z "${SOCKS5_ADDRESS}" ]; then
    bashio::log.error "socks5_address is required but not provided"
    exit 1
fi

if [ -z "${SOCKS5_PORT}" ]; then
    bashio::log.error "socks5_port is required but not provided"
    exit 1
fi

# Set PROXY environment variable for proxychains (format: "socks5 address port")
export PROXY="socks5 ${SOCKS5_ADDRESS} ${SOCKS5_PORT}"

bashio::log.info "SOCKS5 proxy configured: ${SOCKS5_ADDRESS}:${SOCKS5_PORT}"
bashio::log.info "SNI proxy listening on ports 80 (HTTP) and 443 (HTTPS)"

# Generate proxychains configuration from PROXY env var
# Parse PROXY env var (format: "socks5 address port")
PROXY_TYPE=$(echo "${PROXY}" | awk '{print $1}')
PROXY_HOST=$(echo "${PROXY}" | awk '{print $2}')
PROXY_PORT=$(echo "${PROXY}" | awk '{print $3}')

bashio::log.info "Generating proxychains configuration for ${PROXY_TYPE} ${PROXY_HOST}:${PROXY_PORT}"

# Create proxychains configuration
cat > /etc/proxychains.conf << EOF
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
${PROXY_TYPE} ${PROXY_HOST} ${PROXY_PORT}
EOF

bashio::log.info "Proxychains configuration created"

# Run sniproxy with proxychains4
if command -v proxychains4 >/dev/null 2>&1 && command -v sniproxy >/dev/null 2>&1; then
    bashio::log.info "Starting sniproxy with proxychains4..."
    exec proxychains4 -f /etc/proxychains.conf sniproxy -f -c /etc/sniproxy/sniproxy.conf
else
    bashio::log.error "proxychains4 or sniproxy command not found"
    exit 1
fi
