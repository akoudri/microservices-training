#!/bin/bash

# gcloud compute instances add-tags master --tags=k8s-node
# gcloud compute instances add-tags node1 --tags=k8s-node
# gcloud compute instances add-tags node2 --tags=k8s-node
# gcloud compute instances add-tags node3 --tags=k8s-node

gcloud compute firewall-rules create allow-metallb-memberlist \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:7946,udp:7946 \
  --source-ranges=10.132.0.0/24 \
  --target-tags=k8s-node \
  --description="Allow memberlist traffic for MetalLB"

gcloud compute firewall-rules create allow-ingress-traffic \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:80,tcp:443,tcp:8443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=k8s-node \
  --description="Allow ingress traffic to the cluster"

gcloud compute firewall-rules create allow-health-checks \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:10256 \
  --source-ranges=10.132.0.0/24 \
  --target-tags=k8s-node \
  --description="Allow health checks for MetalLB"    

gcloud compute firewall-rules create allow-webhook-admission \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:8443 \
  --source-ranges=10.132.0.0/24 \
  --target-tags=k8s-node \
  --description="Allow webhook admission controller traffic"

# FIXME: cette solution ne fonctionne pas, il est important de résoudre le problème de webhook admission
# sh configure-webhook.sh