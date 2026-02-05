---
name: duplicati
title: Duplicati - Backup Solution
description: Free backup software with cloud storage support
category: Backup & Storage
version: latest
architectures:
  - amd64
  - aarch64
ports:
  - 8200
---

# Duplicati App

Free backup software to store encrypted backups online. Supports many storage providers including Google Drive, Amazon S3, Dropbox, and more.

## Features

- ☁️ **Cloud Storage Support**: Google Drive, Dropbox, Amazon S3, OneDrive, and more
- 🔐 **Strong Encryption**: AES-256 encryption for all backups
- 📅 **Flexible Scheduling**: Automated backups on your schedule
- 🔄 **Incremental Backups**: Only upload changed data
- 🗜️ **Compression**: Reduce storage usage with built-in compression
- 🌐 **Web Interface**: Easy-to-use browser-based management
- 📁 **File Versioning**: Keep multiple versions of your files

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "Duplicati" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Start the app

## Usage

### Accessing the Web Interface

After starting the app, access Duplicati at:
- **Via Ingress**: Click "Open Web UI" in the app panel
- **Direct Access**: `http://homeassistant.local:8200`

### Creating Your First Backup

1. Open the Duplicati web interface
2. Click "Add backup"
3. Choose your backup destination (cloud provider or local)
4. Select folders to back up
5. Set encryption passphrase
6. Configure schedule
7. Save and run your first backup

## Supported Storage Providers

| Provider | Description |
|----------|-------------|
| Google Drive | Google's cloud storage |
| Dropbox | Popular cloud storage |
| Amazon S3 | AWS object storage |
| OneDrive | Microsoft cloud storage |
| Backblaze B2 | Affordable cloud backup |
| SFTP/SSH | Remote servers |
| WebDAV | Standard web protocol |
| Local/Network | Local drives or NAS |

## Configuration

### Backup Sources

The app has access to:
- `/config` - App configuration directory
- `/share` - Home Assistant shared folder

### Recommended Backup Strategy

1. **Home Assistant Config**: Back up `/config` folder regularly
2. **Encryption**: Always set a strong passphrase
3. **Retention**: Keep at least 7 days of versions
4. **Testing**: Regularly test restoring files

## Example Backup Configuration

```
Source: /config
Destination: Google Drive
Schedule: Daily at 3:00 AM
Retention: 7 versions
Encryption: AES-256
```

## Restoring Files

1. Open Duplicati web interface
2. Go to "Restore"
3. Select the backup to restore from
4. Choose files or folders to restore
5. Select restore location
6. Start restoration

## Tips

1. **Test Restores**: Periodically verify your backups work
2. **Multiple Destinations**: Consider backing up to multiple locations
3. **Bandwidth**: Schedule large backups during off-peak hours
4. **Notifications**: Set up email alerts for backup status

## Troubleshooting

### Backup Fails

- Check storage provider credentials
- Verify internet connectivity
- Check available storage space
- Review Duplicati logs for errors

### Slow Backups

- First backup is always slowest (full backup)
- Subsequent backups are incremental
- Consider excluding large, rarely-changed files

### Cannot Access Web UI

- Ensure the app is running
- Try accessing via Ingress
- Check port 8200 availability

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-addons/issues)
- [Duplicati Documentation](https://duplicati.readthedocs.io/)
- [Duplicati Forum](https://forum.duplicati.com/)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/duplicati)
