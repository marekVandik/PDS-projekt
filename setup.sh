#!/bin/bash

docker ps > /dev/null || { echo "setup.sh: restart with docker.service running"; exit 1; }

echo "setup.sh: building docker images"

echo "router node - pds-router"
docker build -t pds-router -f ./containers/pds-router/Dockerfile ./containers
echo "client node - pds-client"
docker build -t pds-client -f ./containers/pds-client/Dockerfile ./containers
echo "server node - pds-server"
docker build -t pds-server -f ./containers/pds-server/Dockerfile ./containers

# TODO - check result of docker build
#echo "setup.sh: images built"
