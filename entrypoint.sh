#!/bin/bash

set -e

echo "Starting DeepSeek Harness..."

su -s /bin/bash node -c \
    'cd /workspace && exec dsh web --no-open' &

echo "Starting Nginx on :8080..."

exec nginx -g "daemon off;"