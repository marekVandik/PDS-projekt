#!/bin/bash

tc qdisc add dev eth0 root handle 1: netem delay $PDS_TOPO_DELAY_C loss $PDS_TOPO_LOSS_C duplicate $PDS_TOPO_DUPL_C
tc qdisc add dev eth0 parent 1:10 handle 10: tbf rate $PDS_TOPO_RATE_C burst $PDS_TOPO_BURST_C minburst 1540 limit $PDS_TOPO_LIMIT_C
#tc qdisc add dev eth0 parent 10: fq

tc qdisc add dev eth1 root handle 1: netem delay $PDS_TOPO_DELAY_S loss $PDS_TOPO_LOSS_S duplicate $PDS_TOPO_DUPL_S
tc qdisc add dev eth1 parent 1:10 handle 10: tbf rate $PDS_TOPO_RATE_S burst $PDS_TOPO_BURST_S minburst 1540 limit $PDS_TOPO_LIMIT_S
#tc qdisc add dev eth1 parent 10: fq

echo "simulation set to $PDS_TOPO_NAME"
echo "$PDS_TOPO_NAME to-client params: rate $PDS_TOPO_RATE_C, limit $PDS_TOPO_LIMIT_C, burst $PDS_TOPO_BURST_C, delay $PDS_TOPO_DELAY_C, loss $PDS_TOPO_LOSS_C, duplicate $PDS_TOPO_DUPL_C"
echo "$PDS_TOPO_NAME to-server params: rate $PDS_TOPO_RATE_S, limit $PDS_TOPO_LIMIT_S, burst $PDS_TOPO_BURST_S, delay $PDS_TOPO_DELAY_S, loss $PDS_TOPO_LOSS_S, duplicate $PDS_TOPO_DUPL_S"
