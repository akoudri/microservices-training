#!/bin/bash

# Read a specific key from the etcd cluster (JSON output)
# To be executed on a node with access to the control plane
#
# Usage: ./req-key-etcd.sh <key>
#
# Examples:
#   ./req-key-etcd.sh /registry/namespaces/default
#   ./req-key-etcd.sh /registry/pods/default/my-pod

if [ $# -ne 1 ]; then
  echo "Usage: $0 <key>"
  exit 1
fi

ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$ETCD_POD" ]; then
  echo "Error: no etcd pod found in kube-system namespace"
  echo ""
  echo "Note: on managed clusters (GKE, EKS, AKS), etcd is not accessible."
  echo "This script requires a self-managed cluster (e.g. kubeadm)."
  exit 1
fi

echo "Using etcd pod: $ETCD_POD"
echo "Reading key: $1"
echo "---"

kubectl exec -n kube-system "$ETCD_POD" -- \
  etcdctl --write-out=json \
    --cacert /etc/kubernetes/pki/etcd/ca.crt \
    --cert /etc/kubernetes/pki/etcd/server.crt \
    --key /etc/kubernetes/pki/etcd/server.key \
    get "$1"
