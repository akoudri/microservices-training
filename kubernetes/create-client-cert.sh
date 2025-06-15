#!/bin/bash

# Generate admin key
openssl genrsa -out admin.key 2048

# Certificate Signing Request (CSR) for the admin certificate
openssl req -new -key admin.key \
    -subj "/CN=kube-admin/O=system:masters" \
    -out admin.csr

# Sign Certificate using CA
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key \
    -out admin.crt

rm *.csr
echo "Admin cert generated"
