#!/bin/bash

# List all keys stored in the etcd cluster
# To be executed on a node with access to the control plane
#
# Usage: ./req-etcd.sh [prefix]
#   prefix : Key prefix to filter (default: /)
#
# Examples:
#   ./req-etcd.sh
#   ./req-etcd.sh /registry/pods
#   ./req-etcd.sh /registry/deployments

ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$ETCD_POD" ]; then
  echo "Error: no etcd pod found in kube-system namespace"
  echo ""
  echo "Note: on managed clusters (GKE, EKS, AKS), etcd is not accessible."
  echo "This script requires a self-managed cluster (e.g. kubeadm)."
  exit 1
fi

PREFIX="${1:-/}"

echo "Using etcd pod: $ETCD_POD"
echo "Listing keys with prefix: $PREFIX"
echo "---"

kubectl exec -n kube-system "$ETCD_POD" -- \
  etcdctl \
    --cacert /etc/kubernetes/pki/etcd/ca.crt \
    --cert /etc/kubernetes/pki/etcd/server.crt \
    --key /etc/kubernetes/pki/etcd/server.key \
    get "$PREFIX" --prefix --keys-only
