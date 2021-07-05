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

# Wait for Kibana to start up before doing anything.
until curl -s "http://kibana:5601/kibana/login" | grep "Loading Elastic" > /dev/null; do
    echo "Waiting for Kibana"
    sleep 5
done

echo "Done!"



