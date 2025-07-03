#!/bin/bash

# Script to compare different kustomize configurations
# This helps understand what each component adds

echo "=== Kustomize Components Comparison ==="
echo ""

# Function to count and show resources
show_resources() {
    local config_name=$1
    local config_path=$2
    
    echo "=== $config_name ==="
    
    if [ -d "$config_path" ]; then
        echo "Resources:"
        # Note: This would work with kustomize installed
        # kustomize build "$config_path" | grep "^kind:" | sort | uniq -c
        
        # Show the kustomization file instead
        if [ -f "$config_path/kustomization.yaml" ]; then
            echo "Configuration:"
            cat "$config_path/kustomization.yaml"
        fi
    else
        echo "Directory not found: $config_path"
    fi
    echo ""
}

# Show base configuration
show_resources "Base Configuration" "base"

# Show component configurations
echo "=== COMPONENTS ==="
show_resources "Redis Component" "components/redis"
show_resources "Logging Component" "components/logging"

echo "=== OVERLAYS ==="
# Show overlay configurations
show_resources "Development (Basic)" "overlays/development"
show_resources "Development with Cache" "overlays/development-with-cache"
show_resources "Staging with Logging" "overlays/staging-with-logging"
show_resources "Production Full Stack" "overlays/production-full-stack"

echo "=== COMPONENT USAGE MATRIX ==="
echo ""
echo "Configuration                | Redis | Logging | Description"
echo "----------------------------|-------|---------|------------------"
echo "Base                        |   -   |    -    | Basic webapp only"
echo "Development                 |   -   |    -    | Basic dev environment"
echo "Development with Cache      |   ✓   |    -    | Dev + Redis caching"
echo "Staging with Logging        |   -   |    ✓    | Staging + Log collection"
echo "Production Full Stack       |   ✓   |    ✓    | Production + All features"
echo ""

echo "=== WHAT EACH COMPONENT ADDS ==="
echo ""
echo "Redis Component:"
echo "  - Redis deployment and service"
echo "  - Environment variables: REDIS_HOST, REDIS_PORT, CACHE_ENABLED"
echo "  - Labels: cache=redis, component=redis"
echo ""
echo "Logging Component:"
echo "  - Fluentd DaemonSet for log collection"
echo "  - Fluentd configuration"
echo "  - Environment variables: ENABLE_LOGGING, LOG_LEVEL, LOG_FORMAT"
echo "  - Labels: logging=enabled, component=logging"
echo ""

echo "=== COMMANDS TO BUILD EACH CONFIGURATION ==="
echo ""
echo "# Base application"
echo "kustomize build base/"
echo ""
echo "# Development environments"
echo "kustomize build overlays/development/"
echo "kustomize build overlays/development-with-cache/"
echo ""
echo "# Staging and production"
echo "kustomize build overlays/staging-with-logging/"
echo "kustomize build overlays/production-full-stack/"
echo ""

echo "=== DIRECTORY STRUCTURE ==="
tree . -I '__pycache__|*.pyc|.git' 2>/dev/null || find . -type f -name "*.yaml" | sort