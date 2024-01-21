#!/bin/sh

set -eux

ME=$(realpath $(dirname $0))

cd $ME

printf 'Running in: %s\n' "$ME"

DOMAIN="ldap.server.intranet"
SSL_PATH="$ME/"
CA_PATH="$SSL_PATH/data/${DOMAIN}_ca"
KEYCERT_PATH="$SSL_PATH/data/${DOMAIN}"

# bake the keys
if [ ! -f $CA_PATH.key ]; then
    openssl ecparam -out $CA_PATH.key -name prime256v1 -genkey
fi

if [ ! -f $KEYCERT_PATH.key ]; then
    openssl ecparam -out $KEYCERT_PATH.key -name prime256v1 -genkey
fi

# bake the CA
openssl req -x509 -config $SSL_PATH/openssl.cnf -new -nodes -key $CA_PATH.key -sha384 -days 15 -out $CA_PATH.cer

# bake the CSR
if [ ! -f $KEYCERT_PATH.csr ]; then
    openssl req -new -config ${SSL_PATH}/${DOMAIN}.csr.conf -key $KEYCERT_PATH.key -out $KEYCERT_PATH.csr
fi

# bake the cert
openssl x509 -req -extensions ext_cert -extfile ${SSL_PATH}/${DOMAIN}.csr.conf -in $KEYCERT_PATH.csr -CA $CA_PATH.cer -CAkey $CA_PATH.key \
    -CAcreateserial -out $KEYCERT_PATH.cer -days 7 -sha384

openssl req -in $KEYCERT_PATH.csr -noout -text
openssl x509 -in $KEYCERT_PATH.cer -noout -text

cat $KEYCERT_PATH.cer > ${KEYCERT_PATH}_fullchain.cer
cat $CA_PATH.cer >> ${KEYCERT_PATH}_fullchain.cer
