# LiteLLM Proxy Server

Unified LLM API gateway supporting 100+ providers with a single OpenAI-compatible endpoint.

## About

[LiteLLM](https://docs.litellm.ai/) lets you call any LLM provider (OpenAI, Anthropic, Ollama, Gemini, Azure, etc.) through one standardised API. This add-on runs the LiteLLM proxy with a web UI for managing models, API keys, and budgets.

## Prerequisites

A **PostgreSQL database** is required. You can use an external instance or another add-on. Set the connection URL in the `database_url` option.

## Configuration

```yaml
master_key: sk-change-this-master-key  # API key for admin and Bearer auth
salt_key: change-this-random-salt       # Secret used to hash API keys — never change after first use
ui_username: admin                      # Web UI login username
ui_password: ""                         # Web UI login password
database_url: postgresql://user:pass@host:5432/litellm
```

> **Important:** `salt_key` is used to hash stored API keys. Changing it after initial setup will invalidate all previously generated keys.

## Model Configuration

After first start, edit `/config/litellm_config.yaml` (created automatically) to define your model routes:

```yaml
model_list:
  - model_name: ollama/llama3
    litellm_params:
      model: ollama/llama3
      api_base: http://localhost:11434

  - model_name: gpt-4o
    litellm_params:
      model: openai/gpt-4o
      api_key: sk-...
```

Restart the add-on after editing the config file.

## Usage

| Endpoint | URL |
|----------|-----|
| Proxy API | `http://homeassistant.local:4000` |
| Web UI | `http://homeassistant.local:4000/ui` |
| Health | `http://homeassistant.local:4000/health/liveliness` |

Authenticate API requests with the `master_key`:

```bash
curl http://homeassistant.local:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-change-this-master-key" \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt-4o", "messages": [{"role": "user", "content": "Hello"}]}'
```
