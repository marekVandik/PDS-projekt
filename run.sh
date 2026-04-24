#!/bin/sh

cp net.env .env
echo "PDS_TOPO=\"baseline-topo.env\"" >> .env
echo "PDS_CC_TYPE=\"BBR\"" >> .env
docker-compose --env-file ".env" up
docker-compose down
