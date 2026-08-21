FROM node:22-bookworm-slim

ARG DSH_VERSION=latest

ENV NODE_ENV=production \
    HOME=/home/node \
    DSH_TELEMETRY_DISABLED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        curl \
        bash \
        nginx \
        tini \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g "@deepseek-ai/dsh@${DSH_VERSION}" \
    && npm cache clean --force

RUN mkdir -p \
        /home/node/.dsh \
        /workspace \
        /var/log/nginx \
        /var/lib/nginx \
        /run/nginx \
    && chown -R node:node /home/node /workspace

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /workspace

EXPOSE 8080

VOLUME [
    "/home/node/.dsh",
    "/workspace"
]

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]