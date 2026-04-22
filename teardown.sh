#!/bin/bash

# TODO check docker exists
# TODO logging
# TODO maybe remove alpine:3.23.3
docker image rm pds-router
docker image rm pds-server
docker image rm pds-client
