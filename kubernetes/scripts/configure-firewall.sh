#!/bin/bash

gcloud compute firewall-rules create allow-metallb \
  --allow tcp:80,tcp:443,tcp:7946,udp:7946 \
  --source-ranges 10.132.0.0/24 \
  --network default

gcloud compute firewall-rules create allow-ingress-webhook \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:8443 \
  --source-ranges=10.132.0.0/24 \
  --network=default \
  --description="Autoriser le trafic vers le webhook ingress-nginx"

gcloud compute firewall-rules create allow-internal-traffic \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=all \
  --source-ranges=10.132.0.0/24 \
  --network=default \
  --description="Trafic interne entre les nœuds du cluster"

