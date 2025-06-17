#! /bin/bash

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --values values.yaml

# kubectl create serviceaccount admin-user -n kubernetes-dashboard

# kubectl create clusterrolebinding admin-user \
#   --clusterrole=cluster-admin \
#   --serviceaccount=kubernetes-dashboard:admin-user

# kubectl -n kubernetes-dashboard create token admin-user

# kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443