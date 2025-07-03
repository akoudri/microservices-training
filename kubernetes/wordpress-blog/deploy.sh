#!/bin/bash

# WordPress Blog Kubernetes Deployment Script

echo "🚀 Deploying WordPress Blog to Kubernetes..."

# Apply all manifests in order
echo "📦 Creating namespace..."
kubectl apply -f 01-namespace.yaml

echo "🔐 Creating secrets..."
kubectl apply -f 02-secrets.yaml

echo "⚙️ Creating configmap..."
kubectl apply -f 03-configmap.yaml

echo "💾 Creating storage..."
kubectl apply -f 04-storage.yaml

echo "🗄️ Deploying MariaDB..."
kubectl apply -f 05-mariadb.yaml

echo "⏳ Waiting for MariaDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mariadb -n wordpress-blog --timeout=300s

echo "🌐 Deploying WordPress..."
kubectl apply -f 06-wordpress.yaml

echo "🔧 Deploying phpMyAdmin..."
kubectl apply -f 07-phpmyadmin.yaml

echo "⏳ Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app=wordpress -n wordpress-blog --timeout=300s
kubectl wait --for=condition=ready pod -l app=phpmyadmin -n wordpress-blog --timeout=300s

echo "✅ Deployment complete!"
echo ""
echo "🔗 Access URLs:"
echo "   WordPress: http://localhost:30080"
echo "   phpMyAdmin: http://localhost:30081"
echo ""
echo "📊 Check deployment status:"
echo "   kubectl get pods -n wordpress-blog"
echo "   kubectl get services -n wordpress-blog"
echo ""
echo "🔍 View logs:"
echo "   kubectl logs -f deployment/wordpress -n wordpress-blog"
echo "   kubectl logs -f deployment/mariadb -n wordpress-blog"