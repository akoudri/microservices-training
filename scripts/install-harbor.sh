#!/bin/bash

kubectl create namespace harbor

helm repo add harbor https://helm.goharbor.io

helm repo update

helm install harbor harbor/harbor --namespace harbor -f harbor-values.yaml