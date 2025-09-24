# Kubernetes Deployment for WordPress Blog Stack

This directory contains Kubernetes manifests generated from the `docker-compose.yaml` file.

## Components

- **MariaDB StatefulSet**: Database with persistent storage (10Gi)
- **WordPress Deployment**: Web application with persistent content storage
- **phpMyAdmin Deployment**: Database management interface
- **Secrets & ConfigMaps**: Database credentials and configuration

## Quick Deploy

```bash
# Deploy all components
kubectl apply -f kubernetes-manifests.yaml

# Check deployment status
kubectl get pods -n training

# Wait for all pods to be ready
kubectl wait --for=condition=Ready pods --all -n training --timeout=300s
```

## Access Applications

```bash
# Get NodePort services
kubectl get svc -n training

# Access WordPress (replace NODE_IP with your cluster node IP)
# WordPress: http://NODE_IP:30080
# phpMyAdmin: http://NODE_IP:30081

# For local testing (port-forward)
kubectl port-forward -n training svc/wordpress 8080:80
kubectl port-forward -n training svc/phpmyadmin 8081:80
```

## Storage

- **MariaDB**: Uses StatefulSet with volumeClaimTemplates for persistent database storage
- **WordPress**: Uses PVC for persistent content storage
- **Storage Size**: 10Gi for both database and WordPress content

## Credentials

Default credentials (same as docker-compose):

- **Database Root Password**: `rootpassword123`
- **WordPress DB User**: `wordpress`
- **WordPress DB Password**: `wordpress123`
- **Database Name**: `wordpress`

## Cleanup

```bash
# Delete all resources
kubectl delete -f kubernetes-manifests.yaml

# Delete persistent volumes (optional - will delete data)
kubectl delete pvc -n training --all
```

## Key Differences from Docker Compose

1. **StatefulSet for MariaDB**: Ensures stable network identity and persistent storage
2. **NodePort Services**: Exposes applications on cluster nodes (ports 30080, 30081)
3. **Secrets/ConfigMaps**: Separate configuration from deployment manifests
4. **Health Checks**: Converted Docker healthchecks to Kubernetes probes
5. **Namespace**: All resources isolated in `wordpress` namespace
