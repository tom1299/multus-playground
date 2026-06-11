#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-multus-kind}"
NETWORK_NAME="${NETWORK_NAME:-multus-secondary}"
NETWORK_SUBNET="${NETWORK_SUBNET:-172.30.0.0/16}"

if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  docker network create --driver bridge --subnet "$NETWORK_SUBNET" "$NETWORK_NAME" >/dev/null
fi

for node in $(kind get nodes --name "$CLUSTER_NAME"); do
  docker network connect "$NETWORK_NAME" "$node" 2>/dev/null || true
done

for node in $(kind get nodes --name "$CLUSTER_NAME"); do
  echo "$node"
  docker exec "$node" sh -c "ip -o -4 addr show | grep '172\\.30\\.' || true"
done

