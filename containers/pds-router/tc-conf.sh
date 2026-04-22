#!/bin/bash

tc qdisc add dev eth0 root handle 1: htb default 10 r2q 100
tc class add dev eth0 parent 1: classid 1:10 htb rate $PDS_TOPO_RATE_C ceil $PDS_TOPO_CEIL_C burst $PDS_TOPO_BURST_C
tc qdisc add dev eth0 parent 1:10 handle 10: netem delay $PDS_TOPO_DELAY_C loss $PDS_TOPO_LOSS_C duplicate $PDS_TOPO_DUPL_C
tc qdisc add dev eth0 parent 10: fq_codel

tc qdisc add dev eth1 root handle 1: htb default 10 r2q 100
tc class add dev eth1 parent 1: classid 1:10 htb rate $PDS_TOPO_RATE_S ceil $PDS_TOPO_CEIL_S burst $PDS_TOPO_BURST_S
tc qdisc add dev eth1 parent 1:10 handle 10: netem delay $PDS_TOPO_DELAY_S loss $PDS_TOPO_LOSS_S duplicate $PDS_TOPO_DUPL_S
tc qdisc add dev eth1 parent 10: fq_codel

echo "simulation set to $PDS_TOPO_NAME"
echo "$PDS_TOPO_NAME to-client params: rate $PDS_TOPO_RATE_C, peakrate $PDS_TOPO_CEIL_C, burst $PDS_TOPO_BURST_C, delay $PDS_TOPO_DELAY_C, loss $PDS_TOPO_LOSS_C, duplicate $PDS_TOPO_DUPL_C"
echo "$PDS_TOPO_NAME to-server params: rate $PDS_TOPO_RATE_S, peakrate $PDS_TOPO_CEIL_S, burst $PDS_TOPO_BURST_S, delay $PDS_TOPO_DELAY_S, loss $PDS_TOPO_LOSS_S, duplicate $PDS_TOPO_DUPL_S"
