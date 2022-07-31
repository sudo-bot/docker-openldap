# Testing the image

## Run the tests

```sh
make test
```

### Re-Build the test certificate

Source: [MariaDB docs](https://mariadb.com/docs/security/data-in-transit-encryption/create-self-signed-certificates-keys-openssl/)

```sh
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=FR/OU=Testing/O=Datacenters Network" \
    -keyout ca.key  -out ca.pem

openssl req -new -newkey rsa:4096 -nodes \
    -subj "/emailAddress=williamdes+sudo-bot-test-cert@wdes.fr/C=FR/OU=Testing/O=Datacenters Network/CN=openldap" \
    -keyout server-key.pem  -out server-req.pem

openssl x509 -req -days 365 -set_serial 01 \
   -in server-req.pem \
   -out server-cert.pem \
   -CA ca.pem \
   -CAkey ca.key

# Cleanup
rm server-req.pem
# Could be needed
# chmod 777 server-cert.pem server-key.pem ca.pem
# Verify
openssl verify -verbose -x509_strict -CAfile ca.pem server-cert.pem
```
