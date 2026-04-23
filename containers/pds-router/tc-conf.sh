#!/bin/bash

dev_test=`ip addr show dev eth0 | grep "$PDS_TO_SERVER" | wc -l`
if [ "$dev_test" == "1" ]; then
	server_dev="eth0"
	client_dev="eth1"
else
	server_dev="eth1"
	client_dev="eth0"
fi

echo "server_dev - $server_dev, client_dev - $client_dev"

tc qdisc add dev "$client_dev" root handle 1: htb default 10
tc class add dev "$client_dev" parent 1: classid 1:10 htb rate $PDS_TOPO_RATE_C cburst $PDS_TOPO_BURST_C
tc qdisc add dev "$client_dev" parent 1:10 handle 10: netem delay $PDS_TOPO_DELAY_C loss $PDS_TOPO_LOSS_C duplicate $PDS_TOPO_DUPL_C limit $PDS_TOPO_LIMIT_C
#tc qdisc add dev "$client_dev" parent 10: pfifo limit $PDS_TOPO_LIMIT_C

tc qdisc add dev "$server_dev" root handle 1: htb default 10
tc class add dev "$server_dev" parent 1: classid 1:10 htb rate $PDS_TOPO_RATE_S cburst $PDS_TOPO_BURST_S
tc qdisc add dev "$server_dev" parent 1: handle 10: netem delay $PDS_TOPO_DELAY_S loss $PDS_TOPO_LOSS_S duplicate $PDS_TOPO_DUPL_S limit $PDS_TOPO_LIMIT_S
#tc qdisc add dev "$server_dev" parent 10: pfifo limit $PDS_TOPO_LIMIT_S

echo "simulation set to $PDS_TOPO_NAME"
echo "$PDS_TOPO_NAME to-client params: rate $PDS_TOPO_RATE_C, limit $PDS_TOPO_LIMIT_C, burst $PDS_TOPO_BURST_C, delay $PDS_TOPO_DELAY_C, loss $PDS_TOPO_LOSS_C, duplicate $PDS_TOPO_DUPL_C"
echo "$PDS_TOPO_NAME to-server params: rate $PDS_TOPO_RATE_S, limit $PDS_TOPO_LIMIT_S, burst $PDS_TOPO_BURST_S, delay $PDS_TOPO_DELAY_S, loss $PDS_TOPO_LOSS_S, duplicate $PDS_TOPO_DUPL_S"
