---
name: hev-socks5-tproxy
title: HevSocks5 TProxy
description: Transparent SOCKS5 proxy client for routing traffic through a remote SOCKS5 server
category: Networking & Proxy
version: 1.0.0
architectures:
  - amd64
  - aarch64
ports: []
---

# HevSocks5 TProxy App

Transparent SOCKS5 proxy client that intercepts TCP/UDP traffic and forwards it through a remote SOCKS5 server, based on [hev-socks5-tproxy](https://github.com/heiher/hev-socks5-tproxy).

## Understanding Transparent vs Regular Proxies

### Regular SOCKS5 Proxy (like go-socks5-proxy)

A regular proxy **provides a SOCKS5 server** that applications connect to. Each app must be configured to use the proxy:

```
Browser [proxy settings: 192.168.1.1:1080] → SOCKS5 Server → Internet
```

**Pros:** Simple, no special permissions needed
**Cons:** Apps must support proxy settings; some apps ignore proxy config

### Transparent Proxy (this app)

A transparent proxy **intercepts traffic at the network level** and forwards it through an external SOCKS5 server. Apps don't need any configuration:

```
Browser [no config] → Network → [iptables intercepts] → TProxy → SOCKS5 Server → Internet
```

**Pros:** Works with any app, no per-app configuration
**Cons:** Requires host network access and iptables privileges

## Features

- **Multi-port support**: Intercept traffic on multiple ports (e.g., 80, 443)
- **IPv4/IPv6 dual stack**: Supports both IP versions
- **UDP support**: Fullcone NAT for UDP traffic
- **Optional DNS proxy**: Prevent DNS leaks by routing DNS through SOCKS5
- **SOCKS5 authentication**: Optional username/password for upstream server
- **Automatic cleanup**: iptables rules removed on shutdown

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "HevSocks5 TProxy" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Configure the app (see Configuration below)
5. Start the app

## Configuration

### Upstream SOCKS5 Server

These options define the SOCKS5 server that traffic will be forwarded to.

```yaml
# IP address or hostname of the SOCKS5 server (REQUIRED)
socks5_address: "192.168.1.100"

# Port of the SOCKS5 server
socks5_port: 1080

# Username for authentication (optional, leave empty for no auth)
socks5_username: ""

# Password for authentication (optional, leave empty for no auth)  
socks5_password: ""

# UDP relay mode: "udp" (UDP-in-UDP) or "tcp" (UDP-in-TCP)
# Use "tcp" if your SOCKS5 server doesn't support UDP relay
socks5_udp_mode: "udp"
```

### Local Listener

Configure which ports to intercept and proxy.

```yaml
# List of ports to intercept (TCP and UDP)
listen_ports:
  - 80    # HTTP
  - 443   # HTTPS
```

### DNS Proxy (Optional)

Enable DNS proxying to prevent DNS leaks when using the transparent proxy.

```yaml
# Enable/disable DNS proxying
dns_enabled: false

# Local port for DNS proxy to listen on
dns_listen_port: 1053

# Upstream DNS server address (e.g., 8.8.8.8, 1.1.1.1)
dns_upstream_address: ""

# Upstream DNS server port (usually 53)
dns_upstream_port: 53
```

## Example Configurations

### Basic HTTP/HTTPS Proxying

Route web traffic through a local SOCKS5 server:

```yaml
socks5_address: "192.168.1.100"
socks5_port: 1080
socks5_username: ""
socks5_password: ""
socks5_udp_mode: "udp"
listen_ports:
  - 80
  - 443
dns_enabled: false
dns_listen_port: 1053
dns_upstream_address: ""
dns_upstream_port: 53
```

### With SOCKS5 Authentication

```yaml
socks5_address: "proxy.vpnprovider.com"
socks5_port: 1080
socks5_username: "vpnuser"
socks5_password: "vpnpassword"
socks5_udp_mode: "tcp"
listen_ports:
  - 80
  - 443
dns_enabled: false
dns_listen_port: 1053
dns_upstream_address: ""
dns_upstream_port: 53
```

### Full Setup with DNS Leak Prevention

```yaml
socks5_address: "192.168.1.100"
socks5_port: 1080
socks5_username: ""
socks5_password: ""
socks5_udp_mode: "udp"
listen_ports:
  - 80
  - 443
dns_enabled: true
dns_listen_port: 1053
dns_upstream_address: "8.8.8.8"
dns_upstream_port: 53
```

## How It Works — Connection Flow

When you configure `listen_ports: [80, 443]` and make a request to `https://example.com:443`:

```
Your App                    hev-socks5-tproxy              SOCKS5 Server           Destination
    │                              │                              │                      │
    │  connect to                  │                              │                      │
    │  example.com:443             │                              │                      │
    │─────────────────────►        │                              │                      │
    │                      iptables intercepts                    │                      │
    │                      packet to port 443                     │                      │
    │                      redirects to internal                  │                      │
    │                      port 12345                             │                      │
    │                              │                              │                      │
    │                              │  SOCKS5 CONNECT              │                      │
    │                              │  "example.com:443"           │                      │
    │                              │─────────────────────►        │                      │
    │                              │                              │  TCP connect         │
    │                              │                              │  to port 443         │
    │                              │                              │─────────────────────►│
    │                              │                              │                      │
    │◄─────────────────────────────┼──────────────────────────────┼──────────────────────│
    │                         traffic relayed                                            │
```

### Key Points

- **listen_ports** — Ports to intercept (e.g., 80, 443). Traffic TO these ports gets proxied.
- **Internal port 12345** — Where the tproxy daemon listens. Automatic, not user-configurable.
- **Destination port preserved** — The final destination keeps the original port (443 → 443).
- **Transparent** — Apps don't know they're being proxied; no app configuration needed.

## Using with go-socks5-proxy App

This app pairs well with the **Go SOCKS5 Proxy** app from this repository:

1. **Install go-socks5-proxy**: Provides a local SOCKS5 server on port 1080
2. **Install hev-socks5-tproxy**: This app
3. **Configure hev-socks5-tproxy**:
   - Set `socks5_address` to your Home Assistant IP (e.g., `172.30.32.1`)
   - Set `socks5_port` to `1080`

This creates a transparent proxy that routes traffic through your local SOCKS5 server.

## Security Considerations

- This app requires **privileged access** to configure network rules
- **Host network mode** is required — the app can see all network traffic
- Only intercept ports you specifically need (don't use `listen_ports: [1-65535]`)
- Consider enabling DNS proxying to prevent DNS leaks

## Hardware Requirements

### Minimum
- **CPU**: 1 core
- **RAM**: 64MB

### Recommended
- **CPU**: 1 core
- **RAM**: 128MB

## Troubleshooting

### "socks5_address is required" error
The `socks5_address` option must be set to a valid IP or hostname.

### Traffic not being proxied
- Verify the upstream SOCKS5 server is running
- Check app logs for iptables errors
- Ensure the configured ports match the traffic you're trying to proxy

### UDP not working
- Try changing `socks5_udp_mode` from `udp` to `tcp`
- Some SOCKS5 servers don't support UDP relay

### DNS leaks
Enable the DNS proxy options and configure your system to use the proxy's DNS port.

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)
- [Upstream Repository](https://github.com/heiher/hev-socks5-tproxy)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/hev-socks5-tproxy)
