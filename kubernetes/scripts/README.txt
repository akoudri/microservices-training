1 - Configure firewall
2 - Installer helm and then install metallb
3 - Configure metallb
4 - Installer ingress
5 - Annoter ingress: kubectl annotate svc -n ingress-nginx ingress-nginx-controller metallb.universe.tf/address-pool=default-pool
5 - Patcher ingress: kubectl patch svc -n ingress-nginx ingress-nginx-controller -p '{"spec":{"externalTrafficPolicy":"Local"}}'
6 - Vérifier l'ip de l'ingress: kubectl get svc -n ingress-nginx ingress-nginx-controller -o wide
