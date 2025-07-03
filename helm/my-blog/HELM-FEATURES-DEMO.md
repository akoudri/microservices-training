# Helm Features Demonstration

This comprehensive WordPress + MariaDB Helm chart showcases the main features of Helm, with particular emphasis on **template helpers**. Below is a detailed breakdown of the features demonstrated.

## 🎯 Template Helpers (`_helpers.tpl`)

### 1. **Named Templates for Reusability**

```yaml
{{- define "my-blog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
```

### 2. **Dynamic Resource Naming**

```yaml
{{- define "my-blog.wordpress.fullname" -}}
{{- printf "%s-wordpress" (include "my-blog.fullname" .) }}
{{- end }}
```

### 3. **Component-Specific Label Generators**

```yaml
{{- define "my-blog.wordpress.labels" -}}
{{ include "my-blog.labels" . }}
app.kubernetes.io/component: wordpress
{{- end }}
```

### 4. **Image Name Construction**

```yaml
{{- define "my-blog.wordpress.image" -}}
{{- $registryName := .Values.wordpress.image.registry -}}
{{- $repositoryName := .Values.wordpress.image.repository -}}
{{- $tag := .Values.wordpress.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
  {{- $registryName = .Values.global.imageRegistry -}}
{{- end -}}
{{- if $registryName }}
  {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
  {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end }}
```

### 5. **Complex Environment Variable Templates**

```yaml
{{- define "my-blog.wordpress.env" -}}
- name: WORDPRESS_DB_HOST
  value: {{ include "my-blog.mariadb.fullname" . }}
- name: WORDPRESS_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "my-blog.mariadb.secretName" . }}
      key: mariadb-password
{{- with .Values.extraEnvVars }}
{{- toYaml . }}
{{- end }}
{{- end }}
```

### 6. **Value Validation Helpers**

```yaml
{{- define "my-blog.validateValues.wordpress.auth" -}}
{{- if and (empty .Values.wordpress.auth.password) (empty .Values.wordpress.auth.existingSecret) -}}
my-blog: wordpress.auth
    You must provide a password for WordPress admin user.
{{- end -}}
{{- end -}}
```

## 🔧 Advanced Templating Features

### 1. **Conditional Resource Creation**

```yaml
{{- if .Values.mariadb.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-blog.mariadb.fullname" . }}
# ... MariaDB deployment spec
{{- end }}
```

### 2. **Loop Constructs for Dynamic Configuration**

```yaml
{{- range .Values.wordpress.ingress.hosts }}
- host: {{ .host | quote }}
  http:
    paths:
      {{- range .paths }}
      - path: {{ .path }}
        pathType: {{ .pathType }}
      {{- end }}
{{- end }}
```

### 3. **Kubernetes API Version Detection**

```yaml
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- else if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
```

## 📊 Configuration Management

### 1. **Hierarchical Values Structure**

```yaml
# Global settings
global:
  storageClass: ""
  imageRegistry: ""

# Component-specific settings
wordpress:
  image:
    registry: docker.io
    repository: bitnami/wordpress
    tag: "6.4.2-debian-11-r0"

  # Sub-component settings
  auth:
    username: admin
    password: ""
```

### 2. **Default Values with Override Capability**

```yaml
{{- define "my-blog.storageClass" -}}
{{- if .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- else if .Values.wordpress.persistence.storageClass }}
{{- .Values.wordpress.persistence.storageClass }}
{{- end }}
{{- end }}
```

### 3. **Secret Management with Auto-Generation**

```yaml
data:
  {{- if .Values.wordpress.auth.password }}
  wordpress-password: {{ .Values.wordpress.auth.password | b64enc | quote }}
  {{- else }}
  wordpress-password: {{ randAlphaNum 10 | b64enc | quote }}
  {{- end }}
```

## 🏗️ Multi-Component Architecture

### 1. **Service Discovery**

WordPress automatically connects to MariaDB using helper-generated service names:

