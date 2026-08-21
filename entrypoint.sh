#!/bin/bash

set -e

PROFILE_DIR="$HOME/.dsh/profiles/web"
PATCH_FILE="$PROFILE_DIR/cordis.patch.yml"
CREDENTIALS_FILE="$HOME/.dsh/.credentials.yaml"
mkdir -p "$PROFILE_DIR"

cat > "$PATCH_FILE" <<EOF
- id: dsh-proxy
  config:
    listenHost: '${DSH_PROXY_HOST:-0.0.0.0}'
    listenPort: ${DSH_PROXY_PORT:-3081}
    upstreamHost: '${DSH_PROXY_UPSTREAM_HOST:-127.0.0.1}'
    upstreamPort: ${DSH_PROXY_UPSTREAM_PORT:-3080}
    username: '${DSH_PROXY_USERNAME:-}'
    password: '${DSH_PROXY_PASSWORD:-}'
EOF


# Configuração dos providers
cat > "$HOME/.dsh/settings.yaml" <<EOF
llm-pi-ai:
  providers:
    ollama-local:
    apiKeyEnv: 'ollama'
      api: openai-completions
      baseURL: '${OLLAMA_BASE_URL:-http://ollama:11434/v1}'
      models:
        - id: '${OLLAMA_MODEL_1:-qwen3.5}'
        - id: '${OLLAMA_MODEL_2:-qwen3-coder}'
        - id: '${OLLAMA_MODEL_3:-deepseek-r1}'
        - id: '${OLLAMA_MODEL_4:-llama3.2}'
        - id: '${OLLAMA_MODEL_5:-gpt-oss}'

    ollama-cloud:
      apiKeyEnv: '${OLLAMA_API_KEY}'
      api: openai-completions
      baseURL: '${OLLAMA_CLOUD_BASE_URL:-https://ollama.com/v1}'
      models:
        - id: '${OLLAMA_CLOUD_MODEL_1:-qwen3-coder:480b}'
        - id: '${OLLAMA_CLOUD_MODEL_2:-deepseek-v3.1:671b}'
        - id: '${OLLAMA_CLOUD_MODEL_3:-gpt-oss:120b}'
EOF

# Modelo padrão
cat > "$HOME/default-model.yaml" <<EOF
- id: agent-default-model
  config:
    provider: ollama-local
    model: llama3.2
EOF

# Configuração do credencial
cat > "$CREDENTIALS_FILE" <<EOF
OLLAMA_API_KEY: '$OLLAMA_API_KEY'
EOF

    chmod 600 "$CREDENTIALS_FILE"
echo "======================================"
echo " DeepSeek Harness"
echo "======================================"

echo "Node: $(node --version)"
echo "DSH:  $(dsh --version)"
echo "Proxy: ${DSH_PROXY_HOST:-0.0.0.0}:${DSH_PROXY_PORT:-3081}"

if [ -n "${DSH_PROXY_USERNAME:-}" ] && [ -n "${DSH_PROXY_PASSWORD:-}" ]; then
    echo "Authentication: enabled"
else
    echo "Authentication: DISABLED"
fi

echo "======================================"

exec dsh web --patch $HOME/default-model.yaml --no-open