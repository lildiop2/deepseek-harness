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
        tini \
        openssh-client \
        python3 \
        make \
        g++ \
        procps \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g "@deepseek-ai/dsh@${DSH_VERSION}" \
    && npm cache clean --force

RUN mkdir -p \
        /home/node/.dsh \
        /workspace \
    && chown -R node:node \
        /home/node \
        /workspace

USER node

WORKDIR /workspace

EXPOSE 3080

VOLUME [
    "/home/node/.dsh",
    "/workspace"
]

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["dsh", "web", "--no-open","--host", "0.0.0.0", "--port", "3080"]