---
name: open-webui
title: Open WebUI - LLM Interface
description: Feature-rich web interface for Ollama and other LLM backends
category: AI & Machine Learning
version: latest
architectures:
  - amd64
  - aarch64
ports:
  - 8080
---

# Open WebUI App

Feature-rich, self-hosted WebUI for Ollama and OpenAI-compatible APIs. ChatGPT-like experience with your local models.

## About

Open WebUI (formerly Ollama WebUI) is an extensible, feature-rich, and user-friendly self-hosted WebUI designed to operate entirely offline. It supports various LLM runners, including Ollama and OpenAI-compatible APIs.

## Features

- 💬 **ChatGPT-like Interface**: Familiar, intuitive chat experience
- 🔒 **Fully Offline**: Complete privacy with local processing
- 🎨 **Customizable**: Themes, settings, and extensions
- 📝 **Markdown Support**: Rich text formatting with syntax highlighting
- 💾 **Conversation History**: Save and organize your chats
- 🔄 **Model Switching**: Switch between models on the fly
- 📱 **Responsive Design**: Works on desktop and mobile
- 🔌 **Extensible**: Support for pipelines and plugins

## Prerequisites

This app works best with the [Ollama](/apps/ollama/) app installed and running. Install Ollama first to run local LLM models.

## Installation

1. Install and start the [Ollama](/apps/ollama/) app (recommended)
2. Add the J0rsa repository to your Home Assistant
3. Search for "Open WebUI" in the App Store (formerly Add-on Store)
4. Click Install and wait for the download to complete
5. Configure the Ollama API URL if needed
6. Start the app

## Usage

### Accessing the Web Interface

After starting the app, access Open WebUI at:
- **Direct Access**: `http://homeassistant.local:5000`

### First-Time Setup

1. Open the web interface
2. Create an admin account
3. Configure your LLM backend (Ollama URL)
4. Start chatting!

### Connecting to Ollama

By default, Open WebUI connects to Ollama at `http://localhost:11434`. If your Ollama app is running on the same Home Assistant instance, this should work automatically.

## Configuration

### Ollama Connection

If Ollama is on a different host:
1. Open Open WebUI settings
2. Go to "Connections"
3. Update the Ollama API URL

### User Management

Open WebUI supports multiple users:
- **Admin**: Full control over settings and users
- **Users**: Can chat and manage own conversations

## Tips

1. **Model Selection**: Use the dropdown to switch between installed Ollama models
2. **System Prompts**: Customize AI behavior with system prompts
3. **Conversation Export**: Export chats for backup or sharing
4. **Dark Mode**: Toggle dark mode in settings

## Integration with Ollama

Ensure Ollama is running and has models downloaded:

```bash
# Check available models (via Ollama API)
curl http://homeassistant.local:11434/api/tags
```

### Recommended Models

- **llama2**: General-purpose conversations
- **mistral**: Fast and capable
- **codellama**: Code assistance
- **neural-chat**: Conversational AI

## Troubleshooting

### Cannot Connect to Ollama

- Verify Ollama app is running
- Check Ollama API URL in settings
- Ensure both apps can communicate

### Slow Responses

- Larger models require more resources
- Try smaller models (7B instead of 13B)
- Check system RAM usage

### Web Interface Not Loading

- Check that port 5000 is accessible
- Verify the app is running
- Check app logs for errors

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [Open WebUI GitHub](https://github.com/open-webui/open-webui)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-apps/tree/main/open-webui)
