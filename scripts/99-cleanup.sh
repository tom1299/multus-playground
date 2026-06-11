#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-multus-kind}"
NETWORK_NAME="${NETWORK_NAME:-multus-secondary}"
CONTAINER_NAME="${CONTAINER_NAME:-multus-nginx}"

kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker network rm "$NETWORK_NAME" >/dev/null 2>&1 || true

if docker network inspect kind >/dev/null 2>&1; then
  if [ "$(docker network inspect kind -f '{{len .Containers}}')" = "0" ]; then
    docker network rm kind >/dev/null 2>&1 || true
  fi
fi

