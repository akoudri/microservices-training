#!/bin/bash

# Docker Registry Installation Script
# This script automates the installation of Docker Registry with Hetzner SMB storage

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
STORAGE_SIZE="100Gi"
HETZNER_USERNAME="u474420"
HETZNER_PASSWORD="Yyx7cXB)czSm\$rT"
HETZNER_SERVER="u474420.your-storagebox.de"

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

# Function to check if kubectl is connected
check_kubectl() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "kubectl is not connected to a cluster. Please configure kubectl first."
        exit 1
    fi
}

# Function to wait for pod to be ready
wait_for_pod() {
    local namespace=$1
    local selector=$2
    local timeout=${3:-300}
    
    print_status "Waiting for pod with selector '$selector' in namespace '$namespace' to be ready..."
    
    if kubectl wait --for=condition=Ready pod -l "$selector" -n "$namespace" --timeout="${timeout}s"; then
        print_success "Pod is ready!"
        return 0
    else
        print_error "Pod did not become ready within $timeout seconds"
        return 1
    fi
}

# Main installation function
main() {
    print_header "Docker Registry Installation Script"
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_command "kubectl"
    check_command "helm"
    check_kubectl
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    print_header "Step 1: Installing SMB CSI Driver"
    
    # Add SMB CSI driver repository
    print_status "Adding SMB CSI driver repository..."
    helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
    helm repo update
    
    # Install SMB CSI driver
    print_status "Installing SMB CSI driver..."
    if helm list -n kube-system | grep -q "csi-driver-smb"; then
        print_warning "SMB CSI driver already installed, skipping..."
    else
        helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system --version v1.16.0
        print_success "SMB CSI driver installed successfully"
    fi
    
    # Wait for CSI driver to be ready
    wait_for_pod "kube-system" "app=csi-smb-controller" 180
    
    print_header "Step 2: Creating SMB Storage Class"
    
    # Create Hetzner SMB secret in kube-system (namespace-independent)
    print_status "Creating Hetzner SMB secret in kube-system..."
    
    # Create or update secret in kube-system
    if kubectl get secret hetzner-smb-secret -n kube-system &> /dev/null; then
        print_warning "Secret already exists, deleting and recreating..."
        kubectl delete secret hetzner-smb-secret -n kube-system
    fi
    
    kubectl create secret generic hetzner-smb-secret \
        --from-literal=username="$HETZNER_USERNAME" \
        --from-literal=password="$HETZNER_PASSWORD" \
        -n kube-system
    
    print_success "SMB secret created successfully in kube-system"
    
    # Create storage class configuration
    print_status "Creating SMB storage class..."
    cat > "$SCRIPT_DIR/hetzner-smb-storage.yaml" << EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hetzner-smb-storage
provisioner: smb.csi.k8s.io
parameters:
  source: "//$HETZNER_SERVER/backup"
  csi.storage.k8s.io/provisioner-secret-name: "hetzner-smb-secret"
  csi.storage.k8s.io/provisioner-secret-namespace: "kube-system"
  csi.storage.k8s.io/node-stage-secret-name: "hetzner-smb-secret"
  csi.storage.k8s.io/node-stage-secret-namespace: "kube-system"
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - vers=2.1
  - uid=999
  - gid=999
  - sec=ntlmssp
  - file_mode=0600
  - dir_mode=0700
  - noperm
EOF
    
    # Apply storage class (check if it exists first)
    if kubectl get storageclass hetzner-smb-storage &> /dev/null; then
        print_warning "SMB storage class already exists, skipping..."
    else
        kubectl apply -f "$SCRIPT_DIR/hetzner-smb-storage.yaml"
        print_success "SMB storage class created successfully"
    fi
    
    print_header "Step 3: Installing Docker Registry"
    
    # Add Docker registry repository
    print_status "Adding Docker registry repository..."
    helm repo add twuni https://helm.twun.io
    helm repo update
    
    # Create Docker registry values
    print_status "Creating Docker registry configuration..."
    cat > "$SCRIPT_DIR/docker-registry-values.yaml" << EOF
replicaCount: 1

image:
  repository: registry
  tag: "2.8.3"
  pullPolicy: IfNotPresent

service:
  name: registry
  type: ClusterIP
  port: 5000
  targetPort: 5000

ingress:
  enabled: true
  className: "traefik"
  annotations: {}
  hosts:
    - $REGISTRY_DOMAIN
  paths:
    - /
  tls: []

persistence:
  enabled: true
  size: $STORAGE_SIZE
  storageClass: "hetzner-smb-storage"
  accessMode: ReadWriteOnce

configData:
  version: 0.1
  log:
    fields:
      service: registry
  storage:
    filesystem:
      rootdirectory: /var/lib/registry
    delete:
      enabled: true
  http:
    addr: :5000
    headers:
      X-Content-Type-Options: [nosniff]
    debug:
      addr: :5001
      prometheus:
        enabled: true
        path: /metrics

resources:
  limits:
    cpu: 200m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi

nodeSelector: {}
tolerations: []
affinity: {}
EOF
    
    # Install Docker registry
    print_status "Installing Docker registry..."
    if helm list -n "$REGISTRY_NAMESPACE" | grep -q "docker-registry"; then
        print_warning "Docker registry already installed, upgrading..."
        helm upgrade docker-registry twuni/docker-registry \
            --namespace "$REGISTRY_NAMESPACE" \
            -f "$SCRIPT_DIR/docker-registry-values.yaml"
    else
        helm install docker-registry twuni/docker-registry \
            --namespace "$REGISTRY_NAMESPACE" \
            --create-namespace \
            -f "$SCRIPT_DIR/docker-registry-values.yaml"
    fi
    
    print_success "Docker registry installed successfully"
    
    print_header "Step 4: Waiting for Registry to be Ready"
    
    # Wait for registry to be ready
    wait_for_pod "$REGISTRY_NAMESPACE" "app=docker-registry" 300
    
    # Wait for PVC to be bound
    print_status "Waiting for PVC to be bound..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if kubectl get pvc docker-registry -n "$REGISTRY_NAMESPACE" -o jsonpath='{.status.phase}' | grep -q "Bound"; then
            print_success "PVC is bound!"
            break
        fi
        sleep 5
        timeout=$((timeout - 5))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "PVC did not bind within timeout"
        exit 1
    fi
    
    print_header "Step 5: Testing Registry Installation"
    
    # Test registry connectivity
    print_status "Testing registry connectivity..."
    sleep 10  # Give ingress time to propagate
    
    # Test HTTP endpoint
    if curl -s -o /dev/null -w "%{http_code}" "http://$REGISTRY_DOMAIN/v2/" | grep -q "200"; then
        print_success "Registry is accessible at http://$REGISTRY_DOMAIN"
    else
        print_warning "Registry might not be accessible yet via ingress, checking service..."
        if kubectl port-forward -n "$REGISTRY_NAMESPACE" service/docker-registry 5000:5000 &
        then
            PF_PID=$!
            sleep 5
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:5000/v2/" | grep -q "200"; then
                print_success "Registry is working via port-forward"
            else
                print_error "Registry is not responding"
            fi
            kill $PF_PID 2>/dev/null || true
        fi
    fi
    
    # Test catalog endpoint
    print_status "Testing registry catalog..."
    if curl -s "http://$REGISTRY_DOMAIN/v2/_catalog" | grep -q "repositories"; then
        print_success "Registry catalog is accessible"
    fi
    
    print_header "Installation Complete!"
    
    echo -e "${GREEN}🎉 Docker Registry has been successfully installed!${NC}\n"
    
    echo -e "${BLUE}📋 Installation Summary:${NC}"
    echo -e "  • Registry URL: http://$REGISTRY_DOMAIN"
    echo -e "  • Namespace: $REGISTRY_NAMESPACE"
    echo -e "  • Storage: $STORAGE_SIZE (Hetzner SMB)"
    echo -e "  • Storage Class: hetzner-smb-storage"
    
    echo -e "\n${BLUE}🚀 Usage Instructions:${NC}"
    echo -e "  • Tag image:  docker tag myimage:latest $REGISTRY_DOMAIN/myimage:latest"
    echo -e "  • Push image: docker push $REGISTRY_DOMAIN/myimage:latest"
    echo -e "  • Pull image: docker pull $REGISTRY_DOMAIN/myimage:latest"
    
    echo -e "\n${BLUE}🔧 Management Commands:${NC}"
    echo -e "  • View pods:  kubectl get pods -n $REGISTRY_NAMESPACE"
    echo -e "  • View logs:  kubectl logs -n $REGISTRY_NAMESPACE -l app=docker-registry"
    echo -e "  • View PVC:   kubectl get pvc -n $REGISTRY_NAMESPACE"
    
    echo -e "\n${BLUE}🧪 Test Script:${NC}"
    echo -e "  • Run: $SCRIPT_DIR/test-registry.sh"
    
    print_success "Installation completed successfully!"
}

# Handle script interruption
trap 'print_error "Installation interrupted"; exit 1' INT TERM

# Run main function
main "$@"