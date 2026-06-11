#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-multus-kind}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kind create cluster --name "$CLUSTER_NAME" --config "$ROOT_DIR/kind-config.yaml"

