# HevSocks5 TProxy App

Transparent SOCKS5 proxy client for routing network traffic through a remote SOCKS5 server.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

## About

This app runs [hev-socks5-tproxy](https://github.com/heiher/hev-socks5-tproxy), a high-performance transparent proxy that intercepts TCP and UDP traffic and forwards it through a SOCKS5 server.

### What is a Transparent Proxy?

Unlike a regular SOCKS5 proxy where each application must be configured to use it, a **transparent proxy** intercepts traffic at the network level. Applications don't know they're being proxied — it's invisible to them.

**Regular SOCKS5 Proxy (e.g., go-socks5-proxy):**
```
App → [configured to use proxy] → SOCKS5 Server → Internet
```

**Transparent Proxy (this app):**
```
App → [normal connection] → [iptables intercepts] → TProxy → SOCKS5 Server → Internet
```

### Use Cases

- **Route all traffic through a VPN's SOCKS5 endpoint** without configuring each app
- **Bypass geo-restrictions** for services that don't support proxy settings
- **Network-wide proxying** when Home Assistant acts as a gateway

## Configuration

### Upstream SOCKS5 Server Options

| Option | Description | Required |
|--------|-------------|----------|
| `socks5_address` | IP address or hostname of the SOCKS5 server to forward traffic to | **Yes** |
| `socks5_port` | Port of the SOCKS5 server (default: `1080`) | No |
| `socks5_username` | Username for SOCKS5 authentication (leave empty if no auth required) | No |
| `socks5_password` | Password for SOCKS5 authentication (leave empty if no auth required) | No |
| `socks5_udp_mode` | How to relay UDP traffic: `udp` (UDP-in-UDP) or `tcp` (UDP-in-TCP) | No |

### Local Listener Options

| Option | Description | Required |
|--------|-------------|----------|
| `listen_ports` | List of ports to intercept and proxy (e.g., `[80, 443]`) | **Yes** |

### DNS Proxy Options (Optional)

Enable these to proxy DNS queries through SOCKS5, preventing DNS leaks.

| Option | Description | Required |
|--------|-------------|----------|
| `dns_enabled` | Enable DNS proxying (`true`/`false`, default: `false`) | No |
| `dns_listen_port` | Local port for DNS proxy (default: `1053`) | No |
| `dns_upstream_address` | Upstream DNS server address (e.g., `8.8.8.8`) | When DNS enabled |
| `dns_upstream_port` | Upstream DNS server port (default: `53`) | No |

## Example Configurations

### Basic: Proxy HTTP/HTTPS through a SOCKS5 server

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
```

### With Authentication

```yaml
socks5_address: "proxy.example.com"
socks5_port: 1080
socks5_username: "myuser"
socks5_password: "mypassword"
socks5_udp_mode: "udp"
listen_ports:
  - 80
  - 443
dns_enabled: false
```

### With DNS Proxying (Prevent DNS Leaks)

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

## How It Works

### Connection Flow

When you configure `listen_ports: [80, 443]` and make a request to `https://example.com:443`:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Your Device                                                                 │
│                                                                             │
│  App requests https://example.com:443                                       │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ iptables TPROXY                                                     │    │
│  │ Intercepts packets to port 443, redirects to internal port 12345   │    │
│  │ (Original destination example.com:443 is preserved in metadata)    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ hev-socks5-tproxy daemon (listening on internal port 12345)        │    │
│  │ Reads original destination from packet metadata                     │    │
│  │ Sends SOCKS5 CONNECT request: "connect to example.com:443"         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│       │                                                                     │
└───────┼─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ SOCKS5 Server (e.g., 192.168.1.100:1080)                                    │
│ Receives CONNECT request, establishes connection to example.com:443        │
└─────────────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ Destination: example.com:443                                                │
│ (Port 443 is preserved — the proxy is transparent)                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Points

- **listen_ports** — Ports to intercept (e.g., 80, 443). Traffic TO these ports gets proxied.
- **Internal port 12345** — Where the tproxy daemon listens. This is automatic, not configurable.
- **Destination port preserved** — If you intercept port 443, the final destination is still port 443. The proxy is transparent to the destination.

### Step by Step

1. The app starts the hev-socks5-tproxy daemon on internal port 12345
2. iptables TPROXY rules intercept traffic destined for your configured ports
3. Intercepted packets are redirected to the daemon (original destination preserved)
4. The daemon extracts the original destination and forwards via SOCKS5
5. The SOCKS5 server connects to the original destination (e.g., example.com:443)
6. On shutdown, iptables rules are automatically cleaned up

## Requirements

This app requires:
- **Host network access** — to intercept network traffic
- **NET_ADMIN capability** — to configure iptables rules
- **NET_RAW capability** — for raw socket access

These permissions are automatically configured.

## Combining with go-socks5-proxy

You can use this app together with the **Go SOCKS5 Proxy** app:

1. Install and configure **go-socks5-proxy** (provides the SOCKS5 server)
2. Install **hev-socks5-tproxy** (this app)
3. Point `socks5_address` to your Home Assistant IP and `socks5_port` to `1080`

This setup allows transparent proxying of traffic through a local SOCKS5 server.

## Troubleshooting

### App won't start
- Check that `socks5_address` is configured
- Verify the SOCKS5 server is reachable

### Traffic not being proxied
- Ensure the SOCKS5 server is running and accepting connections
- Check app logs for iptables rule errors
- Verify your network topology allows traffic interception

### Connection timeouts
- Try changing `socks5_udp_mode` from `udp` to `tcp`
- Some SOCKS5 servers don't support UDP relay

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-addons/issues)
- [Upstream hev-socks5-tproxy](https://github.com/heiher/hev-socks5-tproxy)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
