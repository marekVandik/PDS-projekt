#!/bin/sh

echo "waiting for curl to finish download, this may take a while"

MAX_TIMEOUT=300
SLEEP_AMOUNT=3
current_timeout=0
server_status=$(cat "/var/www/status")
while [ "$server_status" != "$1" ]; do
    if [ "$current_timeout" -gt "$MAX_TIMEOUT" ]; then
        echo "curl didn't finish downloading in $MAX_TIMEOUT s, aborting"
        exit 1
    fi

    sleep $SLEEP_AMOUNT
    current_timeout=`expr $SLEEP_AMOUNT + $current_timeout`
    server_status=$(cat "/var/www/status")
done
