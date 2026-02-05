---
name: ollama
title: Ollama - Local LLM Runner
description: Run Large Language Models locally on your Home Assistant
category: AI & Machine Learning
version: latest
architectures: 
  - amd64
  - aarch64
ports:
  - 11434
---

# Ollama App

Run Large Language Models (LLMs) locally on your Home Assistant hardware with complete privacy and no cloud dependency.

## Features

- 🔒 **Complete Privacy**: All processing happens locally
- 🚀 **Multiple Models**: Support for Llama, Mistral, Phi, and more
- 🎯 **REST API**: Easy integration with Home Assistant and other services
- 💾 **Model Management**: Download, update, and remove models easily
- ⚡ **GPU Support**: Acceleration for supported hardware

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "Ollama" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Configure the app (see Configuration below)
5. Start the app

## Configuration

```yaml
# Example configuration
gpu_support: false  # Enable if you have compatible GPU
models_path: /data/models  # Where to store models
api_host: 0.0.0.0  # API listening address
api_port: 11434  # API port
```

### Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `gpu_support` | Enable GPU acceleration if available | `false` |
| `models_path` | Directory to store downloaded models | `/data/models` |
| `api_host` | API listening address | `0.0.0.0` |
| `api_port` | API listening port | `11434` |

## Usage

### Downloading Models

After starting the app, you can download models using the API:

```bash
curl http://homeassistant.local:11434/api/pull -d '{
  "name": "llama2"
}'
```

### Popular Models

- **llama2**: Meta's Llama 2 model (7B parameters)
- **mistral**: Mistral AI's 7B model
- **phi**: Microsoft's Phi-2 model (2.7B)
- **codellama**: Specialized for code generation
- **neural-chat**: Intel's conversational model

### Running Inference

Send a prompt to the model:

```bash
curl http://homeassistant.local:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?"
}'
```

### Integration with Home Assistant

You can integrate Ollama with Home Assistant using REST commands:

```yaml
rest_command:
  ask_ollama:
    url: "http://localhost:11434/api/generate"
    method: POST
    headers:
      Content-Type: "application/json"
    payload: '{"model": "llama2", "prompt": "{{ prompt }}"}'
```

## Hardware Requirements

### Minimum Requirements
- **CPU**: 4 cores recommended
- **RAM**: 8GB minimum (16GB recommended)
- **Storage**: 10GB+ depending on models

### Model Size Guidelines
- 7B models: ~4GB RAM
- 13B models: ~8GB RAM
- 30B models: ~16GB RAM

## API Documentation

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/generate` | POST | Generate text from a prompt |
| `/api/pull` | POST | Download a model |
| `/api/tags` | GET | List available models |
| `/api/delete` | DELETE | Remove a model |

### Example: List Models

```bash
curl http://homeassistant.local:11434/api/tags
```

## Tips and Tricks

1. **Model Selection**: Start with smaller models (7B) and upgrade if needed
2. **Performance**: Enable GPU support if you have compatible hardware
3. **Storage**: Models are stored persistently in `/data/models`
4. **Memory**: Monitor RAM usage, especially with larger models
5. **API Key**: Consider adding authentication for external access

## Troubleshooting

### App Won't Start
- Check logs for error messages
- Ensure sufficient RAM is available
- Verify port 11434 is not in use

### Model Download Fails
- Check internet connectivity
- Ensure sufficient storage space
- Try downloading a smaller model first

### Slow Performance
- Consider using smaller models
- Enable GPU acceleration if available
- Close other resource-intensive apps

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-addons/issues)
- [Ollama Documentation](https://ollama.ai/docs)
- [Community Forum](https://community.home-assistant.io/)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/ollama)