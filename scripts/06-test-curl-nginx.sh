#!/usr/bin/env bash
set -euo pipefail

POD_NAME="${POD_NAME:-multus-curl}"
NAD_NAME="${NAD_NAME:-secondary-net@eth1}"
NGINX_IP="${NGINX_IP:-172.30.10.100}"

kubectl delete pod "$POD_NAME" --ignore-not-found >/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
  annotations:
    k8s.v1.cni.cncf.io/networks: $NAD_NAME
spec:
  containers:
    - name: curl
      image: curlimages/curl:8.8.0
      command: ["sh", "-c", "sleep 3600"]
  restartPolicy: Never
EOF

kubectl wait --for=condition=Ready "pod/$POD_NAME" --timeout=180s
kubectl exec "$POD_NAME" -- sh -c "ip -o -4 addr show"
kubectl exec "$POD_NAME" -- curl -sS -o /dev/null -w '%{http_code}\n' "http://$NGINX_IP"

