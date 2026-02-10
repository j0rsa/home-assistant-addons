# Netmaker Client App

![](logo.png)

Netmaker WireGuard client that can route traffic through a SOCKS proxy for enhanced privacy and flexibility.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield]

## About

This app runs the official Netmaker client to connect to your Netmaker network and optionally routes all traffic through a SOCKS proxy (like the Xray app). This provides a powerful combination of:

- **Netmaker Network Access**: Connect to your Netmaker-managed WireGuard network
- **SOCKS Proxy Integration**: Route traffic through additional proxy layers for enhanced privacy
- **Flexible Routing**: Choose between direct WireGuard or proxy-routed traffic

Perfect for combining enterprise-grade mesh networking with additional privacy layers.

## Configuration

### Required Settings

#### Option: `host_name`
The name of the host that will be used to identify the device in the Netmaker network.
- Default: `homeassistant-netmaker`

#### Option: `netclient_token`
The Netclient enrollment token from your Netmaker server. Get this from your Netmaker dashboard when creating a new enrollment key.

Example: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### Optional Settings

#### Option: `wg_interface`
The WireGuard interface name that will be created by Netclient.
- Default: `wg0`

#### Option: `socks_proxy`
The SOCKS proxy address to route traffic through when `enable_proxy` is true.
- Default: `homeassistant:1080` (assumes Xray app running on port 1080)
- Format: `hostname:port` or `ip:port`

#### Option: `enable_proxy`
Whether to route WireGuard traffic through the SOCKS proxy or use direct WireGuard routing.
- Default: `true`
- `true`: Route traffic through SOCKS proxy
- `false`: Use direct WireGuard routing

#### Option: `log_level`
Set the log level for tun2socks (when proxy is enabled).
- Default: `info`
- Options: `debug`, `info`, `warning`, `error`

#### Option: `debug_mode`
Enable debug mode for additional troubleshooting tools and verbose logging.
- Default: `false`

#### Option: `auto_restart`
Automatically restart the setup process if it fails.
- Default: `true`

## Example Configuration

### Basic Configuration (with SOCKS proxy):
```yaml
host_name: "homeassistant-netmaker"
netclient_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your_actual_token_here"
wg_interface: "wg0"
socks_proxy: "homeassistant:1080"
enable_proxy: true
log_level: "info"
debug_mode: false
auto_restart: true
```

### Direct WireGuard (no proxy):
```yaml
host_name: "homeassistant-netmaker"
netclient_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your_actual_token_here"
enable_proxy: false
auto_restart: true
```

## Setup Instructions

1. **Set up Netmaker Server**: Ensure you have a working Netmaker server instance
2. **Generate Enrollment Token**: In your Netmaker dashboard, create a new enrollment key
3. **Configure App**: 
   - Set `host_name` to your Netmaker host name
   - Set `netclient_token` to your enrollment token
   - Configure other options as needed
4. **Start App**: The app will automatically join your Netmaker network

## Integration with Xray App

This app works perfectly with the Xray app for enhanced privacy:

1. **Install and configure Xray app** with your VPN server details
2. **Configure Netmaker app** with:
   - `enable_proxy: true`
   - `socks_proxy: "homeassistant:1080"` (Xray's SOCKS port)
3. **Traffic flow**: Your device → Netmaker WireGuard → SOCKS proxy → Xray → VPN server

## How It Works

### With Proxy Enabled (default):
1. Netclient joins your Netmaker network and sets up WireGuard
2. Default route is set through the WireGuard interface
3. tun2socks bridges the WireGuard traffic to your SOCKS proxy
4. All traffic flows: Device → WireGuard → SOCKS Proxy → Internet

### Direct WireGuard Mode:
1. Netclient joins your Netmaker network and sets up WireGuard  
2. Traffic flows directly through WireGuard: Device → WireGuard → Internet

## Troubleshooting

### Enable Debug Mode
Set `debug_mode: true` to get additional debugging tools and verbose logging.

### Check Logs
Monitor the app logs for connection status and error messages.

### Common Issues

- **"Netclient token is required"**: Ensure you've provided a valid enrollment token
- **"WireGuard interface not found"**: Check your Netmaker server connectivity and token validity
- **"Failed to join network"**: Verify your Netmaker server URL and token are correct
- **Proxy connection issues**: Ensure your SOCKS proxy (like Xray) is running and accessible

### Network Requirements

The app requires:
- `NET_ADMIN` capability for network configuration
- Access to `/dev/net/tun` device
- Outbound connectivity to your Netmaker server
- Outbound connectivity to your SOCKS proxy (if enabled)

## Support

For issues and feature requests, please visit the [GitHub repository](https://github.com/j0rsa/home-assistant-apps).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg