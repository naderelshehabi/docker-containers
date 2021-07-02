#!/bin/bash

# Wait for ca file to exist before we continue. If the ca file doesn't exist
# then something went wrong.
CA_CERT=/config/ca/ca.crt
ELASTIC_PASSWORD=$(</run/secrets/elastic_password)
ELASTICSEARCH_URL=https://elasticsearch:9200

while [[ ! -f $CA_CERT || ! -f /config/logstash/logstash.crt || ! -f /config/logstash/logstash.key ]]
do
    echo "Waiting for SSL certificates"
    sleep 2
done

echo "Found SSL certificates"

mkdir -p /usr/share/logstash/config/certs/ca
mkdir -p /usr/share/logstash/config/certs/logstash/

cp /config/ca/ca.crt /usr/share/logstash/config/certs/ca/ca.crt
cp /config/logstash/logstash.crt /usr/share/logstash/config/certs/logstash/logstash.crt
cp /config/logstash/logstash.key /usr/share/logstash/config/certs/logstash/logstash.key


# Wait for Elasticsearch to start up before doing anything.
while [[ "$(curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $CA_CERT -s -o /dev/null -w '%{http_code}' $ELASTICSEARCH_URL)" != "200" ]]; do
    echo "Waiting for Elasticsearch"
    sleep 5
done

# Set the password for the logstash user.
# REF: https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#set-built-in-user-passwords
until curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $CA_CERT -s -H 'Content-Type:application/json' \
    -XPUT $ELASTICSEARCH_URL/_xpack/security/user/logstash_system/_password \
    -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
do
    sleep 2
    echo "logstash user creation failed. Retrying..."
done

echo "logstash user created successfully"

if [ -f /config/logstash/logstash.keystore ]; then
    echo "Copying existing keystore"
    cp /config/logstash/logstash.keystore /usr/share/logstash/config/logstash.keystore
else
    echo "=== CREATE Keystore ==="
    # Passes yes to the question of "creating keystore without passowrd". Otherwise will throw error!!
    echo "y" | /usr/share/logstash/bin/logstash-keystore create

    echo "Setting ELASTIC_PASSWORD..."
    (cat /run/secrets/elastic_password | /usr/share/logstash/bin/logstash-keystore add 'ELASTIC_PASSWORD' -x)

    cp /usr/share/logstash/config/logstash.keystore /config/logstash/logstash.keystore
fi

echo "Done!"