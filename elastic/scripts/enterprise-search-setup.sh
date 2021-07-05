#!/bin/bash

set -uo pipefail

# Wait for ca file to exist before we continue. If the ca file doesn't exist
# then something went wrong.
CA_CERT=/config/ca/ca.crt
KIBANA_URL=http://kibana:5601/kibana

while [ ! -f $CA_CERT ]
do
    echo "Waiting for CA certificate"
    sleep 2
done

echo "Found CA certificate"

# mkdir -p /usr/share/$beat/certs/ca/
# cp /config/ca/ca.crt /usr/share/$beat/certs/ca/ca.crt

# Wait for Kibana to start up before doing anything.
until curl -s "http://kibana:5601/kibana/login" | grep "Loading Elastic" > /dev/null; do
    echo "Waiting for Kibana"
    sleep 5
done

echo "Setting ELASTIC_PASSOWRD in the configuration file"

ELASTIC_PASSWORD=$(</run/secrets/elastic_password)
sed -i "s/[[ELASTIC_PASSWORD]]/$ELASTIC_PASSWORD" /usr/share/enterprise-search/config/enterprise-search.yml

echo "Done!"

