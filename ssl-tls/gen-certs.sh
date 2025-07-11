#!/bin/bash

set -e

CERTS_FOLDER=certs

# --- STEP 1: Generate CA's private key and root cert.

# Create private key for the CA
openssl genrsa -des3 -out $CERTS_FOLDER/test-ca.key 2048

# Request/generate certificate for CA using the private key
openssl req -x509 -new -nodes \
    -key $CERTS_FOLDER/test-ca.key \
    -sha256 \
    -days 365 \
    -out $CERTS_FOLDER/test-root-ca.pem

# Copy this test, self-signed root CA to OS's trusted CA list
sudo cp $CERTS_FOLDER/test-root-ca.pem \
    /usr/local/share/ca-certificates/test-root-ca.crt \
    && sudo update-ca-certificates

# Test if certificate succesuly added
awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt | grep foo.bar

# --- STEP 2: Generate site's private key and root cert.

# Create private key
openssl genrsa -out $CERTS_FOLDER/www.foo.bar.key 2048

# Generate Cert Signing Request (CSR)
openssl req -new -key $CERTS_FOLDER/www.foo.bar.key \
    -out $CERTS_FOLDER/www.foo.bar.csr

# Signing site cert using CA's private key and cert
openssl x509 -req \
    -in $CERTS_FOLDER/www.foo.bar.csr \
    -CA $CERTS_FOLDER/test-root-ca.pem \
    -CAkey $CERTS_FOLDER/test-ca.key \
    -extfile $CERTS_FOLDER/www.foo.bar.ext \
    -CAcreateserial \
    -days 365 \
    -sha256 \
    -out $CERTS_FOLDER/www.foo.bar.crt
