#!/bin/bash

# Create a local Kubernetes cluster with kind (1 control-plane + 2 workers)
# Useful for testing features not available on managed clusters (e.g. etcd access)
#
# Usage: ./kind-create-cluster.sh [cluster-name]
#   cluster-name : Name of the cluster (default: training)
#
# Prerequisites: Docker must be installed and running
#
# Delete the cluster afterwards:
#   kind delete cluster --name training

set -e

CLUSTER_NAME="${1:-training}"

# --- Check Docker ---
if ! command -v docker &>/dev/null; then
  echo "Error: Docker is not installed."
  echo "Install it from https://docs.docker.com/engine/install/"
  exit 1
fi

if ! docker info &>/dev/null; then
  echo "Error: Docker daemon is not running."
  exit 1
fi

# --- Check / Install kind ---
if ! command -v kind &>/dev/null; then
  echo "kind not found, installing..."

  KIND_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    *)
      echo "Error: unsupported architecture $ARCH"
      exit 1
      ;;
  esac

  echo "Downloading kind $KIND_VERSION (linux/$ARCH)..."
  curl -Lo /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
  chmod +x /tmp/kind
  sudo mv /tmp/kind /usr/local/bin/kind

  echo "kind installed: $(kind version)"
fi

# --- Check kubectl ---
if ! command -v kubectl &>/dev/null; then
  echo "Warning: kubectl is not installed. You will need it to interact with the cluster."
  echo "Install it from https://kubernetes.io/docs/tasks/tools/"
fi

# --- Create cluster ---
echo "Creating kind cluster '$CLUSTER_NAME' (1 control-plane + 2 workers)..."

kind create cluster --name "$CLUSTER_NAME" --config - <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

echo ""
echo "Cluster '$CLUSTER_NAME' is ready."
echo ""
echo "Useful commands:"
echo "  kubectl get nodes"
echo "  kubectl get pods -n kube-system"
echo "  ./scripts/req-etcd.sh"
echo "  kind delete cluster --name $CLUSTER_NAME"
