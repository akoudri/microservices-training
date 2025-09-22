#!/bin/bash

# To be executed in node master only
if [ $# != 1 ]; then
  echo "Usage: $0 <key>"
  exit 1
fi

kubectl exec -n kube-system etcd-master1 -- \
  etcdctl --write-out=json \
    --cacert /etc/kubernetes/pki/etcd/ca.crt \
    --cert /etc/kubernetes/pki/etcd/server.crt \
    --key /etc/kubernetes/pki/etcd/server.key \
    get $1