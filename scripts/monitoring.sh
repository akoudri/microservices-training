#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace observability --create-namespace

# kubectl get secret --namespace observability prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# kubectl port-forward svc/prometheus-grafana -n observability 3000:80
