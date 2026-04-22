#!/bin/sh

. /root/scripts-common/show-ipv4.sh "eth0"

. /root/scripts-common/default-gateway.sh     $PDS_GATEWAY
. /root/scripts-common/default-nameserver.sh  $PDS_GATEWAY

. /root/pds-client/status_wait.sh "BBR"
echo "server status BBR, starting download"
curl --ipv4 --no-progress-meter "http://pds-server/data" > /dev/null
echo "CURL_OK" > status.txt
curl --ipv4 -T --no-progress-meter status.txt "https://pds-server/status"

. /root/pds-client/status_wait.sh "RENO"
echo "server status RENO, starting download"
curl --ipv4 --no-progress-meter "http://pds-server/data" > /dev/null
echo "CURL_OK" > status.txt
curl --ipv4 -T --no-progress-meter status.txt "https://pds-server/status"

. /root/pds-client/status_wait.sh "CUBIC"
echo "server status CUBIC, starting download"
curl --ipv4 --no-progress-meter "http://pds-server/data" > /dev/null
echo "CURL_OK" > status.txt
curl --ipv4 -T --no-progress-meter status.txt "https://pds-server/status"

. /root/pds-client/status_wait.sh "QUIC"
echo "server status QUIC, starting download"
curl --ipv4 --no-progress-meter --http3-only "https://pds-server/data" > /dev/null
echo "CURL_OK" > status.txt
curl --ipv4 -T --no-progress-meter status.txt "https://pds-server/status"

echo "all downloads done, quitting"

sleep infinitely
