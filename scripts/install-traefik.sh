#!/bin/bash

# Execute first install-metallb.sh script before this one.

helm repo add traefik https://traefik.github.io/charts
helm repo update

kubectl create namespace traefik

helm install traefik traefik/traefik \
  --namespace=traefik \
  --set dashboard.enabled=true \
  --set service.type=LoadBalancer \
  --set ingressClass.enabled=true \
  --set ingressClass.isDefaultClass=true

# Install CRD for dynamic configuration
helm install traefik-crds traefik/traefik-crds

