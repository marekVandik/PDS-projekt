#!/bin/sh

. /root/scripts-common/show-ipv4.sh "eth0"
. /root/scripts-common/show-ipv4.sh "eth1"

sysctl -w net.ipv4.ip_forward=1

. /root/pds-router/tc-conf.sh $PDS_TOPO

## disabling offloading
#ethtool -K eth0 tso off gso off gro off
#ethtool -K eth1 tso off gso off gro off
#echo "offloading turned off"

echo "$PDS_SERVER pds-server" >> /etc/hosts
echo "starting dnsmasq"
dnsmasq --filter-AAAA --no-resolv

echo "ready"

cnt=0
MAX_TIMEOUT=5
while true; do
	alive=`ping -4 -c 1 -w 1 -W 1 $PDS_SERVER | grep "1 packets received" | wc -l`

	if [ "$alive" -ne "1" ]; then
		cnt=`expr "$cnt" + 1`
	else
		cnt=0
	fi

	if [ "$cnt" -gt "$MAX_TIMEOUT" ]; then
		echo "$PDS_SERVER didn't respond for longer than $MAX_TIMEOUT s, assuming experiment is over, quitting"
		exit 0
	fi

	sleep 1
done
