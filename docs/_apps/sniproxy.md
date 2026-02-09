---
name: sniproxy
title: SNI Proxy - Traffic Router
description: SNI-based proxy for routing HTTP/HTTPS traffic
category: Networking & Proxy
version: latest
architectures:
  - amd64
  - aarch64
  - armv7
ports:
  - 80
  - 443
---

# SNI Proxy App

Transparent SNI-based proxy for routing HTTP and HTTPS traffic based on hostname without decrypting SSL/TLS.

## About

SNI Proxy forwards HTTP(S) traffic respecting Layer 7 DNS rules. It inspects the Server Name Indication (SNI) field in TLS handshakes to route traffic to the appropriate backend without needing to decrypt the traffic.

## Features

- 🔒 **SSL Passthrough**: Routes HTTPS without decryption
- 🌐 **SNI-based Routing**: Routes based on hostname in TLS handshake
- ⚡ **Lightweight**: Minimal resource usage
- 🔄 **Multiple Backends**: Support for routing to different destinations
- 📊 **HTTP Support**: Also handles plain HTTP traffic

## Use Cases

- **Reverse Proxy**: Route traffic to different services based on hostname
- **SSL Passthrough**: Forward HTTPS without terminating SSL
- **Traffic Routing**: Direct traffic to appropriate backends
- **Privacy**: Route traffic without inspecting content

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "SNI Proxy" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Configure routing rules
5. Start the app

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 80 | TCP | HTTP traffic |
| 443 | TCP | HTTPS/SSL traffic |

**Important**: Do not change these ports as they are standard HTTP/HTTPS ports.

## How It Works

1. Client connects to the proxy on port 80 or 443
2. For HTTPS, proxy reads the SNI field from the TLS Client Hello
3. Proxy looks up the destination based on hostname
4. Traffic is forwarded to the backend server
5. Response is relayed back to the client

```
Client → SNI Proxy (443) → [reads SNI: example.com] → Backend Server
```

## Configuration

Configure routing rules to direct traffic to appropriate backends based on hostname patterns.

## Tips

1. **DNS Setup**: Point your domains to the SNI Proxy IP
2. **Firewall**: Ensure ports 80 and 443 are accessible
3. **Backends**: Make sure backend servers are reachable
4. **Logging**: Enable logging to troubleshoot routing issues

## Troubleshooting

### Traffic Not Routing

- Verify DNS points to the proxy
- Check that backend servers are accessible
- Review routing rules configuration

### SSL Errors

- SNI Proxy doesn't terminate SSL - ensure backends have valid certificates
- Check that clients support SNI (most modern clients do)

### Connection Refused

- Verify ports 80/443 are not in use by other services
- Check that the app is running

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/sniproxy)
