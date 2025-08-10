#!/bin/bash

echo "=== Xray Debugging Information ==="
echo

# Check if debug tools are available
if ! command -v dig &> /dev/null || ! command -v ping &> /dev/null; then
    echo "⚠️  Notice: Advanced debugging tools not installed."
    echo "   To install them automatically, enable 'debug_mode: true' in addon config and restart."
    echo
fi

echo "1. Container Network Information:"
echo "   IP Address: $(hostname -i)"
echo "   Hostname: $(hostname)"
if command -v ip &> /dev/null; then
    echo "   Network interfaces:"
    ip addr show | grep -E "(inet |UP)" | sed 's/^/     /'
elif command -v ifconfig &> /dev/null; then
    echo "   Network interfaces (ifconfig):"
    ifconfig | grep -E "(inet |UP)" | sed 's/^/     /'
fi
echo

echo "2. DNS Resolution Test:"
if command -v nslookup &> /dev/null; then
    echo "   Testing DNS resolution for google.com:"
    nslookup google.com || echo "   DNS resolution failed"
elif command -v dig &> /dev/null; then
    echo "   Testing DNS resolution for google.com using dig:"
    dig +short google.com || echo "   DNS resolution failed"
else
    echo "   DNS tools not available"
fi
echo

echo "3. Xray Configuration Analysis:"
CONFIG_FILE="/config/xray_config.json"
if [[ -f "${CONFIG_FILE}" ]]; then
    echo "   Configuration file exists: ✓"
    
    # Extract server info
    SERVER=$(jq -r '.outbounds[0].settings.vnext[0].address // .outbounds[0].settings.servers[0].address // "unknown"' "${CONFIG_FILE}")
    PORT=$(jq -r '.outbounds[0].settings.vnext[0].port // .outbounds[0].settings.servers[0].port // "unknown"' "${CONFIG_FILE}")
    PROTOCOL=$(jq -r '.outbounds[0].protocol // "unknown"' "${CONFIG_FILE}")
    
    echo "   Server: ${SERVER}"
    echo "   Port: ${PORT}"
    echo "   Protocol: ${PROTOCOL}"
    echo
    
    echo "4. Server Connectivity Test:"
    if [[ "${SERVER}" != "unknown" && "${PORT}" != "unknown" ]]; then
        echo "   Testing TCP connection to ${SERVER}:${PORT}..."
        if timeout 10 nc -z "${SERVER}" "${PORT}"; then
            echo "   ✓ Server is reachable via netcat"
            
            # Additional connectivity tests
            echo "   Testing with telnet:"
            if timeout 5 telnet "${SERVER}" "${PORT}" </dev/null 2>/dev/null; then
                echo "   ✓ Telnet connection successful"
            else
                echo "   ✗ Telnet connection failed"
            fi
            
            # Test with nmap if available
            if command -v nmap &> /dev/null; then
                echo "   Testing port with nmap:"
                nmap -p "${PORT}" --connect-timeout 5s "${SERVER}" 2>/dev/null | grep -E "(open|closed|filtered)" || echo "   nmap test inconclusive"
            fi
        else
            echo "   ✗ Server is not reachable"
            echo "   Possible issues:"
            echo "     - Server is down or blocking connections"
            echo "     - Firewall blocking outbound connections"
            echo "     - Incorrect server address or port"
            echo "     - Network connectivity issues"
            
            # Try ping test
            echo "   Testing basic connectivity with ping:"
            if ping -c 3 -W 5 "${SERVER}" > /dev/null 2>&1; then
                echo "   ✓ Server responds to ping (ICMP)"
            else
                echo "   ✗ Server does not respond to ping"
            fi
        fi
    else
        echo "   ✗ Could not extract server information from config"
    fi
    echo
    
    echo "5. DNS Resolution for Server:"
    if [[ "${SERVER}" != "unknown" ]]; then
        if command -v nslookup &> /dev/null; then
            echo "   Resolving ${SERVER} with nslookup:"
            nslookup "${SERVER}" || echo "   nslookup failed for ${SERVER}"
        fi
        if command -v dig &> /dev/null; then
            echo "   Resolving ${SERVER} with dig:"
            dig +short "${SERVER}" || echo "   dig failed for ${SERVER}"
        fi
        if command -v getent &> /dev/null; then
            echo "   Resolving ${SERVER} with getent:"
            getent hosts "${SERVER}" || echo "   getent failed for ${SERVER}"
        fi
    fi
    echo
    
    echo "6. Xray Process Status:"
    if pgrep -f xray > /dev/null; then
        echo "   ✓ Xray process is running"
        echo "   Process details:"
        ps aux | grep xray | grep -v grep
    else
        echo "   ✗ Xray process is not running"
    fi
    echo
    
    echo "7. Port Listening Status:"
    if command -v netstat &> /dev/null; then
        echo "   Checking if ports 8080 and 1080 are listening:"
        netstat -tlnp | grep :8080 || echo "   Port 8080 (HTTP) is not listening"
        netstat -tlnp | grep :1080 || echo "   Port 1080 (SOCKS) is not listening"
    elif command -v ss &> /dev/null; then
        echo "   Checking if ports 8080 and 1080 are listening:"
        ss -tlnp | grep :8080 || echo "   Port 8080 (HTTP) is not listening"
        ss -tlnp | grep :1080 || echo "   Port 1080 (SOCKS) is not listening"
    else
        echo "   Network tools not available"
    fi
    echo
    
    echo "8. Test HTTP Proxy:"
    echo "   Testing local HTTP proxy on port 8080:"
    if curl -x http://127.0.0.1:8080 -s --connect-timeout 5 http://httpbin.org/ip; then
        echo "   ✓ HTTP proxy is working"
    else
        echo "   ✗ HTTP proxy test failed"
    fi
    echo
    
    echo "9. Test SOCKS Proxy:"
    echo "   Testing local SOCKS proxy on port 1080:"
    if curl -x socks5://127.0.0.1:1080 -s --connect-timeout 5 http://httpbin.org/ip; then
        echo "   ✓ SOCKS proxy is working"
    else
        echo "   ✗ SOCKS proxy test failed"
    fi
    
else
    echo "   ✗ Configuration file not found at ${CONFIG_FILE}"
fi

echo
echo "=== End of Debug Information ==="