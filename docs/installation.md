---
title: Installation Guide
description: "Step-by-step guide to install J0rsa Home Assistant apps. One-click setup, manual installation, troubleshooting, and architecture support."
permalink: /installation/
---

# Installation Guide

## Prerequisites

Before installing any apps from this repository, ensure you have:

- ✅ Home Assistant OS, Supervised, or Container installation (Apps are not available for Core installations)
- ✅ Supervisor version 2021.06.0 or newer
- ✅ Sufficient storage space for the apps you want to install
- ✅ Network connectivity for downloading app images

## Adding the Repository

### Method 1: One-Click Installation (Recommended)

The easiest way to add our repository is by clicking the button below:

[![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fj0rsa%2Fhome-assistant-addons)

This will:
1. Open your Home Assistant instance
2. Navigate to the Supervisor App Store (formerly Add-on Store)
3. Pre-fill the repository URL
4. You just need to click "Add"

### Method 2: Manual Installation

If the button doesn't work for your setup, you can add the repository manually:

1. **Navigate to Supervisor**
   - Open your Home Assistant web interface
   - Click on "Settings" in the sidebar
   - Select "Apps"
   - Click on "App Store (formerly Add-on Store)"

2. **Add Repository**
   - Click the three dots menu (⋮) in the top right corner
   - Select "Repositories"
   - Add the following URL:
   ```
   https://github.com/j0rsa/home-assistant-addons
   ```
   - Click "Add"

3. **Refresh the Store**
   - Click the three dots menu (⋮) again
   - Select "Reload"
   - You should now see "J0rsa Apps" in the store

## Installing Apps

Once the repository is added:

1. **Browse Available Apps**
   - In the App Store (formerly Add-on Store), scroll down to find the "J0rsa Apps" section
   - Click on any app to view its details

2. **Install an App**
   - Click on the app you want to install
   - Read the documentation tab for important information
   - Click "Install" and wait for the process to complete
   - This may take several minutes depending on your internet speed and hardware

3. **Configure the App**
   - After installation, go to the "Configuration" tab
   - Modify settings as needed (each app has different options)
   - Click "Save"

4. **Start the App**
   - Go to the "Info" tab
   - Click "Start"
   - Optionally, enable "Start on boot" and "Watchdog" for automatic management
   - Enable "Show in sidebar" for quick access

## Updating Apps

### Automatic Updates

1. In the app's Info tab, enable "Auto-update"
2. The app will automatically update when new versions are available

### Manual Updates

1. When an update is available, you'll see an "Update" button in the app's Info tab
2. Click "Update" to install the latest version
3. Check the changelog before updating for any breaking changes

## Troubleshooting

### Repository Not Showing

If the repository doesn't appear after adding:

1. **Check the URL**: Ensure you entered exactly: `https://github.com/j0rsa/home-assistant-addons`
2. **Reload Supervisor**: Settings → System → Hardware → ⋮ → Reload Supervisor
3. **Check Logs**: Settings → System → Logs → Select "Supervisor"
4. **Network Issues**: Ensure your Home Assistant can access GitHub

### Installation Fails

If an app fails to install:

1. **Check Architecture**: Ensure the app supports your hardware architecture
2. **Storage Space**: Verify you have sufficient disk space
3. **Check Supervisor Logs**: Look for error messages in the Supervisor logs
4. **Network Connectivity**: Ensure stable internet connection
5. **Try Again Later**: Sometimes Docker Hub rate limits can cause temporary failures

### App Won't Start

If an installed app won't start:

1. **Check Configuration**: Review the Configuration tab for any required settings
2. **Port Conflicts**: Ensure no other services are using the same ports
3. **Check App Logs**: View the Log tab for error messages
4. **Resource Limits**: Some apps require significant RAM or CPU

## Architecture Support

Our apps support various architectures. Check compatibility before installation:

- **amd64**: Standard Intel/AMD 64-bit processors (most PCs, Intel NUC)
- **aarch64**: 64-bit ARM processors (Raspberry Pi 4/5, ODROID)
- **armv7**: 32-bit ARM processors (Raspberry Pi 3, older ARM devices)

## Getting Help

If you encounter issues:

1. **Check Documentation**: Each app has a Documentation tab with specific information
2. **GitHub Issues**: Report bugs or request features on our [GitHub repository](https://github.com/j0rsa/home-assistant-apps/issues)
3. **Community Forum**: Ask questions in the [Home Assistant Community](https://community.home-assistant.io/)
4. **Logs**: Always include relevant logs when reporting issues

## Security Considerations

- **API Keys**: Keep any API keys or passwords secure
- **Network Exposure**: Be cautious when exposing apps to the internet
- **Regular Updates**: Keep apps updated for security patches
- **Backup**: Always backup your configuration before major changes

---

[← Back to Home](/) | [View Apps →](/apps/)