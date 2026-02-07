#!/bin/bash

##############################################################################
# Install monitoring stack: Prometheus + Grafana + OpenTelemetry Collector
#
# Usage: ./install-monitoring.sh
#
# What this script installs:
#   1. kube-prometheus-stack (Prometheus, Grafana, Alertmanager, node-exporter)
#   2. OpenTelemetry Collector (receives and exports telemetry to Prometheus)
#
# Access the UIs:
#   Grafana:      http://localhost:3000  (admin / prom-operator)
#   Prometheus:   http://localhost:9090
#   Alertmanager: http://localhost:9093
#
# Port-forward commands (run in separate terminals):
#   kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
#   kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
#   kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093
#
# Uninstall (step by step):
#   1. Remove the OpenTelemetry Collector release:
#      helm uninstall otel-collector -n monitoring
#
#   2. Remove the kube-prometheus-stack release:
#      helm uninstall monitoring -n monitoring
#
#   3. Delete CRDs installed by kube-prometheus-stack (not removed by helm):
#      kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
#      kubectl delete crd alertmanagers.monitoring.coreos.com
#      kubectl delete crd podmonitors.monitoring.coreos.com
#      kubectl delete crd probes.monitoring.coreos.com
#      kubectl delete crd prometheusagents.monitoring.coreos.com
#      kubectl delete crd prometheuses.monitoring.coreos.com
#      kubectl delete crd prometheusrules.monitoring.coreos.com
#      kubectl delete crd scrapeconfigs.monitoring.coreos.com
#      kubectl delete crd servicemonitors.monitoring.coreos.com
#      kubectl delete crd thanosrulers.monitoring.coreos.com
#
#   4. Delete the namespace and any remaining resources:
#      kubectl delete ns monitoring
#
# Quick uninstall (all in one):
#   helm uninstall otel-collector -n monitoring; \
#   helm uninstall monitoring -n monitoring; \
#   kubectl delete crd -l app.kubernetes.io/part-of=kube-prometheus-stack; \
#   kubectl delete ns monitoring
##############################################################################

set -e

NAMESPACE="monitoring"

# --- Check prerequisites ---
for cmd in helm kubectl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# --- Add Helm repos ---
echo "Adding Helm repos..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# --- Install kube-prometheus-stack ---
echo ""
echo "Installing kube-prometheus-stack (Prometheus + Grafana + Alertmanager)..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --set grafana.adminPassword=prom-operator

# --- Install OpenTelemetry Collector ---
echo ""
echo "Installing OpenTelemetry Collector..."
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  --namespace "$NAMESPACE" \
  --set mode=deployment \
  --set image.repository=otel/opentelemetry-collector-contrib \
  --set config.exporters.prometheus.endpoint="0.0.0.0:8889" \
  --set config.exporters.prometheus.resource_to_telemetry_conversion.enabled=true \
  --set config.service.pipelines.metrics.exporters[0]=prometheus

# --- Wait for pods ---
echo ""
echo "Waiting for pods to be ready (this may take a few minutes)..."
kubectl wait --namespace "$NAMESPACE" \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/instance=monitoring \
  --timeout=300s 2>/dev/null || true

# --- Summary ---
echo ""
echo "============================================"
echo "  Monitoring stack installed"
echo "============================================"
echo ""
echo "Namespace: $NAMESPACE"
echo ""
kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | while read -r line; do
  echo "  $line"
done
echo ""
echo "--- Access the UIs (run in separate terminals) ---"
echo ""
echo "  Grafana (admin / prom-operator):"
echo "    kubectl port-forward -n $NAMESPACE svc/monitoring-grafana 3000:80"
echo "    -> http://localhost:3000"
echo ""
echo "  Prometheus:"
echo "    kubectl port-forward -n $NAMESPACE svc/monitoring-kube-prometheus-prometheus 9090:9090"
echo "    -> http://localhost:9090"
echo ""
echo "  Alertmanager:"
echo "    kubectl port-forward -n $NAMESPACE svc/monitoring-kube-prometheus-alertmanager 9093:9093"
echo "    -> http://localhost:9093"
echo ""
echo "--- Useful commands ---"
echo ""
echo "  kubectl get servicemonitors -n $NAMESPACE"
echo "  kubectl get prometheusrules -n $NAMESPACE"
echo "  kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=opentelemetry-collector"
echo ""
echo "--- Uninstall ---"
echo ""
echo "  helm uninstall otel-collector -n $NAMESPACE"
echo "  helm uninstall monitoring -n $NAMESPACE"
echo "  kubectl delete crd -l app.kubernetes.io/part-of=kube-prometheus-stack"
echo "  kubectl delete ns $NAMESPACE"
echo ""
