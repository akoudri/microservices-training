#!/bin/bash

echo "Testing Docker Registry at registry.upskillforge.com"
echo "=================================================="

# Test 1: Check if registry is accessible
echo "1. Testing registry connectivity..."
curl -s -o /dev/null -w "%{http_code}" http://registry.upskillforge.com/v2/

if [ $? -eq 0 ]; then
    echo " ✅ Registry is accessible"
else
    echo " ❌ Registry is not accessible"
fi

# Test 2: List repositories (should be empty initially)
echo "2. Listing repositories..."
curl -s http://registry.upskillforge.com/v2/_catalog

echo ""
echo "=================================================="
echo "Registry Setup Complete!"
echo ""
echo "📍 Registry URL: http://registry.upskillforge.com"
echo "📍 To push images:"
echo "   docker tag myimage:latest registry.upskillforge.com/myimage:latest"
echo "   docker push registry.upskillforge.com/myimage:latest"
echo ""
echo "📍 To pull images:"
echo "   docker pull registry.upskillforge.com/myimage:latest"
echo "=================================================="