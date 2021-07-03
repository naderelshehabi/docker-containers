#!/bin/bash

/usr/local/bin/beat-setup.sh $1

/usr/local/bin/docker-entrypoint -e --strict.perms=false # -e flag to log to stderr and disable syslog/file output