#!/bin/bash

# Étape 1 : Ajouter le repo Helm de MetalLB
helm repo add metallb https://metallb.github.io/metallb

# Étape 2 : Mettre à jour les repos Helm
helm repo update

# Étape 3 : Installer MetalLB avec les paramètres recommandés
helm upgrade --install metallb metallb/metallb \
  --create-namespace \
  --namespace metallb-system \
  --set crds.validationFailurePolicy=Ignore

# Étape 4 : Appliquer la configuration de MetalLB
kubectl apply -f metallb-config.yaml

# Étape 5 : Vérifier l'état du déploiement MetalLB
# kubectl get pods -n metallb-system


# Étape 6 : Vérifier que la configuration a été appliquée
# kubectl -n metallb-system get ipaddresspool