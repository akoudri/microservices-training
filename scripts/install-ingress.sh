#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create namespace ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.ingressClassResource.name=nginx \
  --set controller.service.loadBalancerIP=34.79.219.176

# FIXME: solution temporaire pour le problème de webhook admission
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
