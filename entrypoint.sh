#!/bin/bash

set -e

PROFILE_DIR="$HOME/.dsh/profiles/web"
PATCH_FILE="$PROFILE_DIR/cordis.patch.yml"

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
cat > /home/node/.dsh/settings.yaml <<EOF
llm-pi-ai:
  providers:
    ollama-local:
      apiKeyEnv: ollama
      api: openai-completions
      baseURL: "http://ollama:11434/v1"
      models:
        - id: "qwen3.5"
        - id: "qwen3-coder"
        - id: "deepseek-r1"
        - id: "llama3.2"
        - id: "gpt-oss"

    ollama-cloud:
      apiKeyEnv: OLLAMA_API_KEY
      api: openai-completions
      baseURL: "https://ollama.com/v1"
      models:
        - id: "qwen3-coder:480b"
        - id: "deepseek-v3.1:671b"
        - id: "gpt-oss:120b"
EOF

# Modelo padrão
cat > /home/node/default-model.yaml <<'EOF'
- id: agent-default-model
  config:
    provider: ollama-local
    model: llama3.2
EOF

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