#!/bin/bash

set -uo pipefail

# Wait for ca file to exist before we continue. If the ca file doesn't exist
# then something went wrong.
CA_CERT=/config/ca/ca.crt
ELASTIC_PASSWORD=$(</run/secrets/elastic_password)
ELASTICSEARCH_URL=https://elasticsearch:9200

while [[ ! -f $CA_CERT || ! -f /config/kibana/kibana.crt || ! -f /config/kibana/kibana.key ]]
do
    echo "Waiting for SSL certificates"
    sleep 2
done

echo "Found SSL certificates"

mkdir -p /usr/share/kibana/config/certs/ca
mkdir -p /usr/share/kibana/config/certs/kibana/

cp /config/ca/ca.crt /usr/share/kibana/config/certs/ca/ca.crt
cp /config/kibana/kibana.crt /usr/share/kibana/config/certs/kibana/kibana.crt
cp /config/kibana/kibana.key /usr/share/kibana/config/certs/kibana/kibana.key


# Wait for Elasticsearch to start up before doing anything.
while [[ "$(curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $CA_CERT -s -o /dev/null -w '%{http_code}' $ELASTICSEARCH_URL)" != "200" ]]; do
    echo "Waiting for Elasticsearch"
    sleep 5
done

# Set the password for the kibana user.
# REF: https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#set-built-in-user-passwords
until curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $CA_CERT -s -H 'Content-Type:application/json' \
    -XPUT $ELASTICSEARCH_URL/_xpack/security/user/kibana_system/_password \
    -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
do
    sleep 2
    echo "Kibana user creation failed. Retrying..."
done

echo "Kibana user created successfully"

if [ -f /config/kibana/kibana.keystore ]; then
    echo "Copying existing keystore"
    cp /config/kibana/kibana.keystore /usr/share/kibana/config/kibana.keystore
else
    echo "=== CREATE Keystore ==="
    /usr/share/kibana/bin/kibana-keystore create

    echo "Setting elasticsearch.password..."
    (cat /run/secrets/elastic_password | /usr/share/kibana/bin/kibana-keystore add 'elasticsearch.password' -x)

    cp /usr/share/kibana/config/kibana.keystore /config/kibana/kibana.keystore
fi

echo "Done!"