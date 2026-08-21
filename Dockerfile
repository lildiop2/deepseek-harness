FROM node:24-bookworm-slim

ARG DSH_VERSION=0.1.0-rc.6

ENV NODE_ENV=production \
    HOME=/home/node \
    DSH_TELEMETRY_DISABLED=1

# Dependências necessárias para o Harness e ferramentas de shell
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        curl \
        bash \
        tini \
        openssh-client \
        python3 \
        make \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# Instala o DeepSeek Harness com versão fixa
RUN npm install -g "@deepseek-ai/dsh@${DSH_VERSION}" \
    && npm cache clean --force

# Diretórios persistentes e workspace
RUN mkdir -p /home/node/.dsh /workspace \
    && chown -R node:node /home/node /workspace

USER node

WORKDIR /workspace

EXPOSE 3080

VOLUME ["/home/node/.dsh", "/workspace"]

ENTRYPOINT ["/usr/bin/tini", "--", "dsh"]

CMD ["web"]

