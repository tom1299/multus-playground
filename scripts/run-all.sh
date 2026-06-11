#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$ROOT_DIR/01-create-kind.sh"
"$ROOT_DIR/02-setup-secondary-network.sh"
"$ROOT_DIR/03-run-nginx-secondary.sh"
"$ROOT_DIR/04-install-multus.sh"
"$ROOT_DIR/05-apply-nad.sh"
"$ROOT_DIR/06-test-curl-nginx.sh"

