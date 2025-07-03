# WordPress Blog on Kubernetes

This directory contains Kubernetes manifests for deploying a WordPress blog application with MariaDB database and phpMyAdmin management interface.

## Architecture

- **WordPress**: Web application (NodePort: 30080)
- **MariaDB**: Database backend (ClusterIP)
- **phpMyAdmin**: Database management (NodePort: 30081)

## Prerequisites

- Kubernetes cluster (minikube, kind, or any K8s cluster)
- kubectl configured and connected to your cluster
- Storage class available (default uses `local-path`)

## Quick Deployment

### Option 1: Using the Deploy Script

```bash
cd /home/ali/Training/micro-services/kubernetes/wordpress-blog
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Manual Deployment

```bash
# Apply manifests in order
kubectl apply -f 01-namespace.yaml
kubectl apply -f 02-secrets.yaml
kubectl apply -f 03-configmap.yaml
kubectl apply -f 04-storage.yaml
kubectl apply -f 05-mariadb.yaml
kubectl apply -f 06-wordpress.yaml
kubectl apply -f 07-phpmyadmin.yaml
```

## Access the Application

- **WordPress Blog**: http://localhost:30080
- **phpMyAdmin**: http://localhost:30081

> **Note**: If using a cloud provider or remote cluster, replace `localhost` with your cluster's external IP.

## File Structure

```
wordpress-blog/
├── 01-namespace.yaml      # Namespace definition
├── 02-secrets.yaml        # Database credentials
├── 03-configmap.yaml      # WordPress PHP configuration
├── 04-storage.yaml        # PersistentVolumeClaims
├── 05-mariadb.yaml        # MariaDB deployment and service
├── 06-wordpress.yaml      # WordPress deployment and service
├── 07-phpmyadmin.yaml     # phpMyAdmin deployment and service
├── deploy.sh              # Deployment script
├── cleanup.sh             # Cleanup script
└── README.md              # This file
```

## Configuration

### Database Credentials

Default credentials are stored in `02-secrets.yaml` (base64 encoded):

- Root password: `rootpassword123`
- Database: `wordpress`
- User: `wordpress`
- Password: `wordpress123`

### Storage

- MariaDB: 5Gi persistent volume
- WordPress: 10Gi persistent volume
- Storage class: `local-path` (change in `04-storage.yaml` if needed)

### Resource Limits

- **WordPress**: 512Mi memory, 500m CPU (limits)
- **MariaDB**: 1Gi memory, 500m CPU (limits)
- **phpMyAdmin**: 256Mi memory, 250m CPU (limits)

## Useful Commands

### Check deployment status

```bash
kubectl get pods -n wordpress-blog
kubectl get services -n wordpress-blog
kubectl get pvc -n wordpress-blog
```

### View logs

```bash
kubectl logs -f deployment/wordpress -n wordpress-blog
kubectl logs -f deployment/mariadb -n wordpress-blog
kubectl logs -f deployment/phpmyadmin -n wordpress-blog
```

### Scale WordPress

```bash
kubectl scale deployment wordpress --replicas=3 -n wordpress-blog
```

### Access pod shell

```bash
kubectl exec -it deployment/wordpress -n wordpress-blog -- /bin/bash
kubectl exec -it deployment/mariadb -n wordpress-blog -- /bin/bash
```

## Backup and Restore

### Backup Database

```bash
kubectl exec -it deployment/mariadb -n wordpress-blog -- mysqldump -u wordpress -pwordpress123 wordpress > wordpress-backup.sql
```

### Restore Database

```bash
kubectl exec -i deployment/mariadb -n wordpress-blog -- mysql -u wordpress -pwordpress123 wordpress < wordpress-backup.sql
```

## Cleanup

### Option 1: Using Cleanup Script

```bash
chmod +x cleanup.sh
./cleanup.sh
```

### Option 2: Manual Cleanup

```bash
kubectl delete namespace wordpress-blog
```

## Production Considerations

1. **Security**:

   - Change default passwords
   - Use proper secrets management
   - Configure network policies

2. **Storage**:

   - Use appropriate storage class for your environment
   - Configure backup strategies
   - Consider storage encryption

3. **Scaling**:

   - WordPress can be scaled horizontally
   - MariaDB requires single instance (consider MySQL cluster for HA)
   - Use ingress controller for proper load balancing

4. **Monitoring**:
   - Add resource monitoring
   - Configure log aggregation
   - Set up alerting

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending**:

   - Check storage class availability
   - Verify node resources

2. **Database connection errors**:

   - Check MariaDB pod logs
   - Verify secret values
   - Ensure MariaDB is ready before WordPress

3. **Storage issues**:
   - Check PVC status
   - Verify storage class permissions
   - Review node storage capacity

### Debug Commands

```bash
# Check pod status
kubectl describe pod -n wordpress-blog

# Check events
kubectl get events -n wordpress-blog --sort-by=.metadata.creationTimestamp

# Check storage
kubectl get pv,pvc -n wordpress-blog
```
