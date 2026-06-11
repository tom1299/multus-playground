#!/usr/bin/env bash
set -euo pipefail

NETWORK_NAME="${NETWORK_NAME:-multus-secondary}"
CONTAINER_NAME="${CONTAINER_NAME:-multus-nginx}"
NGINX_IP="${NGINX_IP:-172.30.10.100}"

if docker ps -a --format '{{.Names}}' | grep -x "$CONTAINER_NAME" >/dev/null 2>&1; then
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

docker run -d \
  --name "$CONTAINER_NAME" \
  --network "$NETWORK_NAME" \
  --ip "$NGINX_IP" \
  nginx:alpine >/dev/null

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME"

