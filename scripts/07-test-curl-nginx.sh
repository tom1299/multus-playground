#!/usr/bin/env bash
set -euo pipefail

NAD_NAME="${NAD_NAME:-secondary-net@eth1}"
NGINX_IP="${NGINX_IP:-172.30.10.100}"

test_pods=(multus-curl-w1 multus-curl-w2)

for pod in "${test_pods[@]}"; do

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $pod
  annotations:
    k8s.v1.cni.cncf.io/networks: $NAD_NAME
  labels:
    app: test-pod
spec:
  containers:
    - name: curl
      image: curlimages/curl:8.8.0
      command: ["sh", "-c", "sleep 3600"]
  restartPolicy: Never
  # Schedule pods on different nodes to test secondary IP assignment by whereabouts
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - test-pod
          topologyKey: "kubernetes.io/hostname"
EOF

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
