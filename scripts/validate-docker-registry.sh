#!/bin/bash

# Docker Registry Validation Script
# This script validates that the Docker Registry installation is working correctly

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGISTRY_NAMESPACE="registry"
REGISTRY_DOMAIN="registry.upskillforge.com"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# Function to validate component
validate_component() {
    local component=$1
    local namespace=$2
    local selector=$3
    
    print_status "Validating $component..."
    
    if kubectl get pods -n "$namespace" -l "$selector" --no-headers 2>/dev/null | grep -q "Running"; then
        print_success "$component is running"
        return 0
    else
        print_error "$component is not running"
        return 1
    fi
}

# Function to validate PVC
validate_pvc() {
    local pvc_name=$1
    local namespace=$2
    
    print_status "Validating PVC: $pvc_name..."
    
    if kubectl get pvc "$pvc_name" -n "$namespace" -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Bound"; then
        print_success "PVC $pvc_name is bound"
        return 0
    else
        print_error "PVC $pvc_name is not bound"
        return 1
    fi
}

# Main validation function
main() {
    print_header "Docker Registry Validation Script"
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_command "kubectl"
    check_command "curl"
    
    # Check if kubectl is connected
    if ! kubectl cluster-info &> /dev/null; then
        print_error "kubectl is not connected to a cluster. Please configure kubectl first."
        exit 1
    fi
    
    local errors=0
    
    print_header "Step 1: Validating Kubernetes Components"
    
    # Check if namespace exists
    if kubectl get namespace "$REGISTRY_NAMESPACE" &> /dev/null; then
        print_success "Namespace $REGISTRY_NAMESPACE exists"
    else
        print_error "Namespace $REGISTRY_NAMESPACE does not exist"
        ((errors++))
    fi
    
    # Check SMB CSI driver
    if ! validate_component "SMB CSI Controller" "kube-system" "app=csi-smb-controller"; then
        ((errors++))
    fi
    
    # Check storage class
    if kubectl get storageclass hetzner-smb-storage &> /dev/null; then
        print_success "Storage class hetzner-smb-storage exists"
    else
        print_error "Storage class hetzner-smb-storage does not exist"
        ((errors++))
    fi
    
    # Check secret in kube-system
    if kubectl get secret hetzner-smb-secret -n kube-system &> /dev/null; then
        print_success "SMB secret exists in kube-system"
    else
        print_error "SMB secret does not exist in kube-system"
        ((errors++))
    fi
    
    print_header "Step 2: Validating Docker Registry"
    
    # Check registry pod
    if ! validate_component "Docker Registry" "$REGISTRY_NAMESPACE" "app=docker-registry"; then
        ((errors++))
    fi
    
    # Check PVC
    if ! validate_pvc "docker-registry" "$REGISTRY_NAMESPACE"; then
        ((errors++))
    fi
    
    # Check service
    if kubectl get service docker-registry -n "$REGISTRY_NAMESPACE" &> /dev/null; then
        print_success "Registry service exists"
    else
        print_error "Registry service does not exist"
        ((errors++))
    fi
    
    # Check ingress
    if kubectl get ingress docker-registry -n "$REGISTRY_NAMESPACE" &> /dev/null; then
        print_success "Registry ingress exists"
    else
        print_error "Registry ingress does not exist"
        ((errors++))
    fi
    
    print_header "Step 3: Testing Registry Functionality"
    
    # Test registry API via service (port-forward)
    print_status "Testing registry API via service..."
    
    # Start port-forward in background
    kubectl port-forward -n "$REGISTRY_NAMESPACE" service/docker-registry 5000:5000 &
    PF_PID=$!
    sleep 5
    
    # Test local API
    if curl -s -f "http://localhost:5000/v2/" > /dev/null; then
        print_success "Registry API responds via service"
    else
        print_error "Registry API does not respond via service"
        ((errors++))
    fi
    
    # Test catalog endpoint
    if curl -s -f "http://localhost:5000/v2/_catalog" | grep -q "repositories"; then
        print_success "Registry catalog endpoint works"
    else
        print_error "Registry catalog endpoint does not work"
        ((errors++))
    fi
    
    # Clean up port-forward
    kill $PF_PID 2>/dev/null || true
    
    # Test registry via ingress
    print_status "Testing registry via ingress..."
    sleep 2
    
    if curl -s -f "http://$REGISTRY_DOMAIN/v2/" > /dev/null; then
        print_success "Registry accessible via ingress"
    else
        print_warning "Registry not accessible via ingress (may take time to propagate)"
    fi
    
    print_header "Step 4: Resource Summary"
    
    print_status "Registry Resources:"
    echo "  Namespace: $REGISTRY_NAMESPACE"
    echo "  Pods:"
    kubectl get pods -n "$REGISTRY_NAMESPACE" --no-headers 2>/dev/null | sed 's/^/    /'
    echo "  Services:"
    kubectl get services -n "$REGISTRY_NAMESPACE" --no-headers 2>/dev/null | sed 's/^/    /'
    echo "  PVCs:"
    kubectl get pvc -n "$REGISTRY_NAMESPACE" --no-headers 2>/dev/null | sed 's/^/    /'
    echo "  Storage Classes:"
    kubectl get storageclass hetzner-smb-storage --no-headers 2>/dev/null | sed 's/^/    /'
    
    print_header "Validation Complete!"
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}🎉 All validations passed! Docker Registry is working correctly.${NC}\n"
        
        echo -e "${BLUE}🚀 Quick Test Commands:${NC}"
        echo -e "  • Test API: curl http://$REGISTRY_DOMAIN/v2/"
        echo -e "  • List repos: curl http://$REGISTRY_DOMAIN/v2/_catalog"
        echo -e "  • Port-forward: kubectl port-forward -n $REGISTRY_NAMESPACE service/docker-registry 5000:5000"
        
        echo -e "\n${BLUE}📦 Push/Pull Example:${NC}"
        echo -e "  • Tag: docker tag alpine:latest $REGISTRY_DOMAIN/alpine:latest"
        echo -e "  • Push: docker push $REGISTRY_DOMAIN/alpine:latest"
        echo -e "  • Pull: docker pull $REGISTRY_DOMAIN/alpine:latest"
        
        print_success "Registry is ready for use!"
    else
        echo -e "${RED}❌ Validation failed with $errors error(s).${NC}\n"
        
        print_error "Please check the errors above and fix them before using the registry."
        
        echo -e "\n${BLUE}🔧 Debugging Commands:${NC}"
        echo -e "  • Check pods: kubectl get pods -n $REGISTRY_NAMESPACE"
        echo -e "  • Check logs: kubectl logs -n $REGISTRY_NAMESPACE -l app=docker-registry"
        echo -e "  • Check events: kubectl get events -n $REGISTRY_NAMESPACE"
        
        exit 1
    fi
}

# Handle script interruption
trap 'kill $PF_PID 2>/dev/null || true; print_error "Validation interrupted"; exit 1' INT TERM

# Run main function
main "$@"