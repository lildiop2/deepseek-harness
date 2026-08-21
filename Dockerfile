FROM node:24-bookworm-slim

ARG DSH_VERSION=latest

ENV NODE_ENV=production \
    HOME=/home/node \
    DSH_TELEMETRY_DISABLED=1 \
    PNPM_HOME=/home/node/.local/share/pnpm \
    PATH=/home/node/.local/share/pnpm:/usr/local/bin:$PATH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        curl \
        bash \
        tini \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm \
    && npm install -g "@deepseek-ai/dsh@${DSH_VERSION}" \
    && dsh --version \
    && pnpm --version

RUN mkdir -p \
        /home/node/.dsh \
        /home/node/.local/share/pnpm \
        /workspace \
    && chown -R node:node \
        /home/node \
        /workspace

USER node

WORKDIR /workspace

# Instala o dsh-proxy
RUN dsh plugin --profile web add github:smanx/dsh-proxy#master

# Configuração dos providers
RUN cat > /home/node/.dsh/settings.yaml <<'EOF'
ollama:
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
RUN cat > /home/node/default-model.yaml <<'EOF'
- id: agent-default-model
  config:
    provider: ollama-local
    model: llama3.2
EOF

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh

RUN chmod +x /home/node/entrypoint.sh

EXPOSE 3081

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/home/node/entrypoint.sh"]