# Go SOCKS5 Proxy Add-on

Simple, lightweight SOCKS5 proxy server written in Go.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

## About

This add-on runs a high-performance SOCKS5 proxy server based on [serjs/socks5-server](https://github.com/serjs/socks5-server). It provides:

- **SOCKS5 Protocol**: Standard SOCKS5 proxy support
- **Authentication**: Optional username/password authentication
- **IP Allowlisting**: Restrict access to specific client IPs
- **Destination Filtering**: Control which destinations can be accessed

## Configuration

### Option: `proxy_user`

Username for proxy authentication. Must be used together with `proxy_password`.

### Option: `proxy_password`

Password for proxy authentication. Must be used together with `proxy_user`.

### Option: `allowed_ips`

List of client IP addresses allowed to connect. Leave empty to allow all IPs.

Example:
```yaml
allowed_ips:
  - "192.168.1.100"
  - "192.168.1.101"
```

### Option: `allowed_dest_fqdn`

Regex pattern for allowed destination addresses. Leave empty to allow all destinations.

Example: `.*\.example\.com` to only allow connections to example.com subdomains.

## Example Configuration

### Basic setup without authentication:
```yaml
proxy_user: ""
proxy_password: ""
allowed_ips: ""
allowed_dest_fqdn: ""
```

### Production setup with authentication:
```yaml
proxy_user: "myuser"
proxy_password: "mysecurepassword"
allowed_ips: ""
allowed_dest_fqdn: ""
```

### Restricted setup with IP allowlist:
```yaml
proxy_user: "myuser"
proxy_password: "mysecurepassword"
allowed_ips:
  - "192.168.1.100"
  - "192.168.1.101"
allowed_dest_fqdn: ""
```

## Usage

1. Configure your SOCKS5 proxy settings in the add-on configuration
2. Start the add-on
3. Configure your applications to use the proxy:
   - **Proxy Address**: `homeassistant-ip:1080`
   - **Protocol**: SOCKS5

### Testing the Proxy

Without authentication:
```bash
curl --socks5 homeassistant-ip:1080 https://ipinfo.io
```

With authentication:
```bash
curl --socks5 myuser:mysecurepassword@homeassistant-ip:1080 https://ipinfo.io
```

## Security

- **Authentication**: Always set username and password for production deployments
- **IP Allowlist**: Use `allowed_ips` to restrict which clients can connect
- **Destination Filter**: Use `allowed_dest_fqdn` to control accessible destinations
- **Network**: The add-on binds to all interfaces (0.0.0.0) for Home Assistant integration

## Support

For issues and feature requests, please visit the [GitHub repository](https://github.com/j0rsa/home-assistant-addons).

For socks5-server documentation, see the [upstream repository](https://github.com/serjs/socks5-server).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
