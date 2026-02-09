---
name: xray-configurator
title: Xray Configurator - Config Generator
description: Web interface for converting proxy links to Xray configuration files
category: Networking & Proxy
version: latest
architectures:
  - amd64
  - aarch64
ports:
  - 8099
---

# Xray Configurator App

Web-based interface for converting VLESS and Shadowsocks proxy links into Xray configuration files.

## About

Xray Configurator provides a clean web UI for generating properly formatted Xray configurations without needing command-line tools. Simply paste your proxy link and get a ready-to-use configuration.

## Features

- 🌐 **Web Interface**: Clean, responsive web UI
- 🔗 **Protocol Support**: VLESS and Shadowsocks links
- 📋 **Dual Output**: JSON and Base64 formats
- 📱 **Mobile Friendly**: Responsive design
- 🔒 **Local Processing**: All conversion happens in browser
- ⚡ **Real-time**: Instant conversion

## Supported Protocols

### VLESS

Full support including:
- TLS and REALITY security
- WebSocket, gRPC, HTTP/2 transports
- Flow control (xtls-rprx-vision)
- All standard parameters

### Shadowsocks

All standard encryption methods:
- AES-128-GCM, AES-256-GCM
- ChaCha20-IETF-Poly1305
- And more...

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "Xray Configurator" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Start the app

## Usage

### Accessing the Web Interface

After starting the app:
- **Via Ingress**: Click "Open Web UI" in the app panel
- **Direct Access**: `http://homeassistant.local:8099`

### Converting a Link

1. Open the web interface
2. Paste your VLESS or Shadowsocks URL
3. Optionally adjust the HTTP proxy port
4. Click "Convert Configuration"
5. Copy the JSON or Base64 output

### URL Format Examples

**VLESS:**
```
vless://uuid@server:port?encryption=none&security=tls&sni=example.com&type=tcp#ServerName
```

**Shadowsocks:**
```
ss://base64(method:password)@server:port#ServerName
```

## Output Formats

### JSON Configuration

Ready-to-use Xray configuration file:

```json
{
  "inbounds": [...],
  "outbounds": [...],
  "routing": {...}
}
```

### Base64 Configuration

Encoded configuration string for use with the Xray app's `xray_config_base64` option.

## Generated Configuration Includes

- **HTTP Proxy**: Configurable port (default: 8080)
- **SOCKS5 Proxy**: Port 1080
- **Direct Routing**: Private IP ranges bypass proxy
- **Blocked Traffic**: Blackhole for unwanted connections

## Supported VLESS Parameters

| Parameter | Description |
|-----------|-------------|
| `encryption` | none, auto |
| `security` | tls, reality, none |
| `type` | tcp, ws, grpc, h2 |
| `sni` | Server Name Indication |
| `alpn` | Application-Layer Protocol |
| `fp` | TLS fingerprint |
| `flow` | Flow control |
| `path` | WebSocket/gRPC path |
| `host` | HTTP host header |
| `pbk` | REALITY public key |
| `sid` | REALITY short ID |

## Using with [Xray](/apps/xray/) App

1. Generate configuration using this tool
2. Copy the Base64 output
3. Open [Xray](/apps/xray/) app configuration
4. Paste into `xray_config_base64` field
5. Start Xray app

## Security

- **Local Processing**: No data sent to external servers
- **No Storage**: Configurations are not saved
- **Ingress**: Secure access through Home Assistant auth

## Troubleshooting

### Invalid URL Format

- Ensure your VLESS/SS URL is properly formatted
- Check for missing parameters

### Copy Failed

- Use manual selection with Ctrl+C
- Check browser permissions

### Web Interface Not Loading

- Check port 8099 availability
- Verify app is running

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/xray-configurator)
