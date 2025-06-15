# Kustomize Example

This directory contains a complete example of using Kustomize to manage Kubernetes configurations across different environments.

## Structure

```
kustomize/
├── base/                           # Base configuration
│   ├── kustomization.yaml         # Base kustomization file
│   ├── deployment.yaml            # Base deployment
│   ├── service.yaml               # Base service
│   └── configmap.yaml             # Base configmap
├── overlays/
│   ├── development/               # Development environment
│   │   ├── kustomization.yaml
│   │   ├── deployment-patch.yaml
│   │   └── service-patch.yaml
│   ├── production/                # Production environment
│   │   ├── kustomization.yaml
│   │   ├── deployment-patch.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   └── app.properties
│   └── staging/                   # Staging environment
│       ├── kustomization.yaml
│       └── deployment-json-patch.yaml
└── README.md
```

## Features Demonstrated

### Base Configuration
- Basic deployment with nginx
- Service definition
- ConfigMap for application configuration
- Common labels and annotations

### Development Overlay
- Reduced resource requirements
- NodePort service for local access
- Debug mode enabled
- Single replica
- Name prefix: `dev-`

### Production Overlay
- Increased resource requirements
- Ingress with TLS
- Horizontal Pod Autoscaler (HPA)
- Production configuration file
- 3 replicas minimum
- Name prefix: `prod-`

### Staging Overlay
- JSON6902 patches for advanced patching
- Secret generation
- Mix of development and production features
- Name prefix: `staging-`

## Usage

### Preview configurations (dry-run)

```bash
# Development
kubectl kustomize kustomize/overlays/development

# Production  
kubectl kustomize kustomize/overlays/production

# Staging
kubectl kustomize kustomize/overlays/staging
```

### Apply configurations

```bash
# Development
kubectl apply -k kustomize/overlays/development

# Production
kubectl apply -k kustomize/overlays/production

# Staging
kubectl apply -k kustomize/overlays/staging
```

### Validate configurations

```bash
# Development
kubectl kustomize kustomize/overlays/development | kubectl apply --dry-run=client -f -

# Production
kubectl kustomize kustomize/overlays/production | kubectl apply --dry-run=client -f -
```

## Key Kustomize Concepts Demonstrated

1. **Base and Overlays**: Separation of common configuration from environment-specific changes
2. **Strategic Merge Patches**: Modifying existing resources (deployment-patch.yaml)
3. **JSON6902 Patches**: Advanced patching capabilities (staging environment)
4. **ConfigMap Generation**: Dynamic configuration generation
5. **Secret Generation**: Automatic secret creation
6. **Name Prefixes**: Adding prefixes to resource names
7. **Common Labels**: Adding labels to all resources
8. **Image Transformation**: Changing image tags
9. **Replica Counts**: Modifying replica counts
10. **Namespace Management**: Deploying to different namespaces

## Environment Differences

| Feature | Development | Staging | Production |
|---------|-------------|---------|------------|
| Replicas | 1 | 2 | 3 (min), 10 (max with HPA) |
| Resources | Low | Medium | High |
| Service Type | NodePort | ClusterIP | ClusterIP + Ingress |
| Debug Mode | Enabled | Enabled | Disabled |
| Secrets | None | Generated | None (external) |
| Autoscaling | No | No | Yes (HPA) |

## Commands Reference

```bash
# Build and preview
kubectl kustomize overlays/development
kubectl kustomize overlays/production
kubectl kustomize overlays/staging

# Apply configurations
kubectl apply -k overlays/development
kubectl apply -k overlays/production  
kubectl apply -k overlays/staging

# Delete configurations
kubectl delete -k overlays/development
kubectl delete -k overlays/production
kubectl delete -k overlays/staging

# Validate before applying
kubectl kustomize overlays/production | kubectl apply --dry-run=client -f -
```

This example showcases the power and flexibility of Kustomize for managing Kubernetes configurations across multiple environments while maintaining a clean separation of concerns.