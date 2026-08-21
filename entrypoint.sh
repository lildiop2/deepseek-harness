#!/bin/bash

set -e

echo "======================================"
echo " DeepSeek Harness"
echo "======================================"

echo "Node:"
node --version

echo "DSH:"
command -v dsh || true

dsh --version || true

echo
echo "Installing dsh-proxy..."

dsh plugin --profile web add github:smanx/dsh-proxy#master

echo
echo "Starting DeepSeek Harness..."

exec dsh web --no-open