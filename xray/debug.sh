#!/bin/bash

echo "=== Xray Debugging Information ==="
echo

echo "1. Container Network Information:"
echo "   IP Address: $(hostname -i)"
echo "   Hostname: $(hostname)"
echo

echo "2. DNS Resolution Test:"
if command -v nslookup &> /dev/null; then
    echo "   Testing DNS resolution for google.com:"
    nslookup google.com || echo "   DNS resolution failed"
else
    echo "   nslookup not available"
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
            echo "   ✓ Server is reachable"
        else
            echo "   ✗ Server is not reachable"
            echo "   Possible issues:"
            echo "     - Server is down or blocking connections"
            echo "     - Firewall blocking outbound connections"
            echo "     - Incorrect server address or port"
            echo "     - Network connectivity issues"
        fi
    else
        echo "   ✗ Could not extract server information from config"
    fi
    echo
    
    echo "5. DNS Resolution for Server:"
    if [[ "${SERVER}" != "unknown" ]]; then
        if command -v nslookup &> /dev/null; then
            echo "   Resolving ${SERVER}:"
            nslookup "${SERVER}" || echo "   DNS resolution failed for ${SERVER}"
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
        echo "   Checking if port 8080 is listening:"
        netstat -tlnp | grep :8080 || echo "   Port 8080 is not listening"
    elif command -v ss &> /dev/null; then
        echo "   Checking if port 8080 is listening:"
        ss -tlnp | grep :8080 || echo "   Port 8080 is not listening"
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
    
else
    echo "   ✗ Configuration file not found at ${CONFIG_FILE}"
fi

echo
echo "=== End of Debug Information ==="