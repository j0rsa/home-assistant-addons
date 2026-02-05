---
name: xray
title: Xray - Proxy Client
description: High-performance proxy client supporting VLESS/VMess/Trojan protocols
category: Networking & Proxy
version: latest
architectures:
  - amd64
  - aarch64
  - armv7
ports:
  - 8080
  - 1080
---

# Xray App

Xray-core client for connecting to VLESS/VMess/Trojan servers and creating local HTTP and SOCKS proxies.

## About

This app runs Xray-core as a client to connect to your Xray server (VLESS, VMess, Trojan protocols) and provides local proxies that you can use to route traffic through your Xray server.

## Features

- 🔐 **Multiple Protocols**: VLESS, VMess, Trojan support
- 🌐 **HTTP Proxy**: Port 8080 for HTTP applications
- 🧦 **SOCKS Proxy**: Port 1080 for SOCKS5 applications
- ⚡ **High Performance**: Efficient traffic handling
- 🛡️ **Advanced Routing**: Flexible traffic routing rules
- 🔧 **Full Configuration**: Complete Xray config support

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "Xray" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Configure your Xray client settings
5. Start the app

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 8080 | TCP | HTTP proxy |
| 1080 | TCP | SOCKS5 proxy |

## Configuration

The app accepts the complete Xray client configuration in JSON format.

### Option: `xray_config_json`

The complete Xray client configuration in JSON format.

### Option: `xray_config_base64`

The Xray configuration encoded in base64 (useful for special characters).

### Option: `log_level`

Set the log level: `debug`, `info`, `warning`, `error`, or `none`.

## Example Configuration

### VLESS Configuration

```yaml
xray_config_json: |
  {
    "inbounds": [
      {
        "tag": "http-in",
        "port": 8080,
        "protocol": "http",
        "settings": {
          "auth": "noauth"
        }
      },
      {
        "tag": "socks-in",
        "port": 1080,
        "protocol": "socks",
        "settings": {
          "auth": "noauth"
        }
      }
    ],
    "outbounds": [
      {
        "tag": "vless-out",
        "protocol": "vless",
        "settings": {
          "vnext": [
            {
              "address": "your-server.com",
              "port": 443,
              "users": [
                {
                  "id": "your-uuid-here",
                  "flow": "xtls-rprx-vision"
                }
              ]
            }
          ]
        },
        "streamSettings": {
          "network": "tcp",
          "security": "tls",
          "tlsSettings": {
            "serverName": "your-server.com"
          }
        }
      }
    ]
  }
log_level: warning
```

## Usage

After starting the app, configure your applications to use:

- **HTTP Proxy**: `http://homeassistant.local:8080`
- **SOCKS Proxy**: `socks5://homeassistant.local:1080`

### Testing the Proxy

```bash
# Test HTTP proxy
curl -x http://homeassistant.local:8080 https://ipinfo.io

# Test SOCKS proxy
curl --socks5 homeassistant.local:1080 https://ipinfo.io
```

## Debugging

Enable debug mode for troubleshooting:

1. Set `debug_mode: true` in configuration
2. Check app logs for detailed information
3. Access container for advanced debugging:

```bash
docker exec -it <container_id> xray-debug
```

The debug script checks:
- Network connectivity to your server
- DNS resolution
- Xray process status
- Proxy functionality

## Common Issues

### 504 Gateway Timeout

- Server unreachable or wrong configuration
- Check server address, port, and UUID

### DNS Issues

- Cannot resolve server hostname
- Try using IP address instead

### Connection Refused

- Verify Xray server is running
- Check firewall rules

## Integration with Other Apps

This app works well with:

- **Netmaker Client**: Route WireGuard traffic through Xray
- **HevSocks5 TProxy**: Use Xray as upstream SOCKS server

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-addons/issues)
- [Xray Documentation](https://xtls.github.io/)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/xray)
