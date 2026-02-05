---
title: Home
---

# J0rsa Home Assistant Apps

> **Note:** As of [Home Assistant 2026.2](https://www.home-assistant.io/blog/2026/02/04/release-20262/), add-ons are now called "apps." You may still see the old terminology in some places.

Welcome to the J0rsa Home Assistant Apps repository! We provide high-quality, reliable apps to enhance your Home Assistant experience.

[![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fj0rsa%2Fhome-assistant-addons)

## 🚀 Quick Installation

Click the button above or add this repository URL to your Home Assistant:
```
https://github.com/j0rsa/home-assistant-addons
```

## 📦 Available Apps

### 💾 Backup & Storage

#### [Duplicati](/apps/duplicati)
Comprehensive backup solution with cloud support. Back up your Home Assistant data to various cloud providers or local storage with encryption and scheduling options.
- Supports multiple cloud providers (Google Drive, Dropbox, S3, etc.)
- Encrypted backups with strong AES-256 encryption
- Flexible scheduling and retention policies
- Web-based management interface

**Architectures:** `aarch64` `amd64`

---

### 📥 Download Management

#### [Ariang](/apps/ariang)
Modern web frontend for the powerful aria2 download utility. Manage all your downloads through a sleek, responsive interface.
- Support for HTTP/HTTPS, FTP, BitTorrent, and Metalink
- Real-time download statistics
- Remote control capability
- Queue management

**Architectures:** `aarch64` `amd64`

---

### 🤖 AI & Machine Learning

#### [Ollama](/apps/ollama)
Run Large Language Models locally on your Home Assistant hardware. Complete privacy with no cloud dependency.
- Support for various LLM models (Llama, Mistral, etc.)
- REST API for integration
- GPU acceleration support
- Model management

**Architectures:** `aarch64` `amd64`

#### [Open WebUI](/apps/open-webui)
Feature-rich web interface for Ollama. ChatGPT-like experience with your local models.
- Clean, intuitive chat interface
- Multiple conversation management
- Model switching on the fly
- Markdown support with syntax highlighting

**Architectures:** `aarch64` `amd64`

#### [Qdrant](/apps/qdrant)
High-performance vector database for AI applications. Essential for semantic search and RAG systems.
- REST and gRPC APIs
- Real-time index updates
- Filtering and payload support
- Web UI for management

**Architectures:** `aarch64` `amd64`

---

### 🌐 Networking & Proxy

#### [SNI Proxy](/apps/sniproxy)
Transparent SNI-based proxy for routing HTTPS traffic without decryption.
- SNI-based routing
- Minimal resource usage
- SSL passthrough
- Multiple backend support

**Architectures:** `aarch64` `amd64` `armv7`

#### [Xray](/apps/xray)
Advanced proxy client with support for modern protocols. Enhanced privacy and network freedom.
- VLESS/VMess/Trojan protocol support
- Advanced routing rules
- Traffic statistics
- Low latency

**Architectures:** `aarch64` `amd64` `armv7`

#### [Xray Configurator](/apps/xray-configurator)
Web-based configuration generator for Xray. Simplify complex proxy setups.
- Convert proxy links to configurations
- Visual configuration editor
- Template management
- Export/import configs

**Architectures:** `aarch64` `amd64`

#### [Netmaker Client](/apps/netmaker)
WireGuard VPN client with advanced networking features.
- WireGuard VPN connectivity
- SOCKS proxy support
- Automatic reconnection
- Network mesh support

**Architectures:** `aarch64` `amd64` `armv7`

---

## 🤖 Automation Blueprints

Ready-to-use automation blueprints for Home Assistant:

- **[IKEA Bilresa Unified Controller](/blueprints)** - Complete control for scroll wheel with 3 layers × 3 buttons
- **[ESPHome Auto-Updater](/blueprints)** - Automatically update ESPHome devices

[View all blueprints →](/blueprints)

---

## 🎯 Features

- **Easy Installation**: One-click installation through Home Assistant
- **Regular Updates**: Actively maintained with frequent updates
- **Multi-Architecture**: Support for various hardware platforms
- **Secure**: All apps follow security best practices
- **Documentation**: Comprehensive documentation for each app

## 💡 Getting Started

1. **Add the Repository**: Click the installation button or manually add the repository URL
2. **Browse Apps**: Navigate to Supervisor → App Store (formerly Add-on Store) → J0rsa Apps
3. **Install**: Click on any app to view details and install
4. **Configure**: Follow the documentation for each app to configure

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs or request features via [GitHub Issues](https://github.com/j0rsa/home-assistant-addons/issues)
- Submit pull requests with improvements
- Share your experience and help others in discussions

## 📚 Resources

- [GitHub Repository](https://github.com/j0rsa/home-assistant-addons)
- [Home Assistant Documentation](https://www.home-assistant.io/addons/)
- [Community Forum](https://community.home-assistant.io/)

## ☕ Support

If you find these apps useful, consider supporting the development:

<a href="https://www.buymeacoffee.com/j0rsa" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

---

*Made with ❤️ for the Home Assistant Community*