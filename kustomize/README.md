# Kustomize Examples

This directory contains comprehensive examples of Kustomize usage, with a special focus on **Components** - one of Kustomize's most powerful features for creating reusable, composable configurations.

## Quick Start

```bash
# View the base configuration
kustomize build base/

# See development environment
kustomize build overlays/development/

# See production with all components
kustomize build overlays/production-full-stack/
```

## What's Included

### 📁 Base Configuration

- `base/` - Core application resources (deployment, service, configmap)

### 🧩 Components (Reusable Pieces)

- `components/redis/` - Adds Redis caching capability
- `components/logging/` - Adds centralized logging with Fluentd

### 🌍 Overlays (Environment-Specific)

- `overlays/development/` - Basic development environment
- `overlays/development-with-cache/` - Development + Redis
- `overlays/staging-with-logging/` - Staging + Logging
- `overlays/production-full-stack/` - Production + All components

## Key Concepts Demonstrated

1. **Base Resources**: Common application components
2. **Strategic Merge Patches**: Modifying existing resources
3. **JSON 6902 Patches**: Precise resource modifications
4. **ConfigMap/Secret Generators**: Dynamic configuration creation
5. **Components**: Reusable configuration bundles ⭐
6. **Name Prefixes**: Environment-specific naming
7. **Common Labels**: Consistent labeling across resources
8. **Image Tag Management**: Different images per environment

## Components Deep Dive

**Components** are the star feature here. They allow you to:

- Create reusable pieces of configuration
- Mix and match capabilities across environments
- Maintain DRY (Don't Repeat Yourself) principles
- Compose complex applications from simple building blocks

See `COMPONENTS.md` for detailed documentation.

## Directory Structure

```
kustomize/
├── README.md                          # This file
├── COMPONENTS.md                      # Components documentation
├── compare-configs.sh                 # Comparison script
├── base/                             # Base application
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── components/                       # Reusable components
│   ├── redis/                       # Caching component
│   └── logging/                     # Logging component
└── overlays/                        # Environment configs
    ├── development/                 # Basic dev
    ├── development-with-cache/      # Dev + Redis
    ├── staging-with-logging/        # Staging + Logging
    └── production-full-stack/       # Production + All
```

## Usage Examples

### Environment Progression

```bash
# Start simple
kustomize build base/

# Add caching for development
kustomize build overlays/development-with-cache/

# Add logging for staging
kustomize build overlays/staging-with-logging/

# Full production setup
kustomize build overlays/production-full-stack/
```

### Component Combinations

```bash
# No components (basic app)
kustomize build overlays/development/

# Redis only
kustomize build overlays/development-with-cache/

# Logging only
kustomize build overlays/staging-with-logging/

# Both components
kustomize build overlays/production-full-stack/
```

## Learning Path

1. **Start with Base**: Understand the core application
2. **Explore Overlays**: See how environments differ
3. **Study Components**: Learn the reusable pieces
4. **Mix and Match**: Try different component combinations
5. **Create Your Own**: Build custom components

## Files to Explore

1. `base/kustomization.yaml` - Base configuration
2. `components/redis/kustomization.yaml` - Component definition
3. `overlays/production-full-stack/kustomization.yaml` - Multiple components
4. `COMPONENTS.md` - Detailed component documentation

## Scripts

- `compare-configs.sh` - Compare different configurations
- Shows what each component adds
- Displays resource counts and differences

## Best Practices Demonstrated

1. **Separation of Concerns**: Each component has a single responsibility
2. **Environment Progression**: Build complexity gradually
3. **Consistent Labeling**: Use labels for organization
4. **Resource Optimization**: Different resource limits per environment
5. **Security**: Use secrets for sensitive data
6. **Monitoring**: Include observability components

## Real-World Applications

This structure models real-world scenarios:

- **Development**: Fast iteration, minimal overhead
- **Staging**: Production-like with debugging capabilities
- **Production**: Full feature set with monitoring and scaling

## Next Steps

1. Install kustomize: `curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash`
2. Try building configurations: `kustomize build overlays/production-full-stack/`
3. Apply to a cluster: `kustomize build overlays/development/ | kubectl apply -f -`
4. Create your own components for features like:
   - Monitoring (Prometheus, Grafana)
   - Security (RBAC, Network Policies)
   - Databases (PostgreSQL, MongoDB)
   - Service Mesh (Istio, Linkerd)

---

This example demonstrates how Kustomize components enable building complex, maintainable Kubernetes configurations through composition rather than duplication.
