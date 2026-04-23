#!/bin/sh

echo "waiting for server status $1"

MAX_TIMEOUT=100
SLEEP_AMOUNT=3
current_timeout=0
server_status=$(curl --ipv4 "http://pds-server/status" 2> /dev/null)
while [ "$server_status" != "$1" ]; do
    if [ "$current_timeout" -gt "$MAX_TIMEOUT" ]; then
        echo "pds-server status not $1 in time, status is \"$server_status\", aborting"
        exit 1
    fi

    #echo "pds-server status not $1, retrying in $SLEEP_AMOUNT seconds"
    sleep $SLEEP_AMOUNT
    current_timeout=`expr $SLEEP_AMOUNT + $current_timeout`
    server_status=$(curl --ipv4 "http://pds-server/status" 2> /dev/null)
done
