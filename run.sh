#!/bin/sh

# arg1 is *topo.env, arg2 is CC
function simulate() {
	cp net.env .env
	echo "PDS_TOPO=\"$1\"" >> .env
	echo "PDS_CC_TYPE=\"$2\"" >> .env
	docker-compose --env-file ".env" up
	docker-compose down
}

echo "Running simulations, please do not interact (especially detach) with docker-compose until this finishes"

# baseline measurements
simulate "baseline-topo.env" "BBR"
simulate "baseline-topo.env" "RENO"
simulate "baseline-topo.env" "CUBIC"
simulate "baseline-topo.env" "QUIC"

# wifi measurements
simulate "wifi-topo.env" "BBR"
simulate "wifi-topo.env" "RENO"
simulate "wifi-topo.env" "CUBIC"
simulate "wifi-topo.env" "QUIC"

# geo measurements
simulate "geo-topo.env" "BBR"
simulate "geo-topo.env" "RENO"
simulate "geo-topo.env" "CUBIC"
simulate "geo-topo.env" "QUIC"

# bufferbloat measurements
simulate "bloat-topo.env" "BBR"
simulate "bloat-topo.env" "RENO"
simulate "bloat-topo.env" "CUBIC"
simulate "bloat-topo.env" "QUIC"

echo "Simulations finished, plotting cwnd and goodput"
./graphs.py
echo "Done, see ./results"
