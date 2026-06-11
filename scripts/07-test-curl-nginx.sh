#!/usr/bin/env bash
set -euo pipefail

NAD_NAME="${NAD_NAME:-secondary-net@eth1}"
NGINX_IP="${NGINX_IP:-172.30.10.100}"

pods_ok=(multus-curl-w1 multus-curl-w2)

workers=($(kubectl get nodes -o name | sed 's#node/##' | grep -v 'control-plane'))

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: multus-curl-w1
  annotations:
    k8s.v1.cni.cncf.io/networks: $NAD_NAME
spec:
  nodeName: ${workers[0]}
  containers:
    - name: curl
      image: curlimages/curl:8.8.0
      command: ["sh", "-c", "sleep 3600"]
  restartPolicy: Never
---
apiVersion: v1
kind: Pod
metadata:
  name: multus-curl-w2
  annotations:
    k8s.v1.cni.cncf.io/networks: $NAD_NAME
spec:
  nodeName: ${workers[1]}
  containers:
    - name: curl
      image: curlimages/curl:8.8.0
      command: ["sh", "-c", "sleep 3600"]
  restartPolicy: Never
EOF

for pod in "${pods_ok[@]}"; do
  kubectl wait --for=condition=Ready "pod/$pod" --timeout=180s
  ip=$(kubectl exec "$pod" -- sh -c "ip -o -4 addr show dev eth1 | awk '{print \$4}' | cut -d/ -f1")
  if [ -z "$ip" ]; then
    echo "secondary IP assignment check failed"
    exit 1
  fi
  echo "$ip"
  kubectl exec "$pod" -- curl -sS -o /dev/null -w '%{http_code}\n' "http://$NGINX_IP"
done

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: multus-curl-w3
  annotations:
    k8s.v1.cni.cncf.io/networks: $NAD_NAME
spec:
  nodeName: ${workers[0]}
  containers:
    - name: curl
      image: curlimages/curl:8.8.0
      command: ["sh", "-c", "sleep 3600"]
  restartPolicy: Never
EOF

if kubectl wait --for=condition=Ready pod/multus-curl-w3 --timeout=45s >/dev/null 2>&1; then
  echo "third pod unexpectedly became Ready"
  exit 1
fi

status=$(kubectl get pod multus-curl-w3 -o jsonpath='{.status.phase}')
if [ "$status" = "Running" ] || [ "$status" = "Succeeded" ]; then
  echo "third pod unexpectedly got running state"
  exit 1
fi

echo "$status"
