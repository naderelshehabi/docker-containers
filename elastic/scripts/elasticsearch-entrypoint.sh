#!/usr/bin/env bash

/etc/elasticsearch/elasticsearch-setup.sh

/usr/local/bin/docker-entrypoint.sh eswrapper

