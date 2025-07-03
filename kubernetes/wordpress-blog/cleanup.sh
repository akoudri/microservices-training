#!/bin/bash

# WordPress Blog Kubernetes Cleanup Script

echo "🧹 Cleaning up WordPress Blog from Kubernetes..."

# Delete all resources
echo "🗑️ Deleting all resources..."
kubectl delete -f 07-phpmyadmin.yaml
kubectl delete -f 06-wordpress.yaml
kubectl delete -f 05-mariadb.yaml
kubectl delete -f 04-storage.yaml
kubectl delete -f 03-configmap.yaml
kubectl delete -f 02-secrets.yaml
kubectl delete -f 01-namespace.yaml

echo "⏳ Waiting for cleanup to complete..."
sleep 10

echo "✅ Cleanup complete!"
echo ""
echo "📊 Verify cleanup:"
echo "   kubectl get pods -n wordpress-blog"
echo "   kubectl get pvc -n wordpress-blog"