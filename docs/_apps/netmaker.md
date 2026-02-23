---
name: netmaker
title: Netmaker Client - VPN Client
description: WireGuard VPN client with SOCKS proxy support
category: Networking & Proxy
version: latest
architectures:
  - amd64
  - aarch64
ports: []
---

# Netmaker Client App

Netmaker WireGuard client that can route traffic through a SOCKS proxy for enhanced privacy and flexibility.

## About

This app runs the official Netmaker client to connect to your Netmaker network and optionally routes all traffic through a SOCKS proxy (like the Xray app). This provides a powerful combination of enterprise-grade mesh networking with additional privacy layers.

## Features

- 🔐 **WireGuard VPN**: Connect to Netmaker-managed networks
- 🧦 **SOCKS Proxy Integration**: Route through additional proxy layers
- 🔄 **Flexible Routing**: Direct WireGuard or proxy-routed traffic
- 🔁 **Auto Restart**: Automatic recovery on failure
- 🐛 **Debug Mode**: Troubleshooting tools included

## Use Cases

- **Enterprise Networking**: Connect to Netmaker mesh networks
- **Enhanced Privacy**: Layer proxy on top of VPN
- **Flexible Routing**: Choose direct or proxied traffic
- **Remote Access**: Secure access to home network

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "Netmaker Client" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Configure your Netmaker credentials
5. Start the app

## Configuration

### Required Settings

| Option | Description |
|--------|-------------|
| `host_name` | Device name in Netmaker network (default: `homeassistant-netmaker`) |
| `netclient_token` | Enrollment token from Netmaker dashboard |

### Optional Settings

| Option | Description | Default |
|--------|-------------|---------|
| `wg_interface` | WireGuard interface name | `wg0` |
| `socks_proxy` | SOCKS proxy address | `homeassistant:1080` |
| `enable_proxy` | Route through SOCKS proxy | `true` |
| `log_level` | Log level (debug, info, warning, error) | `info` |
| `debug_mode` | Enable debug tools | `false` |
| `auto_restart` | Auto restart on failure | `true` |

## Example Configurations

### With SOCKS Proxy (Default)

```yaml
host_name: "homeassistant-netmaker"
netclient_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
wg_interface: "wg0"
socks_proxy: "homeassistant:1080"
enable_proxy: true
log_level: "info"
debug_mode: false
auto_restart: true
```

### Direct WireGuard (No Proxy)

```yaml
host_name: "homeassistant-netmaker"
netclient_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
enable_proxy: false
auto_restart: true
```

## Setup Instructions

1. **Set up Netmaker Server**: Ensure you have a working Netmaker instance
2. **Generate Token**: Create enrollment key in Netmaker dashboard
3. **Configure App**: Enter token and other settings
4. **Start App**: It will automatically join your network

## Integration with Xray App

This app works perfectly with the Xray app:

1. Install and configure Xray with your VPN server
2. Configure Netmaker app with:
   - `enable_proxy: true`
   - `socks_proxy: "homeassistant:1080"`
3. Traffic flow: Device → WireGuard → SOCKS Proxy → Xray → VPN

## How It Works

### With Proxy Enabled

```
Device → Netmaker WireGuard → tun2socks → SOCKS Proxy → Internet
```

1. Netclient joins Netmaker network
2. WireGuard tunnel established
3. tun2socks bridges to SOCKS proxy
4. All traffic flows through proxy

### Direct WireGuard Mode

```
Device → Netmaker WireGuard → Internet
```

Traffic flows directly through WireGuard without proxy.

## Troubleshooting

### Enable Debug Mode

Set `debug_mode: true` for additional tools and logging.

### Common Issues

| Issue | Solution |
|-------|----------|
| "Netclient token is required" | Provide valid enrollment token |
| "WireGuard interface not found" | Check Netmaker connectivity |
| "Failed to join network" | Verify server URL and token |
| Proxy connection issues | Ensure SOCKS proxy is running |

### Network Requirements

- `NET_ADMIN` capability
- Access to `/dev/net/tun`
- Outbound to Netmaker server
- Outbound to SOCKS proxy (if enabled)

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)
- [Netmaker Documentation](https://docs.netmaker.io/)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-apps/tree/main/netmaker)
