# Kustomize Components Example

This directory demonstrates **Kustomize Components** - a powerful feature for creating reusable, composable configuration pieces.

## What are Kustomize Components?

Components are reusable bundles of Kubernetes resources and transformations that can be mixed and matched across different environments. They use:

- **API Version**: `kustomize.config.k8s.io/v1alpha1`
- **Kind**: `Component`
- **Reusability**: Can be included in multiple kustomizations
- **Composition**: Multiple components can be combined

## Directory Structure

```
kustomize/
├── base/                           # Base application resources
├── components/                     # Reusable components
│   ├── redis/                     # Caching component
│   │   ├── kustomization.yaml     # Component definition
│   │   ├── redis-deployment.yaml  # Redis server
│   │   ├── redis-service.yaml     # Redis service
│   │   └── deployment-patch.yaml  # Patches main app
│   └── logging/                   # Logging component
│       ├── kustomization.yaml     # Component definition
│       ├── fluentd-daemonset.yaml # Log collector
│       ├── fluentd-configmap.yaml # Log configuration
│       └── deployment-logging-patch.yaml # Patches main app
└── overlays/                      # Environment-specific configs
    ├── development/               # Basic dev environment
    ├── development-with-cache/    # Dev + Redis
    ├── staging-with-logging/      # Staging + Logging
    └── production-full-stack/     # Production + All components
```

## Available Components

### 1. Redis Component (`components/redis/`)

**Purpose**: Adds Redis caching capability to your application.

**What it includes**:

- Redis deployment and service
- Patches webapp with Redis connection environment variables
- Adds caching-related labels

**Environment variables added to webapp**:

- `REDIS_HOST=redis-service`
- `REDIS_PORT=6379`
- `CACHE_ENABLED=true`

### 2. Logging Component (`components/logging/`)

**Purpose**: Adds centralized logging with Fluentd.

**What it includes**:

- Fluentd DaemonSet for log collection
- Fluentd configuration for Kubernetes logs
- Patches webapp with logging environment variables
- Adds logging-related labels and annotations

**Environment variables added to webapp**:

- `ENABLE_LOGGING=true`
- `LOG_LEVEL=info`
- `LOG_FORMAT=json`

## Usage Examples

### Basic Usage

```bash
# Base application only
kustomize build base/

# Development with Redis caching
kustomize build overlays/development-with-cache/

# Staging with logging
kustomize build overlays/staging-with-logging/

# Production with all components
kustomize build overlays/production-full-stack/
```

### How Components are Used in Kustomization

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

# Include one or more components
components:
  - ../../components/redis
  - ../../components/logging
# Your other configurations...
```

## Component Definition Structure

Each component has a `kustomization.yaml` with this structure:

```yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

metadata:
  name: component-name

# Resources that this component adds
resources:
  - resource1.yaml
  - resource2.yaml

# Patches to apply to existing resources
patchesStrategicMerge:
  - patch.yaml

# Common labels/annotations for all resources
commonLabels:
  component: component-name

commonAnnotations:
  managed-by: kustomize-component
```

## Key Benefits

1. **Modularity**: Separate concerns into focused components
2. **Reusability**: Share components across environments
3. **Composition**: Mix and match components as needed
4. **Maintainability**: Update once, affects all users
5. **Flexibility**: Each overlay chooses which components to include

## Real-World Scenarios

### Development Environment

- **Basic**: `base/` only
- **With Caching**: `base/` + `redis` component
- **With Logging**: `base/` + `logging` component

### Staging Environment

- **Standard**: `base/` + `logging` component
- **Performance Testing**: `base/` + `redis` + `logging` components

### Production Environment

- **Full Stack**: `base/` + `redis` + `logging` + additional production resources

## Component Interaction

Components can complement each other:

- **Redis** provides caching capability
- **Logging** provides observability
- Both can be used together for a full-featured application

## Testing Your Configuration

```bash
# Test individual environments
kustomize build overlays/development-with-cache/
kustomize build overlays/staging-with-logging/
kustomize build overlays/production-full-stack/

# Compare configurations
diff <(kustomize build overlays/development/) <(kustomize build overlays/development-with-cache/)
```

## Best Practices

1. **Keep Components Focused**: Each component should have a single responsibility
2. **Document Dependencies**: Clearly state what each component requires
3. **Test Combinations**: Verify that components work well together
4. **Use Descriptive Names**: Component names should clearly indicate their purpose
5. **Version Components**: Consider versioning strategies for component evolution

## Common Patterns

### Adding a New Component

1. Create component directory: `components/new-component/`
2. Add `kustomization.yaml` with `kind: Component`
3. Add required resources
4. Add patches if needed
5. Include in desired overlays

### Conditional Components

Different environments can use different combinations:

- **Development**: Basic functionality
- **Staging**: + Logging for debugging
- **Production**: + Redis + Logging for performance and monitoring

This approach allows you to build applications incrementally, adding capabilities as needed without duplicating configuration.
