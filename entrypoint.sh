#!/bin/bash

set -e

PROFILE_DIR="$HOME/.dsh/profiles/web"
PATCH_FILE="$PROFILE_DIR/cordis.patch.yml"

mkdir -p "$PROFILE_DIR"
# echo
# echo "Installing dsh-proxy..."

# dsh plugin --profile web add github:smanx/dsh-proxy#master

cat > "$PATCH_FILE" <<EOF
- id: dsh-proxy
  config:
    listenHost: '${DSH_PROXY_HOST:-0.0.0.0}'
    listenPort: ${DSH_PROXY_PORT:-3081}
    upstreamHost: '${DSH_PROXY_UPSTREAM_HOST:-127.0.0.1}'
    upstreamPort: ${DSH_PROXY_UPSTREAM_PORT:-0}
    username: '${DSH_PROXY_USERNAME:-}'
    password: '${DSH_PROXY_PASSWORD:-}'
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

exec dsh web --no-open