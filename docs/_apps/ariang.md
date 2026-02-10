---
name: ariang
title: AriaNg - Download Manager
description: Modern web frontend for aria2 download utility
category: Download Management
version: latest
architectures:
  - amd64
  - aarch64
ports:
  - 8080
---

# AriaNg App

Modern web frontend making aria2 easier to use. Manage all your downloads through a sleek, responsive interface.

## About

AriaNg is a modern web frontend for [aria2](https://aria2.github.io/), a lightweight multi-protocol & multi-source, cross-platform download utility operated in command-line.

## Features

- 🌐 **Multi-Protocol Support**: HTTP/HTTPS, FTP, SFTP, BitTorrent, and Metalink
- 📊 **Real-time Statistics**: Live download progress and speed monitoring
- 📱 **Responsive Design**: Works on desktop and mobile devices
- 🎛️ **Queue Management**: Organize and prioritize your downloads
- 🔄 **Remote Control**: Manage downloads from anywhere on your network
- ⚡ **Multi-source Downloads**: Download from multiple sources simultaneously

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "AriaNg" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Start the app

## Usage

### Accessing the Web Interface

After starting the app, access the web UI at:
- **Via Ingress**: Click "Open Web UI" in the app panel
- **Direct Access**: `http://homeassistant.local:8080`

### Adding Downloads

1. Open the AriaNg web interface
2. Click "Add" or paste a download URL
3. Configure download options if needed
4. Start the download

### Supported Protocols

| Protocol | Description |
|----------|-------------|
| HTTP/HTTPS | Standard web downloads |
| FTP/SFTP | File transfer protocols |
| BitTorrent | Peer-to-peer file sharing |
| Metalink | Multi-source downloads |
| Magnet | BitTorrent magnet links |

## Configuration

The app comes pre-configured and ready to use. Downloads are stored in the shared folder accessible to Home Assistant.

## Tips

1. **Large Files**: aria2 excels at downloading large files with resume support
2. **Multiple Sources**: Use Metalink to download from multiple mirrors
3. **BitTorrent**: Add trackers for better peer discovery
4. **Scheduling**: Use Home Assistant automations to control downloads

## Troubleshooting

### Web Interface Not Loading
- Check that port 8080 is not in use by another service
- Try accessing via Home Assistant Ingress

### Slow Downloads
- Check your internet connection
- For BitTorrent, ensure ports are properly forwarded
- Try adding more sources or trackers

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)
- [aria2 Documentation](https://aria2.github.io/manual/en/html/)
- [AriaNg Project](https://github.com/mayswind/AriaNg)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-apps/tree/main/airang)
