#!/bin/bash

# To be executed in node master only
kubectl exec -n kube-system etcd-master1 -- \
  etcdctl \
    --cacert /etc/kubernetes/pki/etcd/ca.crt \
    --cert /etc/kubernetes/pki/etcd/server.crt \
    --key /etc/kubernetes/pki/etcd/server.key \
    get / --prefix --keys-only
