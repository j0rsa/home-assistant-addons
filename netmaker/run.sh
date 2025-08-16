#!/usr/bin/with-contenv bashio

NETCLIENT_TOKEN=$(bashio::config 'netclient_token')
WG_INTERFACE=$(bashio::config 'wg_interface')
SOCKS_PROXY=$(bashio::config 'socks_proxy')
WG_2_SOCKS_PROXY=$(bashio::config 'wg_2_socks_proxy')
LOG_LEVEL=$(bashio::config 'log_level')
DEBUG_MODE=$(bashio::config 'debug_mode')
AUTO_RESTART=$(bashio::config 'auto_restart')
HOST_NAME=$(bashio::config 'host_name')

bashio::log.info "Starting Netmaker Client add-on..."

# Validate required configuration
if [[ -z "${NETCLIENT_TOKEN}" ]]; then
    bashio::log.error "Netclient token is required. Please provide a valid netclient_token."
    exit 1
fi

mkdir -p /data/netclient
ln -s /data/netclient /etc/netclient

# Set up TUN device
bashio::log.info "Setting up network devices..."
mkdir -p /dev/net || true
if [ ! -e /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

# Export environment variables for netclient
export NETCLIENT_TOKEN
export WG_IFACE=${WG_INTERFACE}
export HOST_NAME=${HOST_NAME}

bashio::log.info "SOCKS Proxy: ${SOCKS_PROXY}"
SOCKS_PROXY_IP=$(echo "${SOCKS_PROXY}" | cut -d ':' -f 1)
SOCKS_PROXY_PORT=$(echo "${SOCKS_PROXY}" | cut -d ':' -f 2)

cat <<EOF > /data/redsocks.conf
redsocks {
  local_ip = 127.0.0.1;       # redsocks listens locally
  local_port = 12345;         # local port for redirected traffic
  ip = ${SOCKS_PROXY_IP};     # external socks proxy hostname (use actual IP if needed)
  port = ${SOCKS_PROXY_PORT}; # socks proxy port
  type = socks5;              # SOCKS version
}
EOF

bashio::log.info "Starting redsocks..."
redsocks -c /data/redsocks.conf

bashio::log.info "Forwards HTTP(S) traffic to ${SOCKS_PROXY}"

iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports 12345
iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-ports 12345

# Function to setup netclient
setup_netclient() {
    bashio::log.info "Setting up Netclient..."
    
    # Check netclient version
    bashio::log.info "Netclient version:"
    netclient version || true
    
    # Join the network
    bashio::log.info "Joining Netmaker network..."
    if ! netclient join -t "${NETCLIENT_TOKEN}" -o "${HOST_NAME}"; then
        bashio::log.warning "Failed to join network or already joined"
    fi
    
    return 0
}

# Function to wait for and setup WireGuard interface with immediate proxy
setup_wireguard_with_proxy() {
    bashio::log.info "Waiting for WireGuard interface ${WG_INTERFACE} (indefinite wait)..."
    
    # Wait indefinitely for WireGuard interface to be available
    while true; do
        if ip link show "${WG_INTERFACE}" >/dev/null 2>&1; then
            bashio::log.info "WireGuard interface ${WG_INTERFACE} found!"
            break
        fi
        bashio::log.info "WireGuard interface ${WG_INTERFACE} not ready yet, waiting..."
        sleep 5
    done
    
    # Show interface details
    bashio::log.info "WireGuard interface details:"
    ip addr show "${WG_INTERFACE}"
    
    # Ensure interface is up
    bashio::log.info "Bringing up WireGuard interface..."
    ip link set "${WG_INTERFACE}" up || true
    
    # Setup routing immediately
    bashio::log.info "Setting up routing..."
    if ip route replace default dev "${WG_INTERFACE}"; then
        bashio::log.info "Default route set via ${WG_INTERFACE}"
    else
        bashio::log.warning "Failed to set default route via ${WG_INTERFACE}"
    fi
    
    # Show current routing table if in debug mode
    if [[ "${DEBUG_MODE}" == "true" ]]; then
        bashio::log.info "Current routing table:"
        ip route show
    fi
    
    bashio::log.info "WireGuard to SOCKS Proxy: ${WG_2_SOCKS_PROXY}"
    # Start tun2socks immediately if proxy is enabled
    if [[ "${WG_2_SOCKS_PROXY}" == "true" ]]; then
        bashio::log.info "Starting tun2socks proxy bridge immediately..."
        bashio::log.info "Bridging ${WG_INTERFACE} to SOCKS proxy at ${SOCKS_PROXY}"
        
        # Start tun2socks - this will block
        exec tun2socks \
            -device "${WG_INTERFACE}" \
            -proxy "socks5://${SOCKS_PROXY}" \
            -loglevel "${LOG_LEVEL}"
    else
        bashio::log.info "Proxy disabled, running in direct WireGuard mode"
        # Keep monitoring the interface
        monitor_interface
    fi
}

# Function to monitor interface when proxy is disabled
monitor_interface() {
    bashio::log.info "WireGuard tunnel is active and routing traffic directly"
    # Keep the container running and monitor the interface
    while true; do
        sleep 60
        # Check if interface is still up
        if ! ip link show "${WG_INTERFACE}" >/dev/null 2>&1; then
            bashio::log.error "WireGuard interface ${WG_INTERFACE} is down"
            if [[ "${AUTO_RESTART}" == "true" ]]; then
                bashio::log.info "Auto-restart enabled, restarting setup..."
                return 1
            else
                exit 1
            fi
        fi
    done
}



# Main execution loop
main_loop() {
    while true; do
        bashio::log.info "Starting Netmaker Client setup..."
        
        if setup_netclient; then
            bashio::log.info "Netclient setup completed successfully"
            # Wait for WireGuard interface and start proxy immediately when ready
            setup_wireguard_with_proxy
        else
            bashio::log.error "Netclient setup failed"
        fi
        
        if [[ "${AUTO_RESTART}" == "true" ]]; then
            bashio::log.info "Auto-restart enabled, retrying in 30 seconds..."
            sleep 30
        else
            bashio::log.error "Setup failed and auto-restart is disabled"
            exit 1
        fi
    done
}

# Start main loop
main_loop