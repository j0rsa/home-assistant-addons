# Home Assistant Apps: J0rsa

> **Note:** As of [Home Assistant 2026.2](https://www.home-assistant.io/blog/2026/02/04/release-20262/), add-ons are now called "apps." You may still see the old terminology in some places.

## About

Home Assistant allows anyone to create app repositories to share their apps for Home Assistant easily. This repository is one of those repositories, providing extra Home Assistant apps for your installation.

The primary goal of this project is to provide you (as a Home Assistant user) with additional, high quality, apps that allow you to take your automated home to the next level.

## Installation

[![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fj0rsa%2Fhome-assistant-apps)

If you want to do add the repository manually, please follow the procedure highlighted in the [Home Assistant website](https://home-assistant.io/hassio/installing_third_party_addons). Use the following URL to add this repository: https://github.com/j0rsa/home-assistant-apps

# Apps provided by this repository

## Backup & Storage
- **Duplicati** - Backup your data to the cloud or locally ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

## Download Management
- **Ariang** - Modern web frontend for aria2 download utility ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

## AI & Machine Learning
- **Ollama** - Run offline LLM models locally without cloud connectivity ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
- **Open WebUI** - Feature-rich WebUI for Ollama (formerly Ollama WebUI) ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
- **Qdrant** - High-performance vector database for AI applications with REST and gRPC APIs ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

## Networking & Proxy
- **SNI Proxy** - SNI-based proxy for routing traffic ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armv7 Architecture][armv7-shield]
- **SNI Socket Proxy** - SNI proxy with SOCKS5 support, routes HTTP/HTTPS through a SOCKS5 proxy based on hostname ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
- **Go SOCKS5 Proxy** - Simple, lightweight SOCKS5 proxy server with authentication and IP allowlisting ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
- **HevSocks5 TProxy** - Transparent SOCKS5 proxy client for routing traffic through a remote SOCKS5 server ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
- **Xray** - High-performance proxy client supporting VLESS/VMess/Trojan protocols ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armv7 Architecture][armv7-shield]
- **Xray Configurator** - Web interface to convert proxy links to Xray configuration files ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]
- **Netmaker Client** - WireGuard VPN client with SOCKS proxy support ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armv7 Architecture][armv7-shield]

## DevOps & Git
- **Gitea Mirror** - Mirror GitHub repositories, organizations, and metadata into your self-hosted Gitea instance. Minimal configuration required - all settings managed through the web UI. ![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

# Automation Blueprints

Ready-to-use Home Assistant automation blueprints:

- **IKEA Bilresa Unified Controller** - Complete control for IKEA Bilresa scroll wheel with 3 layers × 3 buttons. Supports brightness adjustment, multi-press actions, hold actions, scenes, and covers.
  
  [![Import Blueprint](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fgithub.com%2Fj0rsa%2Fhome-assistant-apps%2Fblob%2Fmain%2Fblueprints%2Fikea_bilresa_unified.yaml)
  
  [View YAML](https://github.com/j0rsa/home-assistant-apps/blob/main/blueprints/ikea_bilresa_unified.yaml)

- **ESPHome Auto-Updater** - Automatically update ESPHome devices when new versions are available. Supports update windows, notifications, and selective device updates.
  
  [![Import Blueprint](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fgithub.com%2Fj0rsa%2Fhome-assistant-apps%2Fblob%2Fmain%2Fblueprints%2Fesphome_auto_updater.yaml)
  
  [View YAML](https://github.com/j0rsa/home-assistant-apps/blob/main/blueprints/esphome_auto_updater.yaml)

[aarch64-shield]:
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg

<a href="https://www.buymeacoffee.com/j0rsa" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
