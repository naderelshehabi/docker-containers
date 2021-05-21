#!/bin/bash

sleep 30s
cockroach init --host=localhost --certs-dir=/run/secrets
sleep 30s
roach_pass=$(</run/secrets/roach_pass.txt)
echo "CREATE USER roach WITH PASSWORD '$roach_pass';" | cockroach sql --host=localhost --certs-dir=/run/secrets

echo "GRANT admin TO roach;" | cockroach sql --host=localhost --certs-dir=/run/secrets