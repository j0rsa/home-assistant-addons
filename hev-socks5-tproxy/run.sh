#!/usr/bin/with-contenv bashio

CONFIG_FILE="/tmp/hev-socks5-tproxy.yml"
TPROXY_PORT=12345  # Internal port for tproxy daemon

bashio::log.info "Starting HevSocks5 TProxy add-on..."

# Read configuration
SOCKS5_ADDRESS=$(bashio::config 'socks5_address')
SOCKS5_PORT=$(bashio::config 'socks5_port')
SOCKS5_USERNAME=$(bashio::config 'socks5_username')
SOCKS5_PASSWORD=$(bashio::config 'socks5_password')
SOCKS5_UDP_MODE=$(bashio::config 'socks5_udp_mode')
DNS_ENABLED=$(bashio::config 'dns_enabled')
DNS_LISTEN_PORT=$(bashio::config 'dns_listen_port')
DNS_UPSTREAM_ADDRESS=$(bashio::config 'dns_upstream_address')
DNS_UPSTREAM_PORT=$(bashio::config 'dns_upstream_port')

# Read listen ports array
LISTEN_PORTS=$(jq -r '.listen_ports[]' /data/options.json)

# Validate required fields
if [[ -z "${SOCKS5_ADDRESS}" ]]; then
    bashio::log.fatal "socks5_address is required!"
    exit 1
fi

bashio::log.info "SOCKS5 server: ${SOCKS5_ADDRESS}:${SOCKS5_PORT}"
bashio::log.info "UDP relay mode: ${SOCKS5_UDP_MODE}"
bashio::log.info "Listen ports: $(echo ${LISTEN_PORTS} | tr '\n' ' ')"

# Generate configuration file
cat > "${CONFIG_FILE}" <<EOF
main:
  workers: 1

socks5:
  port: ${SOCKS5_PORT}
  address: ${SOCKS5_ADDRESS}
  udp: '${SOCKS5_UDP_MODE}'
EOF

# Add authentication if provided
if [[ -n "${SOCKS5_USERNAME}" ]] && [[ -n "${SOCKS5_PASSWORD}" ]]; then
    bashio::log.info "SOCKS5 authentication enabled for user: ${SOCKS5_USERNAME}"
    cat >> "${CONFIG_FILE}" <<EOF
  username: '${SOCKS5_USERNAME}'
  password: '${SOCKS5_PASSWORD}'
EOF
fi

# Add TCP/UDP listener on internal tproxy port
cat >> "${CONFIG_FILE}" <<EOF

tcp:
  port: ${TPROXY_PORT}
  address: '::'

udp:
  port: ${TPROXY_PORT}
  address: '::'
EOF

# Add DNS configuration if enabled
if [[ "${DNS_ENABLED}" == "true" ]]; then
    if [[ -z "${DNS_UPSTREAM_ADDRESS}" ]]; then
        bashio::log.fatal "dns_upstream_address is required when dns_enabled is true!"
        exit 1
    fi
    bashio::log.info "DNS proxy enabled: listening on ${DNS_LISTEN_PORT}, upstream ${DNS_UPSTREAM_ADDRESS}:${DNS_UPSTREAM_PORT}"
    cat >> "${CONFIG_FILE}" <<EOF

dns:
  port: ${DNS_LISTEN_PORT}
  address: '::'
  upstream: ${DNS_UPSTREAM_ADDRESS}
  upstream-port: ${DNS_UPSTREAM_PORT}
EOF
fi

# Add misc settings
cat >> "${CONFIG_FILE}" <<EOF

misc:
  log-level: info
EOF

bashio::log.info "Configuration generated at ${CONFIG_FILE}"
bashio::log.debug "$(cat ${CONFIG_FILE})"

# Setup iptables rules to redirect configured ports to tproxy
bashio::log.info "Setting up iptables rules..."

# Create routing table for tproxy
ip rule add fwmark 1 lookup 100 2>/dev/null || true
ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null || true
ip -6 rule add fwmark 1 lookup 100 2>/dev/null || true
ip -6 route add local ::/0 dev lo table 100 2>/dev/null || true

# Setup iptables TPROXY rules for each listen port
for PORT in ${LISTEN_PORTS}; do
    bashio::log.info "Redirecting port ${PORT} to tproxy..."
    
    # TCP
    iptables -t mangle -A PREROUTING -p tcp --dport "${PORT}" -j TPROXY \
        --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || \
        bashio::log.warning "Failed to add iptables TCP rule for port ${PORT}"
    
    # UDP  
    iptables -t mangle -A PREROUTING -p udp --dport "${PORT}" -j TPROXY \
        --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || \
        bashio::log.warning "Failed to add iptables UDP rule for port ${PORT}"
    
    # IPv6 TCP
    ip6tables -t mangle -A PREROUTING -p tcp --dport "${PORT}" -j TPROXY \
        --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || \
        bashio::log.warning "Failed to add ip6tables TCP rule for port ${PORT}"
    
    # IPv6 UDP
    ip6tables -t mangle -A PREROUTING -p udp --dport "${PORT}" -j TPROXY \
        --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || \
        bashio::log.warning "Failed to add ip6tables UDP rule for port ${PORT}"
done

bashio::log.info "iptables rules configured"

# Cleanup function
cleanup() {
    bashio::log.info "Cleaning up iptables rules..."
    for PORT in ${LISTEN_PORTS}; do
        iptables -t mangle -D PREROUTING -p tcp --dport "${PORT}" -j TPROXY \
            --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || true
        iptables -t mangle -D PREROUTING -p udp --dport "${PORT}" -j TPROXY \
            --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || true
        ip6tables -t mangle -D PREROUTING -p tcp --dport "${PORT}" -j TPROXY \
            --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || true
        ip6tables -t mangle -D PREROUTING -p udp --dport "${PORT}" -j TPROXY \
            --tproxy-mark 0x1/0x1 --on-port "${TPROXY_PORT}" 2>/dev/null || true
    done
    ip rule del fwmark 1 lookup 100 2>/dev/null || true
    ip -6 rule del fwmark 1 lookup 100 2>/dev/null || true
}

trap cleanup EXIT

exec /usr/local/bin/hev-socks5-tproxy "${CONFIG_FILE}"
