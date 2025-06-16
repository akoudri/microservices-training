#!/bin/bash

echo "🔧 Setting up port forwarding for clean URLs..."

# Forward port 80 to Traefik NodePort 30080
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 30080

# Forward port 443 to Traefik NodePort 30443 (for future HTTPS)
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 30443

# Save the rules (Ubuntu/Debian)
sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo "✅ Port forwarding configured:"
echo "   Port 80 → 30080 (HTTP)"  
echo "   Port 443 → 30443 (HTTPS)"
echo ""
echo "🌐 You can now access your services at:"
echo "   📊 Analytics: http://161.97.182.228/analytics"
echo "   🔧 API: http://161.97.182.228/api"
echo "   🎛️  Dashboard: http://161.97.182.228/dashboard"
echo ""
echo "🔍 Testing the setup..."

# Test the forwarding
sleep 2
curl -I http://localhost/analytics 2>/dev/null | head -1 || echo "⚠️  Testing from localhost - try from external browser"