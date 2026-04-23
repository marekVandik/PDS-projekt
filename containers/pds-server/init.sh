#!/bin/sh

. /root/scripts-common/show-ipv4.sh "eth0"
. /root/scripts-common/default-gateway.sh    $PDS_GATEWAY

echo "creating data for download"
#dd bs=1k count=1k   if=/dev/urandom of=/var/www/data
#dd bs=1k count=2k   if=/dev/urandom of=/var/www/data
#dd bs=1k count=5k   if=/dev/urandom of=/var/www/data
#dd bs=1k count=10k  if=/dev/urandom of=/var/www/data
#dd bs=1k count=20k  if=/dev/urandom of=/var/www/data
#dd bs=1k count=50k  if=/dev/urandom of=/var/www/data
dd bs=1k count=100k if=/dev/urandom of=/var/www/data
#dd bs=1k count=200k if=/dev/urandom of=/var/www/data
#dd bs=1k count=500k if=/dev/urandom of=/var/www/data
#dd bs=1k count=1M   if=/dev/urandom of=/var/www/data
#dd bs=1k count=2M   if=/dev/urandom of=/var/www/data
#dd bs=1k count=5M   if=/dev/urandom of=/var/www/data
#dd bs=1k count=10M  if=/dev/urandom of=/var/www/data

echo "starting http server"
nginx -c /root/pds-server/nginx.conf -t
nginx -c /root/pds-server/nginx.conf
echo "http server start issued"

TOPO_LEN=${#PDS_TOPO}
TOPO_LEN=`expr $TOPO_LEN - 4`
TOPO=${PDS_TOPO:0:$TOPO_LEN}

sysctl -w net.ipv4.tcp_congestion_control=bbr
/tmp/tracing > "/root/results/BBR-$TOPO" &
TRACING_PID=`echo "$!"`
echo "BBR" > /var/www/status
. /root/pds-server/status_wait.sh "CURL_OK"
kill "$TRACING_PID"

sysctl -w net.ipv4.tcp_congestion_control=reno
/tmp/tracing > "/root/results/RENO-$TOPO" &
TRACING_PID=`echo "$!"`
echo "RENO" > /var/www/status
. /root/pds-server/status_wait.sh "CURL_OK"
kill "$TRACING_PID"

sysctl -w net.ipv4.tcp_congestion_control=cubic
/tmp/tracing > "/root/results/CUBIC-$TOPO" &
TRACING_PID=`echo "$!"`
echo "CUBIC" > /var/www/status
. /root/pds-server/status_wait.sh "CURL_OK"
kill "$TRACING_PID"

echo "QUIC" > /var/www/status
. /root/pds-server/status_wait.sh "CURL_OK"
cp "/var/log/nginx/quic.log" "/root/results/QUIC-$TOPO"

echo "all measurements done, quitting"
# TODO tcpdump pcap
