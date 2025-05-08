# MetalLB is not compatible with GCP !
1 - Configure firewall (configure-firewall.sh)
2 - Install metallb (install-metallb.sh)
3 - Provision public IP (provision-ip.sh)
3 - Configure metallb (apply metallb-config.yaml -- configure public IP first)
4 - Install ingress-nginx (install-ingress.sh -- configure public IP first)
6 - Check installation: kubectl get svc -n ingress-nginx ingress-nginx-controller -o wide
