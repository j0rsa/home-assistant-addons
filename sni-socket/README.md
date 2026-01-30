# SNI Socket Proxy Add-on

SNI Socket Proxy routes HTTP and HTTPS traffic through a SOCKS5 proxy based on hostname matching (SNI for HTTPS, Host header for HTTP). This add-on builds on Home Assistant base images with sniproxy and proxychains for use in Home Assistant.

## Highlights
- 🔀 Routes HTTP and HTTPS traffic through SOCKS5 proxy based on hostname
- 🔧 Configurable SOCKS5 proxy address and port
- 📡 Listens on ports 80 (HTTP) and 443 (HTTPS)
- 🛡️ Uses proxychains to route traffic through SOCKS5 proxy

## Access & Networking
- **Ports**: `80/tcp` (HTTP proxy port) and `443/tcp` (HTTPS/SSL proxy port)
- **Configuration**: Set SOCKS5 proxy address and port in add-on configuration

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `socks5_address` | String | `10.0.1.3` | SOCKS5 proxy server address (IP or hostname) |
| `socks5_port` | Integer | `1080` | SOCKS5 proxy server port (1-65535) |

## How It Works

1. The add-on listens on ports 80 (HTTP) and 443 (HTTPS) for incoming connections
2. For HTTPS: It extracts the SNI hostname from the TLS handshake
3. For HTTP: It extracts the hostname from the Host header
4. All traffic matching the hostname pattern is routed through the configured SOCKS5 proxy
5. The SOCKS5 proxy forwards the traffic to the destination server

## First-time Setup

1. Configure the SOCKS5 proxy address and port in the add-on configuration
2. Start the add-on
3. Configure your clients to use this add-on as an HTTP/HTTPS proxy (ports 80/443)
4. All HTTP and HTTPS traffic will be routed through the configured SOCKS5 proxy

## Use Cases

- Route specific HTTP and HTTPS traffic through a SOCKS5 proxy (e.g., VPN, Tor, or another proxy)
- Transparent proxying based on hostname
- Network traffic routing and filtering

## Troubleshooting

- **Connection issues**: Verify that the SOCKS5 proxy address and port are correct and accessible
- **Port conflicts**: Ensure ports 80 and 443 are not used by another service
- **Logs**: Check the add-on logs for detailed error messages
- **SOCKS5 proxy**: Ensure your SOCKS5 proxy server is running and accessible from the add-on container

## Notes

- This add-on requires ports 80 and 443 to be available
- The SOCKS5 proxy must be accessible from the add-on container's network
- All HTTP and HTTPS traffic matching the hostname pattern will be routed through the SOCKS5 proxy
