---
name: go-socks5-proxy
title: Go SOCKS5 Proxy
description: Simple, lightweight SOCKS5 proxy server
category: Networking & Proxy
version: 1.0.0
architectures:
  - amd64
  - aarch64
ports:
  - 1080
---

# Go SOCKS5 Proxy App

Simple, lightweight SOCKS5 proxy server written in Go, based on [serjs/socks5-server](https://github.com/serjs/socks5-server).

## Features

- **SOCKS5 Protocol**: Standard SOCKS5 proxy support
- **Authentication**: Optional username/password authentication
- **IP Allowlisting**: Restrict access to specific client IPs
- **Destination Filtering**: Control which destinations can be accessed via regex patterns
- **Lightweight**: Minimal resource usage

## Use Cases

### 1. Network Routing
Route traffic from Home Assistant or other services through a SOCKS5 proxy.

### 2. Access Control
Restrict proxy access to specific devices on your network.

### 3. Destination Filtering
Limit which external services can be accessed through the proxy.

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "Go SOCKS5 Proxy" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Configure the app (see Configuration below)
5. Start the app

## Configuration

```yaml
# Example configuration
proxy_user: ""              # Username for authentication
proxy_password: ""          # Password for authentication
allowed_ips: []             # List of allowed client IPs
allowed_dest_fqdn: ""       # Regex pattern for allowed destinations
```

### Configuration Options

| Option | Description | Default | Required |
|--------|-------------|---------|----------|
| `proxy_user` | Username for proxy authentication | `""` | No |
| `proxy_password` | Password for proxy authentication | `""` | No |
| `allowed_ips` | List of client IPs allowed to connect | `[]` | No |
| `allowed_dest_fqdn` | Regex pattern for allowed destination addresses | `""` | No |

## Usage

### Accessing the Proxy

After starting the app, configure your applications to use:

- **Proxy Address**: `homeassistant.local:1080`
- **Protocol**: SOCKS5

### Example Configurations

#### Basic Setup (No Authentication)

```yaml
proxy_user: ""
proxy_password: ""
allowed_ips: []
allowed_dest_fqdn: ""
```

#### Production Setup with Authentication

```yaml
proxy_user: "myuser"
proxy_password: "mysecurepassword"
allowed_ips: []
allowed_dest_fqdn: ""
```

#### Restricted Setup with IP Allowlist

```yaml
proxy_user: "myuser"
proxy_password: "mysecurepassword"
allowed_ips:
  - "192.168.1.100"
  - "192.168.1.101"
allowed_dest_fqdn: ""
```

#### Destination Filtering

Only allow connections to specific domains:

```yaml
proxy_user: "myuser"
proxy_password: "mysecurepassword"
allowed_ips: []
allowed_dest_fqdn: ".*\\.example\\.com"
```

### Testing the Proxy

Without authentication:

```bash
curl --socks5 homeassistant.local:1080 https://ipinfo.io
```

With authentication:

```bash
curl --socks5 myuser:mysecurepassword@homeassistant.local:1080 https://ipinfo.io
```

## Integration with Home Assistant

### Shell Command Example

Create a shell command to test connectivity through the proxy:

```yaml
shell_command:
  test_socks_proxy: 'curl --socks5 homeassistant.local:1080 https://ipinfo.io'
```

### Use with Other Apps

This proxy can be used with other apps that support SOCKS5, such as:

- SNI Socket Proxy - route traffic through this SOCKS5 proxy
- Aria2/Ariang - download through the proxy

## Security Best Practices

1. **Always use authentication** in production environments
2. **Use IP allowlist** to restrict which clients can connect
3. **Use destination filtering** to limit accessible destinations
4. **Limit network exposure** - only expose ports if needed externally

## Hardware Requirements

### Minimum Requirements
- **CPU**: 1 core
- **RAM**: 64MB
- **Storage**: Minimal

### Recommended
- **CPU**: 1 core
- **RAM**: 128MB

## Troubleshooting

### App Won't Start
- Check logs for error messages
- Ensure port 1080 is not in use by another service

### Connection Refused
- Ensure the app is running
- Check if authentication is required
- Verify client IP is in the allowlist (if configured)

### Authentication Failed
- Verify username and password are correct
- Ensure both `proxy_user` and `proxy_password` are set

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)
- [Upstream Repository](https://github.com/serjs/socks5-server)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/go-socks5-proxy)
