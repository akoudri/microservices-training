#!/bin/bash

echo "=== Testing Kubernetes Services ==="
echo

# Get node IPs
echo "🔍 Available Node IPs:"
kubectl get nodes -o wide | grep -E "NAME|vmi|worker"
echo

# Test Traefik Dashboard
echo "🎛️  Testing Traefik Dashboard..."
TRAEFIK_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://161.97.182.228:30800/dashboard/)
if [ "$TRAEFIK_RESPONSE" = "200" ]; then
    echo "✅ Traefik Dashboard: http://161.97.182.228:30800/dashboard/ (Status: $TRAEFIK_RESPONSE)"
else
    echo "❌ Traefik Dashboard: Failed (Status: $TRAEFIK_RESPONSE)"
fi
echo

# Test Analytics (Kibana) Direct Access
echo "📊 Testing Analytics Service..."
ANALYTICS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://161.97.182.228:30601/analytics)
if [ "$ANALYTICS_RESPONSE" = "302" ] || [ "$ANALYTICS_RESPONSE" = "200" ]; then
    echo "✅ Analytics (Kibana): http://161.97.182.228:30601/analytics (Status: $ANALYTICS_RESPONSE)"
else
    echo "❌ Analytics (Kibana): Failed (Status: $ANALYTICS_RESPONSE)"
fi
echo

# Test Elasticsearch
echo "🔍 Testing Elasticsearch..."
ELASTIC_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://161.97.182.228:30200/)
if [ "$ELASTIC_RESPONSE" = "200" ]; then
    echo "✅ Elasticsearch: http://161.97.182.228:30200/ (Status: $ELASTIC_RESPONSE)"
else
    echo "❌ Elasticsearch: Failed (Status: $ELASTIC_RESPONSE)"
fi
echo

# Show services status
echo "📋 Services Status:"
kubectl get services -o wide
echo

# Show pods status
echo "🐳 Pods Status:"
kubectl get pods -o wide
echo

echo "=== Test Complete ==="
echo "🌐 Access your services in browser:"
echo "   📊 Analytics (Kibana): http://161.97.182.228:30601/analytics"
echo "   🎛️  Traefik Dashboard: http://161.97.182.228:30800/dashboard/"
echo "   🔍 Elasticsearch: http://161.97.182.228:30200/"