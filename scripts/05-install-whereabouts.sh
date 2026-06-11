#!/usr/bin/env bash
set -euo pipefail

WHEREABOUTS_IPPOOLS_CRD_URL="${WHEREABOUTS_IPPOOLS_CRD_URL:-https://raw.githubusercontent.com/k8snetworkplumbingwg/whereabouts/master/doc/crds/whereabouts.cni.cncf.io_ippools.yaml}"
WHEREABOUTS_OVERLAP_CRD_URL="${WHEREABOUTS_OVERLAP_CRD_URL:-https://raw.githubusercontent.com/k8snetworkplumbingwg/whereabouts/master/doc/crds/whereabouts.cni.cncf.io_overlappingrangeipreservations.yaml}"
WHEREABOUTS_MANIFEST_URL="${WHEREABOUTS_MANIFEST_URL:-https://raw.githubusercontent.com/k8snetworkplumbingwg/whereabouts/master/doc/crds/daemonset-install.yaml}"

kubectl apply -f "$WHEREABOUTS_IPPOOLS_CRD_URL"
kubectl apply -f "$WHEREABOUTS_OVERLAP_CRD_URL"
kubectl apply -f "$WHEREABOUTS_MANIFEST_URL"
kubectl -n kube-system rollout status daemonset/whereabouts --timeout=180s
