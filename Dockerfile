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
        $HOME/workspace \
    && chown -R node:node \
        /home/node \
        $HOME/workspace

USER node

WORKDIR $HOME/workspace

# Instala plugins
RUN dsh plugin --profile web add github:smanx/dsh-proxy#master
RUN dsh plugin --profile web add dsh-find-plugin



COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh

RUN chmod +x /home/node/entrypoint.sh

EXPOSE 3081

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/home/node/entrypoint.sh"]