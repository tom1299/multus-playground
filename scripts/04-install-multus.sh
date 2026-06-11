#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-multus-kind}"
MULTUS_MANIFEST_URL="${MULTUS_MANIFEST_URL:-https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset-thick.yml}"
CNI_PLUGINS_VERSION="${CNI_PLUGINS_VERSION:-v1.5.1}"
CNI_PLUGINS_ARCH="${CNI_PLUGINS_ARCH:-amd64}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CNI_TAR="cni-plugins-linux-${CNI_PLUGINS_ARCH}-${CNI_PLUGINS_VERSION}.tgz"
CNI_URL="https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/${CNI_TAR}"

curl -fsSL "$CNI_URL" -o "$TMP_DIR/$CNI_TAR"
tar -xzf "$TMP_DIR/$CNI_TAR" -C "$TMP_DIR" ./macvlan

for node in $(kind get nodes --name "$CLUSTER_NAME"); do
  docker cp "$TMP_DIR/macvlan" "$node:/opt/cni/bin/macvlan"
  docker exec "$node" chmod +x /opt/cni/bin/macvlan
  docker exec "$node" sh -c 'test -x /opt/cni/bin/macvlan'
done

kubectl apply -f "$MULTUS_MANIFEST_URL"
kubectl -n kube-system rollout status daemonset/kube-multus-ds --timeout=180s