```yaml
- name: WORDPRESS_DB_HOST
  value: { { include "my-blog.mariadb.fullname" . } }
```

### 2. **Shared Secret References**

```yaml
- name: WORDPRESS_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: { { include "my-blog.mariadb.secretName" . } }
      key: mariadb-password
```

## 🧪 Testing and Validation

### 1. **Helm Test Hooks**

```yaml
metadata:
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-weight": "1"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
```

### 2. **Multi-Step Testing**

- WordPress connectivity test (weight: 1)
- MariaDB connectivity test (weight: 2)

## 📈 Operational Features

### 1. **Horizontal Pod Autoscaler**

```yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
# ... HPA configuration
{{- end }}
```

### 2. **Comprehensive Health Checks**

```yaml
{{- if .Values.wordpress.livenessProbe.enabled }}
livenessProbe:
  {{- include "my-blog.probe" .Values.wordpress.livenessProbe | nindent 12 }}
  httpGet:
    path: {{ .Values.wordpress.livenessProbe.httpGet.path }}
{{- end }}
```

### 3. **Flexible Ingress Configuration**

- Supports multiple ingress controllers
- TLS termination
- Path-based routing

## 🔍 Rich Metadata and Labels

### 1. **Standardized Labels**

```yaml
{{- define "my-blog.labels" -}}
helm.sh/chart: {{ include "my-blog.chart" . }}
{{ include "my-blog.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}
```

### 2. **Component Identification**

Each component gets specific labels for monitoring and selection:

- `app.kubernetes.io/component: wordpress`
- `app.kubernetes.io/component: mariadb`

## 🚀 Usage Examples

### Basic Installation

```bash
helm install my-blog ./helm/my-blog
```

### Custom Configuration

```bash
helm install my-blog ./helm/my-blog \
  --set wordpress.auth.password=mypassword \
  --set wordpress.ingress.enabled=true \
  --set wordpress.ingress.hosts[0].host=blog.example.com
```

### Testing

```bash
helm test my-blog
```

### Template Validation

```bash
helm template my-blog ./helm/my-blog --debug
```

## 🎓 Learning Outcomes

This chart demonstrates:

1. **Template Helpers**: How to create reusable, maintainable templates
2. **Conditional Logic**: Dynamic resource creation based on values
3. **Multi-Component Apps**: Managing complex applications with dependencies
4. **Configuration Management**: Hierarchical values and overrides
5. **Secret Management**: Secure handling of sensitive data
6. **Testing**: Automated validation with Helm hooks
7. **Operational Concerns**: Health checks, scaling, and monitoring
8. **Best Practices**: Consistent naming, labeling, and documentation

## 📋 File Structure

```
helm/my-blog/
├── Chart.yaml                      # Chart metadata
├── values.yaml                     # Default configuration
├── README.md                       # Usage documentation
├── HELM-FEATURES-DEMO.md          # This file
└── templates/
    ├── _helpers.tpl               # Template helpers
    ├── NOTES.txt                  # Post-install instructions
    ├── serviceaccount.yaml        # Service account
    ├── wordpress-deployment.yaml  # WordPress deployment
    ├── wordpress-service.yaml     # WordPress service
    ├── wordpress-secret.yaml      # WordPress secrets
    ├── wordpress-pvc.yaml         # WordPress storage
    ├── mariadb-deployment.yaml    # MariaDB deployment
    ├── mariadb-service.yaml       # MariaDB service
    ├── mariadb-secret.yaml        # MariaDB secrets
    ├── mariadb-pvc.yaml          # MariaDB storage
    ├── ingress.yaml              # Ingress configuration
    ├── hpa.yaml                  # Horizontal Pod Autoscaler
    └── tests/
        └── test-wordpress-connection.yaml  # Connectivity tests
```

This comprehensive example serves as a complete reference for Helm's capabilities, with template helpers being the star feature that enables code reuse, maintainability, and consistency across complex deployments.
