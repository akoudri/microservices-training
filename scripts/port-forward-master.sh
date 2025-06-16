#!/bin/bash
# Port forwarding script for Master node (161.97.182.228)

echo "🔧 Setting up port forwarding on Master node (161.97.182.228)..."

# Check if already configured
if iptables -t nat -L PREROUTING | grep -q "dpt:80"; then
    echo "⚠️  Port forwarding rules already exist. Clearing old rules..."
    sudo iptables -t nat -F PREROUTING
fi

# Forward port 80 to Traefik NodePort 30080
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 30080

# Forward port 443 to Traefik NodePort 30443 (for future HTTPS)
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 30443

echo "✅ Port forwarding configured on Master:"
echo "   Port 80 → 30080 (HTTP)"  
echo "   Port 443 → 30443 (HTTPS)"

# Test the setup
echo "🧪 Testing local access..."
sleep 2
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://localhost/analytics)
if [ "$RESPONSE" = "302" ] || [ "$RESPONSE" = "200" ]; then
    echo "✅ Master node: Working (Status: $RESPONSE)"
    echo "🌐 Access: http://161.97.182.228/analytics"
else
    echo "⚠️  Test failed (Status: $RESPONSE) - May work from external browser"
fi

echo "📋 To make persistent, save iptables rules:"
echo "   sudo iptables-save > /etc/iptables/rules.v4"