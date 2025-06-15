#!/bin/bash

# Generate server key
openssl genrsa -out ca.key 2048

# Certificate Signing Request (CSR) for the CA certificate
openssl req -new -key ca.key \
    -subj "/CN=ca" \
    -out ca.csr

# Sign CSR with private key to create a self-signed certificate
openssl x509 -req -in ca.csr -signkey ca.key \
    -days 365 \
    -out ca.crt

rm *.csr
echo "CA cert generated"
