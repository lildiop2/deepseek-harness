FROM node:24-bookworm-slim

ARG DSH_VERSION=latest

ENV NODE_ENV=production \
    HOME=/home/node \
    DSH_TELEMETRY_DISABLED=1 \
    PATH=/usr/local/bin:$PATH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        curl \
        bash \
        tini \
    && rm -rf /var/lib/apt/lists/*
    
# pnpm
RUN npm install -g pnpm \
    && pnpm --version

RUN npm install -g "@deepseek-ai/dsh@${DSH_VERSION}" \
    && npm cache clean --force

RUN mkdir -p \
        /home/node/.dsh \
        /home/node/.local/share/pnpm \
        /workspace \
    && chown -R node:node \
        /home/node \
        /workspace

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER node

WORKDIR /workspace

EXPOSE 3081

VOLUME ["/home/node/.dsh","/workspace"]

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]