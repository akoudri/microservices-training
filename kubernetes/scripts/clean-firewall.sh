#!/bin/bash

gcloud compute firewall-rules delete allow-metallb-memberlist 

gcloud compute firewall-rules delete allow-ingress-traffic

gcloud compute firewall-rules delete allow-health-checks   

gcloud compute firewall-rules delete allow-webhook-admission 
