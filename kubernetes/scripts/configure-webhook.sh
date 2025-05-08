#!/bin/bash

fw_rule=$(gcloud compute firewall-rules list --format="value(name)" --filter="name~'training-[a-z0-9]+-master'")

# Vérifie si la règle existe
if [ -n "$fw_rule" ]; then
  # Met à jour la règle existante
  gcloud compute firewall-rules update $fw_rule --allow=tcp:8443,tcp:10250,tcp:443
  echo "Règle $fw_rule mise à jour"
else
  echo "Aucune règle master trouvée, création d'une nouvelle règle"
  # Crée une nouvelle règle spécifique pour le webhook
  gcloud compute firewall-rules create allow-k8s-webhook \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:8443 \
    --source-ranges=10.132.0.0/24
fi

