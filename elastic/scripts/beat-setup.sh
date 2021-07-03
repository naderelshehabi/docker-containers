#!/bin/bash

set -uo pipefail

beat=$1
echo "===================="
echo "Setting up ${beat}"
echo "===================="

# Wait for ca file to exist before we continue. If the ca file doesn't exist
# then something went wrong.
CA_CERT=/config/ca/ca.crt
ELASTIC_PASSWORD=$(</run/secrets/elastic_password)
ELASTICSEARCH_URL=https://elasticsearch:9200

while [ ! -f $CA_CERT ]
do
    echo "Waiting for CA certificate"
    sleep 2
done

echo "Found CA certificate"

# mkdir -p /usr/share/auditbeat/certs/ca/
# cp /config/ca/ca.crt /usr/share/auditbeat/certs/ca/ca.crt

# Wait for Elasticsearch to start up before doing anything.
while [[ "$(curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $CA_CERT -s -o /dev/null -w '%{http_code}' $ELASTICSEARCH_URL)" != "200" ]]; do
    echo "Waiting for Elasticsearch"
    sleep 5
done

echo "Creating keystore..."
# create beat keystore
${beat} --strict.perms=false keystore create --force
# chown 1000 /usr/share/$beat/$beat.keystore
# chmod go-w /usr/share/$beat/$beat.yml


echo "adding ELASTIC_PASSWORD to keystore..."
echo "$ELASTIC_PASSWORD" | ${beat} --strict.perms=false keystore add ELASTIC_PASSWORD --stdin
${beat} --strict.perms=false keystore list

echo "Setting up dashboards..."
# Load the sample dashboards for the Beat.
# REF: https://www.elastic.co/guide/en/beats/metricbeat/master/metricbeat-sample-dashboards.html
${beat} --strict.perms=false setup -v

# echo "Copy keystore to ./config dir"
# cp /usr/share/$beat/$beat.keystore /config/$beat/$beat.keystore
# chown 1000:1000 /config/$beat/$beat.keystore