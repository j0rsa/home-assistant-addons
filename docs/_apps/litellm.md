---
name: litellm
title: LiteLLM - Unified LLM API Gateway
description: OpenAI-compatible proxy supporting 100+ LLM providers with cost tracking and key management
category: AI & Machine Learning
version: latest
architectures:
  - amd64
  - aarch64
ports:
  - 4000
---

# LiteLLM Proxy Server

Unified LLM API gateway that lets you call OpenAI, Anthropic, Ollama, and 100+ other providers through a single OpenAI-compatible endpoint.

## Features

- **Universal API**: One endpoint for all LLM providers
- **Web UI**: Model management, cost tracking, and API key administration at `/ui`
- **Virtual API Keys**: Create scoped keys with rate limits and budget caps
- **Cost Tracking**: Per-user and per-key spend monitoring via PostgreSQL
- **Load Balancing**: Route requests across multiple models or providers
- **OpenAI-Compatible**: Drop-in replacement for OpenAI SDK calls

## Prerequisites

A **PostgreSQL database** is required for the management UI, virtual key storage, and cost tracking. Configure the `database_url` option with your connection string.

## Installation

1. Add the J0rsa repository to Home Assistant
2. Install the **LiteLLM** app
3. Set `master_key`, `salt_key`, `ui_password`, and `database_url` before starting
4. Start the app
5. Configure models in `/config/litellm_config.yaml` (created automatically)
6. Restart the app to apply model changes

## Configuration

```yaml
master_key: sk-change-this-master-key
salt_key: change-this-random-salt
ui_username: admin
ui_password: your-ui-password
database_url: postgresql://user:pass@host:5432/litellm
```

| Option | Description | Required |
|--------|-------------|----------|
| `master_key` | Admin API key (used as Bearer token for all API calls) | Yes |
| `salt_key` | Secret for hashing virtual API keys — **never change after setup** | Yes |
| `ui_username` | Web UI login username | Yes |
| `ui_password` | Web UI login password | Yes |
| `database_url` | PostgreSQL connection string | Yes |

## Model Configuration

Edit `/config/litellm_config.yaml` to define available models. Restart the add-on after changes.

```yaml
model_list:
  # Ollama (via the Ollama add-on)
  - model_name: ollama/llama3
    litellm_params:
      model: ollama/llama3
      api_base: http://localhost:11434

  # OpenAI
  - model_name: gpt-4o
    litellm_params:
      model: openai/gpt-4o
      api_key: sk-...

  # Anthropic
  - model_name: claude-3-5-sonnet
    litellm_params:
      model: anthropic/claude-3-5-sonnet-20241022
      api_key: sk-ant-...
```

## Usage

### Accessing Services

| Service | URL |
|---------|-----|
| Proxy API | `http://homeassistant.local:4000` |
| Web UI | `http://homeassistant.local:4000/ui` |
| Health check | `http://homeassistant.local:4000/health/liveliness` |

### API Example

```bash
curl http://homeassistant.local:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-change-this-master-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://homeassistant.local:4000",
    api_key="sk-change-this-master-key"
)

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## Security

- The `master_key` grants full admin access — keep it secret
- The `salt_key` is a one-time secret; changing it invalidates all virtual API keys
- Create scoped virtual keys via the web UI to limit access per user or application
- Expose port 4000 only to trusted networks

## Troubleshooting

### App won't start
- Verify `database_url` is correct and the database is reachable
- Check that `master_key` and `salt_key` are non-empty strings

### Models return errors
- Confirm the model name in your request matches an entry in `litellm_config.yaml`
- Check provider API keys and connectivity

### UI login fails
- Use `ui_username` and `ui_password` from the configuration
- If the password is empty, try the `master_key` value

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)

---

[← Back to Apps](/apps/) | [View on GitHub](https://github.com/j0rsa/home-assistant-apps/tree/main/litellm)
