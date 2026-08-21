FROM node:22-bookworm-slim

ARG DSH_VERSION=latest

ENV NODE_ENV=production
ENV HOME=/home/node

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        curl \
        bash \
        tini \
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

# Instala o proxy oficial da comunidade
RUN dsh plugin --profile web add github:smanx/dsh-proxy#master

EXPOSE 3081

VOLUME [ "/home/node/.dsh", "/workspace"]

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["dsh", "web", "--no-open"]