#!/usr/bin/env bash

/usr/local/bin/enterprise-search-setup.sh

# Passing elastic password variable to the entrypoint

ELASTIC_PASSWORD=$(</run/secrets/elastic_password) /usr/local/bin/docker-entrypoint.sh