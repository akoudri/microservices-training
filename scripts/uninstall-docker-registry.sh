#!/bin/bash

# Docker Registry Uninstall Script
# This script removes the Docker Registry and related components

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGISTRY_NAMESPACE="registry"

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

# Function to ask for confirmation
confirm() {
    read -p "Are you sure you want to $1? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Operation cancelled"
        exit 0
    fi
}

main() {
    print_header "Docker Registry Uninstall Script"
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it first."
        exit 1
    fi
    
    # Check if connected to cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "kubectl is not connected to a cluster. Please configure kubectl first."
        exit 1
    fi
    
    # Confirm uninstall
    confirm "uninstall Docker Registry and all related components"
    
    print_header "Step 1: Removing Docker Registry"
    
    # Uninstall Docker Registry
    print_status "Uninstalling Docker Registry..."
    if helm list -n "$REGISTRY_NAMESPACE" | grep -q "docker-registry"; then
        helm uninstall docker-registry -n "$REGISTRY_NAMESPACE"
        print_success "Docker Registry uninstalled"
    else
        print_warning "Docker Registry not found, skipping..."
    fi
    
    print_header "Step 2: Cleaning up Storage"
    
    # Delete PVCs (this will also delete PVs due to Retain policy)
    print_status "Deleting PVCs..."
    if kubectl get pvc -n "$REGISTRY_NAMESPACE" &> /dev/null; then
        kubectl delete pvc --all -n "$REGISTRY_NAMESPACE"
        print_success "PVCs deleted"
    else
        print_warning "No PVCs found, skipping..."
    fi
    
    # Delete secrets
    print_status "Deleting SMB secret from kube-system..."
    if kubectl get secret hetzner-smb-secret -n kube-system &> /dev/null; then
        kubectl delete secret hetzner-smb-secret -n kube-system
        print_success "SMB secret deleted from kube-system"
    else
        print_warning "SMB secret not found in kube-system, skipping..."
    fi
    
    print_header "Step 3: Removing Namespace"
    
    # Delete namespace
    print_status "Deleting namespace..."
    if kubectl get namespace "$REGISTRY_NAMESPACE" &> /dev/null; then
        kubectl delete namespace "$REGISTRY_NAMESPACE"
        print_success "Namespace deleted"
    else
        print_warning "Namespace not found, skipping..."
    fi
    
    print_header "Step 4: Optional Cleanup"
    
    # Ask about storage class
    read -p "Do you want to remove the SMB storage class? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing SMB storage class..."
        if kubectl get storageclass hetzner-smb-storage &> /dev/null; then
            kubectl delete storageclass hetzner-smb-storage
            print_success "SMB storage class deleted"
        else
            print_warning "SMB storage class not found, skipping..."
        fi
    fi
    
    # Ask about SMB CSI driver
    read -p "Do you want to remove the SMB CSI driver? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing SMB CSI driver..."
        if helm list -n kube-system | grep -q "csi-driver-smb"; then
            helm uninstall csi-driver-smb -n kube-system
            print_success "SMB CSI driver removed"
        else
            print_warning "SMB CSI driver not found, skipping..."
        fi
    fi
    
    print_header "Cleanup Complete!"
    
    echo -e "${GREEN}🎉 Docker Registry has been successfully uninstalled!${NC}\n"
    
    echo -e "${BLUE}📋 What was removed:${NC}"
    echo -e "  • Docker Registry application"
    echo -e "  • Registry namespace and resources"
    echo -e "  • SMB secrets and PVCs"
    
    echo -e "\n${BLUE}ℹ️  Note:${NC}"
    echo -e "  • Data on Hetzner Storage Box is preserved"
    echo -e "  • SMB CSI driver may still be running (if you chose to keep it)"
    echo -e "  • StorageClass may still exist (if you chose to keep it)"
    
    print_success "Uninstall completed successfully!"
}

# Handle script interruption
trap 'print_error "Uninstall interrupted"; exit 1' INT TERM

# Run main function
main "$@"