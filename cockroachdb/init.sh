#!/bin/bash

# sleep 3
# echo "init"
# sleep 3
# testing=$(<./secrets/roach_pass.txt)
# echo "pass is $testing"

sleep 30s
cockroach init --host=localhost --certs-dir=/run/secrets
sleep 30s
roach_pass=$(</run/secrets/roach_pass.txt)
echo "CREATE USER roach WITH PASSWORD '$roach_pass';" | cockroach sql --host=cockroachdb-1 --certs-dir=/run/secrets