#!/bin/bash

##############################################################################
# Install Kubernetes Dashboard via Helm
#
# Usage: ./install-dashboard.sh
#
# What this script does:
#   1. Adds the kubernetes-dashboard Helm repo
#   2. Installs the dashboard in the kubernetes-dashboard namespace
#   3. Creates an admin ServiceAccount + ClusterRoleBinding
#   4. Generates a login token
#   5. Starts kubectl port-forward to access the dashboard
#
# Access the dashboard:
#   https://localhost:8443
#
# Generate a new token (if expired):
#   kubectl -n kubernetes-dashboard create token admin-user
#
# Uninstall:
#   helm uninstall kubernetes-dashboard -n kubernetes-dashboard
#   kubectl delete ns kubernetes-dashboard
##############################################################################

set -e

# --- Check prerequisites ---
for cmd in helm kubectl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# --- Add Helm repo ---
echo "Adding kubernetes-dashboard Helm repo..."
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# --- Install dashboard ---
echo ""
echo "Installing Kubernetes Dashboard..."
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace \
  --namespace kubernetes-dashboard

# --- Wait for pods to be ready ---
echo ""
echo "Waiting for dashboard pods to be ready..."
kubectl wait --namespace kubernetes-dashboard \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/instance=kubernetes-dashboard \
  --timeout=120s 2>/dev/null || true

# --- Create admin user ---
echo ""
echo "Creating admin-user ServiceAccount..."
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# --- Generate token ---
echo ""
echo "============================================"
echo "Login token:"
echo "============================================"
kubectl -n kubernetes-dashboard create token admin-user
echo ""
echo "============================================"

# --- Port-forward ---
echo ""
echo "Starting port-forward on https://localhost:8443 ..."
echo "Use the token above to log in."
echo "Press Ctrl+C to stop."
echo ""
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
