#!/bin/bash

set -e

# Diretório do perfil web do DeepSeek Harness
PROFILE_DIR="$HOME/.dsh/profiles/web"

# Arquivo de configuração adicional do plugin dsh-proxy
PATCH_FILE="$PROFILE_DIR/cordis.patch.yml"

# Garante que o diretório do perfil exista
mkdir -p "$PROFILE_DIR"

echo
echo "Installing dsh-proxy..."

# Instala o plugin dsh-proxy no perfil web
dsh plugin --profile web add github:smanx/dsh-proxy#master

# Gera a configuração do proxy a partir das variáveis de ambiente.
#
# Variáveis disponíveis:
#   DSH_PROXY_HOST           - Host onde o proxy irá escutar
#   DSH_PROXY_PORT           - Porta do proxy
#   DSH_PROXY_UPSTREAM_HOST  - Host do serviço upstream
#   DSH_PROXY_UPSTREAM_PORT  - Porta do serviço upstream
#   DSH_PROXY_USERNAME       - Usuário para autenticação
#   DSH_PROXY_PASSWORD       - Senha para autenticação
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

# Exibe informações da instalação e configuração atual
echo "======================================"
echo " DeepSeek Harness"
echo "======================================"

echo "Node: $(node --version)"
echo "DSH:  $(dsh --version)"
echo "Proxy: ${DSH_PROXY_HOST:-0.0.0.0}:${DSH_PROXY_PORT:-3081}"

# Informa se a autenticação HTTP do proxy está configurada
if [ -n "${DSH_PROXY_USERNAME:-}" ] && [ -n "${DSH_PROXY_PASSWORD:-}" ]; then
    echo "Authentication: enabled"
else
    echo "Authentication: DISABLED"
fi

echo "======================================"

# Inicia o DeepSeek Harness sem abrir o navegador.
# O exec substitui o processo do shell pelo processo do DSH.
exec dsh web --no-open