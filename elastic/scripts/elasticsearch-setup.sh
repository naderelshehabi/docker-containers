#!/bin/bash

umask 0002

mkdir -p /usr/share/elasticsearch/config/certs/elasticsearch
mkdir -p /usr/share/elasticsearch/config/certs/ca
mkdir -p /config/elasticsearch

if [ -f /config/elasticsearch/elasticsearch.keystore ]; then
    echo "Copying existing keystore"
    cp /config/elasticsearch/elasticsearch.keystore /usr/share/elasticsearch/config/elasticsearch.keystore
else
    echo "=== CREATE Keystore ==="
    /usr/share/elasticsearch/bin/elasticsearch-keystore create

    echo "Setting bootstrap.password..."
    (cat /run/secrets/elastic_password | /usr/share/elasticsearch/bin/elasticsearch-keystore add -x 'bootstrap.password')

    cp /usr/share/elasticsearch/config/elasticsearch.keystore /config/elasticsearch/elasticsearch.keystore
fi

if [[ -f /config/ca/ca.crt && -f /config/ca/ca.key && \
    -f /config/elasticsearch/elasticsearch.crt && -f /config/elasticsearch/elasticsearch.key ]]; then
    echo "Copying existing SSL certificates"

    cp /config/elasticsearch/* /usr/share/elasticsearch/config/certs/elasticsearch/
    cp /config/ca/* /usr/share/elasticsearch/config/certs/ca/

    echo "Done!"

    exit 0
fi

# Create elastic search directory in the configuration volume
mkdir -p /config/ca
mkdir -p /config/ssl
mkdir -p /config/kibana
mkdir -p /config/logstash

# Create SSL Certs
echo "=== CREATE SSL CERTS ==="

# check if old docker-cluster-ca.zip exists, if it does remove and create a new one.
if [ -f /config/ssl/docker-cluster-ca.zip ]; then
    echo "Remove old ca zip..."
    rm /config/ssl/docker-cluster-ca.zip
fi
echo "Creating docker-cluster-ca.zip..."
/usr/share/elasticsearch/bin/elasticsearch-certutil ca --pem --silent --out /config/ssl/docker-cluster-ca.zip

# check if ca directory exists, if does, remove then unzip new files
if [ -d /config/ssl/ca ]; then
    echo "CA directory exists, removing..."
    rm -rf /config/ssl/ca
fi
echo "Unzip ca files..."
unzip /config/ssl/docker-cluster-ca.zip -d /config/ssl

# check if certs zip exist. If it does remove and create a new one.
if [ -f /config/ssl/docker-cluster.zip ]; then
    echo "Remove old docker-cluster.zip zip..."
    rm /config/ssl/docker-cluster.zip
fi
echo "Create cluster certs zipfile..."
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem --in /usr/share/elasticsearch/config/instances.yml --out /config/ssl/docker-cluster.zip --ca-cert /config/ssl/ca/ca.crt --ca-key /config/ssl/ca/ca.key

if [ -d /config/ssl/docker-cluster ]; then
    rm -rf /config/ssl/docker-cluster
fi

echo "Unzipping cluster certs zipfile..."
unzip /config/ssl/docker-cluster.zip -d /config/ssl/docker-cluster

echo "Move logstash certs to logstash config dir..."
mv /config/ssl/docker-cluster/logstash/* /config/logstash/

echo "Move kibana certs to kibana config dir..."
mv /config/ssl/docker-cluster/kibana/* /config/kibana/

echo "Move elasticsearch certs to elasticsearch config dir..."
cp /config/ssl/docker-cluster/elasticsearch/* /usr/share/elasticsearch/config/certs/elasticsearch/
cp /config/ssl/ca/* /usr/share/elasticsearch/config/certs/ca/

mv /config/ssl/docker-cluster/elasticsearch/* /config/elasticsearch/
mv /config/ssl/ca/* /config/ca/

rm -r /config/ssl


chown -R 1000:0 /config

echo "Done!"