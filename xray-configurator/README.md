# Xray Configurator

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Supports aarch64 Architecture](https://img.shields.io/badge/aarch64-yes-green.svg)
![Supports amd64 Architecture](https://img.shields.io/badge/amd64-yes-green.svg)

## About

Xray Configurator is a Home Assistant app that provides a web-based interface for converting VLESS and Shadowsocks proxy links into Xray configuration files. This tool makes it easy to generate properly formatted Xray configurations without needing command-line tools.

## Features

- **Web-based Interface**: Clean, responsive web UI accessible through Home Assistant
- **Protocol Support**: 
  - VLESS (with TLS, REALITY, WebSocket, gRPC, HTTP/2)
  - Shadowsocks (all standard encryption methods)
- **Dual Output Formats**:
  - Pretty-formatted JSON configuration
  - Base64-encoded configuration string
- **One-Click Copy**: Copy buttons for both output formats
- **Real-time Conversion**: Instant conversion as you paste links
- **Mobile Friendly**: Responsive design works on all devices

## Installation

1. Add this repository to your Home Assistant supervisor:
   ```
   https://github.com/j0rsa/home-assistant-apps
   ```

2. Install the "Xray Configurator" app

3. Start the app

4. Access the web interface through the Home Assistant sidebar or directly at:
   ```
   http://your-home-assistant:8099
   ```

## Usage

### Converting Links

1. Open the Xray Configurator web interface
2. Paste your VLESS or Shadowsocks URL into the input field
3. Optionally adjust the HTTP proxy port (default: 8080)
4. Click "Convert Configuration"
5. Copy the generated JSON or Base64 configuration using the copy buttons

### Supported URL Formats

**VLESS Example:**
```
vless://uuid@server:port?encryption=none&security=tls&sni=example.com&type=tcp#ServerName
```

**Shadowsocks Example:**
```
ss://base64(method:password)@server:port#ServerName
```

### Using the Generated Configuration

The generated JSON configuration can be used directly with Xray:
```bash
xray run -config config.json
```

The base64 configuration can be used with the main Xray app by pasting it into the `xray_config_base64` option.

## Configuration Options

The app itself requires no configuration - it's ready to use out of the box. However, you can customize:

- **HTTP Proxy Port**: Set the port for the HTTP proxy in the generated configuration (default: 8080)
- **SOCKS Proxy Port**: Always set to 1080 in generated configurations

## Security Features

- **Local Processing**: All conversion happens locally in your browser - no data is sent to external servers
- **No Data Storage**: The app doesn't store any configuration data
- **Home Assistant Ingress**: Secure access through Home Assistant's authentication system

## Network Configuration

The generated Xray configurations include:

- **HTTP Proxy**: Configurable port (default: 8080)
- **SOCKS5 Proxy**: Fixed port 1080
- **Direct Routing**: Private IP ranges bypass proxy
- **Blocked Traffic**: Blackhole for unwanted connections

## Troubleshooting

### Common Issues

1. **Invalid URL Format**: Ensure your VLESS/SS URL is properly formatted
2. **Copy Failed**: Try using the manual selection and Ctrl+C if copy buttons don't work
3. **Web Interface Not Loading**: Check that port 8099 is not blocked by firewall

### Supported VLESS Parameters

- `encryption`: none (default), auto
- `security`: tls (default), reality, none  
- `type`: tcp (default), ws, grpc, h2
- `sni`: Server Name Indication
- `alpn`: Application-Layer Protocol Negotiation
- `fp`: TLS fingerprint
- `flow`: Flow control (xtls-rprx-vision, etc.)
- `path`: WebSocket/gRPC path
- `host`: HTTP host header
- `pbk`: REALITY public key
- `sid`: REALITY short ID

### Supported Shadowsocks Methods

All standard Shadowsocks encryption methods are supported:
- AES-128-GCM, AES-256-GCM
- ChaCha20-IETF-Poly1305
- AES-128-CTR, AES-256-CTR
- And more...

## License

This app is released under the MIT License.

## Support

For issues and feature requests, please visit the [GitHub repository](https://github.com/j0rsa/home-assistant-apps/issues).

---

**Note**: This tool generates Xray configurations compatible with the latest Xray-core versions. Always test your configurations before using them in production environments.