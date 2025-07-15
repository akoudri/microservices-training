#!/bin/bash

# Ajouter le dépôt du driver
helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
helm repo update

# Installer le driver dans votre cluster
helm install csi-driver-smb csi-driver-smb/csi-driver-smb \
  --namespace kube-system \
  --version v1.16.0

kubectl create secret generic hetzner-smb-secret \
  --from-literal=username='u474420' \
  --from-literal=password='Yyx7cXB)czSm$rT' \
  --namespace default

kubectl apply -f hetzner-sc.yaml
