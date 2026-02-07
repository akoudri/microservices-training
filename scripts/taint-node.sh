#!/bin/bash

# Taint a Kubernetes node
# Usage:
#   ./taint-node.sh <node-name> [key] [value] [effect]
#
# Arguments:
#   node-name  : Name of the node to taint (required)
#   key        : Taint key (default: dedicated)
#   value      : Taint value (default: special)
#   effect     : NoSchedule | PreferNoSchedule | NoExecute (default: NoSchedule)
#
# Examples:
#   ./taint-node.sh worker-1
#   ./taint-node.sh worker-1 env production NoSchedule
#   ./taint-node.sh worker-1 gpu true NoExecute
#
# To remove the taint afterwards:
#   kubectl taint nodes <node-name> <key>-

NODE_NAME="${1:?Usage: $0 <node-name> [key] [value] [effect]}"
TAINT_KEY="${2:-dedicated}"
TAINT_VALUE="${3:-special}"
TAINT_EFFECT="${4:-NoSchedule}"

# Validate effect
case "$TAINT_EFFECT" in
  NoSchedule|PreferNoSchedule|NoExecute) ;;
  *)
    echo "Error: effect must be NoSchedule, PreferNoSchedule or NoExecute"
    exit 1
    ;;
esac

echo "Tainting node '$NODE_NAME' with ${TAINT_KEY}=${TAINT_VALUE}:${TAINT_EFFECT} ..."
kubectl taint nodes "$NODE_NAME" "${TAINT_KEY}=${TAINT_VALUE}:${TAINT_EFFECT}"

echo ""
echo "Current taints on $NODE_NAME:"
kubectl describe node "$NODE_NAME" | grep -A5 "^Taints:"
