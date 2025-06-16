#!/bin/bash

echo "🚀 Setting up High Availability Ingress with Clean URLs"
echo "======================================================"

# Node information
MASTER_IP="161.97.182.228"
WORKER1_IP="161.97.182.224"  
WORKER2_IP="161.97.182.220"

echo "📋 Node Configuration:"
echo "   Master:  $MASTER_IP"
echo "   Worker1: $WORKER1_IP"
echo "   Worker2: $WORKER2_IP"
echo

# Ensure Traefik is running with proper replicas
echo "🔧 Ensuring Traefik deployment..."
kubectl apply -f /home/ali/Training/micro-services/kubernetes/traefik.yaml
kubectl scale deployment traefik-deployment --replicas=3

echo "⏳ Waiting for Traefik pods to start..."
sleep 15

# Check the deployment
echo "📊 Checking Traefik deployment:"
kubectl get deployment traefik-deployment
echo
kubectl get pods -l app=traefik -o wide

echo
echo "📋 Current access methods:"
echo "   🔧 With NodePort: http://$MASTER_IP:30080/analytics"
echo "   🎛️  Dashboard: http://$MASTER_IP:30800/dashboard/"
echo

echo "🔧 To enable clean URLs (http://IP/analytics), you need to:"
echo "   1. Run ./port-forward-master.sh on the master node ($MASTER_IP)"
echo "   2. Run ./port-forward-worker1.sh on worker1 node ($WORKER1_IP)"  
echo "   3. Run ./port-forward-worker2.sh on worker2 node ($WORKER2_IP)"
echo

echo "📁 Port forwarding scripts created:"
echo "   - port-forward-master.sh (for $MASTER_IP)"
echo "   - port-forward-worker1.sh (for $WORKER1_IP)"
echo "   - port-forward-worker2.sh (for $WORKER2_IP)"
echo

echo "🧪 Testing NodePort access..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://$MASTER_IP:30080/analytics)
if [ "$RESPONSE" = "302" ] || [ "$RESPONSE" = "200" ]; then
    echo "✅ Traefik ingress working (Status: $RESPONSE)"
    echo "✅ Ready for port forwarding setup!"
else
    echo "❌ Traefik ingress not responding (Status: $RESPONSE)"
fi

echo
echo "🎯 After running port forwarding scripts, you'll have:"
echo "   📊 Analytics: http://$MASTER_IP/analytics"
echo "   📊 Analytics: http://$WORKER1_IP/analytics"  
echo "   📊 Analytics: http://$WORKER2_IP/analytics"
echo "   🔧 API: http://ANY-IP/api"
echo "   🎛️  Dashboard: http://ANY-IP:8080/dashboard/"