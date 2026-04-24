#!/bin/sh

. /root/scripts-common/show-ipv4.sh "eth0"

. /root/scripts-common/default-gateway.sh     $PDS_GATEWAY
. /root/scripts-common/default-nameserver.sh  $PDS_GATEWAY

. /root/pds-client/status_wait.sh "$PDS_CC_TYPE"
echo "server status ${PDS_CC_TYPE}, starting download"
if [ "$PDS_CC_TYPE" == "QUIC" ]; then
	curl --ipv4 --no-progress-meter --http3-only "https://pds-server/data" > /dev/null
else
	curl --ipv4 --no-progress-meter "http://pds-server/data" > /dev/null
fi
echo "downloading finished"
echo "CURL_OK" > status.txt
curl --ipv4 --no-progress-meter -T status.txt "https://pds-server/status"
echo "quitting"
