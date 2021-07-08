#!/bin/sh

# Reading secrets into variables

echo "setting up environment variables"

PGADMIN_USER=`cat /run/secrets/pgadmin_user`
PGADMIN_PASS=`cat /run/secrets/pgadmin_password`

# Setting environment variable for the main entrypoint
echo "Calling entry point with the default username and password"

PGADMIN_DEFAULT_EMAIL=$PGADMIN_USER PGADMIN_DEFAULT_PASSWORD=$PGADMIN_PASS /entrypoint.sh

