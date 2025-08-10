#!/usr/bin/with-contenv bashio

NETMAKER_SERVER=$(bashio::config 'netmaker_server')
NETCLIENT_TOKEN=$(bashio::config 'netclient_token')
WG_INTERFACE=$(bashio::config 'wg_interface')
SOCKS_PROXY=$(bashio::config 'socks_proxy')
ENABLE_PROXY=$(bashio::config 'enable_proxy')
LOG_LEVEL=$(bashio::config 'log_level')
DEBUG_MODE=$(bashio::config 'debug_mode')
AUTO_RESTART=$(bashio::config 'auto_restart')

bashio::log.info "Starting Netmaker Client add-on..."

# Validate required configuration
if [[ -z "${NETCLIENT_TOKEN}" ]]; then
    bashio::log.error "Netclient token is required. Please provide a valid netclient_token."
    exit 1
fi

if [[ -z "${NETMAKER_SERVER}" ]]; then
    bashio::log.error "Netmaker server URL is required. Please provide a valid netmaker_server."
    exit 1
fi

# Install debug tools if debug mode is enabled
if [[ "${DEBUG_MODE}" == "true" ]]; then
    bashio::log.info "Debug mode enabled - installing debugging tools..."
    apk add --no-cache \
        iputils \
        bind-tools \
        tcpdump \
        netcat-openbsd > /dev/null 2>&1
    bashio::log.info "Debug tools installed successfully"
fi

# Set up TUN device
bashio::log.info "Setting up network devices..."
mkdir -p /dev/net || true
if [ ! -e /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

# Export environment variables for netclient
export NETMAKER_SERVER
export NETCLIENT_TOKEN
export WG_IFACE=${WG_INTERFACE}

bashio::log.info "Netmaker Server: ${NETMAKER_SERVER}"
bashio::log.info "WireGuard Interface: ${WG_INTERFACE}"
bashio::log.info "SOCKS Proxy: ${SOCKS_PROXY}"
bashio::log.info "Proxy Enabled: ${ENABLE_PROXY}"

# Function to setup netclient
setup_netclient() {
    bashio::log.info "Setting up Netclient..."
    
    # Check netclient version
    bashio::log.info "Netclient version:"
    netclient -v || true
    
    # Clean up any previous installation
    bashio::log.info "Cleaning up previous netclient installation..."
    netclient uninstall || true
    
    # Install netclient
    bashio::log.info "Installing netclient..."
    if ! netclient install; then
        bashio::log.error "Failed to install netclient"
        return 1
    fi
    
    # Join the network
    bashio::log.info "Joining Netmaker network..."
    if ! netclient join -t "${NETCLIENT_TOKEN}"; then
        bashio::log.warning "Failed to join network or already joined"
    fi
    
    return 0
}

# Function to setup WireGuard interface
setup_wireguard() {
    bashio::log.info "Setting up WireGuard interface..."
    
    # Wait for WireGuard interface to be available
    local retry_count=0
    local max_retries=30
    
    while [ $retry_count -lt $max_retries ]; do
        if ip link show "${WG_INTERFACE}" >/dev/null 2>&1; then
            bashio::log.info "WireGuard interface ${WG_INTERFACE} found"
            break
        fi
        bashio::log.info "Waiting for WireGuard interface ${WG_INTERFACE}... (attempt $((retry_count + 1))/${max_retries})"
        sleep 2
        retry_count=$((retry_count + 1))
    done
    
    if [ $retry_count -eq $max_retries ]; then
        bashio::log.error "WireGuard interface ${WG_INTERFACE} not found after ${max_retries} attempts"
        bashio::log.info "Available interfaces:"
        ip addr show
        return 1
    fi
    
    # Show interface details
    bashio::log.info "WireGuard interface details:"
    ip addr show "${WG_INTERFACE}"
    
    # Ensure interface is up
    bashio::log.info "Bringing up WireGuard interface..."
    ip link set "${WG_INTERFACE}" up || true
    
    return 0
}

# Function to setup routing
setup_routing() {
    bashio::log.info "Setting up routing..."
    
    # Route default traffic via WireGuard interface
    if ip route replace default dev "${WG_INTERFACE}"; then
        bashio::log.info "Default route set via ${WG_INTERFACE}"
    else
        bashio::log.warning "Failed to set default route via ${WG_INTERFACE}"
    fi
    
    # Show current routing table
    if [[ "${DEBUG_MODE}" == "true" ]]; then
        bashio::log.info "Current routing table:"
        ip route show
    fi
}

# Function to start tun2socks
start_tun2socks() {
    if [[ "${ENABLE_PROXY}" != "true" ]]; then
        bashio::log.info "Proxy disabled, starting in direct WireGuard mode"
        bashio::log.info "WireGuard tunnel is active and routing traffic directly"
        # Keep the container running
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
    fi
    
    bashio::log.info "Starting tun2socks proxy bridge..."
    bashio::log.info "Bridging ${WG_INTERFACE} to SOCKS proxy at ${SOCKS_PROXY}"
    
    # Start tun2socks
    exec tun2socks \
        -device "${WG_INTERFACE}" \
        -proxy "socks5://${SOCKS_PROXY}" \
        -loglevel "${LOG_LEVEL}"
}

# Main execution loop
main_loop() {
    while true; do
        bashio::log.info "Starting Netmaker Client setup..."
        
        if setup_netclient && setup_wireguard && setup_routing; then
            bashio::log.info "Setup completed successfully"
            start_tun2socks
        else
            bashio::log.error "Setup failed"
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