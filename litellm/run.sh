#!/bin/bash
set -euo pipefail

OPTIONS_FILE=/data/options.json
LITELLM_CONFIG=/config/litellm_config.yaml

# Read configuration from Home Assistant options
MASTER_KEY=$(jq -r '.master_key' "${OPTIONS_FILE}")
SALT_KEY=$(jq -r '.salt_key' "${OPTIONS_FILE}")
UI_USERNAME=$(jq -r '.ui_username' "${OPTIONS_FILE}")
UI_PASSWORD=$(jq -r '.ui_password' "${OPTIONS_FILE}")
DATABASE_URL=$(jq -r '.database_url' "${OPTIONS_FILE}")
STORE_MODEL_IN_DB=$(jq -r 'if .store_model_in_db then "True" else "False" end' "${OPTIONS_FILE}")

# Export as environment variables consumed by LiteLLM
export LITELLM_MASTER_KEY="${MASTER_KEY}"
export LITELLM_SALT_KEY="${SALT_KEY}"
export UI_USERNAME="${UI_USERNAME}"
export UI_PASSWORD="${UI_PASSWORD}"
export DATABASE_URL="${DATABASE_URL}"
export STORE_MODEL_IN_DB="${STORE_MODEL_IN_DB}"
export PROXY_ADMIN_ID="${UI_USERNAME}"

# Create a default model config if none exists yet
if [ ! -f "${LITELLM_CONFIG}" ]; then
    echo "No config found at ${LITELLM_CONFIG}, creating default..."
    cat > "${LITELLM_CONFIG}" << 'EOF'
# LiteLLM model configuration
# See: https://docs.litellm.ai/docs/proxy/configs
#
# Add your models below. Restart the add-on after changes.
# API keys can be set here or as environment variables.
#
# Example – Ollama (running via the Ollama add-on):
# model_list:
#   - model_name: ollama/llama3
#     litellm_params:
#       model: ollama/llama3
#       api_base: http://localhost:11434
#
# Example – OpenAI:
# model_list:
#   - model_name: gpt-4o
#     litellm_params:
#       model: openai/gpt-4o
#       api_key: sk-...
#
# Example – Anthropic:
# model_list:
#   - model_name: claude-3-5-sonnet
#     litellm_params:
#       model: anthropic/claude-3-5-sonnet-20241022
#       api_key: sk-ant-...

model_list: []
EOF
fi

echo "Starting LiteLLM proxy on port 4000..."
exec litellm --config "${LITELLM_CONFIG}" --port 4000 --host 0.0.0.0 --telemetry False
