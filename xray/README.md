# Xray Add-on

![](logo.png)

Xray-core client for connecting to VLESS/VMess/Trojan servers and creating a local HTTP proxy.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield]

## About

This add-on runs Xray-core as a client to connect to your Xray server (VLESS, VMess, Trojan protocols) and provides a local HTTP proxy on port 8080 that you can use to route traffic through your Xray server.

## Configuration

The add-on accepts the complete Xray client configuration in JSON format, either as plain text or base64 encoded.

### Option: `xray_config_json`

The complete Xray client configuration in JSON format. You can provide your full Xray client config here.

### Option: `xray_config_base64`

The complete Xray client configuration encoded in base64. This is useful if you want to avoid issues with special characters in the JSON configuration.

### Option: `log_level`

Set the log level for Xray. Available options:
- `debug` - Most verbose logging
- `info` - Information messages
- `warning` - Warning messages (default)
- `error` - Error messages only
- `none` - No logging

## Example Configuration

### Using JSON configuration:

```yaml
xray_config_json: |
  {
    "inbounds": [
      {
        "tag": "http-in",
        "port": 8080,
        "protocol": "http",
        "settings": {
          "auth": "noauth"
        }
      }
    ],
    "outbounds": [
      {
        "tag": "vless-out",
        "protocol": "vless",
        "settings": {
          "vnext": [
            {
              "address": "your-server.com",
              "port": 443,
              "users": [
                {
                  "id": "your-uuid-here",
                  "flow": "xtls-rprx-vision"
                }
              ]
            }
          ]
        },
        "streamSettings": {
          "network": "tcp",
          "security": "tls",
          "tlsSettings": {
            "serverName": "your-server.com"
          }
        }
      }
    ]
  }
log_level: warning
```

### Using base64 configuration:

```yaml
xray_config_base64: "ewogICJpbmJvdW5kcyI6IFsKICAgIHsKICAgICAgInRhZyI6ICJodHRwLWluIiwKICAgICAgInBvcnQiOiA4MDgwLAogICAgICAicHJvdG9jb2wiOiAiaHR0cCIsCiAgICAgICJzZXR0aW5ncyI6IHsKICAgICAgICAiYXV0aCI6ICJub2F1dGgiCiAgICAgIH0KICAgIH0KICBdLAogICJvdXRib3VuZHMiOiBbCiAgICB7CiAgICAgICJ0YWciOiAidmxlc3Mtb3V0IiwKICAgICAgInByb3RvY29sIjogInZsZXNzIiwKICAgICAgInNldHRpbmdzIjogewogICAgICAgICJ2bmV4dCI6IFsKICAgICAgICAgIHsKICAgICAgICAgICAgImFkZHJlc3MiOiAieW91ci1zZXJ2ZXIuY29tIiwKICAgICAgICAgICAgInBvcnQiOiA0NDMsCiAgICAgICAgICAgICJ1c2VycyI6IFsKICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAiaWQiOiAieW91ci11dWlkLWhlcmUiLAogICAgICAgICAgICAgICAgImZsb3ciOiAieHRscy1ycHJ4LXZpc2lvbiIKICAgICAgICAgICAgICB9CiAgICAgICAgICAgIF0KICAgICAgICAgIH0KICAgICAgICBdCiAgICAgIH0sCiAgICAgICJzdHJlYW1TZXR0aW5ncyI6IHsKICAgICAgICAibmV0d29yayI6ICJ0Y3AiLAogICAgICAgICJzZWN1cml0eSI6ICJ0bHMiLAogICAgICAgICJ0bHNTZXR0aW5ncyI6IHsKICAgICAgICAgICJzZXJ2ZXJOYW1lIjogInlvdXItc2VydmVyLmNvbSIKICAgICAgICB9CiAgICAgIH0KICAgIH0KICBdCn0="
log_level: warning
```

## Usage

1. Configure your Xray client settings in the add-on configuration
2. Start the add-on
3. The HTTP proxy will be available on port 8080
4. Configure your applications to use `http://homeassistant-ip:8080` as the HTTP proxy

## Debugging Connection Issues

If you're experiencing connection problems (like 504 Gateway Timeout), you can debug the issue by:

1. **Enable Debug Mode**: Set `debug_mode: true` in your addon configuration to see detailed configuration preview
2. **Check Logs**: Look at the addon logs for connectivity test results and error messages
3. **Access Container**: Connect to the Docker container and run the debug script:
   ```bash
   # Get container ID
   docker ps | grep xray
   
   # Access container
   docker exec -it <container_id> /bin/bash
   
   # Run debug script
   xray-debug
   ```

The debug script will check:
- Network connectivity to your server
- DNS resolution
- Xray process status
- HTTP proxy functionality
- Port listening status

Common issues:
- **504 Gateway Timeout**: Server unreachable or wrong configuration
- **DNS Issues**: Cannot resolve server hostname
- **Firewall**: Outbound connections blocked
- **Wrong Configuration**: Check server address, port, UUID, and protocol settings

## Support

For issues and feature requests, please visit the [GitHub repository](https://github.com/j0rsa/home-assistant-addons).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg