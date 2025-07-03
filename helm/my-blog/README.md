# My Blog - WordPress & MariaDB Helm Chart

A comprehensive Helm chart that demonstrates the main features of Helm by deploying a WordPress blog application with MariaDB backend.

## 🚀 Features

This chart showcases the following Helm features:

### 📋 Template Helpers

- **Named Templates**: Reusable template snippets in `_helpers.tpl`
- **Dynamic Naming**: Functions for generating consistent resource names
- **Label Management**: Standardized labels across all resources
- **Image Resolution**: Dynamic image name construction with registry support
- **Storage Class Selection**: Flexible storage class configuration

### 🔧 Advanced Templating

- **Conditional Logic**: Resources created based on configuration
- **Loop Constructs**: Dynamic ingress rules and environment variables
- **Value Validation**: Input validation with helpful error messages
- **Multi-line Templates**: Complex environment variable configurations
- **Version Detection**: Kubernetes API version compatibility

### 🎯 Configuration Management

- **Hierarchical Values**: Global, component, and resource-specific settings
- **Default Values**: Sensible defaults with override capabilities
- **Secret Management**: Automatic password generation and secret handling
- **Environment Variables**: Flexible environment configuration

### 🏗️ Application Architecture

- **Multi-Component Deployment**: WordPress frontend + MariaDB backend
- **Service Discovery**: Automatic service-to-service communication
- **Persistent Storage**: Data persistence with PVC management
- **Health Checks**: Comprehensive liveness and readiness probes

### 📊 Operational Features

- **Horizontal Pod Autoscaling**: Automatic scaling based on CPU/memory
- **Ingress Configuration**: External access with TLS support
- **Testing**: Automated connectivity tests with Helm hooks
- **Monitoring**: Rich labels for observability

## 🛠️ Usage

### Installation

```bash
# Install with default values
helm install my-blog ./helm/my-blog

# Install with custom values
helm install my-blog ./helm/my-blog -f custom-values.yaml

# Install with command-line overrides
helm install my-blog ./helm/my-blog \
  --set wordpress.auth.password=mypassword \
  --set mariadb.auth.rootPassword=rootpassword
```

### Configuration Examples

#### Enable Ingress

```yaml
wordpress:
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: blog.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: blog-tls
        hosts:
          - blog.example.com
```

#### Enable Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

#### Custom Storage

```yaml
global:
  storageClass: fast-ssd

wordpress:
  persistence:
    size: 20Gi

mariadb:
  primary:
    persistence:
      size: 50Gi
```

### Testing

```bash
# Run chart tests
helm test my-blog

# Validate template rendering
helm template my-blog ./helm/my-blog

# Debug template output
helm template my-blog ./helm/my-blog --debug
```

## 📁 Chart Structure

```
my-blog/
├── Chart.yaml                 # Chart metadata
├── values.yaml               # Default configuration
├── README.md                 # This file
├── templates/
│   ├── _helpers.tpl          # Template helpers
│   ├── NOTES.txt             # Post-install notes
│   ├── wordpress-deployment.yaml
│   ├── wordpress-service.yaml
│   ├── wordpress-secret.yaml
│   ├── wordpress-pvc.yaml
│   ├── mariadb-deployment.yaml
│   ├── mariadb-service.yaml
│   ├── mariadb-secret.yaml
│   ├── mariadb-pvc.yaml
│   ├── serviceaccount.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   └── tests/
│       └── test-wordpress-connection.yaml
└── charts/                   # Dependency charts (if any)
```

## 🔍 Helper Templates Explained

### Core Helpers

- `my-blog.name`: Chart name with override support
- `my-blog.fullname`: Full resource name generation
- `my-blog.chart`: Chart name and version
- `my-blog.labels`: Common labels for all resources
- `my-blog.selectorLabels`: Pod selector labels

### Component-Specific Helpers

- `my-blog.wordpress.fullname`: WordPress-specific resource names
- `my-blog.mariadb.fullname`: MariaDB-specific resource names
- `my-blog.wordpress.labels`: WordPress component labels
- `my-blog.mariadb.labels`: MariaDB component labels

### Image Helpers

- `my-blog.wordpress.image`: WordPress image name with registry
- `my-blog.mariadb.image`: MariaDB image name with registry

### Configuration Helpers

- `my-blog.wordpress.env`: WordPress environment variables
- `my-blog.storageClass`: Storage class resolution
- `my-blog.probe`: Standardized probe configuration

### Secret Helpers

- `my-blog.wordpress.secretName`: WordPress secret name
- `my-blog.mariadb.secretName`: MariaDB secret name

### Validation Helpers

- `my-blog.validateValues.wordpress.auth`: WordPress auth validation
- `my-blog.validateValues.mariadb.auth`: MariaDB auth validation

## 🎨 Customization

### Adding New Components

1. Create new templates in `templates/`
2. Add corresponding values in `values.yaml`
3. Create helper functions in `_helpers.tpl`
4. Update labels and selectors

### Extending Helpers

```yaml
# _helpers.tpl
{{- define "my-blog.custom.helper" -}}
{{- printf "%s-custom" (include "my-blog.fullname" .) }}
{{- end }}
```

### Custom Values

```yaml
# values.yaml
custom:
  enabled: false
  config: {}
```

## 📝 Best Practices Demonstrated

1. **Consistent Naming**: All resources use helper functions for naming
2. **Flexible Configuration**: Multiple levels of configuration override
3. **Security**: Secrets are properly managed and not hardcoded
4. **Observability**: Rich labels and annotations for monitoring
5. **Testing**: Automated tests validate deployment
6. **Documentation**: Comprehensive inline documentation
7. **Validation**: Input validation prevents common errors
8. **Maintainability**: Modular template structure

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm template` and `helm install`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
